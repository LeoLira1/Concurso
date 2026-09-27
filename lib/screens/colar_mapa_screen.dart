import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../data/mapa_conteudo_db.dart';
import '../logic/mapa_conteudo.dart';
import '../theme.dart';
import '../widgets/comuns.dart';
import '../widgets/provas_comuns.dart';
import 'colar_screen.dart';
import 'mapa_conteudo_screen.dart' show IconeTipo;

/// Exemplo mostrado na tela (e no README).
const exemploMapaJson =
    '''{"formato":"edital-mapa-v1","materia":"Crimes contra a Administração Pública","topico":"Peculato (arts. 312 e 313)","subtopico":"","titulo":"Peculato","nos":[{"texto":"Peculato-apropriação","detalhe":"Funcionário se apropria de bem que tem a posse em razão do cargo.","tipo":"conceito","filhos":[{"texto":"Ex.: guarda fica com celular apreendido","tipo":"exemplo","filhos":[]}]}]}''';

final tipoMapa = TipoColagem<MapaColado>(
  chave: 'mapa',
  titulo: 'Colar mapa',
  singular: 'mapa',
  plural: 'mapas',
  feminino: false,
  rotulo: 'Mapa',
  exemplo: exemploMapaJson,
  instrucao:
      'Cole o mapa do conteúdo em JSON (formato edital-mapa-v1). Antes de '
      'importar, você vê a árvore. Tópico que não existe no edital é '
      'criado; se o tópico já tem mapa, ele é substituído.',
  campos:
      'formato, materia, topico, subtopico (opcional), titulo e nos (cada '
      'um com texto, detalhe opcional, tipo e filhos). Tipos: conceito, '
      'artigo, exemplo, pegadinha e dica. Até $limiteTextoNo caracteres '
      'por texto, $limiteNiveis níveis e $limiteNos nós',
  ler: lerMapas,
  marcar: (db, l) async {},
  importar: (db, l, concursoId) => db.importarMapas(l, concursoId: concursoId),
  texto: (m) => m.titulo,
  detalhes: (m) => ['${m.totalNos} nós'],
);

/// "Colar mapa": lê o JSON, mostra a árvore (com os erros e o aviso de
/// substituição) e importa.
class ColarMapaScreen extends StatefulWidget {
  const ColarMapaScreen({
    super.key,
    this.materiaPadrao,
    this.topicoPadrao,
    this.subtopicoPadrao,
    this.concursoId,
    this.textoInicial,
  });

  final String? materiaPadrao;
  final String? topicoPadrao;
  final String? subtopicoPadrao;

  /// Edital que recebe os tópicos novos (nulo = "Tudo junto").
  final String? concursoId;
  final String? textoInicial;

  @override
  State<ColarMapaScreen> createState() => _ColarMapaScreenState();
}

class _ColarMapaScreenState extends State<ColarMapaScreen> {
  late final _texto = TextEditingController(text: widget.textoInicial);
  LeituraMapas? _leitura;
  Map<int, DestinoColagem> _destinos = const {};
  Set<int> _substitui = const {};
  bool _importando = false;

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  Future<void> _colar() async {
    final d = await Clipboard.getData(Clipboard.kTextPlain);
    final t = d?.text ?? '';
    if (t.trim().isEmpty) {
      if (mounted) avisar(context, 'A área de transferência está vazia');
      return;
    }
    _texto.text = t;
    await _conferir();
  }

  Future<void> _conferir() async {
    final db = context.read<AppDatabase>();
    final l = lerMapas(
      _texto.text,
      materiaPadrao: widget.materiaPadrao,
      topicoPadrao: widget.topicoPadrao,
      subtopicoPadrao: widget.subtopicoPadrao,
    );
    final destinos = await db.destinosColagem(l, concursoId: widget.concursoId);
    final substitui = await db.mapasQueSubstituem(l);
    if (!mounted) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _leitura = l;
      _destinos = destinos;
      _substitui = substitui;
    });
  }

  Future<void> _importar() async {
    final l = _leitura;
    if (l == null || l.novas == 0 || _importando) return;
    final trocados = [
      for (final m in l.mapas)
        if (m.entra && _substitui.contains(m.indice)) m,
    ];
    if (trocados.isNotEmpty) {
      final ok = await confirmar(
        context,
        titulo: 'Substituir o mapa atual?',
        mensagem: trocados.length == 1
            ? 'O tópico "${_destinoTexto(trocados.single)}" já tem um mapa. '
                  'Ele vai ser trocado por este.'
            : '${trocados.length} tópicos já têm mapa. Eles vão ser trocados '
                  'pelos novos.',
        acao: 'Substituir',
      );
      if (!ok || !mounted) return;
    }
    setState(() => _importando = true);
    final r = await context.read<AppDatabase>().importarMapas(
      l,
      concursoId: widget.concursoId,
    );
    if (!mounted) return;
    setState(() => _importando = false);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          r.novas == 1 ? 'Mapa importado' : '${r.novas} mapas importados',
          style: Theme.of(ctx).textTheme.headlineSmall,
        ),
        content: Text(
          [
            if (trocados.isNotEmpty)
              trocados.length == 1
                  ? 'O mapa anterior foi substituído.'
                  : '${trocados.length} mapas anteriores foram substituídos.',
            if (r.materiasCriadas.isNotEmpty)
              'Matéria nova: ${r.materiasCriadas.join(', ')}.',
            if (r.topicosCriados.isNotEmpty)
              'Tópicos criados no edital: ${r.topicosCriados.join('; ')}.',
            if (trocados.isEmpty &&
                r.materiasCriadas.isEmpty &&
                r.topicosCriados.isEmpty)
              'Entrou num tópico que já existia.',
          ].join('\n\n'),
          style: const TextStyle(fontSize: 16, height: 1.4),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (mounted) Navigator.pop(context, r);
  }

  @override
  Widget build(BuildContext context) {
    final l = _leitura;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: const Text('Colar mapa'),
        actions: [
          if (l != null && l.novas > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: FilledButton.icon(
                key: const ValueKey('importar-mapa'),
                onPressed: _importando ? null : _importar,
                icon: const Icon(Icons.download_done_rounded),
                label: Text(
                  l.novas == 1 ? 'Importar mapa' : 'Importar ${l.novas} mapas',
                ),
              ),
            ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, box) {
          final deitado = box.maxWidth >= 900 && box.maxWidth > box.maxHeight;
          final entrada = EntradaColagem(
            tipo: tipoMapa,
            controller: _texto,
            aoColar: _colar,
            aoConferir: _conferir,
            dica: widget.topicoPadrao == null
                ? null
                : 'Sem "materia"/"topico" no JSON, o mapa vai para '
                      '${[widget.topicoPadrao, widget.subtopicoPadrao].whereType<String>().join(' › ')}.',
            expandir: deitado,
          );
          final previa = l == null
              ? SemPreviaColagem(tipo: tipoMapa)
              : _PreviaMapas(
                  leitura: l,
                  destinos: _destinos,
                  substitui: _substitui,
                );
          if (deitado) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 8, 14, 24),
                    child: entrada,
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(14, 8, 28, 24),
                    children: [previa],
                  ),
                ),
              ],
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [entrada, const SizedBox(height: 20), previa],
          );
        },
      ),
    );
  }
}

String _destinoTexto(MapaColado m) =>
    m.subtopico.isEmpty ? m.topico : '${m.topico} › ${m.subtopico}';

class _PreviaMapas extends StatelessWidget {
  const _PreviaMapas({
    required this.leitura,
    required this.destinos,
    required this.substitui,
  });
  final LeituraMapas leitura;
  final Map<int, DestinoColagem> destinos;
  final Set<int> substitui;

  @override
  Widget build(BuildContext context) {
    final l = leitura;
    if (l.erro != null) {
      return Cartao(
        titulo: 'Não deu para ler',
        corBorda: Cores.acento,
        child: Text(
          l.erro!.replaceFirst('uma lista de mapas', 'o mapa'),
          key: const ValueKey('erro-leitura'),
          style: const TextStyle(fontSize: 16, color: Cores.acento),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final m in l.mapas) ...[
          _PreviaMapa(
            mapa: m,
            destino: destinos[m.indice],
            substitui: substitui.contains(m.indice),
            varios: l.mapas.length > 1,
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _PreviaMapa extends StatelessWidget {
  const _PreviaMapa({
    required this.mapa,
    required this.destino,
    required this.substitui,
    required this.varios,
  });
  final MapaColado mapa;
  final DestinoColagem? destino;
  final bool substitui;
  final bool varios;

  @override
  Widget build(BuildContext context) {
    final m = mapa;
    final contagem = contarPorTipo(m.nos);
    final linhas = <Widget>[
      for (final (n, nivel) in percorrer(m.nos))
        Padding(
          padding: EdgeInsets.only(left: (nivel - 1) * 22.0, top: 4, bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconeTipo(n.tipo, tamanho: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n.texto.isEmpty ? '(sem texto)' : n.texto,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: nivel == 1
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: n.texto.length > limiteTextoNo || n.texto.isEmpty
                            ? Cores.acento
                            : Cores.tinta,
                      ),
                    ),
                    if (n.detalhe.isNotEmpty)
                      Text(
                        n.detalhe,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Cores.tintaSuave,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
    ];
    return Cartao(
      key: ValueKey('previa-mapa-${m.indice}'),
      corBorda: m.valida ? Cores.linha : Cores.acento,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            m.materia.isEmpty ? '(sem matéria)' : m.materia,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Cores.tintaSuave,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            m.topico.isEmpty ? '(sem tópico)' : _destinoTexto(m),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (m.valida && destino != null) SelosDestino(destino!),
          if (m.valida && substitui)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Selo(
                'Vai substituir o mapa atual',
                cor: corAviso,
                icone: Icons.swap_horiz_rounded,
              ),
            ),
          if (m.valida && m.repetida)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Selo(
                'Outro mapa desta lista vai para o mesmo tópico (fica de fora)',
                icone: Icons.content_copy_rounded,
              ),
            ),
          const SizedBox(height: 12),
          Text(
            m.titulo,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Selo('${m.totalNos} nós', icone: Icons.account_tree_outlined),
              for (final t in TipoNoConteudo.values)
                if (contagem[t] case final n?)
                  Selo('$n ${t.rotulo.toLowerCase()}', cor: Color(t.cor)),
            ],
          ),
          if (!m.valida) ...[
            const SizedBox(height: 12),
            Container(
              key: const ValueKey('erros-mapa'),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Cores.acento.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Cores.acento),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    varios
                        ? 'Mapa ${m.indice} com erro (fica de fora):'
                        : 'Corrija antes de importar:',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Cores.acento,
                    ),
                  ),
                  for (final e in m.erros)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '• ${e[0].toUpperCase()}${e.substring(1)}.',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Cores.acento,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 6),
          ...linhas,
        ],
      ),
    );
  }
}

/// Abre "Colar mapa" a partir de um tópico (o que faltar no JSON vai para
/// ele) ou de uma matéria (vai para o tópico do JSON).
Future<void> abrirColarMapa(
  BuildContext context, {
  required Materia materia,
  Topico? topico,
  String? concursoId,
}) async {
  final d = await destinoPadrao(context.read<AppDatabase>(), topico);
  if (!context.mounted) return;
  await Navigator.push(
    context,
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => ColarMapaScreen(
        materiaPadrao: materia.nome,
        topicoPadrao: d.topico,
        subtopicoPadrao: d.subtopico,
        concursoId: concursoId,
      ),
    ),
  );
}

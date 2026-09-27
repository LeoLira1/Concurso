import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../data/provas_db.dart';
import '../logic/desempenho.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/assistir.dart';
import '../widgets/comuns.dart';
import '../widgets/escopo.dart';
import '../widgets/provas_comuns.dart' show corCerto;
import 'cronometro_screen.dart';
import 'resolver_topico_screen.dart';
import 'topico_screen.dart';

/// Converte as sessões (com as respostas das provas já mescladas) em
/// registros por tópico.
List<RegistroTopico> registrosDasSessoes(List<Sessao> sessoes) => [
  for (final s in sessoes)
    if (s.topicoId != null)
      RegistroTopico(
        topicoId: s.topicoId!,
        dia: s.dia,
        feitas: s.questoesFeitas,
        acertos: s.questoesAcertos,
        minutos: s.minutos,
      ),
];

TopicoDesempenho _topico(Topico t) => TopicoDesempenho(
  id: t.id,
  nome: t.nome,
  materiaId: t.materiaId,
  paiId: t.paiId,
  ordem: t.ordem,
);

String _pct(double? a) => a == null ? '—' : '${(a * 100).round()}%';

/// Linha de baixo de cada tópico: sem questões, só quando foi estudado.
String resumoLinha(Desempenho d) => d.total.feitas == 0
    ? d.textoUltimoEstudo
    : '${d.textoTendencia} · ${d.total.feitas} questões · '
          '${d.textoUltimoEstudo}';

/// Ícone, cor e texto da tendência: a cor nunca vem sozinha.
(IconData, Color) _visualTendencia(Tendencia t) => switch (t) {
  Tendencia.subiu => (Icons.trending_up_rounded, corCerto),
  Tendencia.caiu => (Icons.trending_down_rounded, Cores.acento),
  Tendencia.estavel => (Icons.trending_flat_rounded, Cores.tintaSuave),
  Tendencia.semDados => (Icons.remove_rounded, Cores.tintaFraca),
};

/// Desempenho por tópico (etapa 13): % de acerto, tendência, semanas e o
/// que revisar primeiro. Segue o escopo da tela inicial.
class DesempenhoScreen extends StatefulWidget {
  const DesempenhoScreen({super.key});

  @override
  State<DesempenhoScreen> createState() => _DesempenhoScreenState();
}

class _DesempenhoScreenState extends State<DesempenhoScreen> {
  String? _materia;
  OrdemDesempenho _ordem = OrdemDesempenho.edital;

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    final estado = context.watch<AppState>();
    return ComEscopo(
      builder: (context, escopo) => Assistir<List<MateriaInfo>>(
        chave: ('desempenho-materias', escopo),
        stream: () => db.watchMaterias(escopo),
        builder: (context, mats) => Assistir<List<Topico>>(
          chave: ('desempenho-topicos', escopo),
          stream: () => db.watchTodosTopicos(concursoId: escopo),
          builder: (context, tops) => Assistir<List<Sessao>>(
            chave: 'desempenho-sessoes',
            stream: db.watchSessoesComQuestoes,
            builder: (context, sessoes) {
              if (mats == null || tops == null || sessoes == null) {
                return Scaffold(appBar: AppBar(toolbarHeight: 72));
              }
              final materias = {for (final m in mats) m.materia.id: m.materia};
              // Na ordem do edital: matéria, depois tópico.
              final ordemMat = {
                for (final (i, m) in mats.indexed) m.materia.id: i,
              };
              final topicos =
                  [
                    for (final t in tops)
                      if (materias.containsKey(t.materiaId)) _topico(t),
                  ]..sort((a, b) {
                    final c = ordemMat[a.materiaId]!.compareTo(
                      ordemMat[b.materiaId]!,
                    );
                    return c != 0 ? c : a.ordem.compareTo(b.ordem);
                  });
              final todos = calcularDesempenho(
                topicos,
                registrosDasSessoes(sessoes),
                hoje: DateTime.now(),
              );
              final filtro = materias.containsKey(_materia) ? _materia : null;
              final visiveis = [
                for (final d in todos)
                  if (filtro == null || d.topico.materiaId == filtro) d,
              ];
              return _tela(
                subtitulo: estado.verTudo ? 'Todos os concursos' : null,
                escopo: escopo,
                mats: mats,
                materias: materias,
                filtro: filtro,
                lista: visiveis,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _tela({
    required String? subtitulo,
    required String? escopo,
    required List<MateriaInfo> mats,
    required Map<String, Materia> materias,
    required String? filtro,
    required List<Desempenho> lista,
  }) {
    final sugestoes = sugerirRevisao(lista);
    final comQuestoes = lista.where((d) => d.total.feitas > 0).length;
    final ordenada = ordenar(lista, _ordem);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Desempenho por tópico',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              '$comQuestoes de ${lista.length} tópicos com questões'
              '${subtitulo == null ? '' : ' · $subtitulo'}',
              style: const TextStyle(fontSize: 14, color: Cores.tintaSuave),
            ),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
            children: [
              // Filtros numa linha só, acima de tudo.
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _Chip(
                      rotulo: 'Todas',
                      selecionado: filtro == null,
                      aoTocar: () => setState(() => _materia = null),
                    ),
                    for (final m in mats)
                      _Chip(
                        key: ValueKey('filtro-${m.materia.id}'),
                        rotulo: m.materia.nome,
                        cor: Color(m.materia.cor),
                        selecionado: filtro == m.materia.id,
                        aoTocar: () => setState(() => _materia = m.materia.id),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _RevisePrimeiro(
                sugestoes: sugestoes,
                materias: materias,
                aoAbrir: (d) => _abrir(d, materias),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Todos os tópicos',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  PopupMenuButton<OrdemDesempenho>(
                    key: const ValueKey('ordem-desempenho'),
                    tooltip: 'Ordenar',
                    initialValue: _ordem,
                    onSelected: (o) => setState(() => _ordem = o),
                    itemBuilder: (_) => [
                      for (final (o, r) in _rotulosOrdem)
                        PopupMenuItem(value: o, height: 52, child: Text(r)),
                    ],
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.sort_rounded, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            _rotulosOrdem.firstWhere((x) => x.$1 == _ordem).$2,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (lista.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'Nenhum tópico no edital.',
                    style: TextStyle(fontSize: 15, color: Cores.tintaSuave),
                  ),
                ),
              for (final d in ordenada)
                _LinhaTopico(
                  desempenho: d,
                  materia: materias[d.topico.materiaId],
                  aoTocar: () => _abrir(d, materias),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _abrir(Desempenho d, Map<String, Materia> materias) => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => DesempenhoTopicoScreen(
        topicoId: d.topico.id,
        materia: materias[d.topico.materiaId],
      ),
    ),
  );
}

const _rotulosOrdem = [
  (OrdemDesempenho.edital, 'Ordem do edital'),
  (OrdemDesempenho.piorAcerto, 'Pior acerto'),
  (OrdemDesempenho.maiorQueda, 'Maior queda'),
  (OrdemDesempenho.maisQuestoes, 'Mais questões'),
];

class _Chip extends StatelessWidget {
  const _Chip({
    super.key,
    required this.rotulo,
    required this.selecionado,
    required this.aoTocar,
    this.cor,
  });
  final String rotulo;
  final bool selecionado;
  final VoidCallback aoTocar;
  final Color? cor;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      avatar: cor == null ? null : Bolinha(cor!, tamanho: 10),
      label: Text(rotulo),
      selected: selecionado,
      showCheckmark: false,
      labelStyle: TextStyle(
        color: selecionado ? Colors.white : Cores.tinta,
        fontWeight: FontWeight.w700,
      ),
      onSelected: (_) => aoTocar(),
    ),
  );
}

class _RevisePrimeiro extends StatelessWidget {
  const _RevisePrimeiro({
    required this.sugestoes,
    required this.materias,
    required this.aoAbrir,
  });
  final List<Sugestao> sugestoes;
  final Map<String, Materia> materias;
  final ValueChanged<Desempenho> aoAbrir;

  @override
  Widget build(BuildContext context) => Container(
    key: const ValueKey('revise-primeiro'),
    padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
    decoration: BoxDecoration(
      border: Border.all(color: Cores.linha, width: 1.5),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Revise primeiro', style: Theme.of(context).textTheme.titleLarge),
        const Text(
          'Tópicos que caíram, com acerto baixo ou parados há 3+ semanas.',
          style: TextStyle(fontSize: 14, color: Cores.tintaSuave),
        ),
        const SizedBox(height: 8),
        if (sugestoes.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Nada preocupante agora: nenhum tópico caiu, está abaixo de 60% '
              'ou parado.',
              style: TextStyle(fontSize: 15),
            ),
          ),
        for (final (i, s) in sugestoes.indexed)
          InkWell(
            key: ValueKey('sugestao-${s.desempenho.topico.id}'),
            borderRadius: BorderRadius.circular(12),
            onTap: () => aoAbrir(s.desempenho),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 56),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 13,
                    backgroundColor: Cores.tinta,
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.desempenho.topico.nome,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          [
                            s.texto,
                            ?materias[s.desempenho.topico.materiaId]?.nome,
                          ].join(' · '),
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
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Cores.tintaSuave,
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}

class _LinhaTopico extends StatelessWidget {
  const _LinhaTopico({
    required this.desempenho,
    required this.materia,
    required this.aoTocar,
  });
  final Desempenho desempenho;
  final Materia? materia;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final d = desempenho;
    final cor = materia == null ? Cores.tinta : Color(materia!.cor);
    final (icone, corT) = _visualTendencia(d.tendencia);
    final largo = MediaQuery.sizeOf(context).width >= 600;
    return InkWell(
      key: ValueKey('linha-${d.topico.id}'),
      onTap: aoTocar,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            Bolinha(cor, tamanho: 10),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    d.topico.nome,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Um texto só, com o ícone embutido: quebra a linha no
                  // celular em vez de estourar.
                  Text.rich(
                    TextSpan(
                      style: const TextStyle(
                        fontSize: 13,
                        color: Cores.tintaSuave,
                      ),
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 3),
                            child: Icon(icone, size: 16, color: corT),
                          ),
                        ),
                        TextSpan(text: resumoLinha(d)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (largo) ...[
              const SizedBox(width: 12),
              Minilinha(semanas: d.minilinha, cor: cor),
            ],
            const SizedBox(width: 12),
            SizedBox(
              width: 56,
              child: Text(
                _pct(d.acerto),
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: d.fraco ? Cores.acento : Cores.tinta,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Minilinha das últimas semanas: uma coluna fina por semana, altura = %
/// de acerto; semana sem questões fica só com um traço na base.
class Minilinha extends StatelessWidget {
  const Minilinha({super.key, required this.semanas, required this.cor});
  final List<SemanaPlacar> semanas;
  final Color cor;

  @override
  Widget build(BuildContext context) => Semantics(
    label:
        'Acerto nas últimas ${semanas.length} semanas: '
        '${semanas.map((s) => _pct(s.placar.acerto)).join(', ')}',
    child: CustomPaint(
      size: Size(semanas.length * 9.0, 28),
      painter: _MinilinhaPainter(semanas, cor),
    ),
  );
}

class _MinilinhaPainter extends CustomPainter {
  _MinilinhaPainter(this.semanas, this.cor);
  final List<SemanaPlacar> semanas;
  final Color cor;

  @override
  void paint(Canvas canvas, Size size) {
    const largura = 6.0;
    final base = size.height;
    canvas.drawLine(
      Offset(0, base - 0.5),
      Offset(size.width, base - 0.5),
      Paint()
        ..color = Cores.linha
        ..strokeWidth = 1,
    );
    for (final (i, s) in semanas.indexed) {
      final x = i * 9.0 + 1.5;
      final a = s.placar.acerto;
      if (a == null) continue;
      final h = math.max(2.0, a * (base - 2));
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(x, base - h, largura, h),
          topLeft: const Radius.circular(2),
          topRight: const Radius.circular(2),
        ),
        Paint()..color = cor,
      );
    }
  }

  @override
  bool shouldRepaint(_MinilinhaPainter old) =>
      old.semanas != semanas || old.cor != cor;
}

// -----------------------------------------------------------------------------
// Detalhe de um tópico
// -----------------------------------------------------------------------------

/// Desempenho de um tópico: números, as semanas em colunas e os
/// subtópicos.
class DesempenhoTopicoScreen extends StatelessWidget {
  const DesempenhoTopicoScreen({
    super.key,
    required this.topicoId,
    this.materia,
  });
  final String topicoId;
  final Materia? materia;

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return Assistir<Topico?>(
      chave: ('desempenho-topico', topicoId),
      stream: () => (db.select(
        db.topicos,
      )..where((t) => t.id.equals(topicoId))).watchSingleOrNull(),
      builder: (context, t) => Assistir<List<Topico>>(
        chave: ('desempenho-sub', t?.materiaId),
        stream: () => db.watchTopicos(t?.materiaId ?? '', semFiltro: true),
        builder: (context, daMateria) => Assistir<List<Sessao>>(
          chave: 'desempenho-sessoes',
          stream: db.watchSessoesComQuestoes,
          builder: (context, sessoes) {
            if (t == null || daMateria == null || sessoes == null) {
              return Scaffold(appBar: AppBar(toolbarHeight: 72));
            }
            final regs = registrosDasSessoes(sessoes);
            final hoje = DateTime.now();
            // O tópico com a árvore dele.
            final sub = <Topico>[];
            void descer(String id) {
              for (final x in daMateria) {
                if (x.paiId == id) {
                  sub.add(x);
                  descer(x.id);
                }
              }
            }

            descer(t.id);
            final raiz = TopicoDesempenho(
              id: t.id,
              nome: t.nome,
              materiaId: t.materiaId,
            );
            final d = calcularDesempenho(
              [raiz, for (final s in sub) _topico(s)],
              regs,
              hoje: hoje,
            ).single;
            // Cada subtópico direto como raiz (somando os dele).
            final filhos = calcularDesempenho(
              [
                for (final s in sub)
                  s.paiId == t.id
                      ? TopicoDesempenho(
                          id: s.id,
                          nome: s.nome,
                          materiaId: s.materiaId,
                          ordem: s.ordem,
                        )
                      : _topico(s),
              ],
              regs,
              hoje: hoje,
            );
            return _detalhe(context, t, d, filhos);
          },
        ),
      ),
    );
  }

  Widget _detalhe(
    BuildContext context,
    Topico t,
    Desempenho d,
    List<Desempenho> filhos,
  ) {
    final cor = materia == null ? Cores.tinta : Color(materia!.cor);
    final (icone, corT) = _visualTendencia(d.tendencia);
    Widget numero(String rotulo, String valor, {String? detalhe}) => Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Cores.linha, width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rotulo,
            style: const TextStyle(fontSize: 13, color: Cores.tintaSuave),
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          if (detalhe != null)
            Text(
              detalhe,
              style: const TextStyle(fontSize: 13, color: Cores.tintaSuave),
            ),
        ],
      ),
    );
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: Text(
          'Desempenho',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
            children: [
              if (materia != null)
                Row(
                  children: [
                    Bolinha(cor, tamanho: 10),
                    const SizedBox(width: 8),
                    Text(
                      materia!.nome.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                        color: Cores.tintaSuave,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 6),
              Text(t.nome, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(icone, size: 20, color: corT),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      [
                        d.tendencia == Tendencia.semDados
                            ? d.textoTendencia
                            : '${d.textoTendencia} em $janelaTendencia dias',
                        d.textoUltimoEstudo,
                      ].join(' · '),
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  numero(
                    'Acerto total',
                    _pct(d.acerto),
                    detalhe: '${d.total.acertos} de ${d.total.feitas}',
                  ),
                  numero(
                    'Últimos $janelaTendencia dias',
                    _pct(d.recente.acerto),
                    detalhe: '${d.recente.feitas} questões',
                  ),
                  numero(
                    '$janelaTendencia dias antes',
                    _pct(d.anterior.acerto),
                    detalhe: '${d.anterior.feitas} questões',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    key: const ValueKey('resolver-desempenho'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 48),
                    ),
                    onPressed: () => abrirResolverQuestoes(
                      context,
                      titulo: t.nome,
                      topicoId: t.id,
                    ),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Resolver questões'),
                  ),
                  Pilula(
                    icone: Icons.timer_outlined,
                    rotulo: 'Estudar',
                    aoTocar: () => abrirCronometro(
                      context,
                      materiaId: t.materiaId,
                      topicoId: t.id,
                    ),
                  ),
                  Pilula(
                    icone: Icons.open_in_new_rounded,
                    rotulo: 'Abrir tópico',
                    aoTocar: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TopicoScreen(topicoId: t.id),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Acerto por semana',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              GraficoAcertoSemanal(semanas: d.semanas, cor: cor),
              if (filhos.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  'Subtópicos',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                for (final f in filhos)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                f.topico.nome,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${f.total.feitas} questões · '
                                '${f.textoTendencia}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Cores.tintaSuave,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _pct(f.acerto),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: f.fraco ? Cores.acento : Cores.tinta,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Colunas de % de acerto por semana (uma série, na cor da matéria), com
/// a linha de 60% tracejada. Tocar numa coluna mostra a semana e o placar
/// no alto; há visão em tabela.
class GraficoAcertoSemanal extends StatefulWidget {
  const GraficoAcertoSemanal({
    super.key,
    required this.semanas,
    required this.cor,
  });
  final List<SemanaPlacar> semanas;
  final Color cor;

  @override
  State<GraficoAcertoSemanal> createState() => _GraficoAcertoSemanalState();
}

class _GraficoAcertoSemanalState extends State<GraficoAcertoSemanal> {
  int? _sel;
  bool _tabela = false;

  String _semana(SemanaPlacar s) =>
      'Semana de ${s.inicio.day.toString().padLeft(2, '0')}/'
      '${s.inicio.month.toString().padLeft(2, '0')}';

  String _placar(SemanaPlacar s) => s.placar.feitas == 0
      ? 'sem questões'
      : '${_pct(s.placar.acerto)} (${s.placar.acertos} de ${s.placar.feitas})';

  @override
  Widget build(BuildContext context) {
    final l = widget.semanas;
    // Começa na última semana com questões (a atual pode estar vazia).
    final ultima = l.lastIndexWhere((s) => s.placar.feitas > 0);
    final sel = (_sel ?? (ultima < 0 ? l.length - 1 : ultima)).clamp(
      0,
      l.length - 1,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${_semana(l[sel])}: ${_placar(l[sel])}',
                key: const ValueKey('semana-selecionada'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton.icon(
              key: const ValueKey('tabela-semanas'),
              onPressed: () => setState(() => _tabela = !_tabela),
              icon: Icon(
                _tabela ? Icons.bar_chart_rounded : Icons.table_rows_outlined,
                size: 20,
              ),
              label: Text(_tabela ? 'Gráfico' : 'Tabela'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_tabela)
          Table(
            columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth()},
            children: [
              for (final s in l.reversed)
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(_semana(s)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(_placar(s), textAlign: TextAlign.right),
                    ),
                  ],
                ),
            ],
          )
        else
          LayoutBuilder(
            builder: (context, box) {
              // As mesmas contas do desenho: o eixo ocupa 28 px à esquerda.
              final passo = (box.maxWidth - _eixo) / l.length;
              int indice(double x) =>
                  ((x - _eixo) / passo).floor().clamp(0, l.length - 1);
              return GestureDetector(
                key: const ValueKey('grafico-semanas'),
                behavior: HitTestBehavior.opaque,
                onTapDown: (e) =>
                    setState(() => _sel = indice(e.localPosition.dx)),
                onHorizontalDragUpdate: (e) =>
                    setState(() => _sel = indice(e.localPosition.dx)),
                child: CustomPaint(
                  size: Size(box.maxWidth, 200),
                  painter: _SemanasPainter(l, widget.cor, sel),
                ),
              );
            },
          ),
      ],
    );
  }
}

/// Largura do eixo (rótulos de %) à esquerda do gráfico semanal.
const _eixo = 28.0;

class _SemanasPainter extends CustomPainter {
  _SemanasPainter(this.semanas, this.cor, this.sel);
  final List<SemanaPlacar> semanas;
  final Color cor;
  final int sel;

  @override
  void paint(Canvas canvas, Size size) {
    const rodape = 22.0;
    final alto = size.height - rodape;
    final grade = Paint()
      ..color = Cores.linha
      ..strokeWidth = 1;
    TextPainter texto(String s, {Color cor = Cores.tintaSuave}) => TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(fontFamily: 'Roboto', fontSize: 11, color: cor),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    // Grade recessiva: 0, 50 e 100%.
    for (final p in const [0.0, 0.5, 1.0]) {
      final y = alto - p * (alto - 8);
      canvas.drawLine(Offset(_eixo, y), Offset(size.width, y), grade);
      // O 50% fica sem rótulo: colaria no de 60%.
      if (p == 0.5) continue;
      final tp = texto('${(p * 100).round()}%');
      tp.paint(canvas, Offset(0, y - tp.height / 2));
      tp.dispose();
    }
    // Referência de 60% tracejada, com rótulo no eixo.
    final y60 = alto - 0.6 * (alto - 8);
    final t60 = texto('60%', cor: Cores.tinta);
    t60.paint(canvas, Offset(0, y60 - t60.height / 2));
    t60.dispose();
    for (var x = _eixo; x < size.width; x += 8) {
      canvas.drawLine(
        Offset(x, y60),
        Offset(math.min(x + 4, size.width), y60),
        Paint()
          ..color = Cores.tintaSuave
          ..strokeWidth = 1,
      );
    }
    final area = size.width - _eixo;
    final passo = area / semanas.length;
    final larg = math.min(24.0, passo - 6);
    for (final (i, s) in semanas.indexed) {
      final cx = _eixo + passo * i + passo / 2;
      final a = s.placar.acerto;
      final selecionada = i == sel;
      if (a != null) {
        final h = math.max(3.0, a * (alto - 8));
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTWH(cx - larg / 2, alto - h, larg, h),
            topLeft: const Radius.circular(4),
            topRight: const Radius.circular(4),
          ),
          Paint()..color = selecionada ? cor : cor.withValues(alpha: 0.55),
        );
      } else {
        // Sem questões: só um traço na base.
        canvas.drawLine(
          Offset(cx - larg / 2, alto - 1),
          Offset(cx + larg / 2, alto - 1),
          Paint()
            ..color = Cores.tintaFraca
            ..strokeWidth = 2,
        );
      }
      // Rótulos: a selecionada e as pontas (se não colarem nela).
      final ponta = (i == 0 || i == semanas.length - 1) && (i - sel).abs() > 1;
      if (selecionada || ponta) {
        final tp = texto(
          '${s.inicio.day.toString().padLeft(2, '0')}/'
          '${s.inicio.month.toString().padLeft(2, '0')}',
          cor: selecionada ? Cores.tinta : Cores.tintaSuave,
        );
        tp.paint(canvas, Offset(cx - tp.width / 2, alto + 5));
        tp.dispose();
      }
    }
  }

  @override
  bool shouldRepaint(_SemanasPainter old) =>
      old.semanas != semanas || old.cor != cor || old.sel != sel;
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../data/questoes_topico_db.dart';
import '../logic/flashcards.dart' show intervalosCaixas;
import '../theme.dart';
import '../util/texto.dart';
import '../widgets/assistir.dart';
import '../widgets/comuns.dart';
import '../widgets/provas_comuns.dart';

/// Lista das questões de um tópico (com subtópicos) ou de uma matéria.
/// Com [soSuspeitas], abre direto nas de "gabarito suspeito" para revisar:
/// confirmar o gabarito, trocar a letra ou excluir.
class BancoQuestoesScreen extends StatefulWidget {
  const BancoQuestoesScreen({
    super.key,
    required this.titulo,
    this.topicoId,
    this.materiaId,
    this.concursoId,
    this.soSuspeitas = false,
  });

  final String titulo;
  final String? topicoId;
  final String? materiaId;
  final String? concursoId;
  final bool soSuspeitas;

  @override
  State<BancoQuestoesScreen> createState() => _BancoQuestoesScreenState();
}

class _BancoQuestoesScreenState extends State<BancoQuestoesScreen> {
  late bool _soSuspeitas = widget.soSuspeitas;

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: Text(widget.titulo, overflow: TextOverflow.ellipsis),
      ),
      body: Assistir<List<QuestaoTopicoInfo>>(
        chave: (widget.topicoId, widget.materiaId, widget.concursoId),
        stream: () => db.watchQuestoesTopico(
          topicoId: widget.topicoId,
          materiaId: widget.materiaId,
          concursoId: widget.concursoId,
        ),
        builder: (context, l) {
          final todas = l ?? const <QuestaoTopicoInfo>[];
          final suspeitas = todas.where((q) => q.questao.suspeito).length;
          final lista = _soSuspeitas
              ? todas.where((q) => q.questao.suspeito).toList()
              : todas;
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: Text('Todas (${todas.length})'),
                        selected: !_soSuspeitas,
                        onSelected: (_) => setState(() => _soSuspeitas = false),
                      ),
                      ChoiceChip(
                        key: const ValueKey('filtro-suspeitas'),
                        avatar: const Icon(Icons.flag_rounded, color: corAviso),
                        label: Text('Gabarito suspeito ($suspeitas)'),
                        selected: _soSuspeitas,
                        onSelected: (_) => setState(() => _soSuspeitas = true),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (lista.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Text(
                        _soSuspeitas
                            ? 'Nenhuma questão com gabarito suspeito.'
                            : 'Nenhuma questão ainda.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 17,
                          color: Cores.tintaSuave,
                        ),
                      ),
                    ),
                  for (final q in lista)
                    Padding(
                      key: ValueKey(q.id),
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _CartaoQuestao(q: q),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CartaoQuestao extends StatelessWidget {
  const _CartaoQuestao({required this.q});
  final QuestaoTopicoInfo q;

  Future<void> _trocarGabarito(BuildContext context) async {
    final db = context.read<AppDatabase>();
    final letra = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Qual é o gabarito certo?'),
        children: [
          for (final e in q.alternativas.entries)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, e.key),
              child: Text(
                '${e.key}) ${e.value}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: e.key == q.questao.gabarito
                      ? FontWeight.w900
                      : FontWeight.w400,
                ),
              ),
            ),
        ],
      ),
    );
    if (letra == null) return;
    await db.corrigirGabarito(q.id, letra);
    if (context.mounted) avisar(context, 'Gabarito agora é $letra');
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    final x = q.questao;
    final hoje = soDia(DateTime.now());
    final dias = x.proximaRevisao.difference(hoje).inDays;
    return Cartao(
      corBorda: x.suspeito ? corAviso : Cores.linha,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${q.materia.nome} · ${q.caminho}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Cores.tintaSuave,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (x.suspeito)
                const Selo(
                  'Gabarito suspeito',
                  cor: corAviso,
                  icone: Icons.flag_rounded,
                ),
              Selo('Dificuldade ${x.dificuldade}/5'),
              Selo(
                q.nova
                    ? 'Nunca feita'
                    : '${x.acertos} certas · ${x.erros} erradas',
              ),
              Selo(
                dias <= 0
                    ? 'Volta hoje'
                    : dias == 1
                    ? 'Volta amanhã'
                    : 'Volta em $dias dias',
                icone: Icons.event_repeat_rounded,
              ),
              if (x.caixa > 0)
                Selo('Caixa ${x.caixa} (${intervalosCaixas[x.caixa]}d)'),
            ],
          ),
          const SizedBox(height: 12),
          SelectableText(
            x.enunciado,
            style: const TextStyle(fontSize: 16, height: 1.45),
          ),
          const SizedBox(height: 10),
          for (final e in q.alternativas.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '${e.key}) ${e.value}',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.35,
                  fontWeight: e.key == x.gabarito
                      ? FontWeight.w800
                      : FontWeight.w400,
                  color: e.key == x.gabarito ? corCerto : Cores.tinta,
                ),
              ),
            ),
          if (x.explicacao.isNotEmpty) ...[
            const SizedBox(height: 8),
            CaixaObs(x.explicacao, titulo: 'Explicação'),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (x.suspeito)
                Pilula(
                  icone: Icons.check_rounded,
                  rotulo: 'Gabarito está certo',
                  aoTocar: () => db.marcarSuspeito(x.id, false),
                )
              else
                Pilula(
                  icone: Icons.outlined_flag_rounded,
                  rotulo: 'Gabarito suspeito',
                  aoTocar: () => db.marcarSuspeito(x.id, true),
                ),
              Pilula(
                icone: Icons.edit_outlined,
                rotulo: 'Trocar gabarito',
                aoTocar: () => _trocarGabarito(context),
              ),
              Pilula(
                icone: Icons.delete_outline_rounded,
                tooltip: 'Excluir questão',
                aoTocar: () async {
                  final ok = await confirmar(
                    context,
                    titulo: 'Excluir esta questão?',
                    mensagem: 'Ela sai do banco de questões.',
                    acao: 'Excluir',
                  );
                  if (ok) await db.excluirQuestaoTopico(x.id);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

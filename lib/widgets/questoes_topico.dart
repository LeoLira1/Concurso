import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../data/questoes_topico_db.dart';
import '../screens/banco_questoes_screen.dart';
import '../screens/colar_questoes_screen.dart';
import '../screens/resolver_topico_screen.dart';
import '../theme.dart';
import '../util/texto.dart';
import 'assistir.dart';
import 'comuns.dart';
import 'provas_comuns.dart' show corAviso;

/// Números do banco de questões de um tópico ou matéria.
class ResumoQuestoes {
  ResumoQuestoes(List<QuestaoTopicoInfo> l) {
    final hoje = soDia(DateTime.now());
    for (final q in l) {
      total++;
      if (!q.questao.proximaRevisao.isAfter(hoje)) paraHoje++;
      if (q.questao.suspeito) suspeitas++;
      acertos += q.questao.acertos;
      respostas += q.questao.acertos + q.questao.erros;
    }
  }
  int total = 0, paraHoje = 0, suspeitas = 0, acertos = 0, respostas = 0;

  String get subtitulo => total == 0
      ? 'Cole questões em JSON e resolva uma por tela'
      : [
          '$total ${total == 1 ? 'questão' : 'questões'}',
          '$paraHoje para hoje',
          if (respostas > 0)
            '${(acertos * 100 / respostas).round()}% de acerto',
        ].join(' · ');
}

/// Cartão "Questões" da tela do tópico (inclui as dos subtópicos).
class CartaoQuestoesTopico extends StatelessWidget {
  const CartaoQuestoesTopico({
    super.key,
    required this.topico,
    required this.materia,
    required this.concursoId,
  });
  final Topico topico;
  final Materia materia;
  final String? concursoId;

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return Assistir<List<QuestaoTopicoInfo>>(
      chave: topico.id,
      stream: () => db.watchQuestoesTopico(topicoId: topico.id),
      builder: (context, l) {
        final r = ResumoQuestoes(l ?? const []);
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 20, 24),
          decoration: BoxDecoration(
            border: Border.all(color: Cores.linha, width: 1.5),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Questões', style: Theme.of(context).textTheme.titleLarge),
              Text(
                r.subtitulo,
                key: const ValueKey('resumo-questoes'),
                style: const TextStyle(fontSize: 14, color: Cores.tintaSuave),
              ),
              const SizedBox(height: 14),
              BotoesQuestoes(
                resumo: r,
                titulo: topico.nome,
                materia: materia,
                topico: topico,
                concursoId: concursoId,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Atalho "Questões" no alto da tela da matéria.
class AtalhoQuestoesMateria extends StatelessWidget {
  const AtalhoQuestoesMateria({
    super.key,
    required this.materia,
    required this.concursoId,
  });
  final Materia materia;
  final String? concursoId;

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return Assistir<List<QuestaoTopicoInfo>>(
      chave: (materia.id, concursoId),
      stream: () =>
          db.watchQuestoesTopico(materiaId: materia.id, concursoId: concursoId),
      builder: (context, l) => Padding(
        padding: const EdgeInsets.only(top: 12),
        child: BotoesQuestoes(
          resumo: ResumoQuestoes(l ?? const []),
          titulo: materia.nome,
          materia: materia,
          concursoId: concursoId,
        ),
      ),
    );
  }
}

/// Resolver · Colar questões · Ver questões · Gabarito suspeito.
class BotoesQuestoes extends StatelessWidget {
  const BotoesQuestoes({
    super.key,
    required this.resumo,
    required this.titulo,
    required this.materia,
    this.topico,
    required this.concursoId,
  });
  final ResumoQuestoes resumo;
  final String titulo;
  final Materia materia;
  final Topico? topico;
  final String? concursoId;

  void _lista(BuildContext context, {bool soSuspeitas = false}) =>
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BancoQuestoesScreen(
            titulo: 'Questões · $titulo',
            topicoId: topico?.id,
            materiaId: topico == null ? materia.id : null,
            concursoId: topico == null ? concursoId : null,
            soSuspeitas: soSuspeitas,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final r = resumo;
    void resolver({bool todas = false}) => abrirResolverQuestoes(
      context,
      titulo: titulo,
      topicoId: topico?.id,
      materiaId: topico == null ? materia.id : null,
      concursoId: topico == null ? concursoId : null,
      todas: todas,
    );
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (r.paraHoje > 0)
          FilledButton.icon(
            key: const ValueKey('resolver-questoes'),
            style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
            onPressed: resolver,
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text('Resolver ${r.paraHoje}'),
          )
        else if (r.total > 0)
          Pilula(
            key: const ValueKey('resolver-questoes'),
            icone: Icons.replay_rounded,
            rotulo: 'Praticar todas',
            aoTocar: () => resolver(todas: true),
          ),
        Pilula(
          key: const ValueKey('colar-questoes'),
          icone: Icons.content_paste_rounded,
          rotulo: 'Colar questões',
          aoTocar: () => abrirColarQuestoes(
            context,
            materia: materia,
            topico: topico,
            concursoId: concursoId,
          ),
        ),
        if (r.total > 0)
          Pilula(
            icone: Icons.list_alt_rounded,
            rotulo: 'Ver ${r.total}',
            aoTocar: () => _lista(context),
          ),
        if (r.suspeitas > 0)
          Material(
            color: corAviso.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: corAviso, width: 1.5),
            ),
            child: InkWell(
              key: const ValueKey('ver-suspeitas'),
              borderRadius: BorderRadius.circular(14),
              onTap: () => _lista(context, soSuspeitas: true),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.flag_rounded, color: corAviso),
                      const SizedBox(width: 8),
                      Text(
                        '${r.suspeitas} gabarito${r.suspeitas == 1 ? '' : 's'} '
                        'suspeito${r.suspeitas == 1 ? '' : 's'}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: corAviso,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

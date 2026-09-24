import 'dart:math' as math;

import 'package:edital/logic/mapa_mental.dart';
import 'package:flutter_test/flutter_test.dart';

/// Edital sintético: [nMaterias] matérias com [nTopicos] tópicos cada; o
/// número de subtópicos varia (0 a [maxSub]) para ter ramos desiguais.
(List<MateriaMapa>, List<TopicoMapa>) edital(
  int nMaterias,
  int nTopicos,
  int maxSub, {
  int seed = 7,
}) {
  final rnd = math.Random(seed);
  final materias = <MateriaMapa>[];
  final topicos = <TopicoMapa>[];
  for (var m = 0; m < nMaterias; m++) {
    final mid = 'm$m';
    materias.add(
      MateriaMapa(mid, 'Matéria número $m com nome comprido', 0xFF2F7CF6),
    );
    for (var t = 0; t < nTopicos; t++) {
      final tid = '$mid-t$t';
      topicos.add(
        TopicoMapa(
          id: tid,
          materiaId: mid,
          paiId: null,
          nome: 'Tópico $t de $mid',
          visto: rnd.nextBool(),
          ordem: t,
        ),
      );
      final nSub = maxSub == 0 ? 0 : rnd.nextInt(maxSub + 1);
      for (var s = 0; s < nSub; s++) {
        topicos.add(
          TopicoMapa(
            id: '$tid-s$s',
            materiaId: mid,
            paiId: tid,
            nome: 'Subtópico $s',
            visto: rnd.nextBool(),
            ordem: s,
          ),
        );
      }
    }
  }
  return (materias, topicos);
}

int contarNos(NoMapa n) => 1 + n.filhos.fold(0, (s, f) => s + contarNos(f));

void verificar(NoMapa arvore) {
  final l = calcularLayout(arvore);
  // Todos os nós posicionados, cada um uma vez.
  expect(l.nos.length, contarNos(arvore));
  expect({for (final n in l.nos) n.no.id}.length, l.nos.length);
  expect(l.raiz.centro, Offset.zero);
  for (final n in l.nos) {
    expect(n.centro.dx.isFinite && n.centro.dy.isFinite, isTrue);
    expect(l.limites.contains(n.centro), isTrue);
    if (n.pai != null && n.pai != n.polo) {
      // Subtópico sempre para fora do tópico, em volta da mesma matéria.
      expect(n.polo, same(n.pai!.polo));
      expect(n.raio, greaterThan(n.pai!.raio));
    }
  }
  // Uma linha por nó (menos a raiz), sem atravessar nenhum outro nó.
  expect(l.ligacoes, hasLength(l.nos.length - 1));
  final cruza = cruzamentos(l);
  if (cruza.isNotEmpty) {
    final (lig, no) = cruza.first;
    fail(
      '${cruza.length} linhas cruzam nós, ex.: '
      '${lig.pai.no.id} → ${lig.filho.no.id} passa por ${no.no.id}',
    );
  }
  // Nenhuma caixa cruza outra (checagem por força bruta).
  for (var i = 0; i < l.nos.length; i++) {
    final a = l.nos[i].retangulo;
    for (var j = i + 1; j < l.nos.length; j++) {
      final b = l.nos[j].retangulo;
      final cruza =
          a.left < b.right &&
          b.left < a.right &&
          a.top < b.bottom &&
          b.top < a.bottom;
      if (cruza) {
        fail('sobreposição: ${l.nos[i].no.id} × ${l.nos[j].no.id}');
      }
    }
  }
  expect(temSobreposicao(l.nos), isFalse);
}

void main() {
  final hoje = DateTime(2026, 9, 24);

  test('edital grande (8 × 30 × até 4 subtópicos): sem sobreposição', () {
    final (mats, tops) = edital(8, 30, 4);
    final arvore = montarArvore(
      rotuloRaiz: 'Todos',
      materias: mats,
      topicos: tops,
      hoje: hoje,
    );
    expect(contarNos(arvore), greaterThan(8 * 30 + 300));
    final relogio = Stopwatch()..start();
    final l = calcularLayout(arvore);
    relogio.stop();
    // Folgado de propósito (máquina de CI); no tablet fica bem abaixo.
    expect(relogio.elapsedMilliseconds, lessThan(500));
    expect(l.limites.width, lessThan(20000));
    verificar(arvore);
  });

  test('edital grande sem subtópicos e com 3 fixos por tópico', () {
    for (final sub in [0, 3]) {
      final (mats, tops) = edital(8, 30, 0);
      final todos = [
        ...tops,
        if (sub > 0)
          for (final t in tops)
            for (var s = 0; s < sub; s++)
              TopicoMapa(
                id: '${t.id}-x$s',
                materiaId: t.materiaId,
                paiId: t.id,
                nome: 'Sub $s',
                visto: false,
              ),
      ];
      verificar(
        montarArvore(
          rotuloRaiz: 'Todos',
          materias: mats,
          topicos: todos,
          hoje: hoje,
        ),
      );
    }
  });

  test('casos pequenos e desiguais', () {
    for (final (nm, nt, ns) in [
      (1, 0, 0),
      (1, 1, 0),
      (2, 1, 0),
      (3, 2, 5),
      (1, 40, 0),
      (5, 3, 12),
      (12, 5, 2),
    ]) {
      final (mats, tops) = edital(nm, nt, ns, seed: nm * 31 + nt);
      verificar(
        montarArvore(
          rotuloRaiz: 'X',
          materias: mats,
          topicos: tops,
          hoje: hoje,
        ),
      );
    }
  });

  test('sem matérias: só a raiz', () {
    final l = calcularLayout(
      montarArvore(rotuloRaiz: 'X', materias: [], topicos: [], hoje: hoje),
    );
    expect(l.nos.length, 1);
  });

  test('matérias recolhidas somem do mapa sem sobreposição', () {
    final (mats, tops) = edital(8, 30, 3);
    final arvore = montarArvore(
      rotuloRaiz: 'Todos',
      materias: mats,
      topicos: tops,
      recolhidas: {'m1', 'm2', 'm3', 'm6'},
      hoje: hoje,
    );
    final m1 = arvore.filhos[1];
    expect(m1.filhos, isEmpty);
    expect(m1.ocultos, 30);
    expect(m1.folhas, greaterThanOrEqualTo(30));
    verificar(arvore);
  });

  test('matéria no centro', () {
    final (mats, tops) = edital(8, 30, 4);
    final arvore = montarArvore(
      rotuloRaiz: 'Todos',
      materias: mats,
      topicos: tops,
      materiaCentral: 'm4',
      recolhidas: {'m4'}, // ignorado quando está no centro
      hoje: hoje,
    );
    expect(arvore.id, 'm4');
    expect(arvore.tipo, TipoNo.materia);
    expect(arvore.filhos.length, 30);
    verificar(arvore);
  });

  test('matéria com 45 tópicos e subtópicos: círculo completo, sem cruzar', () {
    final mats = [const MateriaMapa('m', 'Direito Constitucional', 1)];
    final tops = [
      for (var i = 0; i < 45; i++) ...[
        TopicoMapa(
          id: 't$i',
          materiaId: 'm',
          paiId: null,
          nome: 'Tópico $i com um nome que ocupa duas linhas',
          visto: i.isEven,
          ordem: i,
        ),
        for (var s = 0; s < (i % 7 == 0 ? 4 : (i % 5 == 0 ? 2 : 0)); s++)
          TopicoMapa(
            id: 't$i-s$s',
            materiaId: 'm',
            paiId: 't$i',
            nome: 'Subtópico $s',
            visto: false,
            ordem: s,
          ),
      ],
    ];
    for (final central in [true, false]) {
      final arvore = montarArvore(
        rotuloRaiz: 'Guarda',
        materias: mats,
        topicos: tops,
        materiaCentral: central ? 'm' : null,
        hoje: hoje,
      );
      verificar(arvore);
      final l = calcularLayout(arvore);
      final materia = l.porId('m')!;
      final topicos = [
        for (final n in l.nos)
          if (n.pai == materia) n,
      ];
      expect(topicos, hasLength(45));
      // Em volta da matéria, nos quatro quadrantes (360°).
      final quadrantes = {
        for (final t in topicos)
          (
            (t.centro - materia.centro).dx >= 0,
            (t.centro - materia.centro).dy >= 0,
          ),
      };
      expect(quadrantes, hasLength(4));
      // Os setores somam o círculo (menos o vão da linha que chega na
      // matéria) e são proporcionais ao número de folhas de cada ramo.
      final soma = topicos.fold<double>(0, (a, t) => a + t.setor);
      expect(soma, lessThanOrEqualTo(2 * math.pi + 1e-9));
      expect(soma, greaterThan(2 * math.pi * 0.9));
      final t0 = l.porId('t0')!; // 4 subtópicos
      final t1 = l.porId('t1')!; // nenhum
      final t5 = l.porId('t5')!; // 2 subtópicos
      expect(t0.setor / t1.setor, closeTo(4, 1e-6));
      expect(t5.setor / t1.setor, closeTo(2, 1e-6));
      // Subtópicos dentro do setor do tópico pai.
      for (final n in l.nos) {
        if (n.pai == null || n.pai == materia || n.pai!.pai != materia) {
          continue;
        }
        final p = n.pai!;
        var d = (n.angulo - p.angulo).abs() % (2 * math.pi);
        if (d > math.pi) d = 2 * math.pi - d;
        expect(d, lessThanOrEqualTo(p.setor / 2 + 1e-9));
      }
    }
  });

  test('ângulos proporcionais ao número de descendentes', () {
    final mats = [const MateriaMapa('a', 'A', 1)];
    final tops = [
      const TopicoMapa(
        id: 'x',
        materiaId: 'a',
        paiId: null,
        nome: 'X',
        visto: false,
      ),
      for (var i = 0; i < 6; i++)
        TopicoMapa(
          id: 'x$i',
          materiaId: 'a',
          paiId: 'x',
          nome: '$i',
          visto: false,
        ),
      const TopicoMapa(
        id: 'y',
        materiaId: 'a',
        paiId: null,
        nome: 'Y',
        visto: false,
        ordem: 1,
      ),
      for (var i = 0; i < 2; i++)
        TopicoMapa(
          id: 'y$i',
          materiaId: 'a',
          paiId: 'y',
          nome: '$i',
          visto: false,
        ),
    ];
    final l = calcularLayout(
      montarArvore(
        rotuloRaiz: 'X',
        materias: mats,
        topicos: tops,
        materiaCentral: 'a',
        hoje: hoje,
      ),
    );
    // 6 folhas contra 2, no círculo inteiro (sem vão: a matéria é o centro).
    expect(l.porId('x')!.setor, closeTo(2 * math.pi * 6 / 8, 1e-9));
    expect(l.porId('y')!.setor, closeTo(2 * math.pi * 2 / 8, 1e-9));
  });

  test('situação: visto, em parte, revisão atrasada e acerto baixo', () {
    final mats = [const MateriaMapa('m', 'M', 1)];
    final tops = [
      const TopicoMapa(
        id: 'p',
        materiaId: 'm',
        paiId: null,
        nome: 'Pai',
        visto: false,
      ),
      const TopicoMapa(
        id: 'p1',
        materiaId: 'm',
        paiId: 'p',
        nome: 'F1',
        visto: true,
      ),
      const TopicoMapa(
        id: 'p2',
        materiaId: 'm',
        paiId: 'p',
        nome: 'F2',
        visto: false,
      ),
      const TopicoMapa(
        id: 'q',
        materiaId: 'm',
        paiId: null,
        nome: 'Q',
        visto: true,
        ordem: 1,
      ),
      const TopicoMapa(
        id: 'r',
        materiaId: 'm',
        paiId: null,
        nome: 'R',
        visto: false,
        ordem: 2,
      ),
    ];
    final arvore = montarArvore(
      rotuloRaiz: 'X',
      materias: mats,
      topicos: tops,
      hoje: hoje,
      info: {
        'q': InfoTopico(proximaRevisao: DateTime(2026, 9, 20)),
        'p1': InfoTopico(feitas: 12, acertos: 6, minutos: 30),
        'p2': InfoTopico(feitas: 5, acertos: 1, flashcards: 4),
        'r': InfoTopico(feitas: 9, acertos: 1),
      },
    );
    final m = arvore.filhos.single;
    final p = m.filhos[0], q = m.filhos[1], r = m.filhos[2];
    expect(p.visto, Visto.parte);
    expect(p.filhos[0].visto, Visto.sim);
    expect(p.filhos[0].acertoBaixo, isTrue); // 50% com 12 questões
    expect(p.filhos[1].acertoBaixo, isFalse); // só 5 questões
    expect(p.acertoBaixo, isTrue); // 7/17 somando os filhos
    expect(p.info.minutos, 30);
    expect(p.info.flashcards, 4);
    expect(q.visto, Visto.sim);
    expect(q.atrasada, isTrue);
    expect(r.acertoBaixo, isFalse); // só 9 questões
    expect(m.progresso, closeTo(2 / 4, 1e-9)); // p1, q de p1, p2, q, r
    expect(m.folhas, 4);
  });
}

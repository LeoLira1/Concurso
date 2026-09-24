import 'package:drift/drift.dart' show Variable;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../data/provas_db.dart';
import '../logic/provas.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../util/texto.dart';
import '../widgets/provas_comuns.dart';
import '../widgets/comuns.dart';
import 'provas_screen.dart';
import 'questoes_screen.dart';

/// Abre 10 questões do concurso em foco (nunca feitas e erradas primeiro).
Future<void> abrirTreinoRapido(BuildContext context) async {
  final db = context.read<AppDatabase>();
  final estado = context.read<AppState>();
  final foco = estado.verTudo ? null : await db.watchFoco().first;
  final qs = await db.treinoRapido(foco?.id);
  if (!context.mounted) return;
  if (qs.isEmpty) {
    final nenhuma = (await db.select(db.questoesProva).get()).isEmpty;
    if (!context.mounted) return;
    avisar(
      context,
      nenhuma
          ? 'Ainda não há provas. Cole uma em Provas → Colar prova.'
          : 'Nenhuma questão deste concurso para treinar.',
    );
    if (nenhuma) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProvasScreen()),
      );
    }
    return;
  }
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => QuestoesScreen(
        questoes: qs,
        modo: ModoQuestoes.treino,
        titulo: 'Treino rápido',
      ),
    ),
  );
}

/// Escolher modo e filtros antes de resolver.
class ResolverScreen extends StatefulWidget {
  const ResolverScreen({super.key});

  @override
  State<ResolverScreen> createState() => _ResolverScreenState();
}

const _tudo = '*';

class _ResolverScreenState extends State<ResolverScreen> {
  late final AppDatabase _db = context.read<AppDatabase>();
  ModoQuestoes _modo = ModoQuestoes.treino;

  List<Concurso> _concursos = [];
  List<Materia> _materias = [];
  List<Topico> _topicos = [];
  List<String> _bancas = [];
  List<int> _anos = [];

  String _escopo = _tudo;
  String? _materia;
  String? _topico;
  String? _banca;
  int? _ano;
  bool _soErradas = false;
  bool _soNunca = false;
  bool _anuladas = false;
  bool _desatualizadas = false;
  bool _revisar = false;

  int? _disponiveis;
  int _quantidade = 20;
  int _minutos = 20 * minutosPorQuestao;
  bool _minutosEditados = false;
  int _consulta = 0;

  FiltroQuestoes get _filtro => FiltroQuestoes(
    concursoId: _escopo == _tudo ? null : _escopo,
    materiaId: _materia,
    topicoId: _topico,
    banca: _banca,
    ano: _ano,
    soErradas: _soErradas,
    soNuncaFeitas: _soNunca,
    incluirAnuladas: _anuladas,
    incluirDesatualizadas: _desatualizadas,
    incluirRevisar: _revisar,
  );

  @override
  void initState() {
    super.initState();
    _iniciar();
  }

  Future<void> _iniciar() async {
    final verTudo = context.read<AppState>().verTudo;
    final concursos = await _db.watchConcursos().first;
    final foco = concursos.where((c) => c.foco).firstOrNull;
    final (bancas, anos) = await _db.bancasEAnos();
    final comQuestoes = await _db
        .customSelect('SELECT DISTINCT materia_id AS id FROM questoes_prova')
        .get();
    final ids = {for (final r in comQuestoes) r.read<String>('id')};
    final mats = [
      for (final m in await _db.todasMaterias())
        if (ids.contains(m.id)) m,
    ];
    if (!mounted) return;
    setState(() {
      _concursos = concursos;
      _escopo = verTudo || foco == null ? _tudo : foco.id;
      _bancas = bancas;
      _anos = anos;
      _materias = mats;
    });
    _contar();
  }

  Future<void> _carregarTopicos() async {
    final m = _materia;
    if (m == null) {
      setState(() => _topicos = []);
      return;
    }
    final r = await _db
        .customSelect(
          'SELECT DISTINCT topico_id AS id FROM questoes_prova '
          'WHERE materia_id = ? AND topico_id IS NOT NULL',
          variables: [Variable.withString(m)],
        )
        .get();
    final ids = {for (final x in r) x.read<String>('id')};
    final ts = await _db.watchTopicos(m, semFiltro: true).first;
    if (!mounted) return;
    setState(
      () => _topicos = [
        for (final t in ts)
          if (ids.contains(t.id)) t,
      ],
    );
  }

  Future<void> _contar() async {
    final n = ++_consulta;
    final l = await _db.questoesFiltradas(_filtro);
    if (!mounted || n != _consulta) return;
    setState(() {
      _disponiveis = l.length;
      if (_quantidade > l.length) _quantidade = l.length;
      if (_quantidade == 0 && l.isNotEmpty) {
        _quantidade = l.length < 20 ? l.length : 20;
      }
      if (!_minutosEditados) _minutos = _quantidade * minutosPorQuestao;
    });
  }

  void _mudar(VoidCallback f) {
    setState(f);
    _contar();
  }

  Future<void> _comecar() async {
    final n = _modo == ModoQuestoes.simulado
        ? _quantidade
        : (_disponiveis ?? 0);
    final qs = await _db.sortear(_filtro, n);
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuestoesScreen(
          questoes: qs,
          modo: _modo,
          minutos: _modo == ModoQuestoes.simulado ? _minutos : null,
        ),
      ),
    ).then((_) => _contar());
  }

  @override
  Widget build(BuildContext context) {
    final disp = _disponiveis;
    return Scaffold(
      appBar: AppBar(toolbarHeight: 72, title: const Text('Resolver')),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            children: [
              SegmentedButton<ModoQuestoes>(
                segments: const [
                  ButtonSegment(
                    value: ModoQuestoes.treino,
                    label: Text('Treino'),
                    icon: Icon(Icons.bolt_rounded),
                  ),
                  ButtonSegment(
                    value: ModoQuestoes.simulado,
                    label: Text('Simulado'),
                    icon: Icon(Icons.timer_outlined),
                  ),
                ],
                selected: {_modo},
                onSelectionChanged: (s) => setState(() => _modo = s.first),
              ),
              const SizedBox(height: 8),
              Text(
                _modo == ModoQuestoes.treino
                    ? 'Uma questão por vez, com a correção na hora.'
                    : 'Várias questões com cronômetro; a correção só no final.',
                style: const TextStyle(color: Cores.tintaSuave),
              ),
              const SizedBox(height: 20),
              Cartao(
                titulo: 'Filtros',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Campo<String>(
                      rotulo: 'Concurso',
                      valor: _escopo,
                      itens: {
                        _tudo: 'Tudo junto',
                        for (final c in _concursos) c.id: c.nome,
                      },
                      aoMudar: (v) => _mudar(() => _escopo = v ?? _tudo),
                    ),
                    _Campo<String?>(
                      rotulo: 'Matéria',
                      valor: _materia,
                      itens: {
                        null: 'Todas',
                        for (final m in _materias) m.id: m.nome,
                      },
                      aoMudar: (v) {
                        _mudar(() {
                          _materia = v;
                          _topico = null;
                        });
                        _carregarTopicos();
                      },
                    ),
                    if (_materia != null && _topicos.isNotEmpty)
                      _Campo<String?>(
                        rotulo: 'Tópico',
                        valor: _topico,
                        itens: {
                          null: 'Todos',
                          for (final t in _topicos) t.id: t.nome,
                        },
                        aoMudar: (v) => _mudar(() => _topico = v),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: _Campo<String?>(
                            rotulo: 'Banca',
                            valor: _banca,
                            itens: {
                              null: 'Todas',
                              for (final b in _bancas) b: b,
                            },
                            aoMudar: (v) => _mudar(() => _banca = v),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 150,
                          child: _Campo<int?>(
                            rotulo: 'Ano',
                            valor: _ano,
                            itens: {
                              null: 'Todos',
                              for (final a in _anos) a: '$a',
                            },
                            aoMudar: (v) => _mudar(() => _ano = v),
                          ),
                        ),
                      ],
                    ),
                    _Chave(
                      'Só as que errei',
                      _soErradas,
                      (v) => _mudar(() => _soErradas = v),
                    ),
                    _Chave(
                      'Só as nunca feitas',
                      _soNunca,
                      (v) => _mudar(() => _soNunca = v),
                    ),
                    const Divider(),
                    const Padding(
                      padding: EdgeInsets.only(top: 12, bottom: 4),
                      child: Text(
                        'Normalmente ficam de fora:',
                        style: TextStyle(color: Cores.tintaSuave),
                      ),
                    ),
                    _Chave(
                      'Incluir anuladas',
                      _anuladas,
                      (v) => _mudar(() => _anuladas = v),
                    ),
                    _Chave(
                      'Incluir desatualizadas (lei mudou)',
                      _desatualizadas,
                      (v) => _mudar(() => _desatualizadas = v),
                    ),
                    _Chave(
                      'Incluir "revisar" ainda não conferidas',
                      _revisar,
                      (v) => _mudar(() => _revisar = v),
                    ),
                  ],
                ),
              ),
              if (_modo == ModoQuestoes.simulado && (disp ?? 0) > 0) ...[
                const SizedBox(height: 16),
                Cartao(
                  titulo: 'Simulado',
                  child: Column(
                    children: [
                      _Contador(
                        rotulo: 'Questões',
                        valor: _quantidade,
                        min: 1,
                        max: disp!,
                        passo: 5,
                        aoMudar: (v) => setState(() {
                          _quantidade = v;
                          if (!_minutosEditados) {
                            _minutos = v * minutosPorQuestao;
                          }
                        }),
                      ),
                      _Contador(
                        rotulo: 'Tempo',
                        valor: _minutos,
                        min: 1,
                        max: 600,
                        passo: 5,
                        formatar: minutosFmt,
                        aoMudar: (v) => setState(() {
                          _minutos = v;
                          _minutosEditados = true;
                        }),
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Sugestão: 4 minutos por questão.',
                          style: TextStyle(color: Cores.tintaSuave),
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
      bottomNavigationBar: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      disp == null
                          ? 'Contando…'
                          : disp == 0
                          ? 'Nenhuma questão com esses filtros.'
                          : '$disp ${disp == 1 ? 'questão disponível' : 'questões disponíveis'}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  FilledButton.icon(
                    key: const ValueKey('comecar'),
                    onPressed: (disp ?? 0) == 0 ? null : _comecar,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Começar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Campo<T> extends StatelessWidget {
  const _Campo({
    required this.rotulo,
    required this.valor,
    required this.itens,
    required this.aoMudar,
  });
  final String rotulo;
  final T valor;
  final Map<T, String> itens;
  final ValueChanged<T?> aoMudar;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: DropdownButtonFormField<T>(
      key: ValueKey('filtro-$rotulo-$valor'),
      initialValue: itens.containsKey(valor) ? valor : itens.keys.first,
      isExpanded: true,
      decoration: InputDecoration(labelText: rotulo),
      items: [
        for (final e in itens.entries)
          DropdownMenuItem<T>(
            value: e.key,
            child: Text(e.value, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: aoMudar,
    ),
  );
}

class _Chave extends StatelessWidget {
  const _Chave(this.rotulo, this.valor, this.aoMudar);
  final String rotulo;
  final bool valor;
  final ValueChanged<bool> aoMudar;

  @override
  Widget build(BuildContext context) => SwitchListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(rotulo, style: const TextStyle(fontSize: 16)),
    value: valor,
    onChanged: aoMudar,
  );
}

class _Contador extends StatelessWidget {
  const _Contador({
    required this.rotulo,
    required this.valor,
    required this.min,
    required this.max,
    required this.passo,
    required this.aoMudar,
    this.formatar,
  });
  final String rotulo;
  final int valor;
  final int min;
  final int max;
  final int passo;
  final ValueChanged<int> aoMudar;
  final String Function(int)? formatar;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Expanded(
          child: Text(
            rotulo,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        IconButton.outlined(
          onPressed: valor <= min
              ? null
              : () => aoMudar((valor - passo).clamp(min, max)),
          icon: const Icon(Icons.remove_rounded),
        ),
        SizedBox(
          width: 90,
          child: Text(
            formatar?.call(valor) ?? '$valor',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
        ),
        IconButton.outlined(
          onPressed: valor >= max
              ? null
              : () => aoMudar((valor + passo).clamp(min, max)),
          icon: const Icon(Icons.add_rounded),
        ),
      ],
    ),
  );
}

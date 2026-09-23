import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Gera ids únicos entre aparelhos (necessário para sincronizar depois).
String novoId() => _uuid.v4();

/// Todas as tabelas usam id texto (UUID) e `atualizadoEm` para permitir
/// sincronização futura (Turso / libSQL) sem conflito de ids entre aparelhos.
mixin Sincronizavel on Table {
  TextColumn get id => text().clientDefault(novoId)();
  DateTimeColumn get atualizadoEm => dateTime().clientDefault(DateTime.now)();

  @override
  Set<Column> get primaryKey => {id};
}

class Concursos extends Table with Sincronizavel {
  TextColumn get nome => text()();
  TextColumn get banca => text().withDefault(const Constant(''))();
  DateTimeColumn get dataProva => dateTime().nullable()();
  IntColumn get cor => integer()();
  BoolColumn get foco => boolean().withDefault(const Constant(false))();
  BoolColumn get exemplo => boolean().withDefault(const Constant(false))();
  IntColumn get ordem => integer().withDefault(const Constant(0))();
  DateTimeColumn get criadoEm => dateTime().clientDefault(DateTime.now)();
}

/// Matéria global. O nome normalizado (`chave`) é único: "Português" em dois
/// concursos é a mesma matéria, com o mesmo progresso, revisões e questões.
class Materias extends Table with Sincronizavel {
  TextColumn get nome => text()();
  TextColumn get chave => text().unique()();
  IntColumn get cor => integer()();
}

/// Liga um concurso às matérias do seu edital (com a ordem daquele edital).
class ConcursoMaterias extends Table {
  TextColumn get concursoId =>
      text().references(Concursos, #id, onDelete: KeyAction.cascade)();
  TextColumn get materiaId =>
      text().references(Materias, #id, onDelete: KeyAction.cascade)();
  IntColumn get ordem => integer().withDefault(const Constant(0))();
  DateTimeColumn get atualizadoEm => dateTime().clientDefault(DateTime.now)();

  @override
  Set<Column> get primaryKey => {concursoId, materiaId};
}

class Topicos extends Table with Sincronizavel {
  TextColumn get materiaId =>
      text().references(Materias, #id, onDelete: KeyAction.cascade)();
  TextColumn get paiId =>
      text().nullable().references(Topicos, #id, onDelete: KeyAction.cascade)();
  TextColumn get nome => text()();
  IntColumn get ordem => integer().withDefault(const Constant(0))();
  BoolColumn get visto => boolean().withDefault(const Constant(false))();
  DateTimeColumn get vistoEm => dateTime().nullable()();
}

/// Revisões espaçadas (1, 7 e 30 dias) geradas ao marcar um tópico como visto.
@DataClassName('Revisao')
class Revisoes extends Table with Sincronizavel {
  TextColumn get topicoId =>
      text().references(Topicos, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get dataPrevista => dateTime()();
  IntColumn get intervaloDias => integer()();
  DateTimeColumn get feitaEm => dateTime().nullable()();
}

/// Registro de questões por matéria.
@DataClassName('RegistroQuestoes')
class Questoes extends Table with Sincronizavel {
  TextColumn get materiaId =>
      text().references(Materias, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get data => dateTime()();
  IntColumn get feitas => integer()();
  IntColumn get acertos => integer()();
}

/// Sessão de estudo. Qualquer sessão num dia marca o dia na grade.
@DataClassName('Sessao')
class Sessoes extends Table with Sincronizavel {
  TextColumn get materiaId => text().nullable().references(
    Materias,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get topicoId =>
      text().nullable().references(Topicos, #id, onDelete: KeyAction.setNull)();

  /// Dia (meia-noite local) em que a sessão conta na grade.
  DateTimeColumn get dia => dateTime()();
  DateTimeColumn get inicio => dateTime().clientDefault(DateTime.now)();
  IntColumn get minutos => integer()();
}

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

  // Ciclo de estudos (v2).
  /// Duração de uma volta completa do ciclo, em minutos.
  IntColumn get cicloMinutos => integer().withDefault(const Constant(1200))();

  /// Tamanho de referência de cada sessão do ciclo, em minutos.
  IntColumn get cicloBlocoMin => integer().withDefault(const Constant(60))();

  /// Índice da próxima etapa na fila do ciclo.
  IntColumn get cicloPosicao => integer().withDefault(const Constant(0))();

  /// Quantas voltas completas já foram feitas.
  IntColumn get cicloVoltas => integer().withDefault(const Constant(0))();
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

  // Ciclo de estudos (v2): cada concurso tem seu peso/dificuldade por matéria.
  IntColumn get peso => integer().withDefault(const Constant(3))();
  IntColumn get dificuldade => integer().withDefault(const Constant(3))();
  BoolColumn get noCiclo => boolean().withDefault(const Constant(true))();

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

  // Registro ao finalizar (v3).
  /// videoaula, pdf, questoes, revisao, lei_seca (ver logic/metodo.dart).
  TextColumn get metodo => text().nullable()();
  IntColumn get questoesFeitas => integer().withDefault(const Constant(0))();
  IntColumn get questoesAcertos => integer().withDefault(const Constant(0))();
  IntColumn get paginas => integer().withDefault(const Constant(0))();

  /// Onde parou (texto curto), mostrado na próxima sessão da mesma matéria.
  TextColumn get pontoParada => text().nullable()();
}

/// Resumo ou mapa mental anexado a um tópico (v4). O arquivo fica na pasta
/// do app; aqui só o caminho relativo a ela.
class Anexos extends Table with Sincronizavel {
  TextColumn get topicoId =>
      text().references(Topicos, #id, onDelete: KeyAction.cascade)();

  /// 'imagem' ou 'pdf'.
  TextColumn get tipo => text()();
  TextColumn get nome => text()();

  /// Caminho relativo à pasta de anexos do app (ex.: "a1b2.jpg").
  TextColumn get arquivo => text()();
  IntColumn get bytes => integer().withDefault(const Constant(0))();
  DateTimeColumn get criadoEm => dateTime().clientDefault(DateTime.now)();
}

/// Flashcard de um tópico, com repetição espaçada simples (caixas de Leitner).
class Flashcards extends Table with Sincronizavel {
  TextColumn get topicoId =>
      text().references(Topicos, #id, onDelete: KeyAction.cascade)();
  TextColumn get frente => text()();
  TextColumn get verso => text()();
  IntColumn get ordem => integer().withDefault(const Constant(0))();

  /// 0 = novo/errado ... 5 = bem sabido.
  IntColumn get caixa => integer().withDefault(const Constant(0))();

  /// Dia em que o cartão volta a aparecer.
  DateTimeColumn get proximaRevisao => dateTime().clientDefault(DateTime.now)();
  IntColumn get acertos => integer().withDefault(const Constant(0))();
  IntColumn get erros => integer().withDefault(const Constant(0))();
  DateTimeColumn get criadoEm => dateTime().clientDefault(DateTime.now)();
}

/// Em quais editais (concursos) um tópico entra (v5). A matéria e o tópico
/// são compartilhados, com um progresso só; o vínculo diz quais concursos
/// mostram o tópico. Só tópicos de primeiro nível têm vínculo: os
/// subtópicos seguem o tópico pai.
@DataClassName('TopicoConcurso')
class TopicoConcursos extends Table {
  TextColumn get topicoId =>
      text().references(Topicos, #id, onDelete: KeyAction.cascade)();
  TextColumn get concursoId =>
      text().references(Concursos, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get atualizadoEm => dateTime().clientDefault(DateTime.now)();

  @override
  Set<Column> get primaryKey => {topicoId, concursoId};
}

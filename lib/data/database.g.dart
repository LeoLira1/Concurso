// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ConcursosTable extends Concursos
    with TableInfo<$ConcursosTable, Concurso> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConcursosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: novoId,
  );
  static const VerificationMeta _atualizadoEmMeta = const VerificationMeta(
    'atualizadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> atualizadoEm = GeneratedColumn<DateTime>(
    'atualizado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bancaMeta = const VerificationMeta('banca');
  @override
  late final GeneratedColumn<String> banca = GeneratedColumn<String>(
    'banca',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _dataProvaMeta = const VerificationMeta(
    'dataProva',
  );
  @override
  late final GeneratedColumn<DateTime> dataProva = GeneratedColumn<DateTime>(
    'data_prova',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _corMeta = const VerificationMeta('cor');
  @override
  late final GeneratedColumn<int> cor = GeneratedColumn<int>(
    'cor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _focoMeta = const VerificationMeta('foco');
  @override
  late final GeneratedColumn<bool> foco = GeneratedColumn<bool>(
    'foco',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("foco" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _exemploMeta = const VerificationMeta(
    'exemplo',
  );
  @override
  late final GeneratedColumn<bool> exemplo = GeneratedColumn<bool>(
    'exemplo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("exemplo" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _ordemMeta = const VerificationMeta('ordem');
  @override
  late final GeneratedColumn<int> ordem = GeneratedColumn<int>(
    'ordem',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _criadoEmMeta = const VerificationMeta(
    'criadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> criadoEm = GeneratedColumn<DateTime>(
    'criado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _cicloMinutosMeta = const VerificationMeta(
    'cicloMinutos',
  );
  @override
  late final GeneratedColumn<int> cicloMinutos = GeneratedColumn<int>(
    'ciclo_minutos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1200),
  );
  static const VerificationMeta _cicloBlocoMinMeta = const VerificationMeta(
    'cicloBlocoMin',
  );
  @override
  late final GeneratedColumn<int> cicloBlocoMin = GeneratedColumn<int>(
    'ciclo_bloco_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(60),
  );
  static const VerificationMeta _cicloPosicaoMeta = const VerificationMeta(
    'cicloPosicao',
  );
  @override
  late final GeneratedColumn<int> cicloPosicao = GeneratedColumn<int>(
    'ciclo_posicao',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _cicloVoltasMeta = const VerificationMeta(
    'cicloVoltas',
  );
  @override
  late final GeneratedColumn<int> cicloVoltas = GeneratedColumn<int>(
    'ciclo_voltas',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    atualizadoEm,
    nome,
    banca,
    dataProva,
    cor,
    foco,
    exemplo,
    ordem,
    criadoEm,
    cicloMinutos,
    cicloBlocoMin,
    cicloPosicao,
    cicloVoltas,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'concursos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Concurso> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('atualizado_em')) {
      context.handle(
        _atualizadoEmMeta,
        atualizadoEm.isAcceptableOrUnknown(
          data['atualizado_em']!,
          _atualizadoEmMeta,
        ),
      );
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('banca')) {
      context.handle(
        _bancaMeta,
        banca.isAcceptableOrUnknown(data['banca']!, _bancaMeta),
      );
    }
    if (data.containsKey('data_prova')) {
      context.handle(
        _dataProvaMeta,
        dataProva.isAcceptableOrUnknown(data['data_prova']!, _dataProvaMeta),
      );
    }
    if (data.containsKey('cor')) {
      context.handle(
        _corMeta,
        cor.isAcceptableOrUnknown(data['cor']!, _corMeta),
      );
    } else if (isInserting) {
      context.missing(_corMeta);
    }
    if (data.containsKey('foco')) {
      context.handle(
        _focoMeta,
        foco.isAcceptableOrUnknown(data['foco']!, _focoMeta),
      );
    }
    if (data.containsKey('exemplo')) {
      context.handle(
        _exemploMeta,
        exemplo.isAcceptableOrUnknown(data['exemplo']!, _exemploMeta),
      );
    }
    if (data.containsKey('ordem')) {
      context.handle(
        _ordemMeta,
        ordem.isAcceptableOrUnknown(data['ordem']!, _ordemMeta),
      );
    }
    if (data.containsKey('criado_em')) {
      context.handle(
        _criadoEmMeta,
        criadoEm.isAcceptableOrUnknown(data['criado_em']!, _criadoEmMeta),
      );
    }
    if (data.containsKey('ciclo_minutos')) {
      context.handle(
        _cicloMinutosMeta,
        cicloMinutos.isAcceptableOrUnknown(
          data['ciclo_minutos']!,
          _cicloMinutosMeta,
        ),
      );
    }
    if (data.containsKey('ciclo_bloco_min')) {
      context.handle(
        _cicloBlocoMinMeta,
        cicloBlocoMin.isAcceptableOrUnknown(
          data['ciclo_bloco_min']!,
          _cicloBlocoMinMeta,
        ),
      );
    }
    if (data.containsKey('ciclo_posicao')) {
      context.handle(
        _cicloPosicaoMeta,
        cicloPosicao.isAcceptableOrUnknown(
          data['ciclo_posicao']!,
          _cicloPosicaoMeta,
        ),
      );
    }
    if (data.containsKey('ciclo_voltas')) {
      context.handle(
        _cicloVoltasMeta,
        cicloVoltas.isAcceptableOrUnknown(
          data['ciclo_voltas']!,
          _cicloVoltasMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Concurso map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Concurso(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      atualizadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}atualizado_em'],
      )!,
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      banca: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}banca'],
      )!,
      dataProva: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data_prova'],
      ),
      cor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cor'],
      )!,
      foco: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}foco'],
      )!,
      exemplo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}exemplo'],
      )!,
      ordem: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordem'],
      )!,
      criadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}criado_em'],
      )!,
      cicloMinutos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ciclo_minutos'],
      )!,
      cicloBlocoMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ciclo_bloco_min'],
      )!,
      cicloPosicao: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ciclo_posicao'],
      )!,
      cicloVoltas: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ciclo_voltas'],
      )!,
    );
  }

  @override
  $ConcursosTable createAlias(String alias) {
    return $ConcursosTable(attachedDatabase, alias);
  }
}

class Concurso extends DataClass implements Insertable<Concurso> {
  final String id;
  final DateTime atualizadoEm;
  final String nome;
  final String banca;
  final DateTime? dataProva;
  final int cor;
  final bool foco;
  final bool exemplo;
  final int ordem;
  final DateTime criadoEm;

  /// Duração de uma volta completa do ciclo, em minutos.
  final int cicloMinutos;

  /// Tamanho de referência de cada sessão do ciclo, em minutos.
  final int cicloBlocoMin;

  /// Índice da próxima etapa na fila do ciclo.
  final int cicloPosicao;

  /// Quantas voltas completas já foram feitas.
  final int cicloVoltas;
  const Concurso({
    required this.id,
    required this.atualizadoEm,
    required this.nome,
    required this.banca,
    this.dataProva,
    required this.cor,
    required this.foco,
    required this.exemplo,
    required this.ordem,
    required this.criadoEm,
    required this.cicloMinutos,
    required this.cicloBlocoMin,
    required this.cicloPosicao,
    required this.cicloVoltas,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['atualizado_em'] = Variable<DateTime>(atualizadoEm);
    map['nome'] = Variable<String>(nome);
    map['banca'] = Variable<String>(banca);
    if (!nullToAbsent || dataProva != null) {
      map['data_prova'] = Variable<DateTime>(dataProva);
    }
    map['cor'] = Variable<int>(cor);
    map['foco'] = Variable<bool>(foco);
    map['exemplo'] = Variable<bool>(exemplo);
    map['ordem'] = Variable<int>(ordem);
    map['criado_em'] = Variable<DateTime>(criadoEm);
    map['ciclo_minutos'] = Variable<int>(cicloMinutos);
    map['ciclo_bloco_min'] = Variable<int>(cicloBlocoMin);
    map['ciclo_posicao'] = Variable<int>(cicloPosicao);
    map['ciclo_voltas'] = Variable<int>(cicloVoltas);
    return map;
  }

  ConcursosCompanion toCompanion(bool nullToAbsent) {
    return ConcursosCompanion(
      id: Value(id),
      atualizadoEm: Value(atualizadoEm),
      nome: Value(nome),
      banca: Value(banca),
      dataProva: dataProva == null && nullToAbsent
          ? const Value.absent()
          : Value(dataProva),
      cor: Value(cor),
      foco: Value(foco),
      exemplo: Value(exemplo),
      ordem: Value(ordem),
      criadoEm: Value(criadoEm),
      cicloMinutos: Value(cicloMinutos),
      cicloBlocoMin: Value(cicloBlocoMin),
      cicloPosicao: Value(cicloPosicao),
      cicloVoltas: Value(cicloVoltas),
    );
  }

  factory Concurso.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Concurso(
      id: serializer.fromJson<String>(json['id']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      nome: serializer.fromJson<String>(json['nome']),
      banca: serializer.fromJson<String>(json['banca']),
      dataProva: serializer.fromJson<DateTime?>(json['dataProva']),
      cor: serializer.fromJson<int>(json['cor']),
      foco: serializer.fromJson<bool>(json['foco']),
      exemplo: serializer.fromJson<bool>(json['exemplo']),
      ordem: serializer.fromJson<int>(json['ordem']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
      cicloMinutos: serializer.fromJson<int>(json['cicloMinutos']),
      cicloBlocoMin: serializer.fromJson<int>(json['cicloBlocoMin']),
      cicloPosicao: serializer.fromJson<int>(json['cicloPosicao']),
      cicloVoltas: serializer.fromJson<int>(json['cicloVoltas']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'atualizadoEm': serializer.toJson<DateTime>(atualizadoEm),
      'nome': serializer.toJson<String>(nome),
      'banca': serializer.toJson<String>(banca),
      'dataProva': serializer.toJson<DateTime?>(dataProva),
      'cor': serializer.toJson<int>(cor),
      'foco': serializer.toJson<bool>(foco),
      'exemplo': serializer.toJson<bool>(exemplo),
      'ordem': serializer.toJson<int>(ordem),
      'criadoEm': serializer.toJson<DateTime>(criadoEm),
      'cicloMinutos': serializer.toJson<int>(cicloMinutos),
      'cicloBlocoMin': serializer.toJson<int>(cicloBlocoMin),
      'cicloPosicao': serializer.toJson<int>(cicloPosicao),
      'cicloVoltas': serializer.toJson<int>(cicloVoltas),
    };
  }

  Concurso copyWith({
    String? id,
    DateTime? atualizadoEm,
    String? nome,
    String? banca,
    Value<DateTime?> dataProva = const Value.absent(),
    int? cor,
    bool? foco,
    bool? exemplo,
    int? ordem,
    DateTime? criadoEm,
    int? cicloMinutos,
    int? cicloBlocoMin,
    int? cicloPosicao,
    int? cicloVoltas,
  }) => Concurso(
    id: id ?? this.id,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    nome: nome ?? this.nome,
    banca: banca ?? this.banca,
    dataProva: dataProva.present ? dataProva.value : this.dataProva,
    cor: cor ?? this.cor,
    foco: foco ?? this.foco,
    exemplo: exemplo ?? this.exemplo,
    ordem: ordem ?? this.ordem,
    criadoEm: criadoEm ?? this.criadoEm,
    cicloMinutos: cicloMinutos ?? this.cicloMinutos,
    cicloBlocoMin: cicloBlocoMin ?? this.cicloBlocoMin,
    cicloPosicao: cicloPosicao ?? this.cicloPosicao,
    cicloVoltas: cicloVoltas ?? this.cicloVoltas,
  );
  Concurso copyWithCompanion(ConcursosCompanion data) {
    return Concurso(
      id: data.id.present ? data.id.value : this.id,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      nome: data.nome.present ? data.nome.value : this.nome,
      banca: data.banca.present ? data.banca.value : this.banca,
      dataProva: data.dataProva.present ? data.dataProva.value : this.dataProva,
      cor: data.cor.present ? data.cor.value : this.cor,
      foco: data.foco.present ? data.foco.value : this.foco,
      exemplo: data.exemplo.present ? data.exemplo.value : this.exemplo,
      ordem: data.ordem.present ? data.ordem.value : this.ordem,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
      cicloMinutos: data.cicloMinutos.present
          ? data.cicloMinutos.value
          : this.cicloMinutos,
      cicloBlocoMin: data.cicloBlocoMin.present
          ? data.cicloBlocoMin.value
          : this.cicloBlocoMin,
      cicloPosicao: data.cicloPosicao.present
          ? data.cicloPosicao.value
          : this.cicloPosicao,
      cicloVoltas: data.cicloVoltas.present
          ? data.cicloVoltas.value
          : this.cicloVoltas,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Concurso(')
          ..write('id: $id, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('nome: $nome, ')
          ..write('banca: $banca, ')
          ..write('dataProva: $dataProva, ')
          ..write('cor: $cor, ')
          ..write('foco: $foco, ')
          ..write('exemplo: $exemplo, ')
          ..write('ordem: $ordem, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('cicloMinutos: $cicloMinutos, ')
          ..write('cicloBlocoMin: $cicloBlocoMin, ')
          ..write('cicloPosicao: $cicloPosicao, ')
          ..write('cicloVoltas: $cicloVoltas')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    atualizadoEm,
    nome,
    banca,
    dataProva,
    cor,
    foco,
    exemplo,
    ordem,
    criadoEm,
    cicloMinutos,
    cicloBlocoMin,
    cicloPosicao,
    cicloVoltas,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Concurso &&
          other.id == this.id &&
          other.atualizadoEm == this.atualizadoEm &&
          other.nome == this.nome &&
          other.banca == this.banca &&
          other.dataProva == this.dataProva &&
          other.cor == this.cor &&
          other.foco == this.foco &&
          other.exemplo == this.exemplo &&
          other.ordem == this.ordem &&
          other.criadoEm == this.criadoEm &&
          other.cicloMinutos == this.cicloMinutos &&
          other.cicloBlocoMin == this.cicloBlocoMin &&
          other.cicloPosicao == this.cicloPosicao &&
          other.cicloVoltas == this.cicloVoltas);
}

class ConcursosCompanion extends UpdateCompanion<Concurso> {
  final Value<String> id;
  final Value<DateTime> atualizadoEm;
  final Value<String> nome;
  final Value<String> banca;
  final Value<DateTime?> dataProva;
  final Value<int> cor;
  final Value<bool> foco;
  final Value<bool> exemplo;
  final Value<int> ordem;
  final Value<DateTime> criadoEm;
  final Value<int> cicloMinutos;
  final Value<int> cicloBlocoMin;
  final Value<int> cicloPosicao;
  final Value<int> cicloVoltas;
  final Value<int> rowid;
  const ConcursosCompanion({
    this.id = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.nome = const Value.absent(),
    this.banca = const Value.absent(),
    this.dataProva = const Value.absent(),
    this.cor = const Value.absent(),
    this.foco = const Value.absent(),
    this.exemplo = const Value.absent(),
    this.ordem = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.cicloMinutos = const Value.absent(),
    this.cicloBlocoMin = const Value.absent(),
    this.cicloPosicao = const Value.absent(),
    this.cicloVoltas = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConcursosCompanion.insert({
    this.id = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    required String nome,
    this.banca = const Value.absent(),
    this.dataProva = const Value.absent(),
    required int cor,
    this.foco = const Value.absent(),
    this.exemplo = const Value.absent(),
    this.ordem = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.cicloMinutos = const Value.absent(),
    this.cicloBlocoMin = const Value.absent(),
    this.cicloPosicao = const Value.absent(),
    this.cicloVoltas = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : nome = Value(nome),
       cor = Value(cor);
  static Insertable<Concurso> custom({
    Expression<String>? id,
    Expression<DateTime>? atualizadoEm,
    Expression<String>? nome,
    Expression<String>? banca,
    Expression<DateTime>? dataProva,
    Expression<int>? cor,
    Expression<bool>? foco,
    Expression<bool>? exemplo,
    Expression<int>? ordem,
    Expression<DateTime>? criadoEm,
    Expression<int>? cicloMinutos,
    Expression<int>? cicloBlocoMin,
    Expression<int>? cicloPosicao,
    Expression<int>? cicloVoltas,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (nome != null) 'nome': nome,
      if (banca != null) 'banca': banca,
      if (dataProva != null) 'data_prova': dataProva,
      if (cor != null) 'cor': cor,
      if (foco != null) 'foco': foco,
      if (exemplo != null) 'exemplo': exemplo,
      if (ordem != null) 'ordem': ordem,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (cicloMinutos != null) 'ciclo_minutos': cicloMinutos,
      if (cicloBlocoMin != null) 'ciclo_bloco_min': cicloBlocoMin,
      if (cicloPosicao != null) 'ciclo_posicao': cicloPosicao,
      if (cicloVoltas != null) 'ciclo_voltas': cicloVoltas,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConcursosCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? atualizadoEm,
    Value<String>? nome,
    Value<String>? banca,
    Value<DateTime?>? dataProva,
    Value<int>? cor,
    Value<bool>? foco,
    Value<bool>? exemplo,
    Value<int>? ordem,
    Value<DateTime>? criadoEm,
    Value<int>? cicloMinutos,
    Value<int>? cicloBlocoMin,
    Value<int>? cicloPosicao,
    Value<int>? cicloVoltas,
    Value<int>? rowid,
  }) {
    return ConcursosCompanion(
      id: id ?? this.id,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      nome: nome ?? this.nome,
      banca: banca ?? this.banca,
      dataProva: dataProva ?? this.dataProva,
      cor: cor ?? this.cor,
      foco: foco ?? this.foco,
      exemplo: exemplo ?? this.exemplo,
      ordem: ordem ?? this.ordem,
      criadoEm: criadoEm ?? this.criadoEm,
      cicloMinutos: cicloMinutos ?? this.cicloMinutos,
      cicloBlocoMin: cicloBlocoMin ?? this.cicloBlocoMin,
      cicloPosicao: cicloPosicao ?? this.cicloPosicao,
      cicloVoltas: cicloVoltas ?? this.cicloVoltas,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (atualizadoEm.present) {
      map['atualizado_em'] = Variable<DateTime>(atualizadoEm.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (banca.present) {
      map['banca'] = Variable<String>(banca.value);
    }
    if (dataProva.present) {
      map['data_prova'] = Variable<DateTime>(dataProva.value);
    }
    if (cor.present) {
      map['cor'] = Variable<int>(cor.value);
    }
    if (foco.present) {
      map['foco'] = Variable<bool>(foco.value);
    }
    if (exemplo.present) {
      map['exemplo'] = Variable<bool>(exemplo.value);
    }
    if (ordem.present) {
      map['ordem'] = Variable<int>(ordem.value);
    }
    if (criadoEm.present) {
      map['criado_em'] = Variable<DateTime>(criadoEm.value);
    }
    if (cicloMinutos.present) {
      map['ciclo_minutos'] = Variable<int>(cicloMinutos.value);
    }
    if (cicloBlocoMin.present) {
      map['ciclo_bloco_min'] = Variable<int>(cicloBlocoMin.value);
    }
    if (cicloPosicao.present) {
      map['ciclo_posicao'] = Variable<int>(cicloPosicao.value);
    }
    if (cicloVoltas.present) {
      map['ciclo_voltas'] = Variable<int>(cicloVoltas.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConcursosCompanion(')
          ..write('id: $id, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('nome: $nome, ')
          ..write('banca: $banca, ')
          ..write('dataProva: $dataProva, ')
          ..write('cor: $cor, ')
          ..write('foco: $foco, ')
          ..write('exemplo: $exemplo, ')
          ..write('ordem: $ordem, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('cicloMinutos: $cicloMinutos, ')
          ..write('cicloBlocoMin: $cicloBlocoMin, ')
          ..write('cicloPosicao: $cicloPosicao, ')
          ..write('cicloVoltas: $cicloVoltas, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MateriasTable extends Materias with TableInfo<$MateriasTable, Materia> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MateriasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: novoId,
  );
  static const VerificationMeta _atualizadoEmMeta = const VerificationMeta(
    'atualizadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> atualizadoEm = GeneratedColumn<DateTime>(
    'atualizado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chaveMeta = const VerificationMeta('chave');
  @override
  late final GeneratedColumn<String> chave = GeneratedColumn<String>(
    'chave',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _corMeta = const VerificationMeta('cor');
  @override
  late final GeneratedColumn<int> cor = GeneratedColumn<int>(
    'cor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, atualizadoEm, nome, chave, cor];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'materias';
  @override
  VerificationContext validateIntegrity(
    Insertable<Materia> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('atualizado_em')) {
      context.handle(
        _atualizadoEmMeta,
        atualizadoEm.isAcceptableOrUnknown(
          data['atualizado_em']!,
          _atualizadoEmMeta,
        ),
      );
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('chave')) {
      context.handle(
        _chaveMeta,
        chave.isAcceptableOrUnknown(data['chave']!, _chaveMeta),
      );
    } else if (isInserting) {
      context.missing(_chaveMeta);
    }
    if (data.containsKey('cor')) {
      context.handle(
        _corMeta,
        cor.isAcceptableOrUnknown(data['cor']!, _corMeta),
      );
    } else if (isInserting) {
      context.missing(_corMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Materia map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Materia(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      atualizadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}atualizado_em'],
      )!,
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      chave: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chave'],
      )!,
      cor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cor'],
      )!,
    );
  }

  @override
  $MateriasTable createAlias(String alias) {
    return $MateriasTable(attachedDatabase, alias);
  }
}

class Materia extends DataClass implements Insertable<Materia> {
  final String id;
  final DateTime atualizadoEm;
  final String nome;
  final String chave;
  final int cor;
  const Materia({
    required this.id,
    required this.atualizadoEm,
    required this.nome,
    required this.chave,
    required this.cor,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['atualizado_em'] = Variable<DateTime>(atualizadoEm);
    map['nome'] = Variable<String>(nome);
    map['chave'] = Variable<String>(chave);
    map['cor'] = Variable<int>(cor);
    return map;
  }

  MateriasCompanion toCompanion(bool nullToAbsent) {
    return MateriasCompanion(
      id: Value(id),
      atualizadoEm: Value(atualizadoEm),
      nome: Value(nome),
      chave: Value(chave),
      cor: Value(cor),
    );
  }

  factory Materia.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Materia(
      id: serializer.fromJson<String>(json['id']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      nome: serializer.fromJson<String>(json['nome']),
      chave: serializer.fromJson<String>(json['chave']),
      cor: serializer.fromJson<int>(json['cor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'atualizadoEm': serializer.toJson<DateTime>(atualizadoEm),
      'nome': serializer.toJson<String>(nome),
      'chave': serializer.toJson<String>(chave),
      'cor': serializer.toJson<int>(cor),
    };
  }

  Materia copyWith({
    String? id,
    DateTime? atualizadoEm,
    String? nome,
    String? chave,
    int? cor,
  }) => Materia(
    id: id ?? this.id,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    nome: nome ?? this.nome,
    chave: chave ?? this.chave,
    cor: cor ?? this.cor,
  );
  Materia copyWithCompanion(MateriasCompanion data) {
    return Materia(
      id: data.id.present ? data.id.value : this.id,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      nome: data.nome.present ? data.nome.value : this.nome,
      chave: data.chave.present ? data.chave.value : this.chave,
      cor: data.cor.present ? data.cor.value : this.cor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Materia(')
          ..write('id: $id, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('nome: $nome, ')
          ..write('chave: $chave, ')
          ..write('cor: $cor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, atualizadoEm, nome, chave, cor);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Materia &&
          other.id == this.id &&
          other.atualizadoEm == this.atualizadoEm &&
          other.nome == this.nome &&
          other.chave == this.chave &&
          other.cor == this.cor);
}

class MateriasCompanion extends UpdateCompanion<Materia> {
  final Value<String> id;
  final Value<DateTime> atualizadoEm;
  final Value<String> nome;
  final Value<String> chave;
  final Value<int> cor;
  final Value<int> rowid;
  const MateriasCompanion({
    this.id = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.nome = const Value.absent(),
    this.chave = const Value.absent(),
    this.cor = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MateriasCompanion.insert({
    this.id = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    required String nome,
    required String chave,
    required int cor,
    this.rowid = const Value.absent(),
  }) : nome = Value(nome),
       chave = Value(chave),
       cor = Value(cor);
  static Insertable<Materia> custom({
    Expression<String>? id,
    Expression<DateTime>? atualizadoEm,
    Expression<String>? nome,
    Expression<String>? chave,
    Expression<int>? cor,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (nome != null) 'nome': nome,
      if (chave != null) 'chave': chave,
      if (cor != null) 'cor': cor,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MateriasCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? atualizadoEm,
    Value<String>? nome,
    Value<String>? chave,
    Value<int>? cor,
    Value<int>? rowid,
  }) {
    return MateriasCompanion(
      id: id ?? this.id,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      nome: nome ?? this.nome,
      chave: chave ?? this.chave,
      cor: cor ?? this.cor,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (atualizadoEm.present) {
      map['atualizado_em'] = Variable<DateTime>(atualizadoEm.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (chave.present) {
      map['chave'] = Variable<String>(chave.value);
    }
    if (cor.present) {
      map['cor'] = Variable<int>(cor.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MateriasCompanion(')
          ..write('id: $id, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('nome: $nome, ')
          ..write('chave: $chave, ')
          ..write('cor: $cor, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConcursoMateriasTable extends ConcursoMaterias
    with TableInfo<$ConcursoMateriasTable, ConcursoMateria> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConcursoMateriasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _concursoIdMeta = const VerificationMeta(
    'concursoId',
  );
  @override
  late final GeneratedColumn<String> concursoId = GeneratedColumn<String>(
    'concurso_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES concursos (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _materiaIdMeta = const VerificationMeta(
    'materiaId',
  );
  @override
  late final GeneratedColumn<String> materiaId = GeneratedColumn<String>(
    'materia_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES materias (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _ordemMeta = const VerificationMeta('ordem');
  @override
  late final GeneratedColumn<int> ordem = GeneratedColumn<int>(
    'ordem',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _atualizadoEmMeta = const VerificationMeta(
    'atualizadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> atualizadoEm = GeneratedColumn<DateTime>(
    'atualizado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _pesoMeta = const VerificationMeta('peso');
  @override
  late final GeneratedColumn<int> peso = GeneratedColumn<int>(
    'peso',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _dificuldadeMeta = const VerificationMeta(
    'dificuldade',
  );
  @override
  late final GeneratedColumn<int> dificuldade = GeneratedColumn<int>(
    'dificuldade',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _noCicloMeta = const VerificationMeta(
    'noCiclo',
  );
  @override
  late final GeneratedColumn<bool> noCiclo = GeneratedColumn<bool>(
    'no_ciclo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("no_ciclo" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    concursoId,
    materiaId,
    ordem,
    atualizadoEm,
    peso,
    dificuldade,
    noCiclo,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'concurso_materias';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConcursoMateria> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('concurso_id')) {
      context.handle(
        _concursoIdMeta,
        concursoId.isAcceptableOrUnknown(data['concurso_id']!, _concursoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_concursoIdMeta);
    }
    if (data.containsKey('materia_id')) {
      context.handle(
        _materiaIdMeta,
        materiaId.isAcceptableOrUnknown(data['materia_id']!, _materiaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_materiaIdMeta);
    }
    if (data.containsKey('ordem')) {
      context.handle(
        _ordemMeta,
        ordem.isAcceptableOrUnknown(data['ordem']!, _ordemMeta),
      );
    }
    if (data.containsKey('atualizado_em')) {
      context.handle(
        _atualizadoEmMeta,
        atualizadoEm.isAcceptableOrUnknown(
          data['atualizado_em']!,
          _atualizadoEmMeta,
        ),
      );
    }
    if (data.containsKey('peso')) {
      context.handle(
        _pesoMeta,
        peso.isAcceptableOrUnknown(data['peso']!, _pesoMeta),
      );
    }
    if (data.containsKey('dificuldade')) {
      context.handle(
        _dificuldadeMeta,
        dificuldade.isAcceptableOrUnknown(
          data['dificuldade']!,
          _dificuldadeMeta,
        ),
      );
    }
    if (data.containsKey('no_ciclo')) {
      context.handle(
        _noCicloMeta,
        noCiclo.isAcceptableOrUnknown(data['no_ciclo']!, _noCicloMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {concursoId, materiaId};
  @override
  ConcursoMateria map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConcursoMateria(
      concursoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}concurso_id'],
      )!,
      materiaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}materia_id'],
      )!,
      ordem: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordem'],
      )!,
      atualizadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}atualizado_em'],
      )!,
      peso: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}peso'],
      )!,
      dificuldade: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dificuldade'],
      )!,
      noCiclo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}no_ciclo'],
      )!,
    );
  }

  @override
  $ConcursoMateriasTable createAlias(String alias) {
    return $ConcursoMateriasTable(attachedDatabase, alias);
  }
}

class ConcursoMateria extends DataClass implements Insertable<ConcursoMateria> {
  final String concursoId;
  final String materiaId;
  final int ordem;
  final DateTime atualizadoEm;
  final int peso;
  final int dificuldade;
  final bool noCiclo;
  const ConcursoMateria({
    required this.concursoId,
    required this.materiaId,
    required this.ordem,
    required this.atualizadoEm,
    required this.peso,
    required this.dificuldade,
    required this.noCiclo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['concurso_id'] = Variable<String>(concursoId);
    map['materia_id'] = Variable<String>(materiaId);
    map['ordem'] = Variable<int>(ordem);
    map['atualizado_em'] = Variable<DateTime>(atualizadoEm);
    map['peso'] = Variable<int>(peso);
    map['dificuldade'] = Variable<int>(dificuldade);
    map['no_ciclo'] = Variable<bool>(noCiclo);
    return map;
  }

  ConcursoMateriasCompanion toCompanion(bool nullToAbsent) {
    return ConcursoMateriasCompanion(
      concursoId: Value(concursoId),
      materiaId: Value(materiaId),
      ordem: Value(ordem),
      atualizadoEm: Value(atualizadoEm),
      peso: Value(peso),
      dificuldade: Value(dificuldade),
      noCiclo: Value(noCiclo),
    );
  }

  factory ConcursoMateria.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConcursoMateria(
      concursoId: serializer.fromJson<String>(json['concursoId']),
      materiaId: serializer.fromJson<String>(json['materiaId']),
      ordem: serializer.fromJson<int>(json['ordem']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      peso: serializer.fromJson<int>(json['peso']),
      dificuldade: serializer.fromJson<int>(json['dificuldade']),
      noCiclo: serializer.fromJson<bool>(json['noCiclo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'concursoId': serializer.toJson<String>(concursoId),
      'materiaId': serializer.toJson<String>(materiaId),
      'ordem': serializer.toJson<int>(ordem),
      'atualizadoEm': serializer.toJson<DateTime>(atualizadoEm),
      'peso': serializer.toJson<int>(peso),
      'dificuldade': serializer.toJson<int>(dificuldade),
      'noCiclo': serializer.toJson<bool>(noCiclo),
    };
  }

  ConcursoMateria copyWith({
    String? concursoId,
    String? materiaId,
    int? ordem,
    DateTime? atualizadoEm,
    int? peso,
    int? dificuldade,
    bool? noCiclo,
  }) => ConcursoMateria(
    concursoId: concursoId ?? this.concursoId,
    materiaId: materiaId ?? this.materiaId,
    ordem: ordem ?? this.ordem,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    peso: peso ?? this.peso,
    dificuldade: dificuldade ?? this.dificuldade,
    noCiclo: noCiclo ?? this.noCiclo,
  );
  ConcursoMateria copyWithCompanion(ConcursoMateriasCompanion data) {
    return ConcursoMateria(
      concursoId: data.concursoId.present
          ? data.concursoId.value
          : this.concursoId,
      materiaId: data.materiaId.present ? data.materiaId.value : this.materiaId,
      ordem: data.ordem.present ? data.ordem.value : this.ordem,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      peso: data.peso.present ? data.peso.value : this.peso,
      dificuldade: data.dificuldade.present
          ? data.dificuldade.value
          : this.dificuldade,
      noCiclo: data.noCiclo.present ? data.noCiclo.value : this.noCiclo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConcursoMateria(')
          ..write('concursoId: $concursoId, ')
          ..write('materiaId: $materiaId, ')
          ..write('ordem: $ordem, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('peso: $peso, ')
          ..write('dificuldade: $dificuldade, ')
          ..write('noCiclo: $noCiclo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    concursoId,
    materiaId,
    ordem,
    atualizadoEm,
    peso,
    dificuldade,
    noCiclo,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConcursoMateria &&
          other.concursoId == this.concursoId &&
          other.materiaId == this.materiaId &&
          other.ordem == this.ordem &&
          other.atualizadoEm == this.atualizadoEm &&
          other.peso == this.peso &&
          other.dificuldade == this.dificuldade &&
          other.noCiclo == this.noCiclo);
}

class ConcursoMateriasCompanion extends UpdateCompanion<ConcursoMateria> {
  final Value<String> concursoId;
  final Value<String> materiaId;
  final Value<int> ordem;
  final Value<DateTime> atualizadoEm;
  final Value<int> peso;
  final Value<int> dificuldade;
  final Value<bool> noCiclo;
  final Value<int> rowid;
  const ConcursoMateriasCompanion({
    this.concursoId = const Value.absent(),
    this.materiaId = const Value.absent(),
    this.ordem = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.peso = const Value.absent(),
    this.dificuldade = const Value.absent(),
    this.noCiclo = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConcursoMateriasCompanion.insert({
    required String concursoId,
    required String materiaId,
    this.ordem = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.peso = const Value.absent(),
    this.dificuldade = const Value.absent(),
    this.noCiclo = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : concursoId = Value(concursoId),
       materiaId = Value(materiaId);
  static Insertable<ConcursoMateria> custom({
    Expression<String>? concursoId,
    Expression<String>? materiaId,
    Expression<int>? ordem,
    Expression<DateTime>? atualizadoEm,
    Expression<int>? peso,
    Expression<int>? dificuldade,
    Expression<bool>? noCiclo,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (concursoId != null) 'concurso_id': concursoId,
      if (materiaId != null) 'materia_id': materiaId,
      if (ordem != null) 'ordem': ordem,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (peso != null) 'peso': peso,
      if (dificuldade != null) 'dificuldade': dificuldade,
      if (noCiclo != null) 'no_ciclo': noCiclo,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConcursoMateriasCompanion copyWith({
    Value<String>? concursoId,
    Value<String>? materiaId,
    Value<int>? ordem,
    Value<DateTime>? atualizadoEm,
    Value<int>? peso,
    Value<int>? dificuldade,
    Value<bool>? noCiclo,
    Value<int>? rowid,
  }) {
    return ConcursoMateriasCompanion(
      concursoId: concursoId ?? this.concursoId,
      materiaId: materiaId ?? this.materiaId,
      ordem: ordem ?? this.ordem,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      peso: peso ?? this.peso,
      dificuldade: dificuldade ?? this.dificuldade,
      noCiclo: noCiclo ?? this.noCiclo,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (concursoId.present) {
      map['concurso_id'] = Variable<String>(concursoId.value);
    }
    if (materiaId.present) {
      map['materia_id'] = Variable<String>(materiaId.value);
    }
    if (ordem.present) {
      map['ordem'] = Variable<int>(ordem.value);
    }
    if (atualizadoEm.present) {
      map['atualizado_em'] = Variable<DateTime>(atualizadoEm.value);
    }
    if (peso.present) {
      map['peso'] = Variable<int>(peso.value);
    }
    if (dificuldade.present) {
      map['dificuldade'] = Variable<int>(dificuldade.value);
    }
    if (noCiclo.present) {
      map['no_ciclo'] = Variable<bool>(noCiclo.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConcursoMateriasCompanion(')
          ..write('concursoId: $concursoId, ')
          ..write('materiaId: $materiaId, ')
          ..write('ordem: $ordem, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('peso: $peso, ')
          ..write('dificuldade: $dificuldade, ')
          ..write('noCiclo: $noCiclo, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TopicosTable extends Topicos with TableInfo<$TopicosTable, Topico> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TopicosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: novoId,
  );
  static const VerificationMeta _atualizadoEmMeta = const VerificationMeta(
    'atualizadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> atualizadoEm = GeneratedColumn<DateTime>(
    'atualizado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _materiaIdMeta = const VerificationMeta(
    'materiaId',
  );
  @override
  late final GeneratedColumn<String> materiaId = GeneratedColumn<String>(
    'materia_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES materias (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _paiIdMeta = const VerificationMeta('paiId');
  @override
  late final GeneratedColumn<String> paiId = GeneratedColumn<String>(
    'pai_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES topicos (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ordemMeta = const VerificationMeta('ordem');
  @override
  late final GeneratedColumn<int> ordem = GeneratedColumn<int>(
    'ordem',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _vistoMeta = const VerificationMeta('visto');
  @override
  late final GeneratedColumn<bool> visto = GeneratedColumn<bool>(
    'visto',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("visto" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _vistoEmMeta = const VerificationMeta(
    'vistoEm',
  );
  @override
  late final GeneratedColumn<DateTime> vistoEm = GeneratedColumn<DateTime>(
    'visto_em',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    atualizadoEm,
    materiaId,
    paiId,
    nome,
    ordem,
    visto,
    vistoEm,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'topicos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Topico> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('atualizado_em')) {
      context.handle(
        _atualizadoEmMeta,
        atualizadoEm.isAcceptableOrUnknown(
          data['atualizado_em']!,
          _atualizadoEmMeta,
        ),
      );
    }
    if (data.containsKey('materia_id')) {
      context.handle(
        _materiaIdMeta,
        materiaId.isAcceptableOrUnknown(data['materia_id']!, _materiaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_materiaIdMeta);
    }
    if (data.containsKey('pai_id')) {
      context.handle(
        _paiIdMeta,
        paiId.isAcceptableOrUnknown(data['pai_id']!, _paiIdMeta),
      );
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('ordem')) {
      context.handle(
        _ordemMeta,
        ordem.isAcceptableOrUnknown(data['ordem']!, _ordemMeta),
      );
    }
    if (data.containsKey('visto')) {
      context.handle(
        _vistoMeta,
        visto.isAcceptableOrUnknown(data['visto']!, _vistoMeta),
      );
    }
    if (data.containsKey('visto_em')) {
      context.handle(
        _vistoEmMeta,
        vistoEm.isAcceptableOrUnknown(data['visto_em']!, _vistoEmMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Topico map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Topico(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      atualizadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}atualizado_em'],
      )!,
      materiaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}materia_id'],
      )!,
      paiId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pai_id'],
      ),
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      ordem: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordem'],
      )!,
      visto: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}visto'],
      )!,
      vistoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}visto_em'],
      ),
    );
  }

  @override
  $TopicosTable createAlias(String alias) {
    return $TopicosTable(attachedDatabase, alias);
  }
}

class Topico extends DataClass implements Insertable<Topico> {
  final String id;
  final DateTime atualizadoEm;
  final String materiaId;
  final String? paiId;
  final String nome;
  final int ordem;
  final bool visto;
  final DateTime? vistoEm;
  const Topico({
    required this.id,
    required this.atualizadoEm,
    required this.materiaId,
    this.paiId,
    required this.nome,
    required this.ordem,
    required this.visto,
    this.vistoEm,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['atualizado_em'] = Variable<DateTime>(atualizadoEm);
    map['materia_id'] = Variable<String>(materiaId);
    if (!nullToAbsent || paiId != null) {
      map['pai_id'] = Variable<String>(paiId);
    }
    map['nome'] = Variable<String>(nome);
    map['ordem'] = Variable<int>(ordem);
    map['visto'] = Variable<bool>(visto);
    if (!nullToAbsent || vistoEm != null) {
      map['visto_em'] = Variable<DateTime>(vistoEm);
    }
    return map;
  }

  TopicosCompanion toCompanion(bool nullToAbsent) {
    return TopicosCompanion(
      id: Value(id),
      atualizadoEm: Value(atualizadoEm),
      materiaId: Value(materiaId),
      paiId: paiId == null && nullToAbsent
          ? const Value.absent()
          : Value(paiId),
      nome: Value(nome),
      ordem: Value(ordem),
      visto: Value(visto),
      vistoEm: vistoEm == null && nullToAbsent
          ? const Value.absent()
          : Value(vistoEm),
    );
  }

  factory Topico.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Topico(
      id: serializer.fromJson<String>(json['id']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      materiaId: serializer.fromJson<String>(json['materiaId']),
      paiId: serializer.fromJson<String?>(json['paiId']),
      nome: serializer.fromJson<String>(json['nome']),
      ordem: serializer.fromJson<int>(json['ordem']),
      visto: serializer.fromJson<bool>(json['visto']),
      vistoEm: serializer.fromJson<DateTime?>(json['vistoEm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'atualizadoEm': serializer.toJson<DateTime>(atualizadoEm),
      'materiaId': serializer.toJson<String>(materiaId),
      'paiId': serializer.toJson<String?>(paiId),
      'nome': serializer.toJson<String>(nome),
      'ordem': serializer.toJson<int>(ordem),
      'visto': serializer.toJson<bool>(visto),
      'vistoEm': serializer.toJson<DateTime?>(vistoEm),
    };
  }

  Topico copyWith({
    String? id,
    DateTime? atualizadoEm,
    String? materiaId,
    Value<String?> paiId = const Value.absent(),
    String? nome,
    int? ordem,
    bool? visto,
    Value<DateTime?> vistoEm = const Value.absent(),
  }) => Topico(
    id: id ?? this.id,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    materiaId: materiaId ?? this.materiaId,
    paiId: paiId.present ? paiId.value : this.paiId,
    nome: nome ?? this.nome,
    ordem: ordem ?? this.ordem,
    visto: visto ?? this.visto,
    vistoEm: vistoEm.present ? vistoEm.value : this.vistoEm,
  );
  Topico copyWithCompanion(TopicosCompanion data) {
    return Topico(
      id: data.id.present ? data.id.value : this.id,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      materiaId: data.materiaId.present ? data.materiaId.value : this.materiaId,
      paiId: data.paiId.present ? data.paiId.value : this.paiId,
      nome: data.nome.present ? data.nome.value : this.nome,
      ordem: data.ordem.present ? data.ordem.value : this.ordem,
      visto: data.visto.present ? data.visto.value : this.visto,
      vistoEm: data.vistoEm.present ? data.vistoEm.value : this.vistoEm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Topico(')
          ..write('id: $id, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('materiaId: $materiaId, ')
          ..write('paiId: $paiId, ')
          ..write('nome: $nome, ')
          ..write('ordem: $ordem, ')
          ..write('visto: $visto, ')
          ..write('vistoEm: $vistoEm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    atualizadoEm,
    materiaId,
    paiId,
    nome,
    ordem,
    visto,
    vistoEm,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Topico &&
          other.id == this.id &&
          other.atualizadoEm == this.atualizadoEm &&
          other.materiaId == this.materiaId &&
          other.paiId == this.paiId &&
          other.nome == this.nome &&
          other.ordem == this.ordem &&
          other.visto == this.visto &&
          other.vistoEm == this.vistoEm);
}

class TopicosCompanion extends UpdateCompanion<Topico> {
  final Value<String> id;
  final Value<DateTime> atualizadoEm;
  final Value<String> materiaId;
  final Value<String?> paiId;
  final Value<String> nome;
  final Value<int> ordem;
  final Value<bool> visto;
  final Value<DateTime?> vistoEm;
  final Value<int> rowid;
  const TopicosCompanion({
    this.id = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.materiaId = const Value.absent(),
    this.paiId = const Value.absent(),
    this.nome = const Value.absent(),
    this.ordem = const Value.absent(),
    this.visto = const Value.absent(),
    this.vistoEm = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TopicosCompanion.insert({
    this.id = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    required String materiaId,
    this.paiId = const Value.absent(),
    required String nome,
    this.ordem = const Value.absent(),
    this.visto = const Value.absent(),
    this.vistoEm = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : materiaId = Value(materiaId),
       nome = Value(nome);
  static Insertable<Topico> custom({
    Expression<String>? id,
    Expression<DateTime>? atualizadoEm,
    Expression<String>? materiaId,
    Expression<String>? paiId,
    Expression<String>? nome,
    Expression<int>? ordem,
    Expression<bool>? visto,
    Expression<DateTime>? vistoEm,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (materiaId != null) 'materia_id': materiaId,
      if (paiId != null) 'pai_id': paiId,
      if (nome != null) 'nome': nome,
      if (ordem != null) 'ordem': ordem,
      if (visto != null) 'visto': visto,
      if (vistoEm != null) 'visto_em': vistoEm,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TopicosCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? atualizadoEm,
    Value<String>? materiaId,
    Value<String?>? paiId,
    Value<String>? nome,
    Value<int>? ordem,
    Value<bool>? visto,
    Value<DateTime?>? vistoEm,
    Value<int>? rowid,
  }) {
    return TopicosCompanion(
      id: id ?? this.id,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      materiaId: materiaId ?? this.materiaId,
      paiId: paiId ?? this.paiId,
      nome: nome ?? this.nome,
      ordem: ordem ?? this.ordem,
      visto: visto ?? this.visto,
      vistoEm: vistoEm ?? this.vistoEm,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (atualizadoEm.present) {
      map['atualizado_em'] = Variable<DateTime>(atualizadoEm.value);
    }
    if (materiaId.present) {
      map['materia_id'] = Variable<String>(materiaId.value);
    }
    if (paiId.present) {
      map['pai_id'] = Variable<String>(paiId.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (ordem.present) {
      map['ordem'] = Variable<int>(ordem.value);
    }
    if (visto.present) {
      map['visto'] = Variable<bool>(visto.value);
    }
    if (vistoEm.present) {
      map['visto_em'] = Variable<DateTime>(vistoEm.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TopicosCompanion(')
          ..write('id: $id, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('materiaId: $materiaId, ')
          ..write('paiId: $paiId, ')
          ..write('nome: $nome, ')
          ..write('ordem: $ordem, ')
          ..write('visto: $visto, ')
          ..write('vistoEm: $vistoEm, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RevisoesTable extends Revisoes with TableInfo<$RevisoesTable, Revisao> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RevisoesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: novoId,
  );
  static const VerificationMeta _atualizadoEmMeta = const VerificationMeta(
    'atualizadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> atualizadoEm = GeneratedColumn<DateTime>(
    'atualizado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _topicoIdMeta = const VerificationMeta(
    'topicoId',
  );
  @override
  late final GeneratedColumn<String> topicoId = GeneratedColumn<String>(
    'topico_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES topicos (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _dataPrevistaMeta = const VerificationMeta(
    'dataPrevista',
  );
  @override
  late final GeneratedColumn<DateTime> dataPrevista = GeneratedColumn<DateTime>(
    'data_prevista',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intervaloDiasMeta = const VerificationMeta(
    'intervaloDias',
  );
  @override
  late final GeneratedColumn<int> intervaloDias = GeneratedColumn<int>(
    'intervalo_dias',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _feitaEmMeta = const VerificationMeta(
    'feitaEm',
  );
  @override
  late final GeneratedColumn<DateTime> feitaEm = GeneratedColumn<DateTime>(
    'feita_em',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    atualizadoEm,
    topicoId,
    dataPrevista,
    intervaloDias,
    feitaEm,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'revisoes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Revisao> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('atualizado_em')) {
      context.handle(
        _atualizadoEmMeta,
        atualizadoEm.isAcceptableOrUnknown(
          data['atualizado_em']!,
          _atualizadoEmMeta,
        ),
      );
    }
    if (data.containsKey('topico_id')) {
      context.handle(
        _topicoIdMeta,
        topicoId.isAcceptableOrUnknown(data['topico_id']!, _topicoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_topicoIdMeta);
    }
    if (data.containsKey('data_prevista')) {
      context.handle(
        _dataPrevistaMeta,
        dataPrevista.isAcceptableOrUnknown(
          data['data_prevista']!,
          _dataPrevistaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dataPrevistaMeta);
    }
    if (data.containsKey('intervalo_dias')) {
      context.handle(
        _intervaloDiasMeta,
        intervaloDias.isAcceptableOrUnknown(
          data['intervalo_dias']!,
          _intervaloDiasMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_intervaloDiasMeta);
    }
    if (data.containsKey('feita_em')) {
      context.handle(
        _feitaEmMeta,
        feitaEm.isAcceptableOrUnknown(data['feita_em']!, _feitaEmMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Revisao map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Revisao(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      atualizadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}atualizado_em'],
      )!,
      topicoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topico_id'],
      )!,
      dataPrevista: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data_prevista'],
      )!,
      intervaloDias: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}intervalo_dias'],
      )!,
      feitaEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}feita_em'],
      ),
    );
  }

  @override
  $RevisoesTable createAlias(String alias) {
    return $RevisoesTable(attachedDatabase, alias);
  }
}

class Revisao extends DataClass implements Insertable<Revisao> {
  final String id;
  final DateTime atualizadoEm;
  final String topicoId;
  final DateTime dataPrevista;
  final int intervaloDias;
  final DateTime? feitaEm;
  const Revisao({
    required this.id,
    required this.atualizadoEm,
    required this.topicoId,
    required this.dataPrevista,
    required this.intervaloDias,
    this.feitaEm,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['atualizado_em'] = Variable<DateTime>(atualizadoEm);
    map['topico_id'] = Variable<String>(topicoId);
    map['data_prevista'] = Variable<DateTime>(dataPrevista);
    map['intervalo_dias'] = Variable<int>(intervaloDias);
    if (!nullToAbsent || feitaEm != null) {
      map['feita_em'] = Variable<DateTime>(feitaEm);
    }
    return map;
  }

  RevisoesCompanion toCompanion(bool nullToAbsent) {
    return RevisoesCompanion(
      id: Value(id),
      atualizadoEm: Value(atualizadoEm),
      topicoId: Value(topicoId),
      dataPrevista: Value(dataPrevista),
      intervaloDias: Value(intervaloDias),
      feitaEm: feitaEm == null && nullToAbsent
          ? const Value.absent()
          : Value(feitaEm),
    );
  }

  factory Revisao.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Revisao(
      id: serializer.fromJson<String>(json['id']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      topicoId: serializer.fromJson<String>(json['topicoId']),
      dataPrevista: serializer.fromJson<DateTime>(json['dataPrevista']),
      intervaloDias: serializer.fromJson<int>(json['intervaloDias']),
      feitaEm: serializer.fromJson<DateTime?>(json['feitaEm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'atualizadoEm': serializer.toJson<DateTime>(atualizadoEm),
      'topicoId': serializer.toJson<String>(topicoId),
      'dataPrevista': serializer.toJson<DateTime>(dataPrevista),
      'intervaloDias': serializer.toJson<int>(intervaloDias),
      'feitaEm': serializer.toJson<DateTime?>(feitaEm),
    };
  }

  Revisao copyWith({
    String? id,
    DateTime? atualizadoEm,
    String? topicoId,
    DateTime? dataPrevista,
    int? intervaloDias,
    Value<DateTime?> feitaEm = const Value.absent(),
  }) => Revisao(
    id: id ?? this.id,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    topicoId: topicoId ?? this.topicoId,
    dataPrevista: dataPrevista ?? this.dataPrevista,
    intervaloDias: intervaloDias ?? this.intervaloDias,
    feitaEm: feitaEm.present ? feitaEm.value : this.feitaEm,
  );
  Revisao copyWithCompanion(RevisoesCompanion data) {
    return Revisao(
      id: data.id.present ? data.id.value : this.id,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      topicoId: data.topicoId.present ? data.topicoId.value : this.topicoId,
      dataPrevista: data.dataPrevista.present
          ? data.dataPrevista.value
          : this.dataPrevista,
      intervaloDias: data.intervaloDias.present
          ? data.intervaloDias.value
          : this.intervaloDias,
      feitaEm: data.feitaEm.present ? data.feitaEm.value : this.feitaEm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Revisao(')
          ..write('id: $id, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('topicoId: $topicoId, ')
          ..write('dataPrevista: $dataPrevista, ')
          ..write('intervaloDias: $intervaloDias, ')
          ..write('feitaEm: $feitaEm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    atualizadoEm,
    topicoId,
    dataPrevista,
    intervaloDias,
    feitaEm,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Revisao &&
          other.id == this.id &&
          other.atualizadoEm == this.atualizadoEm &&
          other.topicoId == this.topicoId &&
          other.dataPrevista == this.dataPrevista &&
          other.intervaloDias == this.intervaloDias &&
          other.feitaEm == this.feitaEm);
}

class RevisoesCompanion extends UpdateCompanion<Revisao> {
  final Value<String> id;
  final Value<DateTime> atualizadoEm;
  final Value<String> topicoId;
  final Value<DateTime> dataPrevista;
  final Value<int> intervaloDias;
  final Value<DateTime?> feitaEm;
  final Value<int> rowid;
  const RevisoesCompanion({
    this.id = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.topicoId = const Value.absent(),
    this.dataPrevista = const Value.absent(),
    this.intervaloDias = const Value.absent(),
    this.feitaEm = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RevisoesCompanion.insert({
    this.id = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    required String topicoId,
    required DateTime dataPrevista,
    required int intervaloDias,
    this.feitaEm = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : topicoId = Value(topicoId),
       dataPrevista = Value(dataPrevista),
       intervaloDias = Value(intervaloDias);
  static Insertable<Revisao> custom({
    Expression<String>? id,
    Expression<DateTime>? atualizadoEm,
    Expression<String>? topicoId,
    Expression<DateTime>? dataPrevista,
    Expression<int>? intervaloDias,
    Expression<DateTime>? feitaEm,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (topicoId != null) 'topico_id': topicoId,
      if (dataPrevista != null) 'data_prevista': dataPrevista,
      if (intervaloDias != null) 'intervalo_dias': intervaloDias,
      if (feitaEm != null) 'feita_em': feitaEm,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RevisoesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? atualizadoEm,
    Value<String>? topicoId,
    Value<DateTime>? dataPrevista,
    Value<int>? intervaloDias,
    Value<DateTime?>? feitaEm,
    Value<int>? rowid,
  }) {
    return RevisoesCompanion(
      id: id ?? this.id,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      topicoId: topicoId ?? this.topicoId,
      dataPrevista: dataPrevista ?? this.dataPrevista,
      intervaloDias: intervaloDias ?? this.intervaloDias,
      feitaEm: feitaEm ?? this.feitaEm,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (atualizadoEm.present) {
      map['atualizado_em'] = Variable<DateTime>(atualizadoEm.value);
    }
    if (topicoId.present) {
      map['topico_id'] = Variable<String>(topicoId.value);
    }
    if (dataPrevista.present) {
      map['data_prevista'] = Variable<DateTime>(dataPrevista.value);
    }
    if (intervaloDias.present) {
      map['intervalo_dias'] = Variable<int>(intervaloDias.value);
    }
    if (feitaEm.present) {
      map['feita_em'] = Variable<DateTime>(feitaEm.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RevisoesCompanion(')
          ..write('id: $id, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('topicoId: $topicoId, ')
          ..write('dataPrevista: $dataPrevista, ')
          ..write('intervaloDias: $intervaloDias, ')
          ..write('feitaEm: $feitaEm, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuestoesTable extends Questoes
    with TableInfo<$QuestoesTable, RegistroQuestoes> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuestoesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: novoId,
  );
  static const VerificationMeta _atualizadoEmMeta = const VerificationMeta(
    'atualizadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> atualizadoEm = GeneratedColumn<DateTime>(
    'atualizado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _materiaIdMeta = const VerificationMeta(
    'materiaId',
  );
  @override
  late final GeneratedColumn<String> materiaId = GeneratedColumn<String>(
    'materia_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES materias (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<DateTime> data = GeneratedColumn<DateTime>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _feitasMeta = const VerificationMeta('feitas');
  @override
  late final GeneratedColumn<int> feitas = GeneratedColumn<int>(
    'feitas',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _acertosMeta = const VerificationMeta(
    'acertos',
  );
  @override
  late final GeneratedColumn<int> acertos = GeneratedColumn<int>(
    'acertos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    atualizadoEm,
    materiaId,
    data,
    feitas,
    acertos,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'questoes';
  @override
  VerificationContext validateIntegrity(
    Insertable<RegistroQuestoes> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('atualizado_em')) {
      context.handle(
        _atualizadoEmMeta,
        atualizadoEm.isAcceptableOrUnknown(
          data['atualizado_em']!,
          _atualizadoEmMeta,
        ),
      );
    }
    if (data.containsKey('materia_id')) {
      context.handle(
        _materiaIdMeta,
        materiaId.isAcceptableOrUnknown(data['materia_id']!, _materiaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_materiaIdMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('feitas')) {
      context.handle(
        _feitasMeta,
        feitas.isAcceptableOrUnknown(data['feitas']!, _feitasMeta),
      );
    } else if (isInserting) {
      context.missing(_feitasMeta);
    }
    if (data.containsKey('acertos')) {
      context.handle(
        _acertosMeta,
        acertos.isAcceptableOrUnknown(data['acertos']!, _acertosMeta),
      );
    } else if (isInserting) {
      context.missing(_acertosMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RegistroQuestoes map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RegistroQuestoes(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      atualizadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}atualizado_em'],
      )!,
      materiaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}materia_id'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data'],
      )!,
      feitas: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}feitas'],
      )!,
      acertos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}acertos'],
      )!,
    );
  }

  @override
  $QuestoesTable createAlias(String alias) {
    return $QuestoesTable(attachedDatabase, alias);
  }
}

class RegistroQuestoes extends DataClass
    implements Insertable<RegistroQuestoes> {
  final String id;
  final DateTime atualizadoEm;
  final String materiaId;
  final DateTime data;
  final int feitas;
  final int acertos;
  const RegistroQuestoes({
    required this.id,
    required this.atualizadoEm,
    required this.materiaId,
    required this.data,
    required this.feitas,
    required this.acertos,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['atualizado_em'] = Variable<DateTime>(atualizadoEm);
    map['materia_id'] = Variable<String>(materiaId);
    map['data'] = Variable<DateTime>(data);
    map['feitas'] = Variable<int>(feitas);
    map['acertos'] = Variable<int>(acertos);
    return map;
  }

  QuestoesCompanion toCompanion(bool nullToAbsent) {
    return QuestoesCompanion(
      id: Value(id),
      atualizadoEm: Value(atualizadoEm),
      materiaId: Value(materiaId),
      data: Value(data),
      feitas: Value(feitas),
      acertos: Value(acertos),
    );
  }

  factory RegistroQuestoes.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RegistroQuestoes(
      id: serializer.fromJson<String>(json['id']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      materiaId: serializer.fromJson<String>(json['materiaId']),
      data: serializer.fromJson<DateTime>(json['data']),
      feitas: serializer.fromJson<int>(json['feitas']),
      acertos: serializer.fromJson<int>(json['acertos']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'atualizadoEm': serializer.toJson<DateTime>(atualizadoEm),
      'materiaId': serializer.toJson<String>(materiaId),
      'data': serializer.toJson<DateTime>(data),
      'feitas': serializer.toJson<int>(feitas),
      'acertos': serializer.toJson<int>(acertos),
    };
  }

  RegistroQuestoes copyWith({
    String? id,
    DateTime? atualizadoEm,
    String? materiaId,
    DateTime? data,
    int? feitas,
    int? acertos,
  }) => RegistroQuestoes(
    id: id ?? this.id,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    materiaId: materiaId ?? this.materiaId,
    data: data ?? this.data,
    feitas: feitas ?? this.feitas,
    acertos: acertos ?? this.acertos,
  );
  RegistroQuestoes copyWithCompanion(QuestoesCompanion data) {
    return RegistroQuestoes(
      id: data.id.present ? data.id.value : this.id,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      materiaId: data.materiaId.present ? data.materiaId.value : this.materiaId,
      data: data.data.present ? data.data.value : this.data,
      feitas: data.feitas.present ? data.feitas.value : this.feitas,
      acertos: data.acertos.present ? data.acertos.value : this.acertos,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RegistroQuestoes(')
          ..write('id: $id, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('materiaId: $materiaId, ')
          ..write('data: $data, ')
          ..write('feitas: $feitas, ')
          ..write('acertos: $acertos')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, atualizadoEm, materiaId, data, feitas, acertos);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RegistroQuestoes &&
          other.id == this.id &&
          other.atualizadoEm == this.atualizadoEm &&
          other.materiaId == this.materiaId &&
          other.data == this.data &&
          other.feitas == this.feitas &&
          other.acertos == this.acertos);
}

class QuestoesCompanion extends UpdateCompanion<RegistroQuestoes> {
  final Value<String> id;
  final Value<DateTime> atualizadoEm;
  final Value<String> materiaId;
  final Value<DateTime> data;
  final Value<int> feitas;
  final Value<int> acertos;
  final Value<int> rowid;
  const QuestoesCompanion({
    this.id = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.materiaId = const Value.absent(),
    this.data = const Value.absent(),
    this.feitas = const Value.absent(),
    this.acertos = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuestoesCompanion.insert({
    this.id = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    required String materiaId,
    required DateTime data,
    required int feitas,
    required int acertos,
    this.rowid = const Value.absent(),
  }) : materiaId = Value(materiaId),
       data = Value(data),
       feitas = Value(feitas),
       acertos = Value(acertos);
  static Insertable<RegistroQuestoes> custom({
    Expression<String>? id,
    Expression<DateTime>? atualizadoEm,
    Expression<String>? materiaId,
    Expression<DateTime>? data,
    Expression<int>? feitas,
    Expression<int>? acertos,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (materiaId != null) 'materia_id': materiaId,
      if (data != null) 'data': data,
      if (feitas != null) 'feitas': feitas,
      if (acertos != null) 'acertos': acertos,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuestoesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? atualizadoEm,
    Value<String>? materiaId,
    Value<DateTime>? data,
    Value<int>? feitas,
    Value<int>? acertos,
    Value<int>? rowid,
  }) {
    return QuestoesCompanion(
      id: id ?? this.id,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      materiaId: materiaId ?? this.materiaId,
      data: data ?? this.data,
      feitas: feitas ?? this.feitas,
      acertos: acertos ?? this.acertos,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (atualizadoEm.present) {
      map['atualizado_em'] = Variable<DateTime>(atualizadoEm.value);
    }
    if (materiaId.present) {
      map['materia_id'] = Variable<String>(materiaId.value);
    }
    if (data.present) {
      map['data'] = Variable<DateTime>(data.value);
    }
    if (feitas.present) {
      map['feitas'] = Variable<int>(feitas.value);
    }
    if (acertos.present) {
      map['acertos'] = Variable<int>(acertos.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestoesCompanion(')
          ..write('id: $id, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('materiaId: $materiaId, ')
          ..write('data: $data, ')
          ..write('feitas: $feitas, ')
          ..write('acertos: $acertos, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessoesTable extends Sessoes with TableInfo<$SessoesTable, Sessao> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessoesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: novoId,
  );
  static const VerificationMeta _atualizadoEmMeta = const VerificationMeta(
    'atualizadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> atualizadoEm = GeneratedColumn<DateTime>(
    'atualizado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _materiaIdMeta = const VerificationMeta(
    'materiaId',
  );
  @override
  late final GeneratedColumn<String> materiaId = GeneratedColumn<String>(
    'materia_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES materias (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _topicoIdMeta = const VerificationMeta(
    'topicoId',
  );
  @override
  late final GeneratedColumn<String> topicoId = GeneratedColumn<String>(
    'topico_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES topicos (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _diaMeta = const VerificationMeta('dia');
  @override
  late final GeneratedColumn<DateTime> dia = GeneratedColumn<DateTime>(
    'dia',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _inicioMeta = const VerificationMeta('inicio');
  @override
  late final GeneratedColumn<DateTime> inicio = GeneratedColumn<DateTime>(
    'inicio',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _minutosMeta = const VerificationMeta(
    'minutos',
  );
  @override
  late final GeneratedColumn<int> minutos = GeneratedColumn<int>(
    'minutos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metodoMeta = const VerificationMeta('metodo');
  @override
  late final GeneratedColumn<String> metodo = GeneratedColumn<String>(
    'metodo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _questoesFeitasMeta = const VerificationMeta(
    'questoesFeitas',
  );
  @override
  late final GeneratedColumn<int> questoesFeitas = GeneratedColumn<int>(
    'questoes_feitas',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _questoesAcertosMeta = const VerificationMeta(
    'questoesAcertos',
  );
  @override
  late final GeneratedColumn<int> questoesAcertos = GeneratedColumn<int>(
    'questoes_acertos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _paginasMeta = const VerificationMeta(
    'paginas',
  );
  @override
  late final GeneratedColumn<int> paginas = GeneratedColumn<int>(
    'paginas',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pontoParadaMeta = const VerificationMeta(
    'pontoParada',
  );
  @override
  late final GeneratedColumn<String> pontoParada = GeneratedColumn<String>(
    'ponto_parada',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _origemMeta = const VerificationMeta('origem');
  @override
  late final GeneratedColumn<String> origem = GeneratedColumn<String>(
    'origem',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    atualizadoEm,
    materiaId,
    topicoId,
    dia,
    inicio,
    minutos,
    metodo,
    questoesFeitas,
    questoesAcertos,
    paginas,
    pontoParada,
    origem,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessoes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Sessao> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('atualizado_em')) {
      context.handle(
        _atualizadoEmMeta,
        atualizadoEm.isAcceptableOrUnknown(
          data['atualizado_em']!,
          _atualizadoEmMeta,
        ),
      );
    }
    if (data.containsKey('materia_id')) {
      context.handle(
        _materiaIdMeta,
        materiaId.isAcceptableOrUnknown(data['materia_id']!, _materiaIdMeta),
      );
    }
    if (data.containsKey('topico_id')) {
      context.handle(
        _topicoIdMeta,
        topicoId.isAcceptableOrUnknown(data['topico_id']!, _topicoIdMeta),
      );
    }
    if (data.containsKey('dia')) {
      context.handle(
        _diaMeta,
        dia.isAcceptableOrUnknown(data['dia']!, _diaMeta),
      );
    } else if (isInserting) {
      context.missing(_diaMeta);
    }
    if (data.containsKey('inicio')) {
      context.handle(
        _inicioMeta,
        inicio.isAcceptableOrUnknown(data['inicio']!, _inicioMeta),
      );
    }
    if (data.containsKey('minutos')) {
      context.handle(
        _minutosMeta,
        minutos.isAcceptableOrUnknown(data['minutos']!, _minutosMeta),
      );
    } else if (isInserting) {
      context.missing(_minutosMeta);
    }
    if (data.containsKey('metodo')) {
      context.handle(
        _metodoMeta,
        metodo.isAcceptableOrUnknown(data['metodo']!, _metodoMeta),
      );
    }
    if (data.containsKey('questoes_feitas')) {
      context.handle(
        _questoesFeitasMeta,
        questoesFeitas.isAcceptableOrUnknown(
          data['questoes_feitas']!,
          _questoesFeitasMeta,
        ),
      );
    }
    if (data.containsKey('questoes_acertos')) {
      context.handle(
        _questoesAcertosMeta,
        questoesAcertos.isAcceptableOrUnknown(
          data['questoes_acertos']!,
          _questoesAcertosMeta,
        ),
      );
    }
    if (data.containsKey('paginas')) {
      context.handle(
        _paginasMeta,
        paginas.isAcceptableOrUnknown(data['paginas']!, _paginasMeta),
      );
    }
    if (data.containsKey('ponto_parada')) {
      context.handle(
        _pontoParadaMeta,
        pontoParada.isAcceptableOrUnknown(
          data['ponto_parada']!,
          _pontoParadaMeta,
        ),
      );
    }
    if (data.containsKey('origem')) {
      context.handle(
        _origemMeta,
        origem.isAcceptableOrUnknown(data['origem']!, _origemMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Sessao map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Sessao(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      atualizadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}atualizado_em'],
      )!,
      materiaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}materia_id'],
      ),
      topicoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topico_id'],
      ),
      dia: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}dia'],
      )!,
      inicio: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}inicio'],
      )!,
      minutos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minutos'],
      )!,
      metodo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metodo'],
      ),
      questoesFeitas: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}questoes_feitas'],
      )!,
      questoesAcertos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}questoes_acertos'],
      )!,
      paginas: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paginas'],
      )!,
      pontoParada: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ponto_parada'],
      ),
      origem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origem'],
      ),
    );
  }

  @override
  $SessoesTable createAlias(String alias) {
    return $SessoesTable(attachedDatabase, alias);
  }
}

class Sessao extends DataClass implements Insertable<Sessao> {
  final String id;
  final DateTime atualizadoEm;
  final String? materiaId;
  final String? topicoId;

  /// Dia (meia-noite local) em que a sessão conta na grade.
  final DateTime dia;
  final DateTime inicio;
  final int minutos;

  /// videoaula, pdf, questoes, revisao, lei_seca (ver logic/metodo.dart).
  final String? metodo;
  final int questoesFeitas;
  final int questoesAcertos;
  final int paginas;

  /// Onde parou (texto curto), mostrado na próxima sessão da mesma matéria.
  final String? pontoParada;

  /// 'provas' = criada por um Treino/Simulado (v6). As questões dela são
  /// contadas pelas respostas (tabela respostas), não por estes números.
  final String? origem;
  const Sessao({
    required this.id,
    required this.atualizadoEm,
    this.materiaId,
    this.topicoId,
    required this.dia,
    required this.inicio,
    required this.minutos,
    this.metodo,
    required this.questoesFeitas,
    required this.questoesAcertos,
    required this.paginas,
    this.pontoParada,
    this.origem,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['atualizado_em'] = Variable<DateTime>(atualizadoEm);
    if (!nullToAbsent || materiaId != null) {
      map['materia_id'] = Variable<String>(materiaId);
    }
    if (!nullToAbsent || topicoId != null) {
      map['topico_id'] = Variable<String>(topicoId);
    }
    map['dia'] = Variable<DateTime>(dia);
    map['inicio'] = Variable<DateTime>(inicio);
    map['minutos'] = Variable<int>(minutos);
    if (!nullToAbsent || metodo != null) {
      map['metodo'] = Variable<String>(metodo);
    }
    map['questoes_feitas'] = Variable<int>(questoesFeitas);
    map['questoes_acertos'] = Variable<int>(questoesAcertos);
    map['paginas'] = Variable<int>(paginas);
    if (!nullToAbsent || pontoParada != null) {
      map['ponto_parada'] = Variable<String>(pontoParada);
    }
    if (!nullToAbsent || origem != null) {
      map['origem'] = Variable<String>(origem);
    }
    return map;
  }

  SessoesCompanion toCompanion(bool nullToAbsent) {
    return SessoesCompanion(
      id: Value(id),
      atualizadoEm: Value(atualizadoEm),
      materiaId: materiaId == null && nullToAbsent
          ? const Value.absent()
          : Value(materiaId),
      topicoId: topicoId == null && nullToAbsent
          ? const Value.absent()
          : Value(topicoId),
      dia: Value(dia),
      inicio: Value(inicio),
      minutos: Value(minutos),
      metodo: metodo == null && nullToAbsent
          ? const Value.absent()
          : Value(metodo),
      questoesFeitas: Value(questoesFeitas),
      questoesAcertos: Value(questoesAcertos),
      paginas: Value(paginas),
      pontoParada: pontoParada == null && nullToAbsent
          ? const Value.absent()
          : Value(pontoParada),
      origem: origem == null && nullToAbsent
          ? const Value.absent()
          : Value(origem),
    );
  }

  factory Sessao.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Sessao(
      id: serializer.fromJson<String>(json['id']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      materiaId: serializer.fromJson<String?>(json['materiaId']),
      topicoId: serializer.fromJson<String?>(json['topicoId']),
      dia: serializer.fromJson<DateTime>(json['dia']),
      inicio: serializer.fromJson<DateTime>(json['inicio']),
      minutos: serializer.fromJson<int>(json['minutos']),
      metodo: serializer.fromJson<String?>(json['metodo']),
      questoesFeitas: serializer.fromJson<int>(json['questoesFeitas']),
      questoesAcertos: serializer.fromJson<int>(json['questoesAcertos']),
      paginas: serializer.fromJson<int>(json['paginas']),
      pontoParada: serializer.fromJson<String?>(json['pontoParada']),
      origem: serializer.fromJson<String?>(json['origem']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'atualizadoEm': serializer.toJson<DateTime>(atualizadoEm),
      'materiaId': serializer.toJson<String?>(materiaId),
      'topicoId': serializer.toJson<String?>(topicoId),
      'dia': serializer.toJson<DateTime>(dia),
      'inicio': serializer.toJson<DateTime>(inicio),
      'minutos': serializer.toJson<int>(minutos),
      'metodo': serializer.toJson<String?>(metodo),
      'questoesFeitas': serializer.toJson<int>(questoesFeitas),
      'questoesAcertos': serializer.toJson<int>(questoesAcertos),
      'paginas': serializer.toJson<int>(paginas),
      'pontoParada': serializer.toJson<String?>(pontoParada),
      'origem': serializer.toJson<String?>(origem),
    };
  }

  Sessao copyWith({
    String? id,
    DateTime? atualizadoEm,
    Value<String?> materiaId = const Value.absent(),
    Value<String?> topicoId = const Value.absent(),
    DateTime? dia,
    DateTime? inicio,
    int? minutos,
    Value<String?> metodo = const Value.absent(),
    int? questoesFeitas,
    int? questoesAcertos,
    int? paginas,
    Value<String?> pontoParada = const Value.absent(),
    Value<String?> origem = const Value.absent(),
  }) => Sessao(
    id: id ?? this.id,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    materiaId: materiaId.present ? materiaId.value : this.materiaId,
    topicoId: topicoId.present ? topicoId.value : this.topicoId,
    dia: dia ?? this.dia,
    inicio: inicio ?? this.inicio,
    minutos: minutos ?? this.minutos,
    metodo: metodo.present ? metodo.value : this.metodo,
    questoesFeitas: questoesFeitas ?? this.questoesFeitas,
    questoesAcertos: questoesAcertos ?? this.questoesAcertos,
    paginas: paginas ?? this.paginas,
    pontoParada: pontoParada.present ? pontoParada.value : this.pontoParada,
    origem: origem.present ? origem.value : this.origem,
  );
  Sessao copyWithCompanion(SessoesCompanion data) {
    return Sessao(
      id: data.id.present ? data.id.value : this.id,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      materiaId: data.materiaId.present ? data.materiaId.value : this.materiaId,
      topicoId: data.topicoId.present ? data.topicoId.value : this.topicoId,
      dia: data.dia.present ? data.dia.value : this.dia,
      inicio: data.inicio.present ? data.inicio.value : this.inicio,
      minutos: data.minutos.present ? data.minutos.value : this.minutos,
      metodo: data.metodo.present ? data.metodo.value : this.metodo,
      questoesFeitas: data.questoesFeitas.present
          ? data.questoesFeitas.value
          : this.questoesFeitas,
      questoesAcertos: data.questoesAcertos.present
          ? data.questoesAcertos.value
          : this.questoesAcertos,
      paginas: data.paginas.present ? data.paginas.value : this.paginas,
      pontoParada: data.pontoParada.present
          ? data.pontoParada.value
          : this.pontoParada,
      origem: data.origem.present ? data.origem.value : this.origem,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Sessao(')
          ..write('id: $id, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('materiaId: $materiaId, ')
          ..write('topicoId: $topicoId, ')
          ..write('dia: $dia, ')
          ..write('inicio: $inicio, ')
          ..write('minutos: $minutos, ')
          ..write('metodo: $metodo, ')
          ..write('questoesFeitas: $questoesFeitas, ')
          ..write('questoesAcertos: $questoesAcertos, ')
          ..write('paginas: $paginas, ')
          ..write('pontoParada: $pontoParada, ')
          ..write('origem: $origem')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    atualizadoEm,
    materiaId,
    topicoId,
    dia,
    inicio,
    minutos,
    metodo,
    questoesFeitas,
    questoesAcertos,
    paginas,
    pontoParada,
    origem,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Sessao &&
          other.id == this.id &&
          other.atualizadoEm == this.atualizadoEm &&
          other.materiaId == this.materiaId &&
          other.topicoId == this.topicoId &&
          other.dia == this.dia &&
          other.inicio == this.inicio &&
          other.minutos == this.minutos &&
          other.metodo == this.metodo &&
          other.questoesFeitas == this.questoesFeitas &&
          other.questoesAcertos == this.questoesAcertos &&
          other.paginas == this.paginas &&
          other.pontoParada == this.pontoParada &&
          other.origem == this.origem);
}

class SessoesCompanion extends UpdateCompanion<Sessao> {
  final Value<String> id;
  final Value<DateTime> atualizadoEm;
  final Value<String?> materiaId;
  final Value<String?> topicoId;
  final Value<DateTime> dia;
  final Value<DateTime> inicio;
  final Value<int> minutos;
  final Value<String?> metodo;
  final Value<int> questoesFeitas;
  final Value<int> questoesAcertos;
  final Value<int> paginas;
  final Value<String?> pontoParada;
  final Value<String?> origem;
  final Value<int> rowid;
  const SessoesCompanion({
    this.id = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.materiaId = const Value.absent(),
    this.topicoId = const Value.absent(),
    this.dia = const Value.absent(),
    this.inicio = const Value.absent(),
    this.minutos = const Value.absent(),
    this.metodo = const Value.absent(),
    this.questoesFeitas = const Value.absent(),
    this.questoesAcertos = const Value.absent(),
    this.paginas = const Value.absent(),
    this.pontoParada = const Value.absent(),
    this.origem = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessoesCompanion.insert({
    this.id = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.materiaId = const Value.absent(),
    this.topicoId = const Value.absent(),
    required DateTime dia,
    this.inicio = const Value.absent(),
    required int minutos,
    this.metodo = const Value.absent(),
    this.questoesFeitas = const Value.absent(),
    this.questoesAcertos = const Value.absent(),
    this.paginas = const Value.absent(),
    this.pontoParada = const Value.absent(),
    this.origem = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : dia = Value(dia),
       minutos = Value(minutos);
  static Insertable<Sessao> custom({
    Expression<String>? id,
    Expression<DateTime>? atualizadoEm,
    Expression<String>? materiaId,
    Expression<String>? topicoId,
    Expression<DateTime>? dia,
    Expression<DateTime>? inicio,
    Expression<int>? minutos,
    Expression<String>? metodo,
    Expression<int>? questoesFeitas,
    Expression<int>? questoesAcertos,
    Expression<int>? paginas,
    Expression<String>? pontoParada,
    Expression<String>? origem,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (materiaId != null) 'materia_id': materiaId,
      if (topicoId != null) 'topico_id': topicoId,
      if (dia != null) 'dia': dia,
      if (inicio != null) 'inicio': inicio,
      if (minutos != null) 'minutos': minutos,
      if (metodo != null) 'metodo': metodo,
      if (questoesFeitas != null) 'questoes_feitas': questoesFeitas,
      if (questoesAcertos != null) 'questoes_acertos': questoesAcertos,
      if (paginas != null) 'paginas': paginas,
      if (pontoParada != null) 'ponto_parada': pontoParada,
      if (origem != null) 'origem': origem,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessoesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? atualizadoEm,
    Value<String?>? materiaId,
    Value<String?>? topicoId,
    Value<DateTime>? dia,
    Value<DateTime>? inicio,
    Value<int>? minutos,
    Value<String?>? metodo,
    Value<int>? questoesFeitas,
    Value<int>? questoesAcertos,
    Value<int>? paginas,
    Value<String?>? pontoParada,
    Value<String?>? origem,
    Value<int>? rowid,
  }) {
    return SessoesCompanion(
      id: id ?? this.id,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      materiaId: materiaId ?? this.materiaId,
      topicoId: topicoId ?? this.topicoId,
      dia: dia ?? this.dia,
      inicio: inicio ?? this.inicio,
      minutos: minutos ?? this.minutos,
      metodo: metodo ?? this.metodo,
      questoesFeitas: questoesFeitas ?? this.questoesFeitas,
      questoesAcertos: questoesAcertos ?? this.questoesAcertos,
      paginas: paginas ?? this.paginas,
      pontoParada: pontoParada ?? this.pontoParada,
      origem: origem ?? this.origem,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (atualizadoEm.present) {
      map['atualizado_em'] = Variable<DateTime>(atualizadoEm.value);
    }
    if (materiaId.present) {
      map['materia_id'] = Variable<String>(materiaId.value);
    }
    if (topicoId.present) {
      map['topico_id'] = Variable<String>(topicoId.value);
    }
    if (dia.present) {
      map['dia'] = Variable<DateTime>(dia.value);
    }
    if (inicio.present) {
      map['inicio'] = Variable<DateTime>(inicio.value);
    }
    if (minutos.present) {
      map['minutos'] = Variable<int>(minutos.value);
    }
    if (metodo.present) {
      map['metodo'] = Variable<String>(metodo.value);
    }
    if (questoesFeitas.present) {
      map['questoes_feitas'] = Variable<int>(questoesFeitas.value);
    }
    if (questoesAcertos.present) {
      map['questoes_acertos'] = Variable<int>(questoesAcertos.value);
    }
    if (paginas.present) {
      map['paginas'] = Variable<int>(paginas.value);
    }
    if (pontoParada.present) {
      map['ponto_parada'] = Variable<String>(pontoParada.value);
    }
    if (origem.present) {
      map['origem'] = Variable<String>(origem.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessoesCompanion(')
          ..write('id: $id, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('materiaId: $materiaId, ')
          ..write('topicoId: $topicoId, ')
          ..write('dia: $dia, ')
          ..write('inicio: $inicio, ')
          ..write('minutos: $minutos, ')
          ..write('metodo: $metodo, ')
          ..write('questoesFeitas: $questoesFeitas, ')
          ..write('questoesAcertos: $questoesAcertos, ')
          ..write('paginas: $paginas, ')
          ..write('pontoParada: $pontoParada, ')
          ..write('origem: $origem, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AnexosTable extends Anexos with TableInfo<$AnexosTable, Anexo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnexosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: novoId,
  );
  static const VerificationMeta _atualizadoEmMeta = const VerificationMeta(
    'atualizadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> atualizadoEm = GeneratedColumn<DateTime>(
    'atualizado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _topicoIdMeta = const VerificationMeta(
    'topicoId',
  );
  @override
  late final GeneratedColumn<String> topicoId = GeneratedColumn<String>(
    'topico_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES topicos (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _arquivoMeta = const VerificationMeta(
    'arquivo',
  );
  @override
  late final GeneratedColumn<String> arquivo = GeneratedColumn<String>(
    'arquivo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bytesMeta = const VerificationMeta('bytes');
  @override
  late final GeneratedColumn<int> bytes = GeneratedColumn<int>(
    'bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _criadoEmMeta = const VerificationMeta(
    'criadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> criadoEm = GeneratedColumn<DateTime>(
    'criado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    atualizadoEm,
    topicoId,
    tipo,
    nome,
    arquivo,
    bytes,
    criadoEm,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'anexos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Anexo> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('atualizado_em')) {
      context.handle(
        _atualizadoEmMeta,
        atualizadoEm.isAcceptableOrUnknown(
          data['atualizado_em']!,
          _atualizadoEmMeta,
        ),
      );
    }
    if (data.containsKey('topico_id')) {
      context.handle(
        _topicoIdMeta,
        topicoId.isAcceptableOrUnknown(data['topico_id']!, _topicoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_topicoIdMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('arquivo')) {
      context.handle(
        _arquivoMeta,
        arquivo.isAcceptableOrUnknown(data['arquivo']!, _arquivoMeta),
      );
    } else if (isInserting) {
      context.missing(_arquivoMeta);
    }
    if (data.containsKey('bytes')) {
      context.handle(
        _bytesMeta,
        bytes.isAcceptableOrUnknown(data['bytes']!, _bytesMeta),
      );
    }
    if (data.containsKey('criado_em')) {
      context.handle(
        _criadoEmMeta,
        criadoEm.isAcceptableOrUnknown(data['criado_em']!, _criadoEmMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Anexo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Anexo(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      atualizadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}atualizado_em'],
      )!,
      topicoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topico_id'],
      )!,
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      arquivo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}arquivo'],
      )!,
      bytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bytes'],
      )!,
      criadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}criado_em'],
      )!,
    );
  }

  @override
  $AnexosTable createAlias(String alias) {
    return $AnexosTable(attachedDatabase, alias);
  }
}

class Anexo extends DataClass implements Insertable<Anexo> {
  final String id;
  final DateTime atualizadoEm;
  final String topicoId;

  /// 'imagem' ou 'pdf'.
  final String tipo;
  final String nome;

  /// Caminho relativo à pasta de anexos do app (ex.: "a1b2.jpg").
  final String arquivo;
  final int bytes;
  final DateTime criadoEm;
  const Anexo({
    required this.id,
    required this.atualizadoEm,
    required this.topicoId,
    required this.tipo,
    required this.nome,
    required this.arquivo,
    required this.bytes,
    required this.criadoEm,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['atualizado_em'] = Variable<DateTime>(atualizadoEm);
    map['topico_id'] = Variable<String>(topicoId);
    map['tipo'] = Variable<String>(tipo);
    map['nome'] = Variable<String>(nome);
    map['arquivo'] = Variable<String>(arquivo);
    map['bytes'] = Variable<int>(bytes);
    map['criado_em'] = Variable<DateTime>(criadoEm);
    return map;
  }

  AnexosCompanion toCompanion(bool nullToAbsent) {
    return AnexosCompanion(
      id: Value(id),
      atualizadoEm: Value(atualizadoEm),
      topicoId: Value(topicoId),
      tipo: Value(tipo),
      nome: Value(nome),
      arquivo: Value(arquivo),
      bytes: Value(bytes),
      criadoEm: Value(criadoEm),
    );
  }

  factory Anexo.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Anexo(
      id: serializer.fromJson<String>(json['id']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      topicoId: serializer.fromJson<String>(json['topicoId']),
      tipo: serializer.fromJson<String>(json['tipo']),
      nome: serializer.fromJson<String>(json['nome']),
      arquivo: serializer.fromJson<String>(json['arquivo']),
      bytes: serializer.fromJson<int>(json['bytes']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'atualizadoEm': serializer.toJson<DateTime>(atualizadoEm),
      'topicoId': serializer.toJson<String>(topicoId),
      'tipo': serializer.toJson<String>(tipo),
      'nome': serializer.toJson<String>(nome),
      'arquivo': serializer.toJson<String>(arquivo),
      'bytes': serializer.toJson<int>(bytes),
      'criadoEm': serializer.toJson<DateTime>(criadoEm),
    };
  }

  Anexo copyWith({
    String? id,
    DateTime? atualizadoEm,
    String? topicoId,
    String? tipo,
    String? nome,
    String? arquivo,
    int? bytes,
    DateTime? criadoEm,
  }) => Anexo(
    id: id ?? this.id,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    topicoId: topicoId ?? this.topicoId,
    tipo: tipo ?? this.tipo,
    nome: nome ?? this.nome,
    arquivo: arquivo ?? this.arquivo,
    bytes: bytes ?? this.bytes,
    criadoEm: criadoEm ?? this.criadoEm,
  );
  Anexo copyWithCompanion(AnexosCompanion data) {
    return Anexo(
      id: data.id.present ? data.id.value : this.id,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      topicoId: data.topicoId.present ? data.topicoId.value : this.topicoId,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      nome: data.nome.present ? data.nome.value : this.nome,
      arquivo: data.arquivo.present ? data.arquivo.value : this.arquivo,
      bytes: data.bytes.present ? data.bytes.value : this.bytes,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Anexo(')
          ..write('id: $id, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('topicoId: $topicoId, ')
          ..write('tipo: $tipo, ')
          ..write('nome: $nome, ')
          ..write('arquivo: $arquivo, ')
          ..write('bytes: $bytes, ')
          ..write('criadoEm: $criadoEm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    atualizadoEm,
    topicoId,
    tipo,
    nome,
    arquivo,
    bytes,
    criadoEm,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Anexo &&
          other.id == this.id &&
          other.atualizadoEm == this.atualizadoEm &&
          other.topicoId == this.topicoId &&
          other.tipo == this.tipo &&
          other.nome == this.nome &&
          other.arquivo == this.arquivo &&
          other.bytes == this.bytes &&
          other.criadoEm == this.criadoEm);
}

class AnexosCompanion extends UpdateCompanion<Anexo> {
  final Value<String> id;
  final Value<DateTime> atualizadoEm;
  final Value<String> topicoId;
  final Value<String> tipo;
  final Value<String> nome;
  final Value<String> arquivo;
  final Value<int> bytes;
  final Value<DateTime> criadoEm;
  final Value<int> rowid;
  const AnexosCompanion({
    this.id = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.topicoId = const Value.absent(),
    this.tipo = const Value.absent(),
    this.nome = const Value.absent(),
    this.arquivo = const Value.absent(),
    this.bytes = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AnexosCompanion.insert({
    this.id = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    required String topicoId,
    required String tipo,
    required String nome,
    required String arquivo,
    this.bytes = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : topicoId = Value(topicoId),
       tipo = Value(tipo),
       nome = Value(nome),
       arquivo = Value(arquivo);
  static Insertable<Anexo> custom({
    Expression<String>? id,
    Expression<DateTime>? atualizadoEm,
    Expression<String>? topicoId,
    Expression<String>? tipo,
    Expression<String>? nome,
    Expression<String>? arquivo,
    Expression<int>? bytes,
    Expression<DateTime>? criadoEm,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (topicoId != null) 'topico_id': topicoId,
      if (tipo != null) 'tipo': tipo,
      if (nome != null) 'nome': nome,
      if (arquivo != null) 'arquivo': arquivo,
      if (bytes != null) 'bytes': bytes,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AnexosCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? atualizadoEm,
    Value<String>? topicoId,
    Value<String>? tipo,
    Value<String>? nome,
    Value<String>? arquivo,
    Value<int>? bytes,
    Value<DateTime>? criadoEm,
    Value<int>? rowid,
  }) {
    return AnexosCompanion(
      id: id ?? this.id,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      topicoId: topicoId ?? this.topicoId,
      tipo: tipo ?? this.tipo,
      nome: nome ?? this.nome,
      arquivo: arquivo ?? this.arquivo,
      bytes: bytes ?? this.bytes,
      criadoEm: criadoEm ?? this.criadoEm,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (atualizadoEm.present) {
      map['atualizado_em'] = Variable<DateTime>(atualizadoEm.value);
    }
    if (topicoId.present) {
      map['topico_id'] = Variable<String>(topicoId.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (arquivo.present) {
      map['arquivo'] = Variable<String>(arquivo.value);
    }
    if (bytes.present) {
      map['bytes'] = Variable<int>(bytes.value);
    }
    if (criadoEm.present) {
      map['criado_em'] = Variable<DateTime>(criadoEm.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnexosCompanion(')
          ..write('id: $id, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('topicoId: $topicoId, ')
          ..write('tipo: $tipo, ')
          ..write('nome: $nome, ')
          ..write('arquivo: $arquivo, ')
          ..write('bytes: $bytes, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FlashcardsTable extends Flashcards
    with TableInfo<$FlashcardsTable, Flashcard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FlashcardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: novoId,
  );
  static const VerificationMeta _atualizadoEmMeta = const VerificationMeta(
    'atualizadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> atualizadoEm = GeneratedColumn<DateTime>(
    'atualizado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _topicoIdMeta = const VerificationMeta(
    'topicoId',
  );
  @override
  late final GeneratedColumn<String> topicoId = GeneratedColumn<String>(
    'topico_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES topicos (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _frenteMeta = const VerificationMeta('frente');
  @override
  late final GeneratedColumn<String> frente = GeneratedColumn<String>(
    'frente',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versoMeta = const VerificationMeta('verso');
  @override
  late final GeneratedColumn<String> verso = GeneratedColumn<String>(
    'verso',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ordemMeta = const VerificationMeta('ordem');
  @override
  late final GeneratedColumn<int> ordem = GeneratedColumn<int>(
    'ordem',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _caixaMeta = const VerificationMeta('caixa');
  @override
  late final GeneratedColumn<int> caixa = GeneratedColumn<int>(
    'caixa',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _proximaRevisaoMeta = const VerificationMeta(
    'proximaRevisao',
  );
  @override
  late final GeneratedColumn<DateTime> proximaRevisao =
      GeneratedColumn<DateTime>(
        'proxima_revisao',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        clientDefault: DateTime.now,
      );
  static const VerificationMeta _acertosMeta = const VerificationMeta(
    'acertos',
  );
  @override
  late final GeneratedColumn<int> acertos = GeneratedColumn<int>(
    'acertos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _errosMeta = const VerificationMeta('erros');
  @override
  late final GeneratedColumn<int> erros = GeneratedColumn<int>(
    'erros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _criadoEmMeta = const VerificationMeta(
    'criadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> criadoEm = GeneratedColumn<DateTime>(
    'criado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    atualizadoEm,
    topicoId,
    frente,
    verso,
    ordem,
    caixa,
    proximaRevisao,
    acertos,
    erros,
    criadoEm,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'flashcards';
  @override
  VerificationContext validateIntegrity(
    Insertable<Flashcard> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('atualizado_em')) {
      context.handle(
        _atualizadoEmMeta,
        atualizadoEm.isAcceptableOrUnknown(
          data['atualizado_em']!,
          _atualizadoEmMeta,
        ),
      );
    }
    if (data.containsKey('topico_id')) {
      context.handle(
        _topicoIdMeta,
        topicoId.isAcceptableOrUnknown(data['topico_id']!, _topicoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_topicoIdMeta);
    }
    if (data.containsKey('frente')) {
      context.handle(
        _frenteMeta,
        frente.isAcceptableOrUnknown(data['frente']!, _frenteMeta),
      );
    } else if (isInserting) {
      context.missing(_frenteMeta);
    }
    if (data.containsKey('verso')) {
      context.handle(
        _versoMeta,
        verso.isAcceptableOrUnknown(data['verso']!, _versoMeta),
      );
    } else if (isInserting) {
      context.missing(_versoMeta);
    }
    if (data.containsKey('ordem')) {
      context.handle(
        _ordemMeta,
        ordem.isAcceptableOrUnknown(data['ordem']!, _ordemMeta),
      );
    }
    if (data.containsKey('caixa')) {
      context.handle(
        _caixaMeta,
        caixa.isAcceptableOrUnknown(data['caixa']!, _caixaMeta),
      );
    }
    if (data.containsKey('proxima_revisao')) {
      context.handle(
        _proximaRevisaoMeta,
        proximaRevisao.isAcceptableOrUnknown(
          data['proxima_revisao']!,
          _proximaRevisaoMeta,
        ),
      );
    }
    if (data.containsKey('acertos')) {
      context.handle(
        _acertosMeta,
        acertos.isAcceptableOrUnknown(data['acertos']!, _acertosMeta),
      );
    }
    if (data.containsKey('erros')) {
      context.handle(
        _errosMeta,
        erros.isAcceptableOrUnknown(data['erros']!, _errosMeta),
      );
    }
    if (data.containsKey('criado_em')) {
      context.handle(
        _criadoEmMeta,
        criadoEm.isAcceptableOrUnknown(data['criado_em']!, _criadoEmMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Flashcard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Flashcard(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      atualizadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}atualizado_em'],
      )!,
      topicoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topico_id'],
      )!,
      frente: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frente'],
      )!,
      verso: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}verso'],
      )!,
      ordem: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordem'],
      )!,
      caixa: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}caixa'],
      )!,
      proximaRevisao: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}proxima_revisao'],
      )!,
      acertos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}acertos'],
      )!,
      erros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}erros'],
      )!,
      criadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}criado_em'],
      )!,
    );
  }

  @override
  $FlashcardsTable createAlias(String alias) {
    return $FlashcardsTable(attachedDatabase, alias);
  }
}

class Flashcard extends DataClass implements Insertable<Flashcard> {
  final String id;
  final DateTime atualizadoEm;
  final String topicoId;
  final String frente;
  final String verso;
  final int ordem;

  /// 0 = novo/errado ... 5 = bem sabido.
  final int caixa;

  /// Dia em que o cartão volta a aparecer.
  final DateTime proximaRevisao;
  final int acertos;
  final int erros;
  final DateTime criadoEm;
  const Flashcard({
    required this.id,
    required this.atualizadoEm,
    required this.topicoId,
    required this.frente,
    required this.verso,
    required this.ordem,
    required this.caixa,
    required this.proximaRevisao,
    required this.acertos,
    required this.erros,
    required this.criadoEm,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['atualizado_em'] = Variable<DateTime>(atualizadoEm);
    map['topico_id'] = Variable<String>(topicoId);
    map['frente'] = Variable<String>(frente);
    map['verso'] = Variable<String>(verso);
    map['ordem'] = Variable<int>(ordem);
    map['caixa'] = Variable<int>(caixa);
    map['proxima_revisao'] = Variable<DateTime>(proximaRevisao);
    map['acertos'] = Variable<int>(acertos);
    map['erros'] = Variable<int>(erros);
    map['criado_em'] = Variable<DateTime>(criadoEm);
    return map;
  }

  FlashcardsCompanion toCompanion(bool nullToAbsent) {
    return FlashcardsCompanion(
      id: Value(id),
      atualizadoEm: Value(atualizadoEm),
      topicoId: Value(topicoId),
      frente: Value(frente),
      verso: Value(verso),
      ordem: Value(ordem),
      caixa: Value(caixa),
      proximaRevisao: Value(proximaRevisao),
      acertos: Value(acertos),
      erros: Value(erros),
      criadoEm: Value(criadoEm),
    );
  }

  factory Flashcard.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Flashcard(
      id: serializer.fromJson<String>(json['id']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      topicoId: serializer.fromJson<String>(json['topicoId']),
      frente: serializer.fromJson<String>(json['frente']),
      verso: serializer.fromJson<String>(json['verso']),
      ordem: serializer.fromJson<int>(json['ordem']),
      caixa: serializer.fromJson<int>(json['caixa']),
      proximaRevisao: serializer.fromJson<DateTime>(json['proximaRevisao']),
      acertos: serializer.fromJson<int>(json['acertos']),
      erros: serializer.fromJson<int>(json['erros']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'atualizadoEm': serializer.toJson<DateTime>(atualizadoEm),
      'topicoId': serializer.toJson<String>(topicoId),
      'frente': serializer.toJson<String>(frente),
      'verso': serializer.toJson<String>(verso),
      'ordem': serializer.toJson<int>(ordem),
      'caixa': serializer.toJson<int>(caixa),
      'proximaRevisao': serializer.toJson<DateTime>(proximaRevisao),
      'acertos': serializer.toJson<int>(acertos),
      'erros': serializer.toJson<int>(erros),
      'criadoEm': serializer.toJson<DateTime>(criadoEm),
    };
  }

  Flashcard copyWith({
    String? id,
    DateTime? atualizadoEm,
    String? topicoId,
    String? frente,
    String? verso,
    int? ordem,
    int? caixa,
    DateTime? proximaRevisao,
    int? acertos,
    int? erros,
    DateTime? criadoEm,
  }) => Flashcard(
    id: id ?? this.id,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    topicoId: topicoId ?? this.topicoId,
    frente: frente ?? this.frente,
    verso: verso ?? this.verso,
    ordem: ordem ?? this.ordem,
    caixa: caixa ?? this.caixa,
    proximaRevisao: proximaRevisao ?? this.proximaRevisao,
    acertos: acertos ?? this.acertos,
    erros: erros ?? this.erros,
    criadoEm: criadoEm ?? this.criadoEm,
  );
  Flashcard copyWithCompanion(FlashcardsCompanion data) {
    return Flashcard(
      id: data.id.present ? data.id.value : this.id,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      topicoId: data.topicoId.present ? data.topicoId.value : this.topicoId,
      frente: data.frente.present ? data.frente.value : this.frente,
      verso: data.verso.present ? data.verso.value : this.verso,
      ordem: data.ordem.present ? data.ordem.value : this.ordem,
      caixa: data.caixa.present ? data.caixa.value : this.caixa,
      proximaRevisao: data.proximaRevisao.present
          ? data.proximaRevisao.value
          : this.proximaRevisao,
      acertos: data.acertos.present ? data.acertos.value : this.acertos,
      erros: data.erros.present ? data.erros.value : this.erros,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Flashcard(')
          ..write('id: $id, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('topicoId: $topicoId, ')
          ..write('frente: $frente, ')
          ..write('verso: $verso, ')
          ..write('ordem: $ordem, ')
          ..write('caixa: $caixa, ')
          ..write('proximaRevisao: $proximaRevisao, ')
          ..write('acertos: $acertos, ')
          ..write('erros: $erros, ')
          ..write('criadoEm: $criadoEm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    atualizadoEm,
    topicoId,
    frente,
    verso,
    ordem,
    caixa,
    proximaRevisao,
    acertos,
    erros,
    criadoEm,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Flashcard &&
          other.id == this.id &&
          other.atualizadoEm == this.atualizadoEm &&
          other.topicoId == this.topicoId &&
          other.frente == this.frente &&
          other.verso == this.verso &&
          other.ordem == this.ordem &&
          other.caixa == this.caixa &&
          other.proximaRevisao == this.proximaRevisao &&
          other.acertos == this.acertos &&
          other.erros == this.erros &&
          other.criadoEm == this.criadoEm);
}

class FlashcardsCompanion extends UpdateCompanion<Flashcard> {
  final Value<String> id;
  final Value<DateTime> atualizadoEm;
  final Value<String> topicoId;
  final Value<String> frente;
  final Value<String> verso;
  final Value<int> ordem;
  final Value<int> caixa;
  final Value<DateTime> proximaRevisao;
  final Value<int> acertos;
  final Value<int> erros;
  final Value<DateTime> criadoEm;
  final Value<int> rowid;
  const FlashcardsCompanion({
    this.id = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.topicoId = const Value.absent(),
    this.frente = const Value.absent(),
    this.verso = const Value.absent(),
    this.ordem = const Value.absent(),
    this.caixa = const Value.absent(),
    this.proximaRevisao = const Value.absent(),
    this.acertos = const Value.absent(),
    this.erros = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FlashcardsCompanion.insert({
    this.id = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    required String topicoId,
    required String frente,
    required String verso,
    this.ordem = const Value.absent(),
    this.caixa = const Value.absent(),
    this.proximaRevisao = const Value.absent(),
    this.acertos = const Value.absent(),
    this.erros = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : topicoId = Value(topicoId),
       frente = Value(frente),
       verso = Value(verso);
  static Insertable<Flashcard> custom({
    Expression<String>? id,
    Expression<DateTime>? atualizadoEm,
    Expression<String>? topicoId,
    Expression<String>? frente,
    Expression<String>? verso,
    Expression<int>? ordem,
    Expression<int>? caixa,
    Expression<DateTime>? proximaRevisao,
    Expression<int>? acertos,
    Expression<int>? erros,
    Expression<DateTime>? criadoEm,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (topicoId != null) 'topico_id': topicoId,
      if (frente != null) 'frente': frente,
      if (verso != null) 'verso': verso,
      if (ordem != null) 'ordem': ordem,
      if (caixa != null) 'caixa': caixa,
      if (proximaRevisao != null) 'proxima_revisao': proximaRevisao,
      if (acertos != null) 'acertos': acertos,
      if (erros != null) 'erros': erros,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FlashcardsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? atualizadoEm,
    Value<String>? topicoId,
    Value<String>? frente,
    Value<String>? verso,
    Value<int>? ordem,
    Value<int>? caixa,
    Value<DateTime>? proximaRevisao,
    Value<int>? acertos,
    Value<int>? erros,
    Value<DateTime>? criadoEm,
    Value<int>? rowid,
  }) {
    return FlashcardsCompanion(
      id: id ?? this.id,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      topicoId: topicoId ?? this.topicoId,
      frente: frente ?? this.frente,
      verso: verso ?? this.verso,
      ordem: ordem ?? this.ordem,
      caixa: caixa ?? this.caixa,
      proximaRevisao: proximaRevisao ?? this.proximaRevisao,
      acertos: acertos ?? this.acertos,
      erros: erros ?? this.erros,
      criadoEm: criadoEm ?? this.criadoEm,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (atualizadoEm.present) {
      map['atualizado_em'] = Variable<DateTime>(atualizadoEm.value);
    }
    if (topicoId.present) {
      map['topico_id'] = Variable<String>(topicoId.value);
    }
    if (frente.present) {
      map['frente'] = Variable<String>(frente.value);
    }
    if (verso.present) {
      map['verso'] = Variable<String>(verso.value);
    }
    if (ordem.present) {
      map['ordem'] = Variable<int>(ordem.value);
    }
    if (caixa.present) {
      map['caixa'] = Variable<int>(caixa.value);
    }
    if (proximaRevisao.present) {
      map['proxima_revisao'] = Variable<DateTime>(proximaRevisao.value);
    }
    if (acertos.present) {
      map['acertos'] = Variable<int>(acertos.value);
    }
    if (erros.present) {
      map['erros'] = Variable<int>(erros.value);
    }
    if (criadoEm.present) {
      map['criado_em'] = Variable<DateTime>(criadoEm.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FlashcardsCompanion(')
          ..write('id: $id, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('topicoId: $topicoId, ')
          ..write('frente: $frente, ')
          ..write('verso: $verso, ')
          ..write('ordem: $ordem, ')
          ..write('caixa: $caixa, ')
          ..write('proximaRevisao: $proximaRevisao, ')
          ..write('acertos: $acertos, ')
          ..write('erros: $erros, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TopicoConcursosTable extends TopicoConcursos
    with TableInfo<$TopicoConcursosTable, TopicoConcurso> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TopicoConcursosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _topicoIdMeta = const VerificationMeta(
    'topicoId',
  );
  @override
  late final GeneratedColumn<String> topicoId = GeneratedColumn<String>(
    'topico_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES topicos (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _concursoIdMeta = const VerificationMeta(
    'concursoId',
  );
  @override
  late final GeneratedColumn<String> concursoId = GeneratedColumn<String>(
    'concurso_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES concursos (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _atualizadoEmMeta = const VerificationMeta(
    'atualizadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> atualizadoEm = GeneratedColumn<DateTime>(
    'atualizado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  @override
  List<GeneratedColumn> get $columns => [topicoId, concursoId, atualizadoEm];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'topico_concursos';
  @override
  VerificationContext validateIntegrity(
    Insertable<TopicoConcurso> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('topico_id')) {
      context.handle(
        _topicoIdMeta,
        topicoId.isAcceptableOrUnknown(data['topico_id']!, _topicoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_topicoIdMeta);
    }
    if (data.containsKey('concurso_id')) {
      context.handle(
        _concursoIdMeta,
        concursoId.isAcceptableOrUnknown(data['concurso_id']!, _concursoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_concursoIdMeta);
    }
    if (data.containsKey('atualizado_em')) {
      context.handle(
        _atualizadoEmMeta,
        atualizadoEm.isAcceptableOrUnknown(
          data['atualizado_em']!,
          _atualizadoEmMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {topicoId, concursoId};
  @override
  TopicoConcurso map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TopicoConcurso(
      topicoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topico_id'],
      )!,
      concursoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}concurso_id'],
      )!,
      atualizadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}atualizado_em'],
      )!,
    );
  }

  @override
  $TopicoConcursosTable createAlias(String alias) {
    return $TopicoConcursosTable(attachedDatabase, alias);
  }
}

class TopicoConcurso extends DataClass implements Insertable<TopicoConcurso> {
  final String topicoId;
  final String concursoId;
  final DateTime atualizadoEm;
  const TopicoConcurso({
    required this.topicoId,
    required this.concursoId,
    required this.atualizadoEm,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['topico_id'] = Variable<String>(topicoId);
    map['concurso_id'] = Variable<String>(concursoId);
    map['atualizado_em'] = Variable<DateTime>(atualizadoEm);
    return map;
  }

  TopicoConcursosCompanion toCompanion(bool nullToAbsent) {
    return TopicoConcursosCompanion(
      topicoId: Value(topicoId),
      concursoId: Value(concursoId),
      atualizadoEm: Value(atualizadoEm),
    );
  }

  factory TopicoConcurso.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TopicoConcurso(
      topicoId: serializer.fromJson<String>(json['topicoId']),
      concursoId: serializer.fromJson<String>(json['concursoId']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'topicoId': serializer.toJson<String>(topicoId),
      'concursoId': serializer.toJson<String>(concursoId),
      'atualizadoEm': serializer.toJson<DateTime>(atualizadoEm),
    };
  }

  TopicoConcurso copyWith({
    String? topicoId,
    String? concursoId,
    DateTime? atualizadoEm,
  }) => TopicoConcurso(
    topicoId: topicoId ?? this.topicoId,
    concursoId: concursoId ?? this.concursoId,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
  );
  TopicoConcurso copyWithCompanion(TopicoConcursosCompanion data) {
    return TopicoConcurso(
      topicoId: data.topicoId.present ? data.topicoId.value : this.topicoId,
      concursoId: data.concursoId.present
          ? data.concursoId.value
          : this.concursoId,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TopicoConcurso(')
          ..write('topicoId: $topicoId, ')
          ..write('concursoId: $concursoId, ')
          ..write('atualizadoEm: $atualizadoEm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(topicoId, concursoId, atualizadoEm);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TopicoConcurso &&
          other.topicoId == this.topicoId &&
          other.concursoId == this.concursoId &&
          other.atualizadoEm == this.atualizadoEm);
}

class TopicoConcursosCompanion extends UpdateCompanion<TopicoConcurso> {
  final Value<String> topicoId;
  final Value<String> concursoId;
  final Value<DateTime> atualizadoEm;
  final Value<int> rowid;
  const TopicoConcursosCompanion({
    this.topicoId = const Value.absent(),
    this.concursoId = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TopicoConcursosCompanion.insert({
    required String topicoId,
    required String concursoId,
    this.atualizadoEm = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : topicoId = Value(topicoId),
       concursoId = Value(concursoId);
  static Insertable<TopicoConcurso> custom({
    Expression<String>? topicoId,
    Expression<String>? concursoId,
    Expression<DateTime>? atualizadoEm,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (topicoId != null) 'topico_id': topicoId,
      if (concursoId != null) 'concurso_id': concursoId,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TopicoConcursosCompanion copyWith({
    Value<String>? topicoId,
    Value<String>? concursoId,
    Value<DateTime>? atualizadoEm,
    Value<int>? rowid,
  }) {
    return TopicoConcursosCompanion(
      topicoId: topicoId ?? this.topicoId,
      concursoId: concursoId ?? this.concursoId,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (topicoId.present) {
      map['topico_id'] = Variable<String>(topicoId.value);
    }
    if (concursoId.present) {
      map['concurso_id'] = Variable<String>(concursoId.value);
    }
    if (atualizadoEm.present) {
      map['atualizado_em'] = Variable<DateTime>(atualizadoEm.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TopicoConcursosCompanion(')
          ..write('topicoId: $topicoId, ')
          ..write('concursoId: $concursoId, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProvasTable extends Provas with TableInfo<$ProvasTable, Prova> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProvasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: novoId,
  );
  static const VerificationMeta _atualizadoEmMeta = const VerificationMeta(
    'atualizadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> atualizadoEm = GeneratedColumn<DateTime>(
    'atualizado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _bancaMeta = const VerificationMeta('banca');
  @override
  late final GeneratedColumn<String> banca = GeneratedColumn<String>(
    'banca',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orgaoMeta = const VerificationMeta('orgao');
  @override
  late final GeneratedColumn<String> orgao = GeneratedColumn<String>(
    'orgao',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cargoMeta = const VerificationMeta('cargo');
  @override
  late final GeneratedColumn<String> cargo = GeneratedColumn<String>(
    'cargo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _anoMeta = const VerificationMeta('ano');
  @override
  late final GeneratedColumn<int> ano = GeneratedColumn<int>(
    'ano',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chaveMeta = const VerificationMeta('chave');
  @override
  late final GeneratedColumn<String> chave = GeneratedColumn<String>(
    'chave',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gabaritoMeta = const VerificationMeta(
    'gabarito',
  );
  @override
  late final GeneratedColumn<String> gabarito = GeneratedColumn<String>(
    'gabarito',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numAlternativasMeta = const VerificationMeta(
    'numAlternativas',
  );
  @override
  late final GeneratedColumn<int> numAlternativas = GeneratedColumn<int>(
    'num_alternativas',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalQuestoesMeta = const VerificationMeta(
    'totalQuestoes',
  );
  @override
  late final GeneratedColumn<int> totalQuestoes = GeneratedColumn<int>(
    'total_questoes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gabaritoLidoMeta = const VerificationMeta(
    'gabaritoLido',
  );
  @override
  late final GeneratedColumn<String> gabaritoLido = GeneratedColumn<String>(
    'gabarito_lido',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _descartadasMeta = const VerificationMeta(
    'descartadas',
  );
  @override
  late final GeneratedColumn<String> descartadas = GeneratedColumn<String>(
    'descartadas',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _criadoEmMeta = const VerificationMeta(
    'criadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> criadoEm = GeneratedColumn<DateTime>(
    'criado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    atualizadoEm,
    banca,
    orgao,
    cargo,
    ano,
    chave,
    gabarito,
    numAlternativas,
    totalQuestoes,
    gabaritoLido,
    descartadas,
    criadoEm,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'provas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Prova> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('atualizado_em')) {
      context.handle(
        _atualizadoEmMeta,
        atualizadoEm.isAcceptableOrUnknown(
          data['atualizado_em']!,
          _atualizadoEmMeta,
        ),
      );
    }
    if (data.containsKey('banca')) {
      context.handle(
        _bancaMeta,
        banca.isAcceptableOrUnknown(data['banca']!, _bancaMeta),
      );
    } else if (isInserting) {
      context.missing(_bancaMeta);
    }
    if (data.containsKey('orgao')) {
      context.handle(
        _orgaoMeta,
        orgao.isAcceptableOrUnknown(data['orgao']!, _orgaoMeta),
      );
    } else if (isInserting) {
      context.missing(_orgaoMeta);
    }
    if (data.containsKey('cargo')) {
      context.handle(
        _cargoMeta,
        cargo.isAcceptableOrUnknown(data['cargo']!, _cargoMeta),
      );
    } else if (isInserting) {
      context.missing(_cargoMeta);
    }
    if (data.containsKey('ano')) {
      context.handle(
        _anoMeta,
        ano.isAcceptableOrUnknown(data['ano']!, _anoMeta),
      );
    } else if (isInserting) {
      context.missing(_anoMeta);
    }
    if (data.containsKey('chave')) {
      context.handle(
        _chaveMeta,
        chave.isAcceptableOrUnknown(data['chave']!, _chaveMeta),
      );
    } else if (isInserting) {
      context.missing(_chaveMeta);
    }
    if (data.containsKey('gabarito')) {
      context.handle(
        _gabaritoMeta,
        gabarito.isAcceptableOrUnknown(data['gabarito']!, _gabaritoMeta),
      );
    } else if (isInserting) {
      context.missing(_gabaritoMeta);
    }
    if (data.containsKey('num_alternativas')) {
      context.handle(
        _numAlternativasMeta,
        numAlternativas.isAcceptableOrUnknown(
          data['num_alternativas']!,
          _numAlternativasMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_numAlternativasMeta);
    }
    if (data.containsKey('total_questoes')) {
      context.handle(
        _totalQuestoesMeta,
        totalQuestoes.isAcceptableOrUnknown(
          data['total_questoes']!,
          _totalQuestoesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalQuestoesMeta);
    }
    if (data.containsKey('gabarito_lido')) {
      context.handle(
        _gabaritoLidoMeta,
        gabaritoLido.isAcceptableOrUnknown(
          data['gabarito_lido']!,
          _gabaritoLidoMeta,
        ),
      );
    }
    if (data.containsKey('descartadas')) {
      context.handle(
        _descartadasMeta,
        descartadas.isAcceptableOrUnknown(
          data['descartadas']!,
          _descartadasMeta,
        ),
      );
    }
    if (data.containsKey('criado_em')) {
      context.handle(
        _criadoEmMeta,
        criadoEm.isAcceptableOrUnknown(data['criado_em']!, _criadoEmMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Prova map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Prova(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      atualizadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}atualizado_em'],
      )!,
      banca: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}banca'],
      )!,
      orgao: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}orgao'],
      )!,
      cargo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cargo'],
      )!,
      ano: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ano'],
      )!,
      chave: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chave'],
      )!,
      gabarito: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gabarito'],
      )!,
      numAlternativas: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}num_alternativas'],
      )!,
      totalQuestoes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_questoes'],
      )!,
      gabaritoLido: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gabarito_lido'],
      )!,
      descartadas: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descartadas'],
      )!,
      criadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}criado_em'],
      )!,
    );
  }

  @override
  $ProvasTable createAlias(String alias) {
    return $ProvasTable(attachedDatabase, alias);
  }
}

class Prova extends DataClass implements Insertable<Prova> {
  final String id;
  final DateTime atualizadoEm;
  final String banca;
  final String orgao;
  final String cargo;
  final int ano;
  final String chave;

  /// 'preliminar' ou 'definitivo'.
  final String gabarito;
  final int numAlternativas;
  final int totalQuestoes;

  /// JSON número → letra, com todas as questões (inclusive descartadas).
  final String gabaritoLido;

  /// JSON [{numero, motivo}].
  final String descartadas;
  final DateTime criadoEm;
  const Prova({
    required this.id,
    required this.atualizadoEm,
    required this.banca,
    required this.orgao,
    required this.cargo,
    required this.ano,
    required this.chave,
    required this.gabarito,
    required this.numAlternativas,
    required this.totalQuestoes,
    required this.gabaritoLido,
    required this.descartadas,
    required this.criadoEm,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['atualizado_em'] = Variable<DateTime>(atualizadoEm);
    map['banca'] = Variable<String>(banca);
    map['orgao'] = Variable<String>(orgao);
    map['cargo'] = Variable<String>(cargo);
    map['ano'] = Variable<int>(ano);
    map['chave'] = Variable<String>(chave);
    map['gabarito'] = Variable<String>(gabarito);
    map['num_alternativas'] = Variable<int>(numAlternativas);
    map['total_questoes'] = Variable<int>(totalQuestoes);
    map['gabarito_lido'] = Variable<String>(gabaritoLido);
    map['descartadas'] = Variable<String>(descartadas);
    map['criado_em'] = Variable<DateTime>(criadoEm);
    return map;
  }

  ProvasCompanion toCompanion(bool nullToAbsent) {
    return ProvasCompanion(
      id: Value(id),
      atualizadoEm: Value(atualizadoEm),
      banca: Value(banca),
      orgao: Value(orgao),
      cargo: Value(cargo),
      ano: Value(ano),
      chave: Value(chave),
      gabarito: Value(gabarito),
      numAlternativas: Value(numAlternativas),
      totalQuestoes: Value(totalQuestoes),
      gabaritoLido: Value(gabaritoLido),
      descartadas: Value(descartadas),
      criadoEm: Value(criadoEm),
    );
  }

  factory Prova.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Prova(
      id: serializer.fromJson<String>(json['id']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      banca: serializer.fromJson<String>(json['banca']),
      orgao: serializer.fromJson<String>(json['orgao']),
      cargo: serializer.fromJson<String>(json['cargo']),
      ano: serializer.fromJson<int>(json['ano']),
      chave: serializer.fromJson<String>(json['chave']),
      gabarito: serializer.fromJson<String>(json['gabarito']),
      numAlternativas: serializer.fromJson<int>(json['numAlternativas']),
      totalQuestoes: serializer.fromJson<int>(json['totalQuestoes']),
      gabaritoLido: serializer.fromJson<String>(json['gabaritoLido']),
      descartadas: serializer.fromJson<String>(json['descartadas']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'atualizadoEm': serializer.toJson<DateTime>(atualizadoEm),
      'banca': serializer.toJson<String>(banca),
      'orgao': serializer.toJson<String>(orgao),
      'cargo': serializer.toJson<String>(cargo),
      'ano': serializer.toJson<int>(ano),
      'chave': serializer.toJson<String>(chave),
      'gabarito': serializer.toJson<String>(gabarito),
      'numAlternativas': serializer.toJson<int>(numAlternativas),
      'totalQuestoes': serializer.toJson<int>(totalQuestoes),
      'gabaritoLido': serializer.toJson<String>(gabaritoLido),
      'descartadas': serializer.toJson<String>(descartadas),
      'criadoEm': serializer.toJson<DateTime>(criadoEm),
    };
  }

  Prova copyWith({
    String? id,
    DateTime? atualizadoEm,
    String? banca,
    String? orgao,
    String? cargo,
    int? ano,
    String? chave,
    String? gabarito,
    int? numAlternativas,
    int? totalQuestoes,
    String? gabaritoLido,
    String? descartadas,
    DateTime? criadoEm,
  }) => Prova(
    id: id ?? this.id,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    banca: banca ?? this.banca,
    orgao: orgao ?? this.orgao,
    cargo: cargo ?? this.cargo,
    ano: ano ?? this.ano,
    chave: chave ?? this.chave,
    gabarito: gabarito ?? this.gabarito,
    numAlternativas: numAlternativas ?? this.numAlternativas,
    totalQuestoes: totalQuestoes ?? this.totalQuestoes,
    gabaritoLido: gabaritoLido ?? this.gabaritoLido,
    descartadas: descartadas ?? this.descartadas,
    criadoEm: criadoEm ?? this.criadoEm,
  );
  Prova copyWithCompanion(ProvasCompanion data) {
    return Prova(
      id: data.id.present ? data.id.value : this.id,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      banca: data.banca.present ? data.banca.value : this.banca,
      orgao: data.orgao.present ? data.orgao.value : this.orgao,
      cargo: data.cargo.present ? data.cargo.value : this.cargo,
      ano: data.ano.present ? data.ano.value : this.ano,
      chave: data.chave.present ? data.chave.value : this.chave,
      gabarito: data.gabarito.present ? data.gabarito.value : this.gabarito,
      numAlternativas: data.numAlternativas.present
          ? data.numAlternativas.value
          : this.numAlternativas,
      totalQuestoes: data.totalQuestoes.present
          ? data.totalQuestoes.value
          : this.totalQuestoes,
      gabaritoLido: data.gabaritoLido.present
          ? data.gabaritoLido.value
          : this.gabaritoLido,
      descartadas: data.descartadas.present
          ? data.descartadas.value
          : this.descartadas,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Prova(')
          ..write('id: $id, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('banca: $banca, ')
          ..write('orgao: $orgao, ')
          ..write('cargo: $cargo, ')
          ..write('ano: $ano, ')
          ..write('chave: $chave, ')
          ..write('gabarito: $gabarito, ')
          ..write('numAlternativas: $numAlternativas, ')
          ..write('totalQuestoes: $totalQuestoes, ')
          ..write('gabaritoLido: $gabaritoLido, ')
          ..write('descartadas: $descartadas, ')
          ..write('criadoEm: $criadoEm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    atualizadoEm,
    banca,
    orgao,
    cargo,
    ano,
    chave,
    gabarito,
    numAlternativas,
    totalQuestoes,
    gabaritoLido,
    descartadas,
    criadoEm,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Prova &&
          other.id == this.id &&
          other.atualizadoEm == this.atualizadoEm &&
          other.banca == this.banca &&
          other.orgao == this.orgao &&
          other.cargo == this.cargo &&
          other.ano == this.ano &&
          other.chave == this.chave &&
          other.gabarito == this.gabarito &&
          other.numAlternativas == this.numAlternativas &&
          other.totalQuestoes == this.totalQuestoes &&
          other.gabaritoLido == this.gabaritoLido &&
          other.descartadas == this.descartadas &&
          other.criadoEm == this.criadoEm);
}

class ProvasCompanion extends UpdateCompanion<Prova> {
  final Value<String> id;
  final Value<DateTime> atualizadoEm;
  final Value<String> banca;
  final Value<String> orgao;
  final Value<String> cargo;
  final Value<int> ano;
  final Value<String> chave;
  final Value<String> gabarito;
  final Value<int> numAlternativas;
  final Value<int> totalQuestoes;
  final Value<String> gabaritoLido;
  final Value<String> descartadas;
  final Value<DateTime> criadoEm;
  final Value<int> rowid;
  const ProvasCompanion({
    this.id = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.banca = const Value.absent(),
    this.orgao = const Value.absent(),
    this.cargo = const Value.absent(),
    this.ano = const Value.absent(),
    this.chave = const Value.absent(),
    this.gabarito = const Value.absent(),
    this.numAlternativas = const Value.absent(),
    this.totalQuestoes = const Value.absent(),
    this.gabaritoLido = const Value.absent(),
    this.descartadas = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProvasCompanion.insert({
    this.id = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    required String banca,
    required String orgao,
    required String cargo,
    required int ano,
    required String chave,
    required String gabarito,
    required int numAlternativas,
    required int totalQuestoes,
    this.gabaritoLido = const Value.absent(),
    this.descartadas = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : banca = Value(banca),
       orgao = Value(orgao),
       cargo = Value(cargo),
       ano = Value(ano),
       chave = Value(chave),
       gabarito = Value(gabarito),
       numAlternativas = Value(numAlternativas),
       totalQuestoes = Value(totalQuestoes);
  static Insertable<Prova> custom({
    Expression<String>? id,
    Expression<DateTime>? atualizadoEm,
    Expression<String>? banca,
    Expression<String>? orgao,
    Expression<String>? cargo,
    Expression<int>? ano,
    Expression<String>? chave,
    Expression<String>? gabarito,
    Expression<int>? numAlternativas,
    Expression<int>? totalQuestoes,
    Expression<String>? gabaritoLido,
    Expression<String>? descartadas,
    Expression<DateTime>? criadoEm,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (banca != null) 'banca': banca,
      if (orgao != null) 'orgao': orgao,
      if (cargo != null) 'cargo': cargo,
      if (ano != null) 'ano': ano,
      if (chave != null) 'chave': chave,
      if (gabarito != null) 'gabarito': gabarito,
      if (numAlternativas != null) 'num_alternativas': numAlternativas,
      if (totalQuestoes != null) 'total_questoes': totalQuestoes,
      if (gabaritoLido != null) 'gabarito_lido': gabaritoLido,
      if (descartadas != null) 'descartadas': descartadas,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProvasCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? atualizadoEm,
    Value<String>? banca,
    Value<String>? orgao,
    Value<String>? cargo,
    Value<int>? ano,
    Value<String>? chave,
    Value<String>? gabarito,
    Value<int>? numAlternativas,
    Value<int>? totalQuestoes,
    Value<String>? gabaritoLido,
    Value<String>? descartadas,
    Value<DateTime>? criadoEm,
    Value<int>? rowid,
  }) {
    return ProvasCompanion(
      id: id ?? this.id,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      banca: banca ?? this.banca,
      orgao: orgao ?? this.orgao,
      cargo: cargo ?? this.cargo,
      ano: ano ?? this.ano,
      chave: chave ?? this.chave,
      gabarito: gabarito ?? this.gabarito,
      numAlternativas: numAlternativas ?? this.numAlternativas,
      totalQuestoes: totalQuestoes ?? this.totalQuestoes,
      gabaritoLido: gabaritoLido ?? this.gabaritoLido,
      descartadas: descartadas ?? this.descartadas,
      criadoEm: criadoEm ?? this.criadoEm,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (atualizadoEm.present) {
      map['atualizado_em'] = Variable<DateTime>(atualizadoEm.value);
    }
    if (banca.present) {
      map['banca'] = Variable<String>(banca.value);
    }
    if (orgao.present) {
      map['orgao'] = Variable<String>(orgao.value);
    }
    if (cargo.present) {
      map['cargo'] = Variable<String>(cargo.value);
    }
    if (ano.present) {
      map['ano'] = Variable<int>(ano.value);
    }
    if (chave.present) {
      map['chave'] = Variable<String>(chave.value);
    }
    if (gabarito.present) {
      map['gabarito'] = Variable<String>(gabarito.value);
    }
    if (numAlternativas.present) {
      map['num_alternativas'] = Variable<int>(numAlternativas.value);
    }
    if (totalQuestoes.present) {
      map['total_questoes'] = Variable<int>(totalQuestoes.value);
    }
    if (gabaritoLido.present) {
      map['gabarito_lido'] = Variable<String>(gabaritoLido.value);
    }
    if (descartadas.present) {
      map['descartadas'] = Variable<String>(descartadas.value);
    }
    if (criadoEm.present) {
      map['criado_em'] = Variable<DateTime>(criadoEm.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProvasCompanion(')
          ..write('id: $id, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('banca: $banca, ')
          ..write('orgao: $orgao, ')
          ..write('cargo: $cargo, ')
          ..write('ano: $ano, ')
          ..write('chave: $chave, ')
          ..write('gabarito: $gabarito, ')
          ..write('numAlternativas: $numAlternativas, ')
          ..write('totalQuestoes: $totalQuestoes, ')
          ..write('gabaritoLido: $gabaritoLido, ')
          ..write('descartadas: $descartadas, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TextosBaseTable extends TextosBase
    with TableInfo<$TextosBaseTable, TextoBase> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TextosBaseTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: novoId,
  );
  static const VerificationMeta _atualizadoEmMeta = const VerificationMeta(
    'atualizadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> atualizadoEm = GeneratedColumn<DateTime>(
    'atualizado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _provaIdMeta = const VerificationMeta(
    'provaId',
  );
  @override
  late final GeneratedColumn<String> provaId = GeneratedColumn<String>(
    'prova_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES provas (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _codigoMeta = const VerificationMeta('codigo');
  @override
  late final GeneratedColumn<String> codigo = GeneratedColumn<String>(
    'codigo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tituloMeta = const VerificationMeta('titulo');
  @override
  late final GeneratedColumn<String> titulo = GeneratedColumn<String>(
    'titulo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _conteudoMeta = const VerificationMeta(
    'conteudo',
  );
  @override
  late final GeneratedColumn<String> conteudo = GeneratedColumn<String>(
    'conteudo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    atualizadoEm,
    provaId,
    codigo,
    titulo,
    conteudo,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'textos_base';
  @override
  VerificationContext validateIntegrity(
    Insertable<TextoBase> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('atualizado_em')) {
      context.handle(
        _atualizadoEmMeta,
        atualizadoEm.isAcceptableOrUnknown(
          data['atualizado_em']!,
          _atualizadoEmMeta,
        ),
      );
    }
    if (data.containsKey('prova_id')) {
      context.handle(
        _provaIdMeta,
        provaId.isAcceptableOrUnknown(data['prova_id']!, _provaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_provaIdMeta);
    }
    if (data.containsKey('codigo')) {
      context.handle(
        _codigoMeta,
        codigo.isAcceptableOrUnknown(data['codigo']!, _codigoMeta),
      );
    } else if (isInserting) {
      context.missing(_codigoMeta);
    }
    if (data.containsKey('titulo')) {
      context.handle(
        _tituloMeta,
        titulo.isAcceptableOrUnknown(data['titulo']!, _tituloMeta),
      );
    }
    if (data.containsKey('conteudo')) {
      context.handle(
        _conteudoMeta,
        conteudo.isAcceptableOrUnknown(data['conteudo']!, _conteudoMeta),
      );
    } else if (isInserting) {
      context.missing(_conteudoMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TextoBase map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TextoBase(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      atualizadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}atualizado_em'],
      )!,
      provaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prova_id'],
      )!,
      codigo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codigo'],
      )!,
      titulo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}titulo'],
      )!,
      conteudo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conteudo'],
      )!,
    );
  }

  @override
  $TextosBaseTable createAlias(String alias) {
    return $TextosBaseTable(attachedDatabase, alias);
  }
}

class TextoBase extends DataClass implements Insertable<TextoBase> {
  final String id;
  final DateTime atualizadoEm;
  final String provaId;

  /// Id do texto no JSON (ex.: "T1").
  final String codigo;
  final String titulo;
  final String conteudo;
  const TextoBase({
    required this.id,
    required this.atualizadoEm,
    required this.provaId,
    required this.codigo,
    required this.titulo,
    required this.conteudo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['atualizado_em'] = Variable<DateTime>(atualizadoEm);
    map['prova_id'] = Variable<String>(provaId);
    map['codigo'] = Variable<String>(codigo);
    map['titulo'] = Variable<String>(titulo);
    map['conteudo'] = Variable<String>(conteudo);
    return map;
  }

  TextosBaseCompanion toCompanion(bool nullToAbsent) {
    return TextosBaseCompanion(
      id: Value(id),
      atualizadoEm: Value(atualizadoEm),
      provaId: Value(provaId),
      codigo: Value(codigo),
      titulo: Value(titulo),
      conteudo: Value(conteudo),
    );
  }

  factory TextoBase.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TextoBase(
      id: serializer.fromJson<String>(json['id']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      provaId: serializer.fromJson<String>(json['provaId']),
      codigo: serializer.fromJson<String>(json['codigo']),
      titulo: serializer.fromJson<String>(json['titulo']),
      conteudo: serializer.fromJson<String>(json['conteudo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'atualizadoEm': serializer.toJson<DateTime>(atualizadoEm),
      'provaId': serializer.toJson<String>(provaId),
      'codigo': serializer.toJson<String>(codigo),
      'titulo': serializer.toJson<String>(titulo),
      'conteudo': serializer.toJson<String>(conteudo),
    };
  }

  TextoBase copyWith({
    String? id,
    DateTime? atualizadoEm,
    String? provaId,
    String? codigo,
    String? titulo,
    String? conteudo,
  }) => TextoBase(
    id: id ?? this.id,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    provaId: provaId ?? this.provaId,
    codigo: codigo ?? this.codigo,
    titulo: titulo ?? this.titulo,
    conteudo: conteudo ?? this.conteudo,
  );
  TextoBase copyWithCompanion(TextosBaseCompanion data) {
    return TextoBase(
      id: data.id.present ? data.id.value : this.id,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      provaId: data.provaId.present ? data.provaId.value : this.provaId,
      codigo: data.codigo.present ? data.codigo.value : this.codigo,
      titulo: data.titulo.present ? data.titulo.value : this.titulo,
      conteudo: data.conteudo.present ? data.conteudo.value : this.conteudo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TextoBase(')
          ..write('id: $id, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('provaId: $provaId, ')
          ..write('codigo: $codigo, ')
          ..write('titulo: $titulo, ')
          ..write('conteudo: $conteudo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, atualizadoEm, provaId, codigo, titulo, conteudo);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TextoBase &&
          other.id == this.id &&
          other.atualizadoEm == this.atualizadoEm &&
          other.provaId == this.provaId &&
          other.codigo == this.codigo &&
          other.titulo == this.titulo &&
          other.conteudo == this.conteudo);
}

class TextosBaseCompanion extends UpdateCompanion<TextoBase> {
  final Value<String> id;
  final Value<DateTime> atualizadoEm;
  final Value<String> provaId;
  final Value<String> codigo;
  final Value<String> titulo;
  final Value<String> conteudo;
  final Value<int> rowid;
  const TextosBaseCompanion({
    this.id = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.provaId = const Value.absent(),
    this.codigo = const Value.absent(),
    this.titulo = const Value.absent(),
    this.conteudo = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TextosBaseCompanion.insert({
    this.id = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    required String provaId,
    required String codigo,
    this.titulo = const Value.absent(),
    required String conteudo,
    this.rowid = const Value.absent(),
  }) : provaId = Value(provaId),
       codigo = Value(codigo),
       conteudo = Value(conteudo);
  static Insertable<TextoBase> custom({
    Expression<String>? id,
    Expression<DateTime>? atualizadoEm,
    Expression<String>? provaId,
    Expression<String>? codigo,
    Expression<String>? titulo,
    Expression<String>? conteudo,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (provaId != null) 'prova_id': provaId,
      if (codigo != null) 'codigo': codigo,
      if (titulo != null) 'titulo': titulo,
      if (conteudo != null) 'conteudo': conteudo,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TextosBaseCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? atualizadoEm,
    Value<String>? provaId,
    Value<String>? codigo,
    Value<String>? titulo,
    Value<String>? conteudo,
    Value<int>? rowid,
  }) {
    return TextosBaseCompanion(
      id: id ?? this.id,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      provaId: provaId ?? this.provaId,
      codigo: codigo ?? this.codigo,
      titulo: titulo ?? this.titulo,
      conteudo: conteudo ?? this.conteudo,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (atualizadoEm.present) {
      map['atualizado_em'] = Variable<DateTime>(atualizadoEm.value);
    }
    if (provaId.present) {
      map['prova_id'] = Variable<String>(provaId.value);
    }
    if (codigo.present) {
      map['codigo'] = Variable<String>(codigo.value);
    }
    if (titulo.present) {
      map['titulo'] = Variable<String>(titulo.value);
    }
    if (conteudo.present) {
      map['conteudo'] = Variable<String>(conteudo.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TextosBaseCompanion(')
          ..write('id: $id, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('provaId: $provaId, ')
          ..write('codigo: $codigo, ')
          ..write('titulo: $titulo, ')
          ..write('conteudo: $conteudo, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuestoesProvaTable extends QuestoesProva
    with TableInfo<$QuestoesProvaTable, QuestaoProva> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuestoesProvaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: novoId,
  );
  static const VerificationMeta _atualizadoEmMeta = const VerificationMeta(
    'atualizadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> atualizadoEm = GeneratedColumn<DateTime>(
    'atualizado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _provaIdMeta = const VerificationMeta(
    'provaId',
  );
  @override
  late final GeneratedColumn<String> provaId = GeneratedColumn<String>(
    'prova_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES provas (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _numeroMeta = const VerificationMeta('numero');
  @override
  late final GeneratedColumn<int> numero = GeneratedColumn<int>(
    'numero',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textoIdMeta = const VerificationMeta(
    'textoId',
  );
  @override
  late final GeneratedColumn<String> textoId = GeneratedColumn<String>(
    'texto_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES textos_base (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _materiaIdMeta = const VerificationMeta(
    'materiaId',
  );
  @override
  late final GeneratedColumn<String> materiaId = GeneratedColumn<String>(
    'materia_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES materias (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _topicoIdMeta = const VerificationMeta(
    'topicoId',
  );
  @override
  late final GeneratedColumn<String> topicoId = GeneratedColumn<String>(
    'topico_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES topicos (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _topicoOriginalMeta = const VerificationMeta(
    'topicoOriginal',
  );
  @override
  late final GeneratedColumn<String> topicoOriginal = GeneratedColumn<String>(
    'topico_original',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _enunciadoMeta = const VerificationMeta(
    'enunciado',
  );
  @override
  late final GeneratedColumn<String> enunciado = GeneratedColumn<String>(
    'enunciado',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _alternativasMeta = const VerificationMeta(
    'alternativas',
  );
  @override
  late final GeneratedColumn<String> alternativas = GeneratedColumn<String>(
    'alternativas',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _respostaMeta = const VerificationMeta(
    'resposta',
  );
  @override
  late final GeneratedColumn<String> resposta = GeneratedColumn<String>(
    'resposta',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _obsMeta = const VerificationMeta('obs');
  @override
  late final GeneratedColumn<String> obs = GeneratedColumn<String>(
    'obs',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    atualizadoEm,
    provaId,
    numero,
    textoId,
    materiaId,
    topicoId,
    topicoOriginal,
    enunciado,
    alternativas,
    resposta,
    status,
    obs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'questoes_prova';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuestaoProva> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('atualizado_em')) {
      context.handle(
        _atualizadoEmMeta,
        atualizadoEm.isAcceptableOrUnknown(
          data['atualizado_em']!,
          _atualizadoEmMeta,
        ),
      );
    }
    if (data.containsKey('prova_id')) {
      context.handle(
        _provaIdMeta,
        provaId.isAcceptableOrUnknown(data['prova_id']!, _provaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_provaIdMeta);
    }
    if (data.containsKey('numero')) {
      context.handle(
        _numeroMeta,
        numero.isAcceptableOrUnknown(data['numero']!, _numeroMeta),
      );
    } else if (isInserting) {
      context.missing(_numeroMeta);
    }
    if (data.containsKey('texto_id')) {
      context.handle(
        _textoIdMeta,
        textoId.isAcceptableOrUnknown(data['texto_id']!, _textoIdMeta),
      );
    }
    if (data.containsKey('materia_id')) {
      context.handle(
        _materiaIdMeta,
        materiaId.isAcceptableOrUnknown(data['materia_id']!, _materiaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_materiaIdMeta);
    }
    if (data.containsKey('topico_id')) {
      context.handle(
        _topicoIdMeta,
        topicoId.isAcceptableOrUnknown(data['topico_id']!, _topicoIdMeta),
      );
    }
    if (data.containsKey('topico_original')) {
      context.handle(
        _topicoOriginalMeta,
        topicoOriginal.isAcceptableOrUnknown(
          data['topico_original']!,
          _topicoOriginalMeta,
        ),
      );
    }
    if (data.containsKey('enunciado')) {
      context.handle(
        _enunciadoMeta,
        enunciado.isAcceptableOrUnknown(data['enunciado']!, _enunciadoMeta),
      );
    } else if (isInserting) {
      context.missing(_enunciadoMeta);
    }
    if (data.containsKey('alternativas')) {
      context.handle(
        _alternativasMeta,
        alternativas.isAcceptableOrUnknown(
          data['alternativas']!,
          _alternativasMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_alternativasMeta);
    }
    if (data.containsKey('resposta')) {
      context.handle(
        _respostaMeta,
        resposta.isAcceptableOrUnknown(data['resposta']!, _respostaMeta),
      );
    } else if (isInserting) {
      context.missing(_respostaMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('obs')) {
      context.handle(
        _obsMeta,
        obs.isAcceptableOrUnknown(data['obs']!, _obsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuestaoProva map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuestaoProva(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      atualizadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}atualizado_em'],
      )!,
      provaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prova_id'],
      )!,
      numero: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}numero'],
      )!,
      textoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}texto_id'],
      ),
      materiaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}materia_id'],
      )!,
      topicoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topico_id'],
      ),
      topicoOriginal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topico_original'],
      )!,
      enunciado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}enunciado'],
      )!,
      alternativas: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alternativas'],
      )!,
      resposta: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resposta'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      obs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}obs'],
      )!,
    );
  }

  @override
  $QuestoesProvaTable createAlias(String alias) {
    return $QuestoesProvaTable(attachedDatabase, alias);
  }
}

class QuestaoProva extends DataClass implements Insertable<QuestaoProva> {
  final String id;
  final DateTime atualizadoEm;
  final String provaId;
  final int numero;
  final String? textoId;
  final String materiaId;

  /// Nulo = "sem tópico".
  final String? topicoId;

  /// Tópico como veio do JSON (sempre guardado).
  final String topicoOriginal;
  final String enunciado;

  /// JSON letra → texto.
  final String alternativas;

  /// Letra certa, ou "X" na anulada.
  final String resposta;

  /// Separado por vírgula: anulada, imagem, revisar, desatualizada.
  final String status;
  final String obs;
  const QuestaoProva({
    required this.id,
    required this.atualizadoEm,
    required this.provaId,
    required this.numero,
    this.textoId,
    required this.materiaId,
    this.topicoId,
    required this.topicoOriginal,
    required this.enunciado,
    required this.alternativas,
    required this.resposta,
    required this.status,
    required this.obs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['atualizado_em'] = Variable<DateTime>(atualizadoEm);
    map['prova_id'] = Variable<String>(provaId);
    map['numero'] = Variable<int>(numero);
    if (!nullToAbsent || textoId != null) {
      map['texto_id'] = Variable<String>(textoId);
    }
    map['materia_id'] = Variable<String>(materiaId);
    if (!nullToAbsent || topicoId != null) {
      map['topico_id'] = Variable<String>(topicoId);
    }
    map['topico_original'] = Variable<String>(topicoOriginal);
    map['enunciado'] = Variable<String>(enunciado);
    map['alternativas'] = Variable<String>(alternativas);
    map['resposta'] = Variable<String>(resposta);
    map['status'] = Variable<String>(status);
    map['obs'] = Variable<String>(obs);
    return map;
  }

  QuestoesProvaCompanion toCompanion(bool nullToAbsent) {
    return QuestoesProvaCompanion(
      id: Value(id),
      atualizadoEm: Value(atualizadoEm),
      provaId: Value(provaId),
      numero: Value(numero),
      textoId: textoId == null && nullToAbsent
          ? const Value.absent()
          : Value(textoId),
      materiaId: Value(materiaId),
      topicoId: topicoId == null && nullToAbsent
          ? const Value.absent()
          : Value(topicoId),
      topicoOriginal: Value(topicoOriginal),
      enunciado: Value(enunciado),
      alternativas: Value(alternativas),
      resposta: Value(resposta),
      status: Value(status),
      obs: Value(obs),
    );
  }

  factory QuestaoProva.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuestaoProva(
      id: serializer.fromJson<String>(json['id']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      provaId: serializer.fromJson<String>(json['provaId']),
      numero: serializer.fromJson<int>(json['numero']),
      textoId: serializer.fromJson<String?>(json['textoId']),
      materiaId: serializer.fromJson<String>(json['materiaId']),
      topicoId: serializer.fromJson<String?>(json['topicoId']),
      topicoOriginal: serializer.fromJson<String>(json['topicoOriginal']),
      enunciado: serializer.fromJson<String>(json['enunciado']),
      alternativas: serializer.fromJson<String>(json['alternativas']),
      resposta: serializer.fromJson<String>(json['resposta']),
      status: serializer.fromJson<String>(json['status']),
      obs: serializer.fromJson<String>(json['obs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'atualizadoEm': serializer.toJson<DateTime>(atualizadoEm),
      'provaId': serializer.toJson<String>(provaId),
      'numero': serializer.toJson<int>(numero),
      'textoId': serializer.toJson<String?>(textoId),
      'materiaId': serializer.toJson<String>(materiaId),
      'topicoId': serializer.toJson<String?>(topicoId),
      'topicoOriginal': serializer.toJson<String>(topicoOriginal),
      'enunciado': serializer.toJson<String>(enunciado),
      'alternativas': serializer.toJson<String>(alternativas),
      'resposta': serializer.toJson<String>(resposta),
      'status': serializer.toJson<String>(status),
      'obs': serializer.toJson<String>(obs),
    };
  }

  QuestaoProva copyWith({
    String? id,
    DateTime? atualizadoEm,
    String? provaId,
    int? numero,
    Value<String?> textoId = const Value.absent(),
    String? materiaId,
    Value<String?> topicoId = const Value.absent(),
    String? topicoOriginal,
    String? enunciado,
    String? alternativas,
    String? resposta,
    String? status,
    String? obs,
  }) => QuestaoProva(
    id: id ?? this.id,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    provaId: provaId ?? this.provaId,
    numero: numero ?? this.numero,
    textoId: textoId.present ? textoId.value : this.textoId,
    materiaId: materiaId ?? this.materiaId,
    topicoId: topicoId.present ? topicoId.value : this.topicoId,
    topicoOriginal: topicoOriginal ?? this.topicoOriginal,
    enunciado: enunciado ?? this.enunciado,
    alternativas: alternativas ?? this.alternativas,
    resposta: resposta ?? this.resposta,
    status: status ?? this.status,
    obs: obs ?? this.obs,
  );
  QuestaoProva copyWithCompanion(QuestoesProvaCompanion data) {
    return QuestaoProva(
      id: data.id.present ? data.id.value : this.id,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      provaId: data.provaId.present ? data.provaId.value : this.provaId,
      numero: data.numero.present ? data.numero.value : this.numero,
      textoId: data.textoId.present ? data.textoId.value : this.textoId,
      materiaId: data.materiaId.present ? data.materiaId.value : this.materiaId,
      topicoId: data.topicoId.present ? data.topicoId.value : this.topicoId,
      topicoOriginal: data.topicoOriginal.present
          ? data.topicoOriginal.value
          : this.topicoOriginal,
      enunciado: data.enunciado.present ? data.enunciado.value : this.enunciado,
      alternativas: data.alternativas.present
          ? data.alternativas.value
          : this.alternativas,
      resposta: data.resposta.present ? data.resposta.value : this.resposta,
      status: data.status.present ? data.status.value : this.status,
      obs: data.obs.present ? data.obs.value : this.obs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuestaoProva(')
          ..write('id: $id, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('provaId: $provaId, ')
          ..write('numero: $numero, ')
          ..write('textoId: $textoId, ')
          ..write('materiaId: $materiaId, ')
          ..write('topicoId: $topicoId, ')
          ..write('topicoOriginal: $topicoOriginal, ')
          ..write('enunciado: $enunciado, ')
          ..write('alternativas: $alternativas, ')
          ..write('resposta: $resposta, ')
          ..write('status: $status, ')
          ..write('obs: $obs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    atualizadoEm,
    provaId,
    numero,
    textoId,
    materiaId,
    topicoId,
    topicoOriginal,
    enunciado,
    alternativas,
    resposta,
    status,
    obs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuestaoProva &&
          other.id == this.id &&
          other.atualizadoEm == this.atualizadoEm &&
          other.provaId == this.provaId &&
          other.numero == this.numero &&
          other.textoId == this.textoId &&
          other.materiaId == this.materiaId &&
          other.topicoId == this.topicoId &&
          other.topicoOriginal == this.topicoOriginal &&
          other.enunciado == this.enunciado &&
          other.alternativas == this.alternativas &&
          other.resposta == this.resposta &&
          other.status == this.status &&
          other.obs == this.obs);
}

class QuestoesProvaCompanion extends UpdateCompanion<QuestaoProva> {
  final Value<String> id;
  final Value<DateTime> atualizadoEm;
  final Value<String> provaId;
  final Value<int> numero;
  final Value<String?> textoId;
  final Value<String> materiaId;
  final Value<String?> topicoId;
  final Value<String> topicoOriginal;
  final Value<String> enunciado;
  final Value<String> alternativas;
  final Value<String> resposta;
  final Value<String> status;
  final Value<String> obs;
  final Value<int> rowid;
  const QuestoesProvaCompanion({
    this.id = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.provaId = const Value.absent(),
    this.numero = const Value.absent(),
    this.textoId = const Value.absent(),
    this.materiaId = const Value.absent(),
    this.topicoId = const Value.absent(),
    this.topicoOriginal = const Value.absent(),
    this.enunciado = const Value.absent(),
    this.alternativas = const Value.absent(),
    this.resposta = const Value.absent(),
    this.status = const Value.absent(),
    this.obs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuestoesProvaCompanion.insert({
    this.id = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    required String provaId,
    required int numero,
    this.textoId = const Value.absent(),
    required String materiaId,
    this.topicoId = const Value.absent(),
    this.topicoOriginal = const Value.absent(),
    required String enunciado,
    required String alternativas,
    required String resposta,
    this.status = const Value.absent(),
    this.obs = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : provaId = Value(provaId),
       numero = Value(numero),
       materiaId = Value(materiaId),
       enunciado = Value(enunciado),
       alternativas = Value(alternativas),
       resposta = Value(resposta);
  static Insertable<QuestaoProva> custom({
    Expression<String>? id,
    Expression<DateTime>? atualizadoEm,
    Expression<String>? provaId,
    Expression<int>? numero,
    Expression<String>? textoId,
    Expression<String>? materiaId,
    Expression<String>? topicoId,
    Expression<String>? topicoOriginal,
    Expression<String>? enunciado,
    Expression<String>? alternativas,
    Expression<String>? resposta,
    Expression<String>? status,
    Expression<String>? obs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (provaId != null) 'prova_id': provaId,
      if (numero != null) 'numero': numero,
      if (textoId != null) 'texto_id': textoId,
      if (materiaId != null) 'materia_id': materiaId,
      if (topicoId != null) 'topico_id': topicoId,
      if (topicoOriginal != null) 'topico_original': topicoOriginal,
      if (enunciado != null) 'enunciado': enunciado,
      if (alternativas != null) 'alternativas': alternativas,
      if (resposta != null) 'resposta': resposta,
      if (status != null) 'status': status,
      if (obs != null) 'obs': obs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuestoesProvaCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? atualizadoEm,
    Value<String>? provaId,
    Value<int>? numero,
    Value<String?>? textoId,
    Value<String>? materiaId,
    Value<String?>? topicoId,
    Value<String>? topicoOriginal,
    Value<String>? enunciado,
    Value<String>? alternativas,
    Value<String>? resposta,
    Value<String>? status,
    Value<String>? obs,
    Value<int>? rowid,
  }) {
    return QuestoesProvaCompanion(
      id: id ?? this.id,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      provaId: provaId ?? this.provaId,
      numero: numero ?? this.numero,
      textoId: textoId ?? this.textoId,
      materiaId: materiaId ?? this.materiaId,
      topicoId: topicoId ?? this.topicoId,
      topicoOriginal: topicoOriginal ?? this.topicoOriginal,
      enunciado: enunciado ?? this.enunciado,
      alternativas: alternativas ?? this.alternativas,
      resposta: resposta ?? this.resposta,
      status: status ?? this.status,
      obs: obs ?? this.obs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (atualizadoEm.present) {
      map['atualizado_em'] = Variable<DateTime>(atualizadoEm.value);
    }
    if (provaId.present) {
      map['prova_id'] = Variable<String>(provaId.value);
    }
    if (numero.present) {
      map['numero'] = Variable<int>(numero.value);
    }
    if (textoId.present) {
      map['texto_id'] = Variable<String>(textoId.value);
    }
    if (materiaId.present) {
      map['materia_id'] = Variable<String>(materiaId.value);
    }
    if (topicoId.present) {
      map['topico_id'] = Variable<String>(topicoId.value);
    }
    if (topicoOriginal.present) {
      map['topico_original'] = Variable<String>(topicoOriginal.value);
    }
    if (enunciado.present) {
      map['enunciado'] = Variable<String>(enunciado.value);
    }
    if (alternativas.present) {
      map['alternativas'] = Variable<String>(alternativas.value);
    }
    if (resposta.present) {
      map['resposta'] = Variable<String>(resposta.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (obs.present) {
      map['obs'] = Variable<String>(obs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestoesProvaCompanion(')
          ..write('id: $id, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('provaId: $provaId, ')
          ..write('numero: $numero, ')
          ..write('textoId: $textoId, ')
          ..write('materiaId: $materiaId, ')
          ..write('topicoId: $topicoId, ')
          ..write('topicoOriginal: $topicoOriginal, ')
          ..write('enunciado: $enunciado, ')
          ..write('alternativas: $alternativas, ')
          ..write('resposta: $resposta, ')
          ..write('status: $status, ')
          ..write('obs: $obs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RespostasTable extends Respostas
    with TableInfo<$RespostasTable, Resposta> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RespostasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: novoId,
  );
  static const VerificationMeta _atualizadoEmMeta = const VerificationMeta(
    'atualizadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> atualizadoEm = GeneratedColumn<DateTime>(
    'atualizado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _questaoIdMeta = const VerificationMeta(
    'questaoId',
  );
  @override
  late final GeneratedColumn<String> questaoId = GeneratedColumn<String>(
    'questao_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES questoes_prova (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _marcadaMeta = const VerificationMeta(
    'marcada',
  );
  @override
  late final GeneratedColumn<String> marcada = GeneratedColumn<String>(
    'marcada',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _acertouMeta = const VerificationMeta(
    'acertou',
  );
  @override
  late final GeneratedColumn<bool> acertou = GeneratedColumn<bool>(
    'acertou',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("acertou" IN (0, 1))',
    ),
  );
  static const VerificationMeta _segundosMeta = const VerificationMeta(
    'segundos',
  );
  @override
  late final GeneratedColumn<int> segundos = GeneratedColumn<int>(
    'segundos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _motivoErroMeta = const VerificationMeta(
    'motivoErro',
  );
  @override
  late final GeneratedColumn<String> motivoErro = GeneratedColumn<String>(
    'motivo_erro',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<DateTime> data = GeneratedColumn<DateTime>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _modoMeta = const VerificationMeta('modo');
  @override
  late final GeneratedColumn<String> modo = GeneratedColumn<String>(
    'modo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    atualizadoEm,
    questaoId,
    marcada,
    acertou,
    segundos,
    motivoErro,
    data,
    modo,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'respostas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Resposta> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('atualizado_em')) {
      context.handle(
        _atualizadoEmMeta,
        atualizadoEm.isAcceptableOrUnknown(
          data['atualizado_em']!,
          _atualizadoEmMeta,
        ),
      );
    }
    if (data.containsKey('questao_id')) {
      context.handle(
        _questaoIdMeta,
        questaoId.isAcceptableOrUnknown(data['questao_id']!, _questaoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questaoIdMeta);
    }
    if (data.containsKey('marcada')) {
      context.handle(
        _marcadaMeta,
        marcada.isAcceptableOrUnknown(data['marcada']!, _marcadaMeta),
      );
    } else if (isInserting) {
      context.missing(_marcadaMeta);
    }
    if (data.containsKey('acertou')) {
      context.handle(
        _acertouMeta,
        acertou.isAcceptableOrUnknown(data['acertou']!, _acertouMeta),
      );
    } else if (isInserting) {
      context.missing(_acertouMeta);
    }
    if (data.containsKey('segundos')) {
      context.handle(
        _segundosMeta,
        segundos.isAcceptableOrUnknown(data['segundos']!, _segundosMeta),
      );
    }
    if (data.containsKey('motivo_erro')) {
      context.handle(
        _motivoErroMeta,
        motivoErro.isAcceptableOrUnknown(data['motivo_erro']!, _motivoErroMeta),
      );
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    }
    if (data.containsKey('modo')) {
      context.handle(
        _modoMeta,
        modo.isAcceptableOrUnknown(data['modo']!, _modoMeta),
      );
    } else if (isInserting) {
      context.missing(_modoMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Resposta map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Resposta(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      atualizadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}atualizado_em'],
      )!,
      questaoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}questao_id'],
      )!,
      marcada: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}marcada'],
      )!,
      acertou: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}acertou'],
      )!,
      segundos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}segundos'],
      )!,
      motivoErro: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}motivo_erro'],
      ),
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data'],
      )!,
      modo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}modo'],
      )!,
    );
  }

  @override
  $RespostasTable createAlias(String alias) {
    return $RespostasTable(attachedDatabase, alias);
  }
}

class Resposta extends DataClass implements Insertable<Resposta> {
  final String id;
  final DateTime atualizadoEm;
  final String questaoId;
  final String marcada;
  final bool acertou;
  final int segundos;

  /// nao_sabia, desatencao ou pegadinha (nulo = não informado).
  final String? motivoErro;
  final DateTime data;

  /// 'treino' ou 'simulado'.
  final String modo;
  const Resposta({
    required this.id,
    required this.atualizadoEm,
    required this.questaoId,
    required this.marcada,
    required this.acertou,
    required this.segundos,
    this.motivoErro,
    required this.data,
    required this.modo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['atualizado_em'] = Variable<DateTime>(atualizadoEm);
    map['questao_id'] = Variable<String>(questaoId);
    map['marcada'] = Variable<String>(marcada);
    map['acertou'] = Variable<bool>(acertou);
    map['segundos'] = Variable<int>(segundos);
    if (!nullToAbsent || motivoErro != null) {
      map['motivo_erro'] = Variable<String>(motivoErro);
    }
    map['data'] = Variable<DateTime>(data);
    map['modo'] = Variable<String>(modo);
    return map;
  }

  RespostasCompanion toCompanion(bool nullToAbsent) {
    return RespostasCompanion(
      id: Value(id),
      atualizadoEm: Value(atualizadoEm),
      questaoId: Value(questaoId),
      marcada: Value(marcada),
      acertou: Value(acertou),
      segundos: Value(segundos),
      motivoErro: motivoErro == null && nullToAbsent
          ? const Value.absent()
          : Value(motivoErro),
      data: Value(data),
      modo: Value(modo),
    );
  }

  factory Resposta.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Resposta(
      id: serializer.fromJson<String>(json['id']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      questaoId: serializer.fromJson<String>(json['questaoId']),
      marcada: serializer.fromJson<String>(json['marcada']),
      acertou: serializer.fromJson<bool>(json['acertou']),
      segundos: serializer.fromJson<int>(json['segundos']),
      motivoErro: serializer.fromJson<String?>(json['motivoErro']),
      data: serializer.fromJson<DateTime>(json['data']),
      modo: serializer.fromJson<String>(json['modo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'atualizadoEm': serializer.toJson<DateTime>(atualizadoEm),
      'questaoId': serializer.toJson<String>(questaoId),
      'marcada': serializer.toJson<String>(marcada),
      'acertou': serializer.toJson<bool>(acertou),
      'segundos': serializer.toJson<int>(segundos),
      'motivoErro': serializer.toJson<String?>(motivoErro),
      'data': serializer.toJson<DateTime>(data),
      'modo': serializer.toJson<String>(modo),
    };
  }

  Resposta copyWith({
    String? id,
    DateTime? atualizadoEm,
    String? questaoId,
    String? marcada,
    bool? acertou,
    int? segundos,
    Value<String?> motivoErro = const Value.absent(),
    DateTime? data,
    String? modo,
  }) => Resposta(
    id: id ?? this.id,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    questaoId: questaoId ?? this.questaoId,
    marcada: marcada ?? this.marcada,
    acertou: acertou ?? this.acertou,
    segundos: segundos ?? this.segundos,
    motivoErro: motivoErro.present ? motivoErro.value : this.motivoErro,
    data: data ?? this.data,
    modo: modo ?? this.modo,
  );
  Resposta copyWithCompanion(RespostasCompanion data) {
    return Resposta(
      id: data.id.present ? data.id.value : this.id,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      questaoId: data.questaoId.present ? data.questaoId.value : this.questaoId,
      marcada: data.marcada.present ? data.marcada.value : this.marcada,
      acertou: data.acertou.present ? data.acertou.value : this.acertou,
      segundos: data.segundos.present ? data.segundos.value : this.segundos,
      motivoErro: data.motivoErro.present
          ? data.motivoErro.value
          : this.motivoErro,
      data: data.data.present ? data.data.value : this.data,
      modo: data.modo.present ? data.modo.value : this.modo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Resposta(')
          ..write('id: $id, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('questaoId: $questaoId, ')
          ..write('marcada: $marcada, ')
          ..write('acertou: $acertou, ')
          ..write('segundos: $segundos, ')
          ..write('motivoErro: $motivoErro, ')
          ..write('data: $data, ')
          ..write('modo: $modo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    atualizadoEm,
    questaoId,
    marcada,
    acertou,
    segundos,
    motivoErro,
    data,
    modo,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Resposta &&
          other.id == this.id &&
          other.atualizadoEm == this.atualizadoEm &&
          other.questaoId == this.questaoId &&
          other.marcada == this.marcada &&
          other.acertou == this.acertou &&
          other.segundos == this.segundos &&
          other.motivoErro == this.motivoErro &&
          other.data == this.data &&
          other.modo == this.modo);
}

class RespostasCompanion extends UpdateCompanion<Resposta> {
  final Value<String> id;
  final Value<DateTime> atualizadoEm;
  final Value<String> questaoId;
  final Value<String> marcada;
  final Value<bool> acertou;
  final Value<int> segundos;
  final Value<String?> motivoErro;
  final Value<DateTime> data;
  final Value<String> modo;
  final Value<int> rowid;
  const RespostasCompanion({
    this.id = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.questaoId = const Value.absent(),
    this.marcada = const Value.absent(),
    this.acertou = const Value.absent(),
    this.segundos = const Value.absent(),
    this.motivoErro = const Value.absent(),
    this.data = const Value.absent(),
    this.modo = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RespostasCompanion.insert({
    this.id = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    required String questaoId,
    required String marcada,
    required bool acertou,
    this.segundos = const Value.absent(),
    this.motivoErro = const Value.absent(),
    this.data = const Value.absent(),
    required String modo,
    this.rowid = const Value.absent(),
  }) : questaoId = Value(questaoId),
       marcada = Value(marcada),
       acertou = Value(acertou),
       modo = Value(modo);
  static Insertable<Resposta> custom({
    Expression<String>? id,
    Expression<DateTime>? atualizadoEm,
    Expression<String>? questaoId,
    Expression<String>? marcada,
    Expression<bool>? acertou,
    Expression<int>? segundos,
    Expression<String>? motivoErro,
    Expression<DateTime>? data,
    Expression<String>? modo,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (questaoId != null) 'questao_id': questaoId,
      if (marcada != null) 'marcada': marcada,
      if (acertou != null) 'acertou': acertou,
      if (segundos != null) 'segundos': segundos,
      if (motivoErro != null) 'motivo_erro': motivoErro,
      if (data != null) 'data': data,
      if (modo != null) 'modo': modo,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RespostasCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? atualizadoEm,
    Value<String>? questaoId,
    Value<String>? marcada,
    Value<bool>? acertou,
    Value<int>? segundos,
    Value<String?>? motivoErro,
    Value<DateTime>? data,
    Value<String>? modo,
    Value<int>? rowid,
  }) {
    return RespostasCompanion(
      id: id ?? this.id,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      questaoId: questaoId ?? this.questaoId,
      marcada: marcada ?? this.marcada,
      acertou: acertou ?? this.acertou,
      segundos: segundos ?? this.segundos,
      motivoErro: motivoErro ?? this.motivoErro,
      data: data ?? this.data,
      modo: modo ?? this.modo,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (atualizadoEm.present) {
      map['atualizado_em'] = Variable<DateTime>(atualizadoEm.value);
    }
    if (questaoId.present) {
      map['questao_id'] = Variable<String>(questaoId.value);
    }
    if (marcada.present) {
      map['marcada'] = Variable<String>(marcada.value);
    }
    if (acertou.present) {
      map['acertou'] = Variable<bool>(acertou.value);
    }
    if (segundos.present) {
      map['segundos'] = Variable<int>(segundos.value);
    }
    if (motivoErro.present) {
      map['motivo_erro'] = Variable<String>(motivoErro.value);
    }
    if (data.present) {
      map['data'] = Variable<DateTime>(data.value);
    }
    if (modo.present) {
      map['modo'] = Variable<String>(modo.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RespostasCompanion(')
          ..write('id: $id, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('questaoId: $questaoId, ')
          ..write('marcada: $marcada, ')
          ..write('acertou: $acertou, ')
          ..write('segundos: $segundos, ')
          ..write('motivoErro: $motivoErro, ')
          ..write('data: $data, ')
          ..write('modo: $modo, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PrintsQuestaoTable extends PrintsQuestao
    with TableInfo<$PrintsQuestaoTable, PrintQuestao> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrintsQuestaoTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: novoId,
  );
  static const VerificationMeta _atualizadoEmMeta = const VerificationMeta(
    'atualizadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> atualizadoEm = GeneratedColumn<DateTime>(
    'atualizado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _questaoIdMeta = const VerificationMeta(
    'questaoId',
  );
  @override
  late final GeneratedColumn<String> questaoId = GeneratedColumn<String>(
    'questao_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES questoes_prova (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _arquivoMeta = const VerificationMeta(
    'arquivo',
  );
  @override
  late final GeneratedColumn<String> arquivo = GeneratedColumn<String>(
    'arquivo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, atualizadoEm, questaoId, arquivo];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prints_questao';
  @override
  VerificationContext validateIntegrity(
    Insertable<PrintQuestao> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('atualizado_em')) {
      context.handle(
        _atualizadoEmMeta,
        atualizadoEm.isAcceptableOrUnknown(
          data['atualizado_em']!,
          _atualizadoEmMeta,
        ),
      );
    }
    if (data.containsKey('questao_id')) {
      context.handle(
        _questaoIdMeta,
        questaoId.isAcceptableOrUnknown(data['questao_id']!, _questaoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questaoIdMeta);
    }
    if (data.containsKey('arquivo')) {
      context.handle(
        _arquivoMeta,
        arquivo.isAcceptableOrUnknown(data['arquivo']!, _arquivoMeta),
      );
    } else if (isInserting) {
      context.missing(_arquivoMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PrintQuestao map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PrintQuestao(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      atualizadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}atualizado_em'],
      )!,
      questaoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}questao_id'],
      )!,
      arquivo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}arquivo'],
      )!,
    );
  }

  @override
  $PrintsQuestaoTable createAlias(String alias) {
    return $PrintsQuestaoTable(attachedDatabase, alias);
  }
}

class PrintQuestao extends DataClass implements Insertable<PrintQuestao> {
  final String id;
  final DateTime atualizadoEm;
  final String questaoId;
  final String arquivo;
  const PrintQuestao({
    required this.id,
    required this.atualizadoEm,
    required this.questaoId,
    required this.arquivo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['atualizado_em'] = Variable<DateTime>(atualizadoEm);
    map['questao_id'] = Variable<String>(questaoId);
    map['arquivo'] = Variable<String>(arquivo);
    return map;
  }

  PrintsQuestaoCompanion toCompanion(bool nullToAbsent) {
    return PrintsQuestaoCompanion(
      id: Value(id),
      atualizadoEm: Value(atualizadoEm),
      questaoId: Value(questaoId),
      arquivo: Value(arquivo),
    );
  }

  factory PrintQuestao.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PrintQuestao(
      id: serializer.fromJson<String>(json['id']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      questaoId: serializer.fromJson<String>(json['questaoId']),
      arquivo: serializer.fromJson<String>(json['arquivo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'atualizadoEm': serializer.toJson<DateTime>(atualizadoEm),
      'questaoId': serializer.toJson<String>(questaoId),
      'arquivo': serializer.toJson<String>(arquivo),
    };
  }

  PrintQuestao copyWith({
    String? id,
    DateTime? atualizadoEm,
    String? questaoId,
    String? arquivo,
  }) => PrintQuestao(
    id: id ?? this.id,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    questaoId: questaoId ?? this.questaoId,
    arquivo: arquivo ?? this.arquivo,
  );
  PrintQuestao copyWithCompanion(PrintsQuestaoCompanion data) {
    return PrintQuestao(
      id: data.id.present ? data.id.value : this.id,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      questaoId: data.questaoId.present ? data.questaoId.value : this.questaoId,
      arquivo: data.arquivo.present ? data.arquivo.value : this.arquivo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PrintQuestao(')
          ..write('id: $id, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('questaoId: $questaoId, ')
          ..write('arquivo: $arquivo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, atualizadoEm, questaoId, arquivo);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PrintQuestao &&
          other.id == this.id &&
          other.atualizadoEm == this.atualizadoEm &&
          other.questaoId == this.questaoId &&
          other.arquivo == this.arquivo);
}

class PrintsQuestaoCompanion extends UpdateCompanion<PrintQuestao> {
  final Value<String> id;
  final Value<DateTime> atualizadoEm;
  final Value<String> questaoId;
  final Value<String> arquivo;
  final Value<int> rowid;
  const PrintsQuestaoCompanion({
    this.id = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.questaoId = const Value.absent(),
    this.arquivo = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PrintsQuestaoCompanion.insert({
    this.id = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    required String questaoId,
    required String arquivo,
    this.rowid = const Value.absent(),
  }) : questaoId = Value(questaoId),
       arquivo = Value(arquivo);
  static Insertable<PrintQuestao> custom({
    Expression<String>? id,
    Expression<DateTime>? atualizadoEm,
    Expression<String>? questaoId,
    Expression<String>? arquivo,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (questaoId != null) 'questao_id': questaoId,
      if (arquivo != null) 'arquivo': arquivo,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PrintsQuestaoCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? atualizadoEm,
    Value<String>? questaoId,
    Value<String>? arquivo,
    Value<int>? rowid,
  }) {
    return PrintsQuestaoCompanion(
      id: id ?? this.id,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      questaoId: questaoId ?? this.questaoId,
      arquivo: arquivo ?? this.arquivo,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (atualizadoEm.present) {
      map['atualizado_em'] = Variable<DateTime>(atualizadoEm.value);
    }
    if (questaoId.present) {
      map['questao_id'] = Variable<String>(questaoId.value);
    }
    if (arquivo.present) {
      map['arquivo'] = Variable<String>(arquivo.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PrintsQuestaoCompanion(')
          ..write('id: $id, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('questaoId: $questaoId, ')
          ..write('arquivo: $arquivo, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ConcursosTable concursos = $ConcursosTable(this);
  late final $MateriasTable materias = $MateriasTable(this);
  late final $ConcursoMateriasTable concursoMaterias = $ConcursoMateriasTable(
    this,
  );
  late final $TopicosTable topicos = $TopicosTable(this);
  late final $RevisoesTable revisoes = $RevisoesTable(this);
  late final $QuestoesTable questoes = $QuestoesTable(this);
  late final $SessoesTable sessoes = $SessoesTable(this);
  late final $AnexosTable anexos = $AnexosTable(this);
  late final $FlashcardsTable flashcards = $FlashcardsTable(this);
  late final $TopicoConcursosTable topicoConcursos = $TopicoConcursosTable(
    this,
  );
  late final $ProvasTable provas = $ProvasTable(this);
  late final $TextosBaseTable textosBase = $TextosBaseTable(this);
  late final $QuestoesProvaTable questoesProva = $QuestoesProvaTable(this);
  late final $RespostasTable respostas = $RespostasTable(this);
  late final $PrintsQuestaoTable printsQuestao = $PrintsQuestaoTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    concursos,
    materias,
    concursoMaterias,
    topicos,
    revisoes,
    questoes,
    sessoes,
    anexos,
    flashcards,
    topicoConcursos,
    provas,
    textosBase,
    questoesProva,
    respostas,
    printsQuestao,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'concursos',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('concurso_materias', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'materias',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('concurso_materias', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'materias',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('topicos', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'topicos',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('topicos', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'topicos',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('revisoes', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'materias',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('questoes', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'materias',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('sessoes', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'topicos',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('sessoes', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'topicos',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('anexos', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'topicos',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('flashcards', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'topicos',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('topico_concursos', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'concursos',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('topico_concursos', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'provas',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('textos_base', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'provas',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('questoes_prova', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'textos_base',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('questoes_prova', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'materias',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('questoes_prova', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'topicos',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('questoes_prova', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'questoes_prova',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('respostas', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'questoes_prova',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('prints_questao', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ConcursosTableCreateCompanionBuilder = ConcursosCompanion Function({
  Value<String> id,
  Value<DateTime> atualizadoEm,
  required String nome,
  Value<String> banca,
  Value<DateTime?> dataProva,
  required int cor,
  Value<bool> foco,
  Value<bool> exemplo,
  Value<int> ordem,
  Value<DateTime> criadoEm,
  Value<int> cicloMinutos,
  Value<int> cicloBlocoMin,
  Value<int> cicloPosicao,
  Value<int> cicloVoltas,
  Value<int> rowid,
});
typedef $$ConcursosTableUpdateCompanionBuilder = ConcursosCompanion Function({
  Value<String> id,
  Value<DateTime> atualizadoEm,
  Value<String> nome,
  Value<String> banca,
  Value<DateTime?> dataProva,
  Value<int> cor,
  Value<bool> foco,
  Value<bool> exemplo,
  Value<int> ordem,
  Value<DateTime> criadoEm,
  Value<int> cicloMinutos,
  Value<int> cicloBlocoMin,
  Value<int> cicloPosicao,
  Value<int> cicloVoltas,
  Value<int> rowid,
});

final class $$ConcursosTableReferences
    extends BaseReferences<_$AppDatabase, $ConcursosTable, Concurso> {
  $$ConcursosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ConcursoMateriasTable, List<ConcursoMateria>>
  _concursoMateriasRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.concursoMaterias,
    aliasName: 'concursos__id__concurso_materias__concurso_id',
  );

  $$ConcursoMateriasTableProcessedTableManager get concursoMateriasRefs {
    final manager = $$ConcursoMateriasTableTableManager(
      $_db,
      $_db.concursoMaterias,
    ).filter((f) => f.concursoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _concursoMateriasRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TopicoConcursosTable, List<TopicoConcurso>>
  _topicoConcursosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.topicoConcursos,
    aliasName: 'concursos__id__topico_concursos__concurso_id',
  );

  $$TopicoConcursosTableProcessedTableManager get topicoConcursosRefs {
    final manager = $$TopicoConcursosTableTableManager(
      $_db,
      $_db.topicoConcursos,
    ).filter((f) => f.concursoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _topicoConcursosRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ConcursosTableFilterComposer
    extends Composer<_$AppDatabase, $ConcursosTable> {
  $$ConcursosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get banca => $composableBuilder(
    column: $table.banca,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dataProva => $composableBuilder(
    column: $table.dataProva,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cor => $composableBuilder(
    column: $table.cor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get foco => $composableBuilder(
    column: $table.foco,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get exemplo => $composableBuilder(
    column: $table.exemplo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ordem => $composableBuilder(
    column: $table.ordem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cicloMinutos => $composableBuilder(
    column: $table.cicloMinutos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cicloBlocoMin => $composableBuilder(
    column: $table.cicloBlocoMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cicloPosicao => $composableBuilder(
    column: $table.cicloPosicao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cicloVoltas => $composableBuilder(
    column: $table.cicloVoltas,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> concursoMateriasRefs(
    Expression<bool> Function($$ConcursoMateriasTableFilterComposer f) f,
  ) {
    final $$ConcursoMateriasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.concursoMaterias,
      getReferencedColumn: (t) => t.concursoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConcursoMateriasTableFilterComposer(
            $db: $db,
            $table: $db.concursoMaterias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> topicoConcursosRefs(
    Expression<bool> Function($$TopicoConcursosTableFilterComposer f) f,
  ) {
    final $$TopicoConcursosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.topicoConcursos,
      getReferencedColumn: (t) => t.concursoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TopicoConcursosTableFilterComposer(
            $db: $db,
            $table: $db.topicoConcursos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ConcursosTableOrderingComposer
    extends Composer<_$AppDatabase, $ConcursosTable> {
  $$ConcursosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get banca => $composableBuilder(
    column: $table.banca,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dataProva => $composableBuilder(
    column: $table.dataProva,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cor => $composableBuilder(
    column: $table.cor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get foco => $composableBuilder(
    column: $table.foco,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get exemplo => $composableBuilder(
    column: $table.exemplo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ordem => $composableBuilder(
    column: $table.ordem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cicloMinutos => $composableBuilder(
    column: $table.cicloMinutos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cicloBlocoMin => $composableBuilder(
    column: $table.cicloBlocoMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cicloPosicao => $composableBuilder(
    column: $table.cicloPosicao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cicloVoltas => $composableBuilder(
    column: $table.cicloVoltas,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConcursosTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConcursosTable> {
  $$ConcursosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<String> get banca =>
      $composableBuilder(column: $table.banca, builder: (column) => column);

  GeneratedColumn<DateTime> get dataProva =>
      $composableBuilder(column: $table.dataProva, builder: (column) => column);

  GeneratedColumn<int> get cor =>
      $composableBuilder(column: $table.cor, builder: (column) => column);

  GeneratedColumn<bool> get foco =>
      $composableBuilder(column: $table.foco, builder: (column) => column);

  GeneratedColumn<bool> get exemplo =>
      $composableBuilder(column: $table.exemplo, builder: (column) => column);

  GeneratedColumn<int> get ordem =>
      $composableBuilder(column: $table.ordem, builder: (column) => column);

  GeneratedColumn<DateTime> get criadoEm =>
      $composableBuilder(column: $table.criadoEm, builder: (column) => column);

  GeneratedColumn<int> get cicloMinutos => $composableBuilder(
    column: $table.cicloMinutos,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cicloBlocoMin => $composableBuilder(
    column: $table.cicloBlocoMin,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cicloPosicao => $composableBuilder(
    column: $table.cicloPosicao,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cicloVoltas => $composableBuilder(
    column: $table.cicloVoltas,
    builder: (column) => column,
  );

  Expression<T> concursoMateriasRefs<T extends Object>(
    Expression<T> Function($$ConcursoMateriasTableAnnotationComposer a) f,
  ) {
    final $$ConcursoMateriasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.concursoMaterias,
      getReferencedColumn: (t) => t.concursoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConcursoMateriasTableAnnotationComposer(
            $db: $db,
            $table: $db.concursoMaterias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> topicoConcursosRefs<T extends Object>(
    Expression<T> Function($$TopicoConcursosTableAnnotationComposer a) f,
  ) {
    final $$TopicoConcursosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.topicoConcursos,
      getReferencedColumn: (t) => t.concursoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TopicoConcursosTableAnnotationComposer(
            $db: $db,
            $table: $db.topicoConcursos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ConcursosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConcursosTable,
          Concurso,
          $$ConcursosTableFilterComposer,
          $$ConcursosTableOrderingComposer,
          $$ConcursosTableAnnotationComposer,
          $$ConcursosTableCreateCompanionBuilder,
          $$ConcursosTableUpdateCompanionBuilder,
          (Concurso, $$ConcursosTableReferences),
          Concurso,
          PrefetchHooks Function({
            bool concursoMateriasRefs,
            bool topicoConcursosRefs,
          })
        > {
  $$ConcursosTableTableManager(_$AppDatabase db, $ConcursosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConcursosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConcursosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConcursosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<String> banca = const Value.absent(),
                Value<DateTime?> dataProva = const Value.absent(),
                Value<int> cor = const Value.absent(),
                Value<bool> foco = const Value.absent(),
                Value<bool> exemplo = const Value.absent(),
                Value<int> ordem = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<int> cicloMinutos = const Value.absent(),
                Value<int> cicloBlocoMin = const Value.absent(),
                Value<int> cicloPosicao = const Value.absent(),
                Value<int> cicloVoltas = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConcursosCompanion(
                id: id,
                atualizadoEm: atualizadoEm,
                nome: nome,
                banca: banca,
                dataProva: dataProva,
                cor: cor,
                foco: foco,
                exemplo: exemplo,
                ordem: ordem,
                criadoEm: criadoEm,
                cicloMinutos: cicloMinutos,
                cicloBlocoMin: cicloBlocoMin,
                cicloPosicao: cicloPosicao,
                cicloVoltas: cicloVoltas,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                required String nome,
                Value<String> banca = const Value.absent(),
                Value<DateTime?> dataProva = const Value.absent(),
                required int cor,
                Value<bool> foco = const Value.absent(),
                Value<bool> exemplo = const Value.absent(),
                Value<int> ordem = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<int> cicloMinutos = const Value.absent(),
                Value<int> cicloBlocoMin = const Value.absent(),
                Value<int> cicloPosicao = const Value.absent(),
                Value<int> cicloVoltas = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConcursosCompanion.insert(
                id: id,
                atualizadoEm: atualizadoEm,
                nome: nome,
                banca: banca,
                dataProva: dataProva,
                cor: cor,
                foco: foco,
                exemplo: exemplo,
                ordem: ordem,
                criadoEm: criadoEm,
                cicloMinutos: cicloMinutos,
                cicloBlocoMin: cicloBlocoMin,
                cicloPosicao: cicloPosicao,
                cicloVoltas: cicloVoltas,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ConcursosTable, Concurso>(table),
                  $$ConcursosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({concursoMateriasRefs = false, topicoConcursosRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (concursoMateriasRefs) db.concursoMaterias,
                    if (topicoConcursosRefs) db.topicoConcursos,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (concursoMateriasRefs)
                        await $_getPrefetchedData<
                          Concurso,
                          $ConcursosTable,
                          ConcursoMateria
                        >(
                          currentTable: table,
                          referencedTable: $$ConcursosTableReferences
                              ._concursoMateriasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ConcursosTableReferences(
                                db,
                                table,
                                p0,
                              ).concursoMateriasRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.concursoId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (topicoConcursosRefs)
                        await $_getPrefetchedData<
                          Concurso,
                          $ConcursosTable,
                          TopicoConcurso
                        >(
                          currentTable: table,
                          referencedTable: $$ConcursosTableReferences
                              ._topicoConcursosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ConcursosTableReferences(
                                db,
                                table,
                                p0,
                              ).topicoConcursosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.concursoId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ConcursosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConcursosTable,
      Concurso,
      $$ConcursosTableFilterComposer,
      $$ConcursosTableOrderingComposer,
      $$ConcursosTableAnnotationComposer,
      $$ConcursosTableCreateCompanionBuilder,
      $$ConcursosTableUpdateCompanionBuilder,
      (Concurso, $$ConcursosTableReferences),
      Concurso,
      PrefetchHooks Function({
        bool concursoMateriasRefs,
        bool topicoConcursosRefs,
      })
    >;
typedef $$MateriasTableCreateCompanionBuilder = MateriasCompanion Function({
  Value<String> id,
  Value<DateTime> atualizadoEm,
  required String nome,
  required String chave,
  required int cor,
  Value<int> rowid,
});
typedef $$MateriasTableUpdateCompanionBuilder = MateriasCompanion Function({
  Value<String> id,
  Value<DateTime> atualizadoEm,
  Value<String> nome,
  Value<String> chave,
  Value<int> cor,
  Value<int> rowid,
});

final class $$MateriasTableReferences
    extends BaseReferences<_$AppDatabase, $MateriasTable, Materia> {
  $$MateriasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ConcursoMateriasTable, List<ConcursoMateria>>
  _concursoMateriasRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.concursoMaterias,
    aliasName: 'materias__id__concurso_materias__materia_id',
  );

  $$ConcursoMateriasTableProcessedTableManager get concursoMateriasRefs {
    final manager = $$ConcursoMateriasTableTableManager(
      $_db,
      $_db.concursoMaterias,
    ).filter((f) => f.materiaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _concursoMateriasRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TopicosTable, List<Topico>> _topicosRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.topicos,
    aliasName: 'materias__id__topicos__materia_id',
  );

  $$TopicosTableProcessedTableManager get topicosRefs {
    final manager = $$TopicosTableTableManager(
      $_db,
      $_db.topicos,
    ).filter((f) => f.materiaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_topicosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$QuestoesTable, List<RegistroQuestoes>>
  _questoesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.questoes,
    aliasName: 'materias__id__questoes__materia_id',
  );

  $$QuestoesTableProcessedTableManager get questoesRefs {
    final manager = $$QuestoesTableTableManager(
      $_db,
      $_db.questoes,
    ).filter((f) => f.materiaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_questoesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SessoesTable, List<Sessao>> _sessoesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.sessoes,
    aliasName: 'materias__id__sessoes__materia_id',
  );

  $$SessoesTableProcessedTableManager get sessoesRefs {
    final manager = $$SessoesTableTableManager(
      $_db,
      $_db.sessoes,
    ).filter((f) => f.materiaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessoesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$QuestoesProvaTable, List<QuestaoProva>>
  _questoesProvaRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.questoesProva,
    aliasName: 'materias__id__questoes_prova__materia_id',
  );

  $$QuestoesProvaTableProcessedTableManager get questoesProvaRefs {
    final manager = $$QuestoesProvaTableTableManager(
      $_db,
      $_db.questoesProva,
    ).filter((f) => f.materiaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_questoesProvaRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MateriasTableFilterComposer
    extends Composer<_$AppDatabase, $MateriasTable> {
  $$MateriasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chave => $composableBuilder(
    column: $table.chave,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cor => $composableBuilder(
    column: $table.cor,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> concursoMateriasRefs(
    Expression<bool> Function($$ConcursoMateriasTableFilterComposer f) f,
  ) {
    final $$ConcursoMateriasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.concursoMaterias,
      getReferencedColumn: (t) => t.materiaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConcursoMateriasTableFilterComposer(
            $db: $db,
            $table: $db.concursoMaterias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> topicosRefs(
    Expression<bool> Function($$TopicosTableFilterComposer f) f,
  ) {
    final $$TopicosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.topicos,
      getReferencedColumn: (t) => t.materiaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TopicosTableFilterComposer(
            $db: $db,
            $table: $db.topicos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> questoesRefs(
    Expression<bool> Function($$QuestoesTableFilterComposer f) f,
  ) {
    final $$QuestoesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.questoes,
      getReferencedColumn: (t) => t.materiaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestoesTableFilterComposer(
            $db: $db,
            $table: $db.questoes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sessoesRefs(
    Expression<bool> Function($$SessoesTableFilterComposer f) f,
  ) {
    final $$SessoesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessoes,
      getReferencedColumn: (t) => t.materiaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessoesTableFilterComposer(
            $db: $db,
            $table: $db.sessoes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> questoesProvaRefs(
    Expression<bool> Function($$QuestoesProvaTableFilterComposer f) f,
  ) {
    final $$QuestoesProvaTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.questoesProva,
      getReferencedColumn: (t) => t.materiaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestoesProvaTableFilterComposer(
            $db: $db,
            $table: $db.questoesProva,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MateriasTableOrderingComposer
    extends Composer<_$AppDatabase, $MateriasTable> {
  $$MateriasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chave => $composableBuilder(
    column: $table.chave,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cor => $composableBuilder(
    column: $table.cor,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MateriasTableAnnotationComposer
    extends Composer<_$AppDatabase, $MateriasTable> {
  $$MateriasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<String> get chave =>
      $composableBuilder(column: $table.chave, builder: (column) => column);

  GeneratedColumn<int> get cor =>
      $composableBuilder(column: $table.cor, builder: (column) => column);

  Expression<T> concursoMateriasRefs<T extends Object>(
    Expression<T> Function($$ConcursoMateriasTableAnnotationComposer a) f,
  ) {
    final $$ConcursoMateriasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.concursoMaterias,
      getReferencedColumn: (t) => t.materiaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConcursoMateriasTableAnnotationComposer(
            $db: $db,
            $table: $db.concursoMaterias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> topicosRefs<T extends Object>(
    Expression<T> Function($$TopicosTableAnnotationComposer a) f,
  ) {
    final $$TopicosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.topicos,
      getReferencedColumn: (t) => t.materiaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TopicosTableAnnotationComposer(
            $db: $db,
            $table: $db.topicos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> questoesRefs<T extends Object>(
    Expression<T> Function($$QuestoesTableAnnotationComposer a) f,
  ) {
    final $$QuestoesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.questoes,
      getReferencedColumn: (t) => t.materiaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestoesTableAnnotationComposer(
            $db: $db,
            $table: $db.questoes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sessoesRefs<T extends Object>(
    Expression<T> Function($$SessoesTableAnnotationComposer a) f,
  ) {
    final $$SessoesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessoes,
      getReferencedColumn: (t) => t.materiaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessoesTableAnnotationComposer(
            $db: $db,
            $table: $db.sessoes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> questoesProvaRefs<T extends Object>(
    Expression<T> Function($$QuestoesProvaTableAnnotationComposer a) f,
  ) {
    final $$QuestoesProvaTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.questoesProva,
      getReferencedColumn: (t) => t.materiaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestoesProvaTableAnnotationComposer(
            $db: $db,
            $table: $db.questoesProva,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MateriasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MateriasTable,
          Materia,
          $$MateriasTableFilterComposer,
          $$MateriasTableOrderingComposer,
          $$MateriasTableAnnotationComposer,
          $$MateriasTableCreateCompanionBuilder,
          $$MateriasTableUpdateCompanionBuilder,
          (Materia, $$MateriasTableReferences),
          Materia,
          PrefetchHooks Function({
            bool concursoMateriasRefs,
            bool topicosRefs,
            bool questoesRefs,
            bool sessoesRefs,
            bool questoesProvaRefs,
          })
        > {
  $$MateriasTableTableManager(_$AppDatabase db, $MateriasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MateriasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MateriasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MateriasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<String> chave = const Value.absent(),
                Value<int> cor = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MateriasCompanion(
                id: id,
                atualizadoEm: atualizadoEm,
                nome: nome,
                chave: chave,
                cor: cor,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                required String nome,
                required String chave,
                required int cor,
                Value<int> rowid = const Value.absent(),
              }) => MateriasCompanion.insert(
                id: id,
                atualizadoEm: atualizadoEm,
                nome: nome,
                chave: chave,
                cor: cor,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MateriasTable, Materia>(table),
                  $$MateriasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                concursoMateriasRefs = false,
                topicosRefs = false,
                questoesRefs = false,
                sessoesRefs = false,
                questoesProvaRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (concursoMateriasRefs) db.concursoMaterias,
                    if (topicosRefs) db.topicos,
                    if (questoesRefs) db.questoes,
                    if (sessoesRefs) db.sessoes,
                    if (questoesProvaRefs) db.questoesProva,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (concursoMateriasRefs)
                        await $_getPrefetchedData<
                          Materia,
                          $MateriasTable,
                          ConcursoMateria
                        >(
                          currentTable: table,
                          referencedTable: $$MateriasTableReferences
                              ._concursoMateriasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MateriasTableReferences(
                                db,
                                table,
                                p0,
                              ).concursoMateriasRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.materiaId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (topicosRefs)
                        await $_getPrefetchedData<
                          Materia,
                          $MateriasTable,
                          Topico
                        >(
                          currentTable: table,
                          referencedTable: $$MateriasTableReferences
                              ._topicosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MateriasTableReferences(
                                db,
                                table,
                                p0,
                              ).topicosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.materiaId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (questoesRefs)
                        await $_getPrefetchedData<
                          Materia,
                          $MateriasTable,
                          RegistroQuestoes
                        >(
                          currentTable: table,
                          referencedTable: $$MateriasTableReferences
                              ._questoesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MateriasTableReferences(
                                db,
                                table,
                                p0,
                              ).questoesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.materiaId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (sessoesRefs)
                        await $_getPrefetchedData<
                          Materia,
                          $MateriasTable,
                          Sessao
                        >(
                          currentTable: table,
                          referencedTable: $$MateriasTableReferences
                              ._sessoesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MateriasTableReferences(
                                db,
                                table,
                                p0,
                              ).sessoesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.materiaId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (questoesProvaRefs)
                        await $_getPrefetchedData<
                          Materia,
                          $MateriasTable,
                          QuestaoProva
                        >(
                          currentTable: table,
                          referencedTable: $$MateriasTableReferences
                              ._questoesProvaRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MateriasTableReferences(
                                db,
                                table,
                                p0,
                              ).questoesProvaRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.materiaId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$MateriasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MateriasTable,
      Materia,
      $$MateriasTableFilterComposer,
      $$MateriasTableOrderingComposer,
      $$MateriasTableAnnotationComposer,
      $$MateriasTableCreateCompanionBuilder,
      $$MateriasTableUpdateCompanionBuilder,
      (Materia, $$MateriasTableReferences),
      Materia,
      PrefetchHooks Function({
        bool concursoMateriasRefs,
        bool topicosRefs,
        bool questoesRefs,
        bool sessoesRefs,
        bool questoesProvaRefs,
      })
    >;
typedef $$ConcursoMateriasTableCreateCompanionBuilder =
    ConcursoMateriasCompanion Function({
      required String concursoId,
      required String materiaId,
      Value<int> ordem,
      Value<DateTime> atualizadoEm,
      Value<int> peso,
      Value<int> dificuldade,
      Value<bool> noCiclo,
      Value<int> rowid,
    });
typedef $$ConcursoMateriasTableUpdateCompanionBuilder =
    ConcursoMateriasCompanion Function({
      Value<String> concursoId,
      Value<String> materiaId,
      Value<int> ordem,
      Value<DateTime> atualizadoEm,
      Value<int> peso,
      Value<int> dificuldade,
      Value<bool> noCiclo,
      Value<int> rowid,
    });

final class $$ConcursoMateriasTableReferences
    extends
        BaseReferences<_$AppDatabase, $ConcursoMateriasTable, ConcursoMateria> {
  $$ConcursoMateriasTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ConcursosTable _concursoIdTable(_$AppDatabase db) =>
      db.concursos.createAlias('concurso_materias__concurso_id__concursos__id');

  $$ConcursosTableProcessedTableManager get concursoId {
    final $_column = $_itemColumn<String>('concurso_id')!;

    final manager = $$ConcursosTableTableManager(
      $_db,
      $_db.concursos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_concursoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MateriasTable _materiaIdTable(_$AppDatabase db) =>
      db.materias.createAlias('concurso_materias__materia_id__materias__id');

  $$MateriasTableProcessedTableManager get materiaId {
    final $_column = $_itemColumn<String>('materia_id')!;

    final manager = $$MateriasTableTableManager(
      $_db,
      $_db.materias,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_materiaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ConcursoMateriasTableFilterComposer
    extends Composer<_$AppDatabase, $ConcursoMateriasTable> {
  $$ConcursoMateriasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get ordem => $composableBuilder(
    column: $table.ordem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get peso => $composableBuilder(
    column: $table.peso,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dificuldade => $composableBuilder(
    column: $table.dificuldade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get noCiclo => $composableBuilder(
    column: $table.noCiclo,
    builder: (column) => ColumnFilters(column),
  );

  $$ConcursosTableFilterComposer get concursoId {
    final $$ConcursosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.concursoId,
      referencedTable: $db.concursos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConcursosTableFilterComposer(
            $db: $db,
            $table: $db.concursos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MateriasTableFilterComposer get materiaId {
    final $$MateriasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.materiaId,
      referencedTable: $db.materias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MateriasTableFilterComposer(
            $db: $db,
            $table: $db.materias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConcursoMateriasTableOrderingComposer
    extends Composer<_$AppDatabase, $ConcursoMateriasTable> {
  $$ConcursoMateriasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get ordem => $composableBuilder(
    column: $table.ordem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get peso => $composableBuilder(
    column: $table.peso,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dificuldade => $composableBuilder(
    column: $table.dificuldade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get noCiclo => $composableBuilder(
    column: $table.noCiclo,
    builder: (column) => ColumnOrderings(column),
  );

  $$ConcursosTableOrderingComposer get concursoId {
    final $$ConcursosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.concursoId,
      referencedTable: $db.concursos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConcursosTableOrderingComposer(
            $db: $db,
            $table: $db.concursos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MateriasTableOrderingComposer get materiaId {
    final $$MateriasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.materiaId,
      referencedTable: $db.materias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MateriasTableOrderingComposer(
            $db: $db,
            $table: $db.materias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConcursoMateriasTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConcursoMateriasTable> {
  $$ConcursoMateriasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get ordem =>
      $composableBuilder(column: $table.ordem, builder: (column) => column);

  GeneratedColumn<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => column,
  );

  GeneratedColumn<int> get peso =>
      $composableBuilder(column: $table.peso, builder: (column) => column);

  GeneratedColumn<int> get dificuldade => $composableBuilder(
    column: $table.dificuldade,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get noCiclo =>
      $composableBuilder(column: $table.noCiclo, builder: (column) => column);

  $$ConcursosTableAnnotationComposer get concursoId {
    final $$ConcursosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.concursoId,
      referencedTable: $db.concursos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConcursosTableAnnotationComposer(
            $db: $db,
            $table: $db.concursos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MateriasTableAnnotationComposer get materiaId {
    final $$MateriasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.materiaId,
      referencedTable: $db.materias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MateriasTableAnnotationComposer(
            $db: $db,
            $table: $db.materias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConcursoMateriasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConcursoMateriasTable,
          ConcursoMateria,
          $$ConcursoMateriasTableFilterComposer,
          $$ConcursoMateriasTableOrderingComposer,
          $$ConcursoMateriasTableAnnotationComposer,
          $$ConcursoMateriasTableCreateCompanionBuilder,
          $$ConcursoMateriasTableUpdateCompanionBuilder,
          (ConcursoMateria, $$ConcursoMateriasTableReferences),
          ConcursoMateria,
          PrefetchHooks Function({bool concursoId, bool materiaId})
        > {
  $$ConcursoMateriasTableTableManager(
    _$AppDatabase db,
    $ConcursoMateriasTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConcursoMateriasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConcursoMateriasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConcursoMateriasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> concursoId = const Value.absent(),
                Value<String> materiaId = const Value.absent(),
                Value<int> ordem = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<int> peso = const Value.absent(),
                Value<int> dificuldade = const Value.absent(),
                Value<bool> noCiclo = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConcursoMateriasCompanion(
                concursoId: concursoId,
                materiaId: materiaId,
                ordem: ordem,
                atualizadoEm: atualizadoEm,
                peso: peso,
                dificuldade: dificuldade,
                noCiclo: noCiclo,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String concursoId,
                required String materiaId,
                Value<int> ordem = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<int> peso = const Value.absent(),
                Value<int> dificuldade = const Value.absent(),
                Value<bool> noCiclo = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConcursoMateriasCompanion.insert(
                concursoId: concursoId,
                materiaId: materiaId,
                ordem: ordem,
                atualizadoEm: atualizadoEm,
                peso: peso,
                dificuldade: dificuldade,
                noCiclo: noCiclo,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ConcursoMateriasTable, ConcursoMateria>(table),
                  $$ConcursoMateriasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({concursoId = false, materiaId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (concursoId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.concursoId,
                        referencedTable: $$ConcursoMateriasTableReferences
                            ._concursoIdTable(db),
                        referencedColumn: $$ConcursoMateriasTableReferences
                            ._concursoIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (materiaId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.materiaId,
                        referencedTable: $$ConcursoMateriasTableReferences
                            ._materiaIdTable(db),
                        referencedColumn: $$ConcursoMateriasTableReferences
                            ._materiaIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ConcursoMateriasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConcursoMateriasTable,
      ConcursoMateria,
      $$ConcursoMateriasTableFilterComposer,
      $$ConcursoMateriasTableOrderingComposer,
      $$ConcursoMateriasTableAnnotationComposer,
      $$ConcursoMateriasTableCreateCompanionBuilder,
      $$ConcursoMateriasTableUpdateCompanionBuilder,
      (ConcursoMateria, $$ConcursoMateriasTableReferences),
      ConcursoMateria,
      PrefetchHooks Function({bool concursoId, bool materiaId})
    >;
typedef $$TopicosTableCreateCompanionBuilder = TopicosCompanion Function({
  Value<String> id,
  Value<DateTime> atualizadoEm,
  required String materiaId,
  Value<String?> paiId,
  required String nome,
  Value<int> ordem,
  Value<bool> visto,
  Value<DateTime?> vistoEm,
  Value<int> rowid,
});
typedef $$TopicosTableUpdateCompanionBuilder = TopicosCompanion Function({
  Value<String> id,
  Value<DateTime> atualizadoEm,
  Value<String> materiaId,
  Value<String?> paiId,
  Value<String> nome,
  Value<int> ordem,
  Value<bool> visto,
  Value<DateTime?> vistoEm,
  Value<int> rowid,
});

final class $$TopicosTableReferences
    extends BaseReferences<_$AppDatabase, $TopicosTable, Topico> {
  $$TopicosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MateriasTable _materiaIdTable(_$AppDatabase db) =>
      db.materias.createAlias('topicos__materia_id__materias__id');

  $$MateriasTableProcessedTableManager get materiaId {
    final $_column = $_itemColumn<String>('materia_id')!;

    final manager = $$MateriasTableTableManager(
      $_db,
      $_db.materias,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_materiaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TopicosTable _paiIdTable(_$AppDatabase db) =>
      db.topicos.createAlias('topicos__pai_id__topicos__id');

  $$TopicosTableProcessedTableManager? get paiId {
    final $_column = $_itemColumn<String>('pai_id');
    if ($_column == null) return null;
    final manager = $$TopicosTableTableManager(
      $_db,
      $_db.topicos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_paiIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$RevisoesTable, List<Revisao>> _revisoesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.revisoes,
    aliasName: 'topicos__id__revisoes__topico_id',
  );

  $$RevisoesTableProcessedTableManager get revisoesRefs {
    final manager = $$RevisoesTableTableManager(
      $_db,
      $_db.revisoes,
    ).filter((f) => f.topicoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_revisoesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SessoesTable, List<Sessao>> _sessoesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.sessoes,
    aliasName: 'topicos__id__sessoes__topico_id',
  );

  $$SessoesTableProcessedTableManager get sessoesRefs {
    final manager = $$SessoesTableTableManager(
      $_db,
      $_db.sessoes,
    ).filter((f) => f.topicoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessoesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AnexosTable, List<Anexo>> _anexosRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.anexos,
    aliasName: 'topicos__id__anexos__topico_id',
  );

  $$AnexosTableProcessedTableManager get anexosRefs {
    final manager = $$AnexosTableTableManager(
      $_db,
      $_db.anexos,
    ).filter((f) => f.topicoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_anexosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FlashcardsTable, List<Flashcard>>
  _flashcardsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.flashcards,
    aliasName: 'topicos__id__flashcards__topico_id',
  );

  $$FlashcardsTableProcessedTableManager get flashcardsRefs {
    final manager = $$FlashcardsTableTableManager(
      $_db,
      $_db.flashcards,
    ).filter((f) => f.topicoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_flashcardsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TopicoConcursosTable, List<TopicoConcurso>>
  _topicoConcursosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.topicoConcursos,
    aliasName: 'topicos__id__topico_concursos__topico_id',
  );

  $$TopicoConcursosTableProcessedTableManager get topicoConcursosRefs {
    final manager = $$TopicoConcursosTableTableManager(
      $_db,
      $_db.topicoConcursos,
    ).filter((f) => f.topicoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _topicoConcursosRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$QuestoesProvaTable, List<QuestaoProva>>
  _questoesProvaRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.questoesProva,
    aliasName: 'topicos__id__questoes_prova__topico_id',
  );

  $$QuestoesProvaTableProcessedTableManager get questoesProvaRefs {
    final manager = $$QuestoesProvaTableTableManager(
      $_db,
      $_db.questoesProva,
    ).filter((f) => f.topicoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_questoesProvaRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TopicosTableFilterComposer
    extends Composer<_$AppDatabase, $TopicosTable> {
  $$TopicosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ordem => $composableBuilder(
    column: $table.ordem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get visto => $composableBuilder(
    column: $table.visto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get vistoEm => $composableBuilder(
    column: $table.vistoEm,
    builder: (column) => ColumnFilters(column),
  );

  $$MateriasTableFilterComposer get materiaId {
    final $$MateriasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.materiaId,
      referencedTable: $db.materias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MateriasTableFilterComposer(
            $db: $db,
            $table: $db.materias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TopicosTableFilterComposer get paiId {
    final $$TopicosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paiId,
      referencedTable: $db.topicos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TopicosTableFilterComposer(
            $db: $db,
            $table: $db.topicos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> revisoesRefs(
    Expression<bool> Function($$RevisoesTableFilterComposer f) f,
  ) {
    final $$RevisoesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.revisoes,
      getReferencedColumn: (t) => t.topicoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RevisoesTableFilterComposer(
            $db: $db,
            $table: $db.revisoes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sessoesRefs(
    Expression<bool> Function($$SessoesTableFilterComposer f) f,
  ) {
    final $$SessoesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessoes,
      getReferencedColumn: (t) => t.topicoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessoesTableFilterComposer(
            $db: $db,
            $table: $db.sessoes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> anexosRefs(
    Expression<bool> Function($$AnexosTableFilterComposer f) f,
  ) {
    final $$AnexosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.anexos,
      getReferencedColumn: (t) => t.topicoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AnexosTableFilterComposer(
            $db: $db,
            $table: $db.anexos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> flashcardsRefs(
    Expression<bool> Function($$FlashcardsTableFilterComposer f) f,
  ) {
    final $$FlashcardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.flashcards,
      getReferencedColumn: (t) => t.topicoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FlashcardsTableFilterComposer(
            $db: $db,
            $table: $db.flashcards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> topicoConcursosRefs(
    Expression<bool> Function($$TopicoConcursosTableFilterComposer f) f,
  ) {
    final $$TopicoConcursosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.topicoConcursos,
      getReferencedColumn: (t) => t.topicoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TopicoConcursosTableFilterComposer(
            $db: $db,
            $table: $db.topicoConcursos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> questoesProvaRefs(
    Expression<bool> Function($$QuestoesProvaTableFilterComposer f) f,
  ) {
    final $$QuestoesProvaTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.questoesProva,
      getReferencedColumn: (t) => t.topicoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestoesProvaTableFilterComposer(
            $db: $db,
            $table: $db.questoesProva,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TopicosTableOrderingComposer
    extends Composer<_$AppDatabase, $TopicosTable> {
  $$TopicosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ordem => $composableBuilder(
    column: $table.ordem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get visto => $composableBuilder(
    column: $table.visto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get vistoEm => $composableBuilder(
    column: $table.vistoEm,
    builder: (column) => ColumnOrderings(column),
  );

  $$MateriasTableOrderingComposer get materiaId {
    final $$MateriasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.materiaId,
      referencedTable: $db.materias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MateriasTableOrderingComposer(
            $db: $db,
            $table: $db.materias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TopicosTableOrderingComposer get paiId {
    final $$TopicosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paiId,
      referencedTable: $db.topicos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TopicosTableOrderingComposer(
            $db: $db,
            $table: $db.topicos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TopicosTableAnnotationComposer
    extends Composer<_$AppDatabase, $TopicosTable> {
  $$TopicosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<int> get ordem =>
      $composableBuilder(column: $table.ordem, builder: (column) => column);

  GeneratedColumn<bool> get visto =>
      $composableBuilder(column: $table.visto, builder: (column) => column);

  GeneratedColumn<DateTime> get vistoEm =>
      $composableBuilder(column: $table.vistoEm, builder: (column) => column);

  $$MateriasTableAnnotationComposer get materiaId {
    final $$MateriasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.materiaId,
      referencedTable: $db.materias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MateriasTableAnnotationComposer(
            $db: $db,
            $table: $db.materias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TopicosTableAnnotationComposer get paiId {
    final $$TopicosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paiId,
      referencedTable: $db.topicos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TopicosTableAnnotationComposer(
            $db: $db,
            $table: $db.topicos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> revisoesRefs<T extends Object>(
    Expression<T> Function($$RevisoesTableAnnotationComposer a) f,
  ) {
    final $$RevisoesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.revisoes,
      getReferencedColumn: (t) => t.topicoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RevisoesTableAnnotationComposer(
            $db: $db,
            $table: $db.revisoes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sessoesRefs<T extends Object>(
    Expression<T> Function($$SessoesTableAnnotationComposer a) f,
  ) {
    final $$SessoesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessoes,
      getReferencedColumn: (t) => t.topicoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessoesTableAnnotationComposer(
            $db: $db,
            $table: $db.sessoes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> anexosRefs<T extends Object>(
    Expression<T> Function($$AnexosTableAnnotationComposer a) f,
  ) {
    final $$AnexosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.anexos,
      getReferencedColumn: (t) => t.topicoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AnexosTableAnnotationComposer(
            $db: $db,
            $table: $db.anexos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> flashcardsRefs<T extends Object>(
    Expression<T> Function($$FlashcardsTableAnnotationComposer a) f,
  ) {
    final $$FlashcardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.flashcards,
      getReferencedColumn: (t) => t.topicoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FlashcardsTableAnnotationComposer(
            $db: $db,
            $table: $db.flashcards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> topicoConcursosRefs<T extends Object>(
    Expression<T> Function($$TopicoConcursosTableAnnotationComposer a) f,
  ) {
    final $$TopicoConcursosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.topicoConcursos,
      getReferencedColumn: (t) => t.topicoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TopicoConcursosTableAnnotationComposer(
            $db: $db,
            $table: $db.topicoConcursos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> questoesProvaRefs<T extends Object>(
    Expression<T> Function($$QuestoesProvaTableAnnotationComposer a) f,
  ) {
    final $$QuestoesProvaTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.questoesProva,
      getReferencedColumn: (t) => t.topicoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestoesProvaTableAnnotationComposer(
            $db: $db,
            $table: $db.questoesProva,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TopicosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TopicosTable,
          Topico,
          $$TopicosTableFilterComposer,
          $$TopicosTableOrderingComposer,
          $$TopicosTableAnnotationComposer,
          $$TopicosTableCreateCompanionBuilder,
          $$TopicosTableUpdateCompanionBuilder,
          (Topico, $$TopicosTableReferences),
          Topico,
          PrefetchHooks Function({
            bool materiaId,
            bool paiId,
            bool revisoesRefs,
            bool sessoesRefs,
            bool anexosRefs,
            bool flashcardsRefs,
            bool topicoConcursosRefs,
            bool questoesProvaRefs,
          })
        > {
  $$TopicosTableTableManager(_$AppDatabase db, $TopicosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TopicosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TopicosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TopicosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<String> materiaId = const Value.absent(),
                Value<String?> paiId = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<int> ordem = const Value.absent(),
                Value<bool> visto = const Value.absent(),
                Value<DateTime?> vistoEm = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TopicosCompanion(
                id: id,
                atualizadoEm: atualizadoEm,
                materiaId: materiaId,
                paiId: paiId,
                nome: nome,
                ordem: ordem,
                visto: visto,
                vistoEm: vistoEm,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                required String materiaId,
                Value<String?> paiId = const Value.absent(),
                required String nome,
                Value<int> ordem = const Value.absent(),
                Value<bool> visto = const Value.absent(),
                Value<DateTime?> vistoEm = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TopicosCompanion.insert(
                id: id,
                atualizadoEm: atualizadoEm,
                materiaId: materiaId,
                paiId: paiId,
                nome: nome,
                ordem: ordem,
                visto: visto,
                vistoEm: vistoEm,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TopicosTable, Topico>(table),
                  $$TopicosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                materiaId = false,
                paiId = false,
                revisoesRefs = false,
                sessoesRefs = false,
                anexosRefs = false,
                flashcardsRefs = false,
                topicoConcursosRefs = false,
                questoesProvaRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (revisoesRefs) db.revisoes,
                    if (sessoesRefs) db.sessoes,
                    if (anexosRefs) db.anexos,
                    if (flashcardsRefs) db.flashcards,
                    if (topicoConcursosRefs) db.topicoConcursos,
                    if (questoesProvaRefs) db.questoesProva,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (materiaId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.materiaId,
                            referencedTable: $$TopicosTableReferences
                                ._materiaIdTable(db),
                            referencedColumn: $$TopicosTableReferences
                                ._materiaIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (paiId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.paiId,
                            referencedTable: $$TopicosTableReferences
                                ._paiIdTable(db),
                            referencedColumn: $$TopicosTableReferences
                                ._paiIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (revisoesRefs)
                        await $_getPrefetchedData<
                          Topico,
                          $TopicosTable,
                          Revisao
                        >(
                          currentTable: table,
                          referencedTable: $$TopicosTableReferences
                              ._revisoesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TopicosTableReferences(
                                db,
                                table,
                                p0,
                              ).revisoesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.topicoId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (sessoesRefs)
                        await $_getPrefetchedData<
                          Topico,
                          $TopicosTable,
                          Sessao
                        >(
                          currentTable: table,
                          referencedTable: $$TopicosTableReferences
                              ._sessoesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TopicosTableReferences(
                                db,
                                table,
                                p0,
                              ).sessoesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.topicoId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (anexosRefs)
                        await $_getPrefetchedData<Topico, $TopicosTable, Anexo>(
                          currentTable: table,
                          referencedTable: $$TopicosTableReferences
                              ._anexosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TopicosTableReferences(
                                db,
                                table,
                                p0,
                              ).anexosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.topicoId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (flashcardsRefs)
                        await $_getPrefetchedData<
                          Topico,
                          $TopicosTable,
                          Flashcard
                        >(
                          currentTable: table,
                          referencedTable: $$TopicosTableReferences
                              ._flashcardsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TopicosTableReferences(
                                db,
                                table,
                                p0,
                              ).flashcardsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.topicoId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (topicoConcursosRefs)
                        await $_getPrefetchedData<
                          Topico,
                          $TopicosTable,
                          TopicoConcurso
                        >(
                          currentTable: table,
                          referencedTable: $$TopicosTableReferences
                              ._topicoConcursosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TopicosTableReferences(
                                db,
                                table,
                                p0,
                              ).topicoConcursosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.topicoId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (questoesProvaRefs)
                        await $_getPrefetchedData<
                          Topico,
                          $TopicosTable,
                          QuestaoProva
                        >(
                          currentTable: table,
                          referencedTable: $$TopicosTableReferences
                              ._questoesProvaRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TopicosTableReferences(
                                db,
                                table,
                                p0,
                              ).questoesProvaRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.topicoId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TopicosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TopicosTable,
      Topico,
      $$TopicosTableFilterComposer,
      $$TopicosTableOrderingComposer,
      $$TopicosTableAnnotationComposer,
      $$TopicosTableCreateCompanionBuilder,
      $$TopicosTableUpdateCompanionBuilder,
      (Topico, $$TopicosTableReferences),
      Topico,
      PrefetchHooks Function({
        bool materiaId,
        bool paiId,
        bool revisoesRefs,
        bool sessoesRefs,
        bool anexosRefs,
        bool flashcardsRefs,
        bool topicoConcursosRefs,
        bool questoesProvaRefs,
      })
    >;
typedef $$RevisoesTableCreateCompanionBuilder = RevisoesCompanion Function({
  Value<String> id,
  Value<DateTime> atualizadoEm,
  required String topicoId,
  required DateTime dataPrevista,
  required int intervaloDias,
  Value<DateTime?> feitaEm,
  Value<int> rowid,
});
typedef $$RevisoesTableUpdateCompanionBuilder = RevisoesCompanion Function({
  Value<String> id,
  Value<DateTime> atualizadoEm,
  Value<String> topicoId,
  Value<DateTime> dataPrevista,
  Value<int> intervaloDias,
  Value<DateTime?> feitaEm,
  Value<int> rowid,
});

final class $$RevisoesTableReferences
    extends BaseReferences<_$AppDatabase, $RevisoesTable, Revisao> {
  $$RevisoesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TopicosTable _topicoIdTable(_$AppDatabase db) =>
      db.topicos.createAlias('revisoes__topico_id__topicos__id');

  $$TopicosTableProcessedTableManager get topicoId {
    final $_column = $_itemColumn<String>('topico_id')!;

    final manager = $$TopicosTableTableManager(
      $_db,
      $_db.topicos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_topicoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RevisoesTableFilterComposer
    extends Composer<_$AppDatabase, $RevisoesTable> {
  $$RevisoesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dataPrevista => $composableBuilder(
    column: $table.dataPrevista,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervaloDias => $composableBuilder(
    column: $table.intervaloDias,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get feitaEm => $composableBuilder(
    column: $table.feitaEm,
    builder: (column) => ColumnFilters(column),
  );

  $$TopicosTableFilterComposer get topicoId {
    final $$TopicosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.topicoId,
      referencedTable: $db.topicos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TopicosTableFilterComposer(
            $db: $db,
            $table: $db.topicos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RevisoesTableOrderingComposer
    extends Composer<_$AppDatabase, $RevisoesTable> {
  $$RevisoesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dataPrevista => $composableBuilder(
    column: $table.dataPrevista,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervaloDias => $composableBuilder(
    column: $table.intervaloDias,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get feitaEm => $composableBuilder(
    column: $table.feitaEm,
    builder: (column) => ColumnOrderings(column),
  );

  $$TopicosTableOrderingComposer get topicoId {
    final $$TopicosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.topicoId,
      referencedTable: $db.topicos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TopicosTableOrderingComposer(
            $db: $db,
            $table: $db.topicos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RevisoesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RevisoesTable> {
  $$RevisoesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dataPrevista => $composableBuilder(
    column: $table.dataPrevista,
    builder: (column) => column,
  );

  GeneratedColumn<int> get intervaloDias => $composableBuilder(
    column: $table.intervaloDias,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get feitaEm =>
      $composableBuilder(column: $table.feitaEm, builder: (column) => column);

  $$TopicosTableAnnotationComposer get topicoId {
    final $$TopicosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.topicoId,
      referencedTable: $db.topicos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TopicosTableAnnotationComposer(
            $db: $db,
            $table: $db.topicos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RevisoesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RevisoesTable,
          Revisao,
          $$RevisoesTableFilterComposer,
          $$RevisoesTableOrderingComposer,
          $$RevisoesTableAnnotationComposer,
          $$RevisoesTableCreateCompanionBuilder,
          $$RevisoesTableUpdateCompanionBuilder,
          (Revisao, $$RevisoesTableReferences),
          Revisao,
          PrefetchHooks Function({bool topicoId})
        > {
  $$RevisoesTableTableManager(_$AppDatabase db, $RevisoesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RevisoesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RevisoesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RevisoesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<String> topicoId = const Value.absent(),
                Value<DateTime> dataPrevista = const Value.absent(),
                Value<int> intervaloDias = const Value.absent(),
                Value<DateTime?> feitaEm = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RevisoesCompanion(
                id: id,
                atualizadoEm: atualizadoEm,
                topicoId: topicoId,
                dataPrevista: dataPrevista,
                intervaloDias: intervaloDias,
                feitaEm: feitaEm,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                required String topicoId,
                required DateTime dataPrevista,
                required int intervaloDias,
                Value<DateTime?> feitaEm = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RevisoesCompanion.insert(
                id: id,
                atualizadoEm: atualizadoEm,
                topicoId: topicoId,
                dataPrevista: dataPrevista,
                intervaloDias: intervaloDias,
                feitaEm: feitaEm,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RevisoesTable, Revisao>(table),
                  $$RevisoesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({topicoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (topicoId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.topicoId,
                        referencedTable: $$RevisoesTableReferences
                            ._topicoIdTable(db),
                        referencedColumn: $$RevisoesTableReferences
                            ._topicoIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RevisoesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RevisoesTable,
      Revisao,
      $$RevisoesTableFilterComposer,
      $$RevisoesTableOrderingComposer,
      $$RevisoesTableAnnotationComposer,
      $$RevisoesTableCreateCompanionBuilder,
      $$RevisoesTableUpdateCompanionBuilder,
      (Revisao, $$RevisoesTableReferences),
      Revisao,
      PrefetchHooks Function({bool topicoId})
    >;
typedef $$QuestoesTableCreateCompanionBuilder = QuestoesCompanion Function({
  Value<String> id,
  Value<DateTime> atualizadoEm,
  required String materiaId,
  required DateTime data,
  required int feitas,
  required int acertos,
  Value<int> rowid,
});
typedef $$QuestoesTableUpdateCompanionBuilder = QuestoesCompanion Function({
  Value<String> id,
  Value<DateTime> atualizadoEm,
  Value<String> materiaId,
  Value<DateTime> data,
  Value<int> feitas,
  Value<int> acertos,
  Value<int> rowid,
});

final class $$QuestoesTableReferences
    extends BaseReferences<_$AppDatabase, $QuestoesTable, RegistroQuestoes> {
  $$QuestoesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MateriasTable _materiaIdTable(_$AppDatabase db) =>
      db.materias.createAlias('questoes__materia_id__materias__id');

  $$MateriasTableProcessedTableManager get materiaId {
    final $_column = $_itemColumn<String>('materia_id')!;

    final manager = $$MateriasTableTableManager(
      $_db,
      $_db.materias,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_materiaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$QuestoesTableFilterComposer
    extends Composer<_$AppDatabase, $QuestoesTable> {
  $$QuestoesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get feitas => $composableBuilder(
    column: $table.feitas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get acertos => $composableBuilder(
    column: $table.acertos,
    builder: (column) => ColumnFilters(column),
  );

  $$MateriasTableFilterComposer get materiaId {
    final $$MateriasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.materiaId,
      referencedTable: $db.materias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MateriasTableFilterComposer(
            $db: $db,
            $table: $db.materias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuestoesTableOrderingComposer
    extends Composer<_$AppDatabase, $QuestoesTable> {
  $$QuestoesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get feitas => $composableBuilder(
    column: $table.feitas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get acertos => $composableBuilder(
    column: $table.acertos,
    builder: (column) => ColumnOrderings(column),
  );

  $$MateriasTableOrderingComposer get materiaId {
    final $$MateriasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.materiaId,
      referencedTable: $db.materias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MateriasTableOrderingComposer(
            $db: $db,
            $table: $db.materias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuestoesTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuestoesTable> {
  $$QuestoesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<int> get feitas =>
      $composableBuilder(column: $table.feitas, builder: (column) => column);

  GeneratedColumn<int> get acertos =>
      $composableBuilder(column: $table.acertos, builder: (column) => column);

  $$MateriasTableAnnotationComposer get materiaId {
    final $$MateriasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.materiaId,
      referencedTable: $db.materias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MateriasTableAnnotationComposer(
            $db: $db,
            $table: $db.materias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuestoesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuestoesTable,
          RegistroQuestoes,
          $$QuestoesTableFilterComposer,
          $$QuestoesTableOrderingComposer,
          $$QuestoesTableAnnotationComposer,
          $$QuestoesTableCreateCompanionBuilder,
          $$QuestoesTableUpdateCompanionBuilder,
          (RegistroQuestoes, $$QuestoesTableReferences),
          RegistroQuestoes,
          PrefetchHooks Function({bool materiaId})
        > {
  $$QuestoesTableTableManager(_$AppDatabase db, $QuestoesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuestoesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuestoesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuestoesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<String> materiaId = const Value.absent(),
                Value<DateTime> data = const Value.absent(),
                Value<int> feitas = const Value.absent(),
                Value<int> acertos = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuestoesCompanion(
                id: id,
                atualizadoEm: atualizadoEm,
                materiaId: materiaId,
                data: data,
                feitas: feitas,
                acertos: acertos,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                required String materiaId,
                required DateTime data,
                required int feitas,
                required int acertos,
                Value<int> rowid = const Value.absent(),
              }) => QuestoesCompanion.insert(
                id: id,
                atualizadoEm: atualizadoEm,
                materiaId: materiaId,
                data: data,
                feitas: feitas,
                acertos: acertos,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$QuestoesTable, RegistroQuestoes>(table),
                  $$QuestoesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({materiaId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (materiaId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.materiaId,
                        referencedTable: $$QuestoesTableReferences
                            ._materiaIdTable(db),
                        referencedColumn: $$QuestoesTableReferences
                            ._materiaIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$QuestoesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuestoesTable,
      RegistroQuestoes,
      $$QuestoesTableFilterComposer,
      $$QuestoesTableOrderingComposer,
      $$QuestoesTableAnnotationComposer,
      $$QuestoesTableCreateCompanionBuilder,
      $$QuestoesTableUpdateCompanionBuilder,
      (RegistroQuestoes, $$QuestoesTableReferences),
      RegistroQuestoes,
      PrefetchHooks Function({bool materiaId})
    >;
typedef $$SessoesTableCreateCompanionBuilder = SessoesCompanion Function({
  Value<String> id,
  Value<DateTime> atualizadoEm,
  Value<String?> materiaId,
  Value<String?> topicoId,
  required DateTime dia,
  Value<DateTime> inicio,
  required int minutos,
  Value<String?> metodo,
  Value<int> questoesFeitas,
  Value<int> questoesAcertos,
  Value<int> paginas,
  Value<String?> pontoParada,
  Value<String?> origem,
  Value<int> rowid,
});
typedef $$SessoesTableUpdateCompanionBuilder = SessoesCompanion Function({
  Value<String> id,
  Value<DateTime> atualizadoEm,
  Value<String?> materiaId,
  Value<String?> topicoId,
  Value<DateTime> dia,
  Value<DateTime> inicio,
  Value<int> minutos,
  Value<String?> metodo,
  Value<int> questoesFeitas,
  Value<int> questoesAcertos,
  Value<int> paginas,
  Value<String?> pontoParada,
  Value<String?> origem,
  Value<int> rowid,
});

final class $$SessoesTableReferences
    extends BaseReferences<_$AppDatabase, $SessoesTable, Sessao> {
  $$SessoesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MateriasTable _materiaIdTable(_$AppDatabase db) =>
      db.materias.createAlias('sessoes__materia_id__materias__id');

  $$MateriasTableProcessedTableManager? get materiaId {
    final $_column = $_itemColumn<String>('materia_id');
    if ($_column == null) return null;
    final manager = $$MateriasTableTableManager(
      $_db,
      $_db.materias,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_materiaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TopicosTable _topicoIdTable(_$AppDatabase db) =>
      db.topicos.createAlias('sessoes__topico_id__topicos__id');

  $$TopicosTableProcessedTableManager? get topicoId {
    final $_column = $_itemColumn<String>('topico_id');
    if ($_column == null) return null;
    final manager = $$TopicosTableTableManager(
      $_db,
      $_db.topicos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_topicoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SessoesTableFilterComposer
    extends Composer<_$AppDatabase, $SessoesTable> {
  $$SessoesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dia => $composableBuilder(
    column: $table.dia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get inicio => $composableBuilder(
    column: $table.inicio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minutos => $composableBuilder(
    column: $table.minutos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metodo => $composableBuilder(
    column: $table.metodo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get questoesFeitas => $composableBuilder(
    column: $table.questoesFeitas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get questoesAcertos => $composableBuilder(
    column: $table.questoesAcertos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paginas => $composableBuilder(
    column: $table.paginas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pontoParada => $composableBuilder(
    column: $table.pontoParada,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origem => $composableBuilder(
    column: $table.origem,
    builder: (column) => ColumnFilters(column),
  );

  $$MateriasTableFilterComposer get materiaId {
    final $$MateriasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.materiaId,
      referencedTable: $db.materias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MateriasTableFilterComposer(
            $db: $db,
            $table: $db.materias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TopicosTableFilterComposer get topicoId {
    final $$TopicosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.topicoId,
      referencedTable: $db.topicos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TopicosTableFilterComposer(
            $db: $db,
            $table: $db.topicos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessoesTableOrderingComposer
    extends Composer<_$AppDatabase, $SessoesTable> {
  $$SessoesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dia => $composableBuilder(
    column: $table.dia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get inicio => $composableBuilder(
    column: $table.inicio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minutos => $composableBuilder(
    column: $table.minutos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metodo => $composableBuilder(
    column: $table.metodo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get questoesFeitas => $composableBuilder(
    column: $table.questoesFeitas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get questoesAcertos => $composableBuilder(
    column: $table.questoesAcertos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paginas => $composableBuilder(
    column: $table.paginas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pontoParada => $composableBuilder(
    column: $table.pontoParada,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origem => $composableBuilder(
    column: $table.origem,
    builder: (column) => ColumnOrderings(column),
  );

  $$MateriasTableOrderingComposer get materiaId {
    final $$MateriasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.materiaId,
      referencedTable: $db.materias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MateriasTableOrderingComposer(
            $db: $db,
            $table: $db.materias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TopicosTableOrderingComposer get topicoId {
    final $$TopicosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.topicoId,
      referencedTable: $db.topicos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TopicosTableOrderingComposer(
            $db: $db,
            $table: $db.topicos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessoesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessoesTable> {
  $$SessoesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dia =>
      $composableBuilder(column: $table.dia, builder: (column) => column);

  GeneratedColumn<DateTime> get inicio =>
      $composableBuilder(column: $table.inicio, builder: (column) => column);

  GeneratedColumn<int> get minutos =>
      $composableBuilder(column: $table.minutos, builder: (column) => column);

  GeneratedColumn<String> get metodo =>
      $composableBuilder(column: $table.metodo, builder: (column) => column);

  GeneratedColumn<int> get questoesFeitas => $composableBuilder(
    column: $table.questoesFeitas,
    builder: (column) => column,
  );

  GeneratedColumn<int> get questoesAcertos => $composableBuilder(
    column: $table.questoesAcertos,
    builder: (column) => column,
  );

  GeneratedColumn<int> get paginas =>
      $composableBuilder(column: $table.paginas, builder: (column) => column);

  GeneratedColumn<String> get pontoParada => $composableBuilder(
    column: $table.pontoParada,
    builder: (column) => column,
  );

  GeneratedColumn<String> get origem =>
      $composableBuilder(column: $table.origem, builder: (column) => column);

  $$MateriasTableAnnotationComposer get materiaId {
    final $$MateriasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.materiaId,
      referencedTable: $db.materias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MateriasTableAnnotationComposer(
            $db: $db,
            $table: $db.materias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TopicosTableAnnotationComposer get topicoId {
    final $$TopicosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.topicoId,
      referencedTable: $db.topicos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TopicosTableAnnotationComposer(
            $db: $db,
            $table: $db.topicos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessoesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessoesTable,
          Sessao,
          $$SessoesTableFilterComposer,
          $$SessoesTableOrderingComposer,
          $$SessoesTableAnnotationComposer,
          $$SessoesTableCreateCompanionBuilder,
          $$SessoesTableUpdateCompanionBuilder,
          (Sessao, $$SessoesTableReferences),
          Sessao,
          PrefetchHooks Function({bool materiaId, bool topicoId})
        > {
  $$SessoesTableTableManager(_$AppDatabase db, $SessoesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessoesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessoesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessoesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<String?> materiaId = const Value.absent(),
                Value<String?> topicoId = const Value.absent(),
                Value<DateTime> dia = const Value.absent(),
                Value<DateTime> inicio = const Value.absent(),
                Value<int> minutos = const Value.absent(),
                Value<String?> metodo = const Value.absent(),
                Value<int> questoesFeitas = const Value.absent(),
                Value<int> questoesAcertos = const Value.absent(),
                Value<int> paginas = const Value.absent(),
                Value<String?> pontoParada = const Value.absent(),
                Value<String?> origem = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessoesCompanion(
                id: id,
                atualizadoEm: atualizadoEm,
                materiaId: materiaId,
                topicoId: topicoId,
                dia: dia,
                inicio: inicio,
                minutos: minutos,
                metodo: metodo,
                questoesFeitas: questoesFeitas,
                questoesAcertos: questoesAcertos,
                paginas: paginas,
                pontoParada: pontoParada,
                origem: origem,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<String?> materiaId = const Value.absent(),
                Value<String?> topicoId = const Value.absent(),
                required DateTime dia,
                Value<DateTime> inicio = const Value.absent(),
                required int minutos,
                Value<String?> metodo = const Value.absent(),
                Value<int> questoesFeitas = const Value.absent(),
                Value<int> questoesAcertos = const Value.absent(),
                Value<int> paginas = const Value.absent(),
                Value<String?> pontoParada = const Value.absent(),
                Value<String?> origem = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessoesCompanion.insert(
                id: id,
                atualizadoEm: atualizadoEm,
                materiaId: materiaId,
                topicoId: topicoId,
                dia: dia,
                inicio: inicio,
                minutos: minutos,
                metodo: metodo,
                questoesFeitas: questoesFeitas,
                questoesAcertos: questoesAcertos,
                paginas: paginas,
                pontoParada: pontoParada,
                origem: origem,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SessoesTable, Sessao>(table),
                  $$SessoesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({materiaId = false, topicoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (materiaId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.materiaId,
                        referencedTable: $$SessoesTableReferences
                            ._materiaIdTable(db),
                        referencedColumn: $$SessoesTableReferences
                            ._materiaIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (topicoId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.topicoId,
                        referencedTable: $$SessoesTableReferences
                            ._topicoIdTable(db),
                        referencedColumn: $$SessoesTableReferences
                            ._topicoIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SessoesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessoesTable,
      Sessao,
      $$SessoesTableFilterComposer,
      $$SessoesTableOrderingComposer,
      $$SessoesTableAnnotationComposer,
      $$SessoesTableCreateCompanionBuilder,
      $$SessoesTableUpdateCompanionBuilder,
      (Sessao, $$SessoesTableReferences),
      Sessao,
      PrefetchHooks Function({bool materiaId, bool topicoId})
    >;
typedef $$AnexosTableCreateCompanionBuilder = AnexosCompanion Function({
  Value<String> id,
  Value<DateTime> atualizadoEm,
  required String topicoId,
  required String tipo,
  required String nome,
  required String arquivo,
  Value<int> bytes,
  Value<DateTime> criadoEm,
  Value<int> rowid,
});
typedef $$AnexosTableUpdateCompanionBuilder = AnexosCompanion Function({
  Value<String> id,
  Value<DateTime> atualizadoEm,
  Value<String> topicoId,
  Value<String> tipo,
  Value<String> nome,
  Value<String> arquivo,
  Value<int> bytes,
  Value<DateTime> criadoEm,
  Value<int> rowid,
});

final class $$AnexosTableReferences
    extends BaseReferences<_$AppDatabase, $AnexosTable, Anexo> {
  $$AnexosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TopicosTable _topicoIdTable(_$AppDatabase db) =>
      db.topicos.createAlias('anexos__topico_id__topicos__id');

  $$TopicosTableProcessedTableManager get topicoId {
    final $_column = $_itemColumn<String>('topico_id')!;

    final manager = $$TopicosTableTableManager(
      $_db,
      $_db.topicos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_topicoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AnexosTableFilterComposer
    extends Composer<_$AppDatabase, $AnexosTable> {
  $$AnexosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get arquivo => $composableBuilder(
    column: $table.arquivo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnFilters(column),
  );

  $$TopicosTableFilterComposer get topicoId {
    final $$TopicosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.topicoId,
      referencedTable: $db.topicos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TopicosTableFilterComposer(
            $db: $db,
            $table: $db.topicos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AnexosTableOrderingComposer
    extends Composer<_$AppDatabase, $AnexosTable> {
  $$AnexosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get arquivo => $composableBuilder(
    column: $table.arquivo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  $$TopicosTableOrderingComposer get topicoId {
    final $$TopicosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.topicoId,
      referencedTable: $db.topicos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TopicosTableOrderingComposer(
            $db: $db,
            $table: $db.topicos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AnexosTableAnnotationComposer
    extends Composer<_$AppDatabase, $AnexosTable> {
  $$AnexosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<String> get arquivo =>
      $composableBuilder(column: $table.arquivo, builder: (column) => column);

  GeneratedColumn<int> get bytes =>
      $composableBuilder(column: $table.bytes, builder: (column) => column);

  GeneratedColumn<DateTime> get criadoEm =>
      $composableBuilder(column: $table.criadoEm, builder: (column) => column);

  $$TopicosTableAnnotationComposer get topicoId {
    final $$TopicosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.topicoId,
      referencedTable: $db.topicos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TopicosTableAnnotationComposer(
            $db: $db,
            $table: $db.topicos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AnexosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AnexosTable,
          Anexo,
          $$AnexosTableFilterComposer,
          $$AnexosTableOrderingComposer,
          $$AnexosTableAnnotationComposer,
          $$AnexosTableCreateCompanionBuilder,
          $$AnexosTableUpdateCompanionBuilder,
          (Anexo, $$AnexosTableReferences),
          Anexo,
          PrefetchHooks Function({bool topicoId})
        > {
  $$AnexosTableTableManager(_$AppDatabase db, $AnexosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnexosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnexosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnexosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<String> topicoId = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<String> arquivo = const Value.absent(),
                Value<int> bytes = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AnexosCompanion(
                id: id,
                atualizadoEm: atualizadoEm,
                topicoId: topicoId,
                tipo: tipo,
                nome: nome,
                arquivo: arquivo,
                bytes: bytes,
                criadoEm: criadoEm,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                required String topicoId,
                required String tipo,
                required String nome,
                required String arquivo,
                Value<int> bytes = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AnexosCompanion.insert(
                id: id,
                atualizadoEm: atualizadoEm,
                topicoId: topicoId,
                tipo: tipo,
                nome: nome,
                arquivo: arquivo,
                bytes: bytes,
                criadoEm: criadoEm,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AnexosTable, Anexo>(table),
                  $$AnexosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({topicoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (topicoId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.topicoId,
                        referencedTable: $$AnexosTableReferences._topicoIdTable(
                          db,
                        ),
                        referencedColumn: $$AnexosTableReferences
                            ._topicoIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AnexosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AnexosTable,
      Anexo,
      $$AnexosTableFilterComposer,
      $$AnexosTableOrderingComposer,
      $$AnexosTableAnnotationComposer,
      $$AnexosTableCreateCompanionBuilder,
      $$AnexosTableUpdateCompanionBuilder,
      (Anexo, $$AnexosTableReferences),
      Anexo,
      PrefetchHooks Function({bool topicoId})
    >;
typedef $$FlashcardsTableCreateCompanionBuilder = FlashcardsCompanion Function({
  Value<String> id,
  Value<DateTime> atualizadoEm,
  required String topicoId,
  required String frente,
  required String verso,
  Value<int> ordem,
  Value<int> caixa,
  Value<DateTime> proximaRevisao,
  Value<int> acertos,
  Value<int> erros,
  Value<DateTime> criadoEm,
  Value<int> rowid,
});
typedef $$FlashcardsTableUpdateCompanionBuilder = FlashcardsCompanion Function({
  Value<String> id,
  Value<DateTime> atualizadoEm,
  Value<String> topicoId,
  Value<String> frente,
  Value<String> verso,
  Value<int> ordem,
  Value<int> caixa,
  Value<DateTime> proximaRevisao,
  Value<int> acertos,
  Value<int> erros,
  Value<DateTime> criadoEm,
  Value<int> rowid,
});

final class $$FlashcardsTableReferences
    extends BaseReferences<_$AppDatabase, $FlashcardsTable, Flashcard> {
  $$FlashcardsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TopicosTable _topicoIdTable(_$AppDatabase db) =>
      db.topicos.createAlias('flashcards__topico_id__topicos__id');

  $$TopicosTableProcessedTableManager get topicoId {
    final $_column = $_itemColumn<String>('topico_id')!;

    final manager = $$TopicosTableTableManager(
      $_db,
      $_db.topicos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_topicoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FlashcardsTableFilterComposer
    extends Composer<_$AppDatabase, $FlashcardsTable> {
  $$FlashcardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frente => $composableBuilder(
    column: $table.frente,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get verso => $composableBuilder(
    column: $table.verso,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ordem => $composableBuilder(
    column: $table.ordem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get caixa => $composableBuilder(
    column: $table.caixa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get proximaRevisao => $composableBuilder(
    column: $table.proximaRevisao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get acertos => $composableBuilder(
    column: $table.acertos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get erros => $composableBuilder(
    column: $table.erros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnFilters(column),
  );

  $$TopicosTableFilterComposer get topicoId {
    final $$TopicosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.topicoId,
      referencedTable: $db.topicos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TopicosTableFilterComposer(
            $db: $db,
            $table: $db.topicos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FlashcardsTableOrderingComposer
    extends Composer<_$AppDatabase, $FlashcardsTable> {
  $$FlashcardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frente => $composableBuilder(
    column: $table.frente,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get verso => $composableBuilder(
    column: $table.verso,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ordem => $composableBuilder(
    column: $table.ordem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get caixa => $composableBuilder(
    column: $table.caixa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get proximaRevisao => $composableBuilder(
    column: $table.proximaRevisao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get acertos => $composableBuilder(
    column: $table.acertos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get erros => $composableBuilder(
    column: $table.erros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  $$TopicosTableOrderingComposer get topicoId {
    final $$TopicosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.topicoId,
      referencedTable: $db.topicos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TopicosTableOrderingComposer(
            $db: $db,
            $table: $db.topicos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FlashcardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FlashcardsTable> {
  $$FlashcardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get frente =>
      $composableBuilder(column: $table.frente, builder: (column) => column);

  GeneratedColumn<String> get verso =>
      $composableBuilder(column: $table.verso, builder: (column) => column);

  GeneratedColumn<int> get ordem =>
      $composableBuilder(column: $table.ordem, builder: (column) => column);

  GeneratedColumn<int> get caixa =>
      $composableBuilder(column: $table.caixa, builder: (column) => column);

  GeneratedColumn<DateTime> get proximaRevisao => $composableBuilder(
    column: $table.proximaRevisao,
    builder: (column) => column,
  );

  GeneratedColumn<int> get acertos =>
      $composableBuilder(column: $table.acertos, builder: (column) => column);

  GeneratedColumn<int> get erros =>
      $composableBuilder(column: $table.erros, builder: (column) => column);

  GeneratedColumn<DateTime> get criadoEm =>
      $composableBuilder(column: $table.criadoEm, builder: (column) => column);

  $$TopicosTableAnnotationComposer get topicoId {
    final $$TopicosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.topicoId,
      referencedTable: $db.topicos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TopicosTableAnnotationComposer(
            $db: $db,
            $table: $db.topicos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FlashcardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FlashcardsTable,
          Flashcard,
          $$FlashcardsTableFilterComposer,
          $$FlashcardsTableOrderingComposer,
          $$FlashcardsTableAnnotationComposer,
          $$FlashcardsTableCreateCompanionBuilder,
          $$FlashcardsTableUpdateCompanionBuilder,
          (Flashcard, $$FlashcardsTableReferences),
          Flashcard,
          PrefetchHooks Function({bool topicoId})
        > {
  $$FlashcardsTableTableManager(_$AppDatabase db, $FlashcardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FlashcardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FlashcardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FlashcardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<String> topicoId = const Value.absent(),
                Value<String> frente = const Value.absent(),
                Value<String> verso = const Value.absent(),
                Value<int> ordem = const Value.absent(),
                Value<int> caixa = const Value.absent(),
                Value<DateTime> proximaRevisao = const Value.absent(),
                Value<int> acertos = const Value.absent(),
                Value<int> erros = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FlashcardsCompanion(
                id: id,
                atualizadoEm: atualizadoEm,
                topicoId: topicoId,
                frente: frente,
                verso: verso,
                ordem: ordem,
                caixa: caixa,
                proximaRevisao: proximaRevisao,
                acertos: acertos,
                erros: erros,
                criadoEm: criadoEm,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                required String topicoId,
                required String frente,
                required String verso,
                Value<int> ordem = const Value.absent(),
                Value<int> caixa = const Value.absent(),
                Value<DateTime> proximaRevisao = const Value.absent(),
                Value<int> acertos = const Value.absent(),
                Value<int> erros = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FlashcardsCompanion.insert(
                id: id,
                atualizadoEm: atualizadoEm,
                topicoId: topicoId,
                frente: frente,
                verso: verso,
                ordem: ordem,
                caixa: caixa,
                proximaRevisao: proximaRevisao,
                acertos: acertos,
                erros: erros,
                criadoEm: criadoEm,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FlashcardsTable, Flashcard>(table),
                  $$FlashcardsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({topicoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (topicoId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.topicoId,
                        referencedTable: $$FlashcardsTableReferences
                            ._topicoIdTable(db),
                        referencedColumn: $$FlashcardsTableReferences
                            ._topicoIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$FlashcardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FlashcardsTable,
      Flashcard,
      $$FlashcardsTableFilterComposer,
      $$FlashcardsTableOrderingComposer,
      $$FlashcardsTableAnnotationComposer,
      $$FlashcardsTableCreateCompanionBuilder,
      $$FlashcardsTableUpdateCompanionBuilder,
      (Flashcard, $$FlashcardsTableReferences),
      Flashcard,
      PrefetchHooks Function({bool topicoId})
    >;
typedef $$TopicoConcursosTableCreateCompanionBuilder =
    TopicoConcursosCompanion Function({
      required String topicoId,
      required String concursoId,
      Value<DateTime> atualizadoEm,
      Value<int> rowid,
    });
typedef $$TopicoConcursosTableUpdateCompanionBuilder =
    TopicoConcursosCompanion Function({
      Value<String> topicoId,
      Value<String> concursoId,
      Value<DateTime> atualizadoEm,
      Value<int> rowid,
    });

final class $$TopicoConcursosTableReferences
    extends
        BaseReferences<_$AppDatabase, $TopicoConcursosTable, TopicoConcurso> {
  $$TopicoConcursosTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TopicosTable _topicoIdTable(_$AppDatabase db) =>
      db.topicos.createAlias('topico_concursos__topico_id__topicos__id');

  $$TopicosTableProcessedTableManager get topicoId {
    final $_column = $_itemColumn<String>('topico_id')!;

    final manager = $$TopicosTableTableManager(
      $_db,
      $_db.topicos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_topicoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ConcursosTable _concursoIdTable(_$AppDatabase db) =>
      db.concursos.createAlias('topico_concursos__concurso_id__concursos__id');

  $$ConcursosTableProcessedTableManager get concursoId {
    final $_column = $_itemColumn<String>('concurso_id')!;

    final manager = $$ConcursosTableTableManager(
      $_db,
      $_db.concursos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_concursoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TopicoConcursosTableFilterComposer
    extends Composer<_$AppDatabase, $TopicoConcursosTable> {
  $$TopicoConcursosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnFilters(column),
  );

  $$TopicosTableFilterComposer get topicoId {
    final $$TopicosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.topicoId,
      referencedTable: $db.topicos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TopicosTableFilterComposer(
            $db: $db,
            $table: $db.topicos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ConcursosTableFilterComposer get concursoId {
    final $$ConcursosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.concursoId,
      referencedTable: $db.concursos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConcursosTableFilterComposer(
            $db: $db,
            $table: $db.concursos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TopicoConcursosTableOrderingComposer
    extends Composer<_$AppDatabase, $TopicoConcursosTable> {
  $$TopicoConcursosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  $$TopicosTableOrderingComposer get topicoId {
    final $$TopicosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.topicoId,
      referencedTable: $db.topicos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TopicosTableOrderingComposer(
            $db: $db,
            $table: $db.topicos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ConcursosTableOrderingComposer get concursoId {
    final $$ConcursosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.concursoId,
      referencedTable: $db.concursos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConcursosTableOrderingComposer(
            $db: $db,
            $table: $db.concursos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TopicoConcursosTableAnnotationComposer
    extends Composer<_$AppDatabase, $TopicoConcursosTable> {
  $$TopicoConcursosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => column,
  );

  $$TopicosTableAnnotationComposer get topicoId {
    final $$TopicosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.topicoId,
      referencedTable: $db.topicos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TopicosTableAnnotationComposer(
            $db: $db,
            $table: $db.topicos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ConcursosTableAnnotationComposer get concursoId {
    final $$ConcursosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.concursoId,
      referencedTable: $db.concursos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConcursosTableAnnotationComposer(
            $db: $db,
            $table: $db.concursos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TopicoConcursosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TopicoConcursosTable,
          TopicoConcurso,
          $$TopicoConcursosTableFilterComposer,
          $$TopicoConcursosTableOrderingComposer,
          $$TopicoConcursosTableAnnotationComposer,
          $$TopicoConcursosTableCreateCompanionBuilder,
          $$TopicoConcursosTableUpdateCompanionBuilder,
          (TopicoConcurso, $$TopicoConcursosTableReferences),
          TopicoConcurso,
          PrefetchHooks Function({bool topicoId, bool concursoId})
        > {
  $$TopicoConcursosTableTableManager(
    _$AppDatabase db,
    $TopicoConcursosTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TopicoConcursosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TopicoConcursosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TopicoConcursosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> topicoId = const Value.absent(),
                Value<String> concursoId = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TopicoConcursosCompanion(
                topicoId: topicoId,
                concursoId: concursoId,
                atualizadoEm: atualizadoEm,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String topicoId,
                required String concursoId,
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TopicoConcursosCompanion.insert(
                topicoId: topicoId,
                concursoId: concursoId,
                atualizadoEm: atualizadoEm,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TopicoConcursosTable, TopicoConcurso>(table),
                  $$TopicoConcursosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({topicoId = false, concursoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (topicoId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.topicoId,
                        referencedTable: $$TopicoConcursosTableReferences
                            ._topicoIdTable(db),
                        referencedColumn: $$TopicoConcursosTableReferences
                            ._topicoIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (concursoId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.concursoId,
                        referencedTable: $$TopicoConcursosTableReferences
                            ._concursoIdTable(db),
                        referencedColumn: $$TopicoConcursosTableReferences
                            ._concursoIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TopicoConcursosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TopicoConcursosTable,
      TopicoConcurso,
      $$TopicoConcursosTableFilterComposer,
      $$TopicoConcursosTableOrderingComposer,
      $$TopicoConcursosTableAnnotationComposer,
      $$TopicoConcursosTableCreateCompanionBuilder,
      $$TopicoConcursosTableUpdateCompanionBuilder,
      (TopicoConcurso, $$TopicoConcursosTableReferences),
      TopicoConcurso,
      PrefetchHooks Function({bool topicoId, bool concursoId})
    >;
typedef $$ProvasTableCreateCompanionBuilder = ProvasCompanion Function({
  Value<String> id,
  Value<DateTime> atualizadoEm,
  required String banca,
  required String orgao,
  required String cargo,
  required int ano,
  required String chave,
  required String gabarito,
  required int numAlternativas,
  required int totalQuestoes,
  Value<String> gabaritoLido,
  Value<String> descartadas,
  Value<DateTime> criadoEm,
  Value<int> rowid,
});
typedef $$ProvasTableUpdateCompanionBuilder = ProvasCompanion Function({
  Value<String> id,
  Value<DateTime> atualizadoEm,
  Value<String> banca,
  Value<String> orgao,
  Value<String> cargo,
  Value<int> ano,
  Value<String> chave,
  Value<String> gabarito,
  Value<int> numAlternativas,
  Value<int> totalQuestoes,
  Value<String> gabaritoLido,
  Value<String> descartadas,
  Value<DateTime> criadoEm,
  Value<int> rowid,
});

final class $$ProvasTableReferences
    extends BaseReferences<_$AppDatabase, $ProvasTable, Prova> {
  $$ProvasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TextosBaseTable, List<TextoBase>>
  _textosBaseRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.textosBase,
    aliasName: 'provas__id__textos_base__prova_id',
  );

  $$TextosBaseTableProcessedTableManager get textosBaseRefs {
    final manager = $$TextosBaseTableTableManager(
      $_db,
      $_db.textosBase,
    ).filter((f) => f.provaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_textosBaseRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$QuestoesProvaTable, List<QuestaoProva>>
  _questoesProvaRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.questoesProva,
    aliasName: 'provas__id__questoes_prova__prova_id',
  );

  $$QuestoesProvaTableProcessedTableManager get questoesProvaRefs {
    final manager = $$QuestoesProvaTableTableManager(
      $_db,
      $_db.questoesProva,
    ).filter((f) => f.provaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_questoesProvaRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProvasTableFilterComposer
    extends Composer<_$AppDatabase, $ProvasTable> {
  $$ProvasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get banca => $composableBuilder(
    column: $table.banca,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orgao => $composableBuilder(
    column: $table.orgao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cargo => $composableBuilder(
    column: $table.cargo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ano => $composableBuilder(
    column: $table.ano,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chave => $composableBuilder(
    column: $table.chave,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gabarito => $composableBuilder(
    column: $table.gabarito,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get numAlternativas => $composableBuilder(
    column: $table.numAlternativas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalQuestoes => $composableBuilder(
    column: $table.totalQuestoes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gabaritoLido => $composableBuilder(
    column: $table.gabaritoLido,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descartadas => $composableBuilder(
    column: $table.descartadas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> textosBaseRefs(
    Expression<bool> Function($$TextosBaseTableFilterComposer f) f,
  ) {
    final $$TextosBaseTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.textosBase,
      getReferencedColumn: (t) => t.provaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TextosBaseTableFilterComposer(
            $db: $db,
            $table: $db.textosBase,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> questoesProvaRefs(
    Expression<bool> Function($$QuestoesProvaTableFilterComposer f) f,
  ) {
    final $$QuestoesProvaTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.questoesProva,
      getReferencedColumn: (t) => t.provaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestoesProvaTableFilterComposer(
            $db: $db,
            $table: $db.questoesProva,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProvasTableOrderingComposer
    extends Composer<_$AppDatabase, $ProvasTable> {
  $$ProvasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get banca => $composableBuilder(
    column: $table.banca,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orgao => $composableBuilder(
    column: $table.orgao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cargo => $composableBuilder(
    column: $table.cargo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ano => $composableBuilder(
    column: $table.ano,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chave => $composableBuilder(
    column: $table.chave,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gabarito => $composableBuilder(
    column: $table.gabarito,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get numAlternativas => $composableBuilder(
    column: $table.numAlternativas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalQuestoes => $composableBuilder(
    column: $table.totalQuestoes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gabaritoLido => $composableBuilder(
    column: $table.gabaritoLido,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descartadas => $composableBuilder(
    column: $table.descartadas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProvasTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProvasTable> {
  $$ProvasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get banca =>
      $composableBuilder(column: $table.banca, builder: (column) => column);

  GeneratedColumn<String> get orgao =>
      $composableBuilder(column: $table.orgao, builder: (column) => column);

  GeneratedColumn<String> get cargo =>
      $composableBuilder(column: $table.cargo, builder: (column) => column);

  GeneratedColumn<int> get ano =>
      $composableBuilder(column: $table.ano, builder: (column) => column);

  GeneratedColumn<String> get chave =>
      $composableBuilder(column: $table.chave, builder: (column) => column);

  GeneratedColumn<String> get gabarito =>
      $composableBuilder(column: $table.gabarito, builder: (column) => column);

  GeneratedColumn<int> get numAlternativas => $composableBuilder(
    column: $table.numAlternativas,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalQuestoes => $composableBuilder(
    column: $table.totalQuestoes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get gabaritoLido => $composableBuilder(
    column: $table.gabaritoLido,
    builder: (column) => column,
  );

  GeneratedColumn<String> get descartadas => $composableBuilder(
    column: $table.descartadas,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get criadoEm =>
      $composableBuilder(column: $table.criadoEm, builder: (column) => column);

  Expression<T> textosBaseRefs<T extends Object>(
    Expression<T> Function($$TextosBaseTableAnnotationComposer a) f,
  ) {
    final $$TextosBaseTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.textosBase,
      getReferencedColumn: (t) => t.provaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TextosBaseTableAnnotationComposer(
            $db: $db,
            $table: $db.textosBase,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> questoesProvaRefs<T extends Object>(
    Expression<T> Function($$QuestoesProvaTableAnnotationComposer a) f,
  ) {
    final $$QuestoesProvaTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.questoesProva,
      getReferencedColumn: (t) => t.provaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestoesProvaTableAnnotationComposer(
            $db: $db,
            $table: $db.questoesProva,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProvasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProvasTable,
          Prova,
          $$ProvasTableFilterComposer,
          $$ProvasTableOrderingComposer,
          $$ProvasTableAnnotationComposer,
          $$ProvasTableCreateCompanionBuilder,
          $$ProvasTableUpdateCompanionBuilder,
          (Prova, $$ProvasTableReferences),
          Prova,
          PrefetchHooks Function({bool textosBaseRefs, bool questoesProvaRefs})
        > {
  $$ProvasTableTableManager(_$AppDatabase db, $ProvasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProvasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProvasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProvasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<String> banca = const Value.absent(),
                Value<String> orgao = const Value.absent(),
                Value<String> cargo = const Value.absent(),
                Value<int> ano = const Value.absent(),
                Value<String> chave = const Value.absent(),
                Value<String> gabarito = const Value.absent(),
                Value<int> numAlternativas = const Value.absent(),
                Value<int> totalQuestoes = const Value.absent(),
                Value<String> gabaritoLido = const Value.absent(),
                Value<String> descartadas = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProvasCompanion(
                id: id,
                atualizadoEm: atualizadoEm,
                banca: banca,
                orgao: orgao,
                cargo: cargo,
                ano: ano,
                chave: chave,
                gabarito: gabarito,
                numAlternativas: numAlternativas,
                totalQuestoes: totalQuestoes,
                gabaritoLido: gabaritoLido,
                descartadas: descartadas,
                criadoEm: criadoEm,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                required String banca,
                required String orgao,
                required String cargo,
                required int ano,
                required String chave,
                required String gabarito,
                required int numAlternativas,
                required int totalQuestoes,
                Value<String> gabaritoLido = const Value.absent(),
                Value<String> descartadas = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProvasCompanion.insert(
                id: id,
                atualizadoEm: atualizadoEm,
                banca: banca,
                orgao: orgao,
                cargo: cargo,
                ano: ano,
                chave: chave,
                gabarito: gabarito,
                numAlternativas: numAlternativas,
                totalQuestoes: totalQuestoes,
                gabaritoLido: gabaritoLido,
                descartadas: descartadas,
                criadoEm: criadoEm,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProvasTable, Prova>(table),
                  $$ProvasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({textosBaseRefs = false, questoesProvaRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (textosBaseRefs) db.textosBase,
                    if (questoesProvaRefs) db.questoesProva,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (textosBaseRefs)
                        await $_getPrefetchedData<
                          Prova,
                          $ProvasTable,
                          TextoBase
                        >(
                          currentTable: table,
                          referencedTable: $$ProvasTableReferences
                              ._textosBaseRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProvasTableReferences(
                                db,
                                table,
                                p0,
                              ).textosBaseRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.provaId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (questoesProvaRefs)
                        await $_getPrefetchedData<
                          Prova,
                          $ProvasTable,
                          QuestaoProva
                        >(
                          currentTable: table,
                          referencedTable: $$ProvasTableReferences
                              ._questoesProvaRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProvasTableReferences(
                                db,
                                table,
                                p0,
                              ).questoesProvaRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.provaId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProvasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProvasTable,
      Prova,
      $$ProvasTableFilterComposer,
      $$ProvasTableOrderingComposer,
      $$ProvasTableAnnotationComposer,
      $$ProvasTableCreateCompanionBuilder,
      $$ProvasTableUpdateCompanionBuilder,
      (Prova, $$ProvasTableReferences),
      Prova,
      PrefetchHooks Function({bool textosBaseRefs, bool questoesProvaRefs})
    >;
typedef $$TextosBaseTableCreateCompanionBuilder = TextosBaseCompanion Function({
  Value<String> id,
  Value<DateTime> atualizadoEm,
  required String provaId,
  required String codigo,
  Value<String> titulo,
  required String conteudo,
  Value<int> rowid,
});
typedef $$TextosBaseTableUpdateCompanionBuilder = TextosBaseCompanion Function({
  Value<String> id,
  Value<DateTime> atualizadoEm,
  Value<String> provaId,
  Value<String> codigo,
  Value<String> titulo,
  Value<String> conteudo,
  Value<int> rowid,
});

final class $$TextosBaseTableReferences
    extends BaseReferences<_$AppDatabase, $TextosBaseTable, TextoBase> {
  $$TextosBaseTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProvasTable _provaIdTable(_$AppDatabase db) =>
      db.provas.createAlias('textos_base__prova_id__provas__id');

  $$ProvasTableProcessedTableManager get provaId {
    final $_column = $_itemColumn<String>('prova_id')!;

    final manager = $$ProvasTableTableManager(
      $_db,
      $_db.provas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_provaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$QuestoesProvaTable, List<QuestaoProva>>
  _questoesProvaRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.questoesProva,
    aliasName: 'textos_base__id__questoes_prova__texto_id',
  );

  $$QuestoesProvaTableProcessedTableManager get questoesProvaRefs {
    final manager = $$QuestoesProvaTableTableManager(
      $_db,
      $_db.questoesProva,
    ).filter((f) => f.textoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_questoesProvaRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TextosBaseTableFilterComposer
    extends Composer<_$AppDatabase, $TextosBaseTable> {
  $$TextosBaseTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get codigo => $composableBuilder(
    column: $table.codigo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titulo => $composableBuilder(
    column: $table.titulo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conteudo => $composableBuilder(
    column: $table.conteudo,
    builder: (column) => ColumnFilters(column),
  );

  $$ProvasTableFilterComposer get provaId {
    final $$ProvasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.provaId,
      referencedTable: $db.provas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProvasTableFilterComposer(
            $db: $db,
            $table: $db.provas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> questoesProvaRefs(
    Expression<bool> Function($$QuestoesProvaTableFilterComposer f) f,
  ) {
    final $$QuestoesProvaTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.questoesProva,
      getReferencedColumn: (t) => t.textoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestoesProvaTableFilterComposer(
            $db: $db,
            $table: $db.questoesProva,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TextosBaseTableOrderingComposer
    extends Composer<_$AppDatabase, $TextosBaseTable> {
  $$TextosBaseTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codigo => $composableBuilder(
    column: $table.codigo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titulo => $composableBuilder(
    column: $table.titulo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conteudo => $composableBuilder(
    column: $table.conteudo,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProvasTableOrderingComposer get provaId {
    final $$ProvasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.provaId,
      referencedTable: $db.provas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProvasTableOrderingComposer(
            $db: $db,
            $table: $db.provas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TextosBaseTableAnnotationComposer
    extends Composer<_$AppDatabase, $TextosBaseTable> {
  $$TextosBaseTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get codigo =>
      $composableBuilder(column: $table.codigo, builder: (column) => column);

  GeneratedColumn<String> get titulo =>
      $composableBuilder(column: $table.titulo, builder: (column) => column);

  GeneratedColumn<String> get conteudo =>
      $composableBuilder(column: $table.conteudo, builder: (column) => column);

  $$ProvasTableAnnotationComposer get provaId {
    final $$ProvasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.provaId,
      referencedTable: $db.provas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProvasTableAnnotationComposer(
            $db: $db,
            $table: $db.provas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> questoesProvaRefs<T extends Object>(
    Expression<T> Function($$QuestoesProvaTableAnnotationComposer a) f,
  ) {
    final $$QuestoesProvaTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.questoesProva,
      getReferencedColumn: (t) => t.textoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestoesProvaTableAnnotationComposer(
            $db: $db,
            $table: $db.questoesProva,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TextosBaseTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TextosBaseTable,
          TextoBase,
          $$TextosBaseTableFilterComposer,
          $$TextosBaseTableOrderingComposer,
          $$TextosBaseTableAnnotationComposer,
          $$TextosBaseTableCreateCompanionBuilder,
          $$TextosBaseTableUpdateCompanionBuilder,
          (TextoBase, $$TextosBaseTableReferences),
          TextoBase,
          PrefetchHooks Function({bool provaId, bool questoesProvaRefs})
        > {
  $$TextosBaseTableTableManager(_$AppDatabase db, $TextosBaseTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TextosBaseTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TextosBaseTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TextosBaseTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<String> provaId = const Value.absent(),
                Value<String> codigo = const Value.absent(),
                Value<String> titulo = const Value.absent(),
                Value<String> conteudo = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TextosBaseCompanion(
                id: id,
                atualizadoEm: atualizadoEm,
                provaId: provaId,
                codigo: codigo,
                titulo: titulo,
                conteudo: conteudo,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                required String provaId,
                required String codigo,
                Value<String> titulo = const Value.absent(),
                required String conteudo,
                Value<int> rowid = const Value.absent(),
              }) => TextosBaseCompanion.insert(
                id: id,
                atualizadoEm: atualizadoEm,
                provaId: provaId,
                codigo: codigo,
                titulo: titulo,
                conteudo: conteudo,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TextosBaseTable, TextoBase>(table),
                  $$TextosBaseTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({provaId = false, questoesProvaRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (questoesProvaRefs) db.questoesProva,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (provaId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.provaId,
                            referencedTable: $$TextosBaseTableReferences
                                ._provaIdTable(db),
                            referencedColumn: $$TextosBaseTableReferences
                                ._provaIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (questoesProvaRefs)
                        await $_getPrefetchedData<
                          TextoBase,
                          $TextosBaseTable,
                          QuestaoProva
                        >(
                          currentTable: table,
                          referencedTable: $$TextosBaseTableReferences
                              ._questoesProvaRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TextosBaseTableReferences(
                                db,
                                table,
                                p0,
                              ).questoesProvaRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.textoId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TextosBaseTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TextosBaseTable,
      TextoBase,
      $$TextosBaseTableFilterComposer,
      $$TextosBaseTableOrderingComposer,
      $$TextosBaseTableAnnotationComposer,
      $$TextosBaseTableCreateCompanionBuilder,
      $$TextosBaseTableUpdateCompanionBuilder,
      (TextoBase, $$TextosBaseTableReferences),
      TextoBase,
      PrefetchHooks Function({bool provaId, bool questoesProvaRefs})
    >;
typedef $$QuestoesProvaTableCreateCompanionBuilder =
    QuestoesProvaCompanion Function({
      Value<String> id,
      Value<DateTime> atualizadoEm,
      required String provaId,
      required int numero,
      Value<String?> textoId,
      required String materiaId,
      Value<String?> topicoId,
      Value<String> topicoOriginal,
      required String enunciado,
      required String alternativas,
      required String resposta,
      Value<String> status,
      Value<String> obs,
      Value<int> rowid,
    });
typedef $$QuestoesProvaTableUpdateCompanionBuilder =
    QuestoesProvaCompanion Function({
      Value<String> id,
      Value<DateTime> atualizadoEm,
      Value<String> provaId,
      Value<int> numero,
      Value<String?> textoId,
      Value<String> materiaId,
      Value<String?> topicoId,
      Value<String> topicoOriginal,
      Value<String> enunciado,
      Value<String> alternativas,
      Value<String> resposta,
      Value<String> status,
      Value<String> obs,
      Value<int> rowid,
    });

final class $$QuestoesProvaTableReferences
    extends BaseReferences<_$AppDatabase, $QuestoesProvaTable, QuestaoProva> {
  $$QuestoesProvaTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProvasTable _provaIdTable(_$AppDatabase db) =>
      db.provas.createAlias('questoes_prova__prova_id__provas__id');

  $$ProvasTableProcessedTableManager get provaId {
    final $_column = $_itemColumn<String>('prova_id')!;

    final manager = $$ProvasTableTableManager(
      $_db,
      $_db.provas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_provaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TextosBaseTable _textoIdTable(_$AppDatabase db) =>
      db.textosBase.createAlias('questoes_prova__texto_id__textos_base__id');

  $$TextosBaseTableProcessedTableManager? get textoId {
    final $_column = $_itemColumn<String>('texto_id');
    if ($_column == null) return null;
    final manager = $$TextosBaseTableTableManager(
      $_db,
      $_db.textosBase,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_textoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MateriasTable _materiaIdTable(_$AppDatabase db) =>
      db.materias.createAlias('questoes_prova__materia_id__materias__id');

  $$MateriasTableProcessedTableManager get materiaId {
    final $_column = $_itemColumn<String>('materia_id')!;

    final manager = $$MateriasTableTableManager(
      $_db,
      $_db.materias,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_materiaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TopicosTable _topicoIdTable(_$AppDatabase db) =>
      db.topicos.createAlias('questoes_prova__topico_id__topicos__id');

  $$TopicosTableProcessedTableManager? get topicoId {
    final $_column = $_itemColumn<String>('topico_id');
    if ($_column == null) return null;
    final manager = $$TopicosTableTableManager(
      $_db,
      $_db.topicos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_topicoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$RespostasTable, List<Resposta>>
  _respostasRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.respostas,
    aliasName: 'questoes_prova__id__respostas__questao_id',
  );

  $$RespostasTableProcessedTableManager get respostasRefs {
    final manager = $$RespostasTableTableManager(
      $_db,
      $_db.respostas,
    ).filter((f) => f.questaoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_respostasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PrintsQuestaoTable, List<PrintQuestao>>
  _printsQuestaoRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.printsQuestao,
    aliasName: 'questoes_prova__id__prints_questao__questao_id',
  );

  $$PrintsQuestaoTableProcessedTableManager get printsQuestaoRefs {
    final manager = $$PrintsQuestaoTableTableManager(
      $_db,
      $_db.printsQuestao,
    ).filter((f) => f.questaoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_printsQuestaoRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$QuestoesProvaTableFilterComposer
    extends Composer<_$AppDatabase, $QuestoesProvaTable> {
  $$QuestoesProvaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get numero => $composableBuilder(
    column: $table.numero,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get topicoOriginal => $composableBuilder(
    column: $table.topicoOriginal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get enunciado => $composableBuilder(
    column: $table.enunciado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alternativas => $composableBuilder(
    column: $table.alternativas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resposta => $composableBuilder(
    column: $table.resposta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get obs => $composableBuilder(
    column: $table.obs,
    builder: (column) => ColumnFilters(column),
  );

  $$ProvasTableFilterComposer get provaId {
    final $$ProvasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.provaId,
      referencedTable: $db.provas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProvasTableFilterComposer(
            $db: $db,
            $table: $db.provas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TextosBaseTableFilterComposer get textoId {
    final $$TextosBaseTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.textoId,
      referencedTable: $db.textosBase,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TextosBaseTableFilterComposer(
            $db: $db,
            $table: $db.textosBase,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MateriasTableFilterComposer get materiaId {
    final $$MateriasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.materiaId,
      referencedTable: $db.materias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MateriasTableFilterComposer(
            $db: $db,
            $table: $db.materias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TopicosTableFilterComposer get topicoId {
    final $$TopicosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.topicoId,
      referencedTable: $db.topicos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TopicosTableFilterComposer(
            $db: $db,
            $table: $db.topicos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> respostasRefs(
    Expression<bool> Function($$RespostasTableFilterComposer f) f,
  ) {
    final $$RespostasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.respostas,
      getReferencedColumn: (t) => t.questaoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RespostasTableFilterComposer(
            $db: $db,
            $table: $db.respostas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> printsQuestaoRefs(
    Expression<bool> Function($$PrintsQuestaoTableFilterComposer f) f,
  ) {
    final $$PrintsQuestaoTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.printsQuestao,
      getReferencedColumn: (t) => t.questaoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrintsQuestaoTableFilterComposer(
            $db: $db,
            $table: $db.printsQuestao,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$QuestoesProvaTableOrderingComposer
    extends Composer<_$AppDatabase, $QuestoesProvaTable> {
  $$QuestoesProvaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get numero => $composableBuilder(
    column: $table.numero,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get topicoOriginal => $composableBuilder(
    column: $table.topicoOriginal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get enunciado => $composableBuilder(
    column: $table.enunciado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alternativas => $composableBuilder(
    column: $table.alternativas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resposta => $composableBuilder(
    column: $table.resposta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get obs => $composableBuilder(
    column: $table.obs,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProvasTableOrderingComposer get provaId {
    final $$ProvasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.provaId,
      referencedTable: $db.provas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProvasTableOrderingComposer(
            $db: $db,
            $table: $db.provas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TextosBaseTableOrderingComposer get textoId {
    final $$TextosBaseTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.textoId,
      referencedTable: $db.textosBase,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TextosBaseTableOrderingComposer(
            $db: $db,
            $table: $db.textosBase,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MateriasTableOrderingComposer get materiaId {
    final $$MateriasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.materiaId,
      referencedTable: $db.materias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MateriasTableOrderingComposer(
            $db: $db,
            $table: $db.materias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TopicosTableOrderingComposer get topicoId {
    final $$TopicosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.topicoId,
      referencedTable: $db.topicos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TopicosTableOrderingComposer(
            $db: $db,
            $table: $db.topicos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuestoesProvaTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuestoesProvaTable> {
  $$QuestoesProvaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => column,
  );

  GeneratedColumn<int> get numero =>
      $composableBuilder(column: $table.numero, builder: (column) => column);

  GeneratedColumn<String> get topicoOriginal => $composableBuilder(
    column: $table.topicoOriginal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get enunciado =>
      $composableBuilder(column: $table.enunciado, builder: (column) => column);

  GeneratedColumn<String> get alternativas => $composableBuilder(
    column: $table.alternativas,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resposta =>
      $composableBuilder(column: $table.resposta, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get obs =>
      $composableBuilder(column: $table.obs, builder: (column) => column);

  $$ProvasTableAnnotationComposer get provaId {
    final $$ProvasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.provaId,
      referencedTable: $db.provas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProvasTableAnnotationComposer(
            $db: $db,
            $table: $db.provas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TextosBaseTableAnnotationComposer get textoId {
    final $$TextosBaseTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.textoId,
      referencedTable: $db.textosBase,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TextosBaseTableAnnotationComposer(
            $db: $db,
            $table: $db.textosBase,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MateriasTableAnnotationComposer get materiaId {
    final $$MateriasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.materiaId,
      referencedTable: $db.materias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MateriasTableAnnotationComposer(
            $db: $db,
            $table: $db.materias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TopicosTableAnnotationComposer get topicoId {
    final $$TopicosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.topicoId,
      referencedTable: $db.topicos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TopicosTableAnnotationComposer(
            $db: $db,
            $table: $db.topicos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> respostasRefs<T extends Object>(
    Expression<T> Function($$RespostasTableAnnotationComposer a) f,
  ) {
    final $$RespostasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.respostas,
      getReferencedColumn: (t) => t.questaoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RespostasTableAnnotationComposer(
            $db: $db,
            $table: $db.respostas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> printsQuestaoRefs<T extends Object>(
    Expression<T> Function($$PrintsQuestaoTableAnnotationComposer a) f,
  ) {
    final $$PrintsQuestaoTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.printsQuestao,
      getReferencedColumn: (t) => t.questaoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrintsQuestaoTableAnnotationComposer(
            $db: $db,
            $table: $db.printsQuestao,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$QuestoesProvaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuestoesProvaTable,
          QuestaoProva,
          $$QuestoesProvaTableFilterComposer,
          $$QuestoesProvaTableOrderingComposer,
          $$QuestoesProvaTableAnnotationComposer,
          $$QuestoesProvaTableCreateCompanionBuilder,
          $$QuestoesProvaTableUpdateCompanionBuilder,
          (QuestaoProva, $$QuestoesProvaTableReferences),
          QuestaoProva,
          PrefetchHooks Function({
            bool provaId,
            bool textoId,
            bool materiaId,
            bool topicoId,
            bool respostasRefs,
            bool printsQuestaoRefs,
          })
        > {
  $$QuestoesProvaTableTableManager(_$AppDatabase db, $QuestoesProvaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuestoesProvaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuestoesProvaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuestoesProvaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<String> provaId = const Value.absent(),
                Value<int> numero = const Value.absent(),
                Value<String?> textoId = const Value.absent(),
                Value<String> materiaId = const Value.absent(),
                Value<String?> topicoId = const Value.absent(),
                Value<String> topicoOriginal = const Value.absent(),
                Value<String> enunciado = const Value.absent(),
                Value<String> alternativas = const Value.absent(),
                Value<String> resposta = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> obs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuestoesProvaCompanion(
                id: id,
                atualizadoEm: atualizadoEm,
                provaId: provaId,
                numero: numero,
                textoId: textoId,
                materiaId: materiaId,
                topicoId: topicoId,
                topicoOriginal: topicoOriginal,
                enunciado: enunciado,
                alternativas: alternativas,
                resposta: resposta,
                status: status,
                obs: obs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                required String provaId,
                required int numero,
                Value<String?> textoId = const Value.absent(),
                required String materiaId,
                Value<String?> topicoId = const Value.absent(),
                Value<String> topicoOriginal = const Value.absent(),
                required String enunciado,
                required String alternativas,
                required String resposta,
                Value<String> status = const Value.absent(),
                Value<String> obs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuestoesProvaCompanion.insert(
                id: id,
                atualizadoEm: atualizadoEm,
                provaId: provaId,
                numero: numero,
                textoId: textoId,
                materiaId: materiaId,
                topicoId: topicoId,
                topicoOriginal: topicoOriginal,
                enunciado: enunciado,
                alternativas: alternativas,
                resposta: resposta,
                status: status,
                obs: obs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$QuestoesProvaTable, QuestaoProva>(table),
                  $$QuestoesProvaTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                provaId = false,
                textoId = false,
                materiaId = false,
                topicoId = false,
                respostasRefs = false,
                printsQuestaoRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (respostasRefs) db.respostas,
                    if (printsQuestaoRefs) db.printsQuestao,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (provaId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.provaId,
                            referencedTable: $$QuestoesProvaTableReferences
                                ._provaIdTable(db),
                            referencedColumn: $$QuestoesProvaTableReferences
                                ._provaIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (textoId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.textoId,
                            referencedTable: $$QuestoesProvaTableReferences
                                ._textoIdTable(db),
                            referencedColumn: $$QuestoesProvaTableReferences
                                ._textoIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (materiaId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.materiaId,
                            referencedTable: $$QuestoesProvaTableReferences
                                ._materiaIdTable(db),
                            referencedColumn: $$QuestoesProvaTableReferences
                                ._materiaIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (topicoId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.topicoId,
                            referencedTable: $$QuestoesProvaTableReferences
                                ._topicoIdTable(db),
                            referencedColumn: $$QuestoesProvaTableReferences
                                ._topicoIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (respostasRefs)
                        await $_getPrefetchedData<
                          QuestaoProva,
                          $QuestoesProvaTable,
                          Resposta
                        >(
                          currentTable: table,
                          referencedTable: $$QuestoesProvaTableReferences
                              ._respostasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$QuestoesProvaTableReferences(
                                db,
                                table,
                                p0,
                              ).respostasRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.questaoId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (printsQuestaoRefs)
                        await $_getPrefetchedData<
                          QuestaoProva,
                          $QuestoesProvaTable,
                          PrintQuestao
                        >(
                          currentTable: table,
                          referencedTable: $$QuestoesProvaTableReferences
                              ._printsQuestaoRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$QuestoesProvaTableReferences(
                                db,
                                table,
                                p0,
                              ).printsQuestaoRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.questaoId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$QuestoesProvaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuestoesProvaTable,
      QuestaoProva,
      $$QuestoesProvaTableFilterComposer,
      $$QuestoesProvaTableOrderingComposer,
      $$QuestoesProvaTableAnnotationComposer,
      $$QuestoesProvaTableCreateCompanionBuilder,
      $$QuestoesProvaTableUpdateCompanionBuilder,
      (QuestaoProva, $$QuestoesProvaTableReferences),
      QuestaoProva,
      PrefetchHooks Function({
        bool provaId,
        bool textoId,
        bool materiaId,
        bool topicoId,
        bool respostasRefs,
        bool printsQuestaoRefs,
      })
    >;
typedef $$RespostasTableCreateCompanionBuilder = RespostasCompanion Function({
  Value<String> id,
  Value<DateTime> atualizadoEm,
  required String questaoId,
  required String marcada,
  required bool acertou,
  Value<int> segundos,
  Value<String?> motivoErro,
  Value<DateTime> data,
  required String modo,
  Value<int> rowid,
});
typedef $$RespostasTableUpdateCompanionBuilder = RespostasCompanion Function({
  Value<String> id,
  Value<DateTime> atualizadoEm,
  Value<String> questaoId,
  Value<String> marcada,
  Value<bool> acertou,
  Value<int> segundos,
  Value<String?> motivoErro,
  Value<DateTime> data,
  Value<String> modo,
  Value<int> rowid,
});

final class $$RespostasTableReferences
    extends BaseReferences<_$AppDatabase, $RespostasTable, Resposta> {
  $$RespostasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $QuestoesProvaTable _questaoIdTable(_$AppDatabase db) =>
      db.questoesProva.createAlias('respostas__questao_id__questoes_prova__id');

  $$QuestoesProvaTableProcessedTableManager get questaoId {
    final $_column = $_itemColumn<String>('questao_id')!;

    final manager = $$QuestoesProvaTableTableManager(
      $_db,
      $_db.questoesProva,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_questaoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RespostasTableFilterComposer
    extends Composer<_$AppDatabase, $RespostasTable> {
  $$RespostasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get marcada => $composableBuilder(
    column: $table.marcada,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get acertou => $composableBuilder(
    column: $table.acertou,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get segundos => $composableBuilder(
    column: $table.segundos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get motivoErro => $composableBuilder(
    column: $table.motivoErro,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modo => $composableBuilder(
    column: $table.modo,
    builder: (column) => ColumnFilters(column),
  );

  $$QuestoesProvaTableFilterComposer get questaoId {
    final $$QuestoesProvaTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questaoId,
      referencedTable: $db.questoesProva,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestoesProvaTableFilterComposer(
            $db: $db,
            $table: $db.questoesProva,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RespostasTableOrderingComposer
    extends Composer<_$AppDatabase, $RespostasTable> {
  $$RespostasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get marcada => $composableBuilder(
    column: $table.marcada,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get acertou => $composableBuilder(
    column: $table.acertou,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get segundos => $composableBuilder(
    column: $table.segundos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get motivoErro => $composableBuilder(
    column: $table.motivoErro,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modo => $composableBuilder(
    column: $table.modo,
    builder: (column) => ColumnOrderings(column),
  );

  $$QuestoesProvaTableOrderingComposer get questaoId {
    final $$QuestoesProvaTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questaoId,
      referencedTable: $db.questoesProva,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestoesProvaTableOrderingComposer(
            $db: $db,
            $table: $db.questoesProva,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RespostasTableAnnotationComposer
    extends Composer<_$AppDatabase, $RespostasTable> {
  $$RespostasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get marcada =>
      $composableBuilder(column: $table.marcada, builder: (column) => column);

  GeneratedColumn<bool> get acertou =>
      $composableBuilder(column: $table.acertou, builder: (column) => column);

  GeneratedColumn<int> get segundos =>
      $composableBuilder(column: $table.segundos, builder: (column) => column);

  GeneratedColumn<String> get motivoErro => $composableBuilder(
    column: $table.motivoErro,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<String> get modo =>
      $composableBuilder(column: $table.modo, builder: (column) => column);

  $$QuestoesProvaTableAnnotationComposer get questaoId {
    final $$QuestoesProvaTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questaoId,
      referencedTable: $db.questoesProva,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestoesProvaTableAnnotationComposer(
            $db: $db,
            $table: $db.questoesProva,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RespostasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RespostasTable,
          Resposta,
          $$RespostasTableFilterComposer,
          $$RespostasTableOrderingComposer,
          $$RespostasTableAnnotationComposer,
          $$RespostasTableCreateCompanionBuilder,
          $$RespostasTableUpdateCompanionBuilder,
          (Resposta, $$RespostasTableReferences),
          Resposta,
          PrefetchHooks Function({bool questaoId})
        > {
  $$RespostasTableTableManager(_$AppDatabase db, $RespostasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RespostasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RespostasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RespostasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<String> questaoId = const Value.absent(),
                Value<String> marcada = const Value.absent(),
                Value<bool> acertou = const Value.absent(),
                Value<int> segundos = const Value.absent(),
                Value<String?> motivoErro = const Value.absent(),
                Value<DateTime> data = const Value.absent(),
                Value<String> modo = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RespostasCompanion(
                id: id,
                atualizadoEm: atualizadoEm,
                questaoId: questaoId,
                marcada: marcada,
                acertou: acertou,
                segundos: segundos,
                motivoErro: motivoErro,
                data: data,
                modo: modo,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                required String questaoId,
                required String marcada,
                required bool acertou,
                Value<int> segundos = const Value.absent(),
                Value<String?> motivoErro = const Value.absent(),
                Value<DateTime> data = const Value.absent(),
                required String modo,
                Value<int> rowid = const Value.absent(),
              }) => RespostasCompanion.insert(
                id: id,
                atualizadoEm: atualizadoEm,
                questaoId: questaoId,
                marcada: marcada,
                acertou: acertou,
                segundos: segundos,
                motivoErro: motivoErro,
                data: data,
                modo: modo,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RespostasTable, Resposta>(table),
                  $$RespostasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({questaoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (questaoId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.questaoId,
                        referencedTable: $$RespostasTableReferences
                            ._questaoIdTable(db),
                        referencedColumn: $$RespostasTableReferences
                            ._questaoIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RespostasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RespostasTable,
      Resposta,
      $$RespostasTableFilterComposer,
      $$RespostasTableOrderingComposer,
      $$RespostasTableAnnotationComposer,
      $$RespostasTableCreateCompanionBuilder,
      $$RespostasTableUpdateCompanionBuilder,
      (Resposta, $$RespostasTableReferences),
      Resposta,
      PrefetchHooks Function({bool questaoId})
    >;
typedef $$PrintsQuestaoTableCreateCompanionBuilder =
    PrintsQuestaoCompanion Function({
      Value<String> id,
      Value<DateTime> atualizadoEm,
      required String questaoId,
      required String arquivo,
      Value<int> rowid,
    });
typedef $$PrintsQuestaoTableUpdateCompanionBuilder =
    PrintsQuestaoCompanion Function({
      Value<String> id,
      Value<DateTime> atualizadoEm,
      Value<String> questaoId,
      Value<String> arquivo,
      Value<int> rowid,
    });

final class $$PrintsQuestaoTableReferences
    extends BaseReferences<_$AppDatabase, $PrintsQuestaoTable, PrintQuestao> {
  $$PrintsQuestaoTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $QuestoesProvaTable _questaoIdTable(_$AppDatabase db) => db
      .questoesProva
      .createAlias('prints_questao__questao_id__questoes_prova__id');

  $$QuestoesProvaTableProcessedTableManager get questaoId {
    final $_column = $_itemColumn<String>('questao_id')!;

    final manager = $$QuestoesProvaTableTableManager(
      $_db,
      $_db.questoesProva,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_questaoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PrintsQuestaoTableFilterComposer
    extends Composer<_$AppDatabase, $PrintsQuestaoTable> {
  $$PrintsQuestaoTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get arquivo => $composableBuilder(
    column: $table.arquivo,
    builder: (column) => ColumnFilters(column),
  );

  $$QuestoesProvaTableFilterComposer get questaoId {
    final $$QuestoesProvaTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questaoId,
      referencedTable: $db.questoesProva,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestoesProvaTableFilterComposer(
            $db: $db,
            $table: $db.questoesProva,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PrintsQuestaoTableOrderingComposer
    extends Composer<_$AppDatabase, $PrintsQuestaoTable> {
  $$PrintsQuestaoTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get arquivo => $composableBuilder(
    column: $table.arquivo,
    builder: (column) => ColumnOrderings(column),
  );

  $$QuestoesProvaTableOrderingComposer get questaoId {
    final $$QuestoesProvaTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questaoId,
      referencedTable: $db.questoesProva,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestoesProvaTableOrderingComposer(
            $db: $db,
            $table: $db.questoesProva,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PrintsQuestaoTableAnnotationComposer
    extends Composer<_$AppDatabase, $PrintsQuestaoTable> {
  $$PrintsQuestaoTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get arquivo =>
      $composableBuilder(column: $table.arquivo, builder: (column) => column);

  $$QuestoesProvaTableAnnotationComposer get questaoId {
    final $$QuestoesProvaTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questaoId,
      referencedTable: $db.questoesProva,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestoesProvaTableAnnotationComposer(
            $db: $db,
            $table: $db.questoesProva,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PrintsQuestaoTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PrintsQuestaoTable,
          PrintQuestao,
          $$PrintsQuestaoTableFilterComposer,
          $$PrintsQuestaoTableOrderingComposer,
          $$PrintsQuestaoTableAnnotationComposer,
          $$PrintsQuestaoTableCreateCompanionBuilder,
          $$PrintsQuestaoTableUpdateCompanionBuilder,
          (PrintQuestao, $$PrintsQuestaoTableReferences),
          PrintQuestao,
          PrefetchHooks Function({bool questaoId})
        > {
  $$PrintsQuestaoTableTableManager(_$AppDatabase db, $PrintsQuestaoTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PrintsQuestaoTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PrintsQuestaoTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PrintsQuestaoTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<String> questaoId = const Value.absent(),
                Value<String> arquivo = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PrintsQuestaoCompanion(
                id: id,
                atualizadoEm: atualizadoEm,
                questaoId: questaoId,
                arquivo: arquivo,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                required String questaoId,
                required String arquivo,
                Value<int> rowid = const Value.absent(),
              }) => PrintsQuestaoCompanion.insert(
                id: id,
                atualizadoEm: atualizadoEm,
                questaoId: questaoId,
                arquivo: arquivo,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PrintsQuestaoTable, PrintQuestao>(table),
                  $$PrintsQuestaoTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({questaoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (questaoId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.questaoId,
                        referencedTable: $$PrintsQuestaoTableReferences
                            ._questaoIdTable(db),
                        referencedColumn: $$PrintsQuestaoTableReferences
                            ._questaoIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PrintsQuestaoTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PrintsQuestaoTable,
      PrintQuestao,
      $$PrintsQuestaoTableFilterComposer,
      $$PrintsQuestaoTableOrderingComposer,
      $$PrintsQuestaoTableAnnotationComposer,
      $$PrintsQuestaoTableCreateCompanionBuilder,
      $$PrintsQuestaoTableUpdateCompanionBuilder,
      (PrintQuestao, $$PrintsQuestaoTableReferences),
      PrintQuestao,
      PrefetchHooks Function({bool questaoId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ConcursosTableTableManager get concursos =>
      $$ConcursosTableTableManager(_db, _db.concursos);
  $$MateriasTableTableManager get materias =>
      $$MateriasTableTableManager(_db, _db.materias);
  $$ConcursoMateriasTableTableManager get concursoMaterias =>
      $$ConcursoMateriasTableTableManager(_db, _db.concursoMaterias);
  $$TopicosTableTableManager get topicos =>
      $$TopicosTableTableManager(_db, _db.topicos);
  $$RevisoesTableTableManager get revisoes =>
      $$RevisoesTableTableManager(_db, _db.revisoes);
  $$QuestoesTableTableManager get questoes =>
      $$QuestoesTableTableManager(_db, _db.questoes);
  $$SessoesTableTableManager get sessoes =>
      $$SessoesTableTableManager(_db, _db.sessoes);
  $$AnexosTableTableManager get anexos =>
      $$AnexosTableTableManager(_db, _db.anexos);
  $$FlashcardsTableTableManager get flashcards =>
      $$FlashcardsTableTableManager(_db, _db.flashcards);
  $$TopicoConcursosTableTableManager get topicoConcursos =>
      $$TopicoConcursosTableTableManager(_db, _db.topicoConcursos);
  $$ProvasTableTableManager get provas =>
      $$ProvasTableTableManager(_db, _db.provas);
  $$TextosBaseTableTableManager get textosBase =>
      $$TextosBaseTableTableManager(_db, _db.textosBase);
  $$QuestoesProvaTableTableManager get questoesProva =>
      $$QuestoesProvaTableTableManager(_db, _db.questoesProva);
  $$RespostasTableTableManager get respostas =>
      $$RespostasTableTableManager(_db, _db.respostas);
  $$PrintsQuestaoTableTableManager get printsQuestao =>
      $$PrintsQuestaoTableTableManager(_db, _db.printsQuestao);
}

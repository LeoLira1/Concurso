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
          ..write('pontoParada: $pontoParada')
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
          other.pontoParada == this.pontoParada);
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
          PrefetchHooks Function({bool concursoMateriasRefs})
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
          prefetchHooksCallback: ({concursoMateriasRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (concursoMateriasRefs) db.concursoMaterias,
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
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.concursoId == item.id),
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
      PrefetchHooks Function({bool concursoMateriasRefs})
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
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (concursoMateriasRefs) db.concursoMaterias,
                    if (topicosRefs) db.topicos,
                    if (questoesRefs) db.questoes,
                    if (sessoesRefs) db.sessoes,
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
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (revisoesRefs) db.revisoes,
                    if (sessoesRefs) db.sessoes,
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
}

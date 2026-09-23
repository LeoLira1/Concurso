/// Planejamento dos lembretes (sem depender do plugin de notificações, para
/// poder testar). O app agenda os próximos [diasAgendados] dias e refaz o
/// plano sempre que algo muda ou o app é aberto.
library;

const diasAgendados = 14;

/// Ids fixos por tipo: estudo = 1000 + dia, revisões = 2000 + dia.
const idBaseEstudo = 1000;
const idBaseRevisoes = 2000;
const idCronometro = 3000;

const payloadRevisoes = 'revisoes';
const payloadEstudo = 'estudo';
const payloadCronometro = 'cronometro';

class ConfigLembretes {
  const ConfigLembretes({
    this.estudoAtivo = true,
    this.estudoHora = 19,
    this.estudoMinuto = 0,
    this.soSeNaoEstudei = true,
    this.revisoesAtivo = true,
    this.revisoesHora = 8,
    this.revisoesMinuto = 0,
  });

  final bool estudoAtivo;
  final int estudoHora;
  final int estudoMinuto;

  /// Não lembra de estudar se já existe sessão registrada no dia.
  final bool soSeNaoEstudei;

  final bool revisoesAtivo;
  final int revisoesHora;
  final int revisoesMinuto;

  ConfigLembretes copyWith({
    bool? estudoAtivo,
    int? estudoHora,
    int? estudoMinuto,
    bool? soSeNaoEstudei,
    bool? revisoesAtivo,
    int? revisoesHora,
    int? revisoesMinuto,
  }) => ConfigLembretes(
    estudoAtivo: estudoAtivo ?? this.estudoAtivo,
    estudoHora: estudoHora ?? this.estudoHora,
    estudoMinuto: estudoMinuto ?? this.estudoMinuto,
    soSeNaoEstudei: soSeNaoEstudei ?? this.soSeNaoEstudei,
    revisoesAtivo: revisoesAtivo ?? this.revisoesAtivo,
    revisoesHora: revisoesHora ?? this.revisoesHora,
    revisoesMinuto: revisoesMinuto ?? this.revisoesMinuto,
  );

  Map<String, Object> paraJson() => {
    'estudoAtivo': estudoAtivo,
    'estudoHora': estudoHora,
    'estudoMinuto': estudoMinuto,
    'soSeNaoEstudei': soSeNaoEstudei,
    'revisoesAtivo': revisoesAtivo,
    'revisoesHora': revisoesHora,
    'revisoesMinuto': revisoesMinuto,
  };

  factory ConfigLembretes.deJson(Map<String, Object?> j) => ConfigLembretes(
    estudoAtivo: j['estudoAtivo'] as bool? ?? true,
    estudoHora: j['estudoHora'] as int? ?? 19,
    estudoMinuto: j['estudoMinuto'] as int? ?? 0,
    soSeNaoEstudei: j['soSeNaoEstudei'] as bool? ?? true,
    revisoesAtivo: j['revisoesAtivo'] as bool? ?? true,
    revisoesHora: j['revisoesHora'] as int? ?? 8,
    revisoesMinuto: j['revisoesMinuto'] as int? ?? 0,
  );
}

class LembretePlanejado {
  const LembretePlanejado({
    required this.id,
    required this.quando,
    required this.titulo,
    required this.corpo,
    required this.payload,
  });

  final int id;
  final DateTime quando;
  final String titulo;
  final String corpo;
  final String payload;

  @override
  String toString() => '$id $quando $titulo — $corpo';
}

/// Revisão pendente vista pelo planejador.
class RevisaoPendente {
  const RevisaoPendente(this.data, this.topico);
  final DateTime data;
  final String topico;
}

DateTime _dia(DateTime d) => DateTime(d.year, d.month, d.day);

String _listar(List<String> nomes) {
  if (nomes.length <= 2) return nomes.join(' e ');
  return '${nomes.take(2).join(', ')} e mais ${nomes.length - 2}';
}

/// Monta os lembretes dos próximos dias.
///
/// [revisoes] são as revisões pendentes (inclusive atrasadas); em cada dia
/// o lembrete conta todas as que vencem até aquele dia, supondo que ainda
/// não foram feitas — o plano é refeito quando você marca alguma.
List<LembretePlanejado> planejarLembretes({
  required DateTime agora,
  required ConfigLembretes config,
  required List<RevisaoPendente> revisoes,
  required bool estudouHoje,
  String? proximaDoCiclo,
}) {
  final hoje = _dia(agora);
  final plano = <LembretePlanejado>[];
  for (var d = 0; d < diasAgendados; d++) {
    final dia = DateTime(hoje.year, hoje.month, hoje.day + d);

    if (config.revisoesAtivo) {
      final quando = DateTime(
        dia.year,
        dia.month,
        dia.day,
        config.revisoesHora,
        config.revisoesMinuto,
      );
      final doDia = [
        for (final r in revisoes)
          if (!_dia(r.data).isAfter(dia)) r,
      ];
      if (quando.isAfter(agora) && doDia.isNotEmpty) {
        final atrasadas = doDia.where((r) => _dia(r.data).isBefore(dia)).length;
        plano.add(
          LembretePlanejado(
            id: idBaseRevisoes + d,
            quando: quando,
            titulo: doDia.length == 1
                ? '1 revisão para hoje'
                : '${doDia.length} revisões para hoje',
            corpo: [
              _listar(doDia.map((r) => r.topico).toList()),
              if (atrasadas > 0)
                '($atrasadas atrasada${atrasadas == 1 ? '' : 's'})',
            ].join(' '),
            payload: payloadRevisoes,
          ),
        );
      }
    }

    if (config.estudoAtivo) {
      final quando = DateTime(
        dia.year,
        dia.month,
        dia.day,
        config.estudoHora,
        config.estudoMinuto,
      );
      final pular = d == 0 && estudouHoje && config.soSeNaoEstudei;
      if (quando.isAfter(agora) && !pular) {
        plano.add(
          LembretePlanejado(
            id: idBaseEstudo + d,
            quando: quando,
            titulo: 'Hora de estudar',
            corpo: proximaDoCiclo == null
                ? 'Abra o Edital e registre a sessão de hoje.'
                : 'Próxima do ciclo: $proximaDoCiclo',
            payload: payloadEstudo,
          ),
        );
      }
    }
  }
  return plano;
}

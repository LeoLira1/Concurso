import 'dart:convert';

import 'package:http/http.dart' as http;

/// Um comando SQL com argumentos posicionais (?).
class Comando {
  const Comando(this.sql, [this.args = const []]);
  final String sql;
  final List<Object?> args;
}

typedef Linha = Map<String, Object?>;

/// Onde os comandos são executados: o Turso (HTTP) ou, nos testes, um
/// SQLite local que faz o papel do servidor.
abstract interface class ExecutorRemoto {
  /// Executa os comandos em ordem; devolve as linhas de cada um.
  Future<List<List<Linha>>> executar(List<Comando> comandos);
}

class ErroTurso implements Exception {
  ErroTurso(this.mensagem, {this.autenticacao = false});
  final String mensagem;
  final bool autenticacao;

  @override
  String toString() => mensagem;
}

/// Cliente da API HTTP do Turso (protocolo Hrana, POST /v2/pipeline).
class ClienteTurso implements ExecutorRemoto {
  ClienteTurso({required String url, required this.token, http.Client? cliente})
    : endpoint = Uri.parse('${normalizarUrl(url)}/v2/pipeline'),
      _http = cliente ?? http.Client();

  final Uri endpoint;
  final String token;
  final http.Client _http;

  /// "libsql://edital-fulano.turso.io" -> "https://edital-fulano.turso.io".
  static String normalizarUrl(String url) {
    var u = url.trim();
    u = u.replaceFirst(RegExp(r'^(libsql|wss|ws)://'), 'https://');
    if (!u.startsWith('http')) u = 'https://$u';
    return u.replaceFirst(RegExp(r'/+$'), '');
  }

  static Map<String, Object?> _valor(Object? v) => switch (v) {
    null => {'type': 'null'},
    bool b => {'type': 'integer', 'value': b ? '1' : '0'},
    int i => {'type': 'integer', 'value': '$i'},
    double d => {'type': 'float', 'value': d},
    DateTime d => {
      'type': 'integer',
      'value': '${d.millisecondsSinceEpoch ~/ 1000}',
    },
    _ => {'type': 'text', 'value': '$v'},
  };

  static Object? _ler(Map<String, dynamic> v) => switch (v['type']) {
    'null' => null,
    'integer' => int.parse('${v['value']}'),
    'float' => (v['value'] as num).toDouble(),
    'text' => v['value'] as String,
    'blob' => base64Decode(v['base64'] as String),
    _ => v['value'],
  };

  @override
  Future<List<List<Linha>>> executar(List<Comando> comandos) async {
    final corpo = jsonEncode({
      'baton': null,
      'requests': [
        for (final c in comandos)
          {
            'type': 'execute',
            'stmt': {
              'sql': c.sql,
              'args': [for (final a in c.args) _valor(a)],
            },
          },
        {'type': 'close'},
      ],
    });
    final http.Response r;
    try {
      r = await _http
          .post(
            endpoint,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: corpo,
          )
          .timeout(const Duration(seconds: 30));
    } catch (e) {
      throw ErroTurso('Sem conexão com o Turso ($e)');
    }
    if (r.statusCode == 401 || r.statusCode == 403) {
      throw ErroTurso('Token inválido ou sem permissão', autenticacao: true);
    }
    if (r.statusCode != 200) {
      throw ErroTurso('Turso respondeu ${r.statusCode}: ${r.body}');
    }
    final json = jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
    final resultados = json['results'] as List;
    final saida = <List<Linha>>[];
    for (var i = 0; i < comandos.length; i++) {
      final res = resultados[i] as Map<String, dynamic>;
      if (res['type'] == 'error') {
        throw ErroTurso('Erro no Turso: ${(res['error'] as Map)['message']}');
      }
      final result = (res['response'] as Map)['result'] as Map<String, dynamic>;
      final cols = [
        for (final c in result['cols'] as List) (c as Map)['name'] as String,
      ];
      saida.add([
        for (final linha in result['rows'] as List)
          {
            for (var k = 0; k < cols.length; k++)
              cols[k]: _ler((linha as List)[k] as Map<String, dynamic>),
          },
      ]);
    }
    return saida;
  }
}

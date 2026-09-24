import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:path_provider/path_provider.dart';

import '../data/database.dart';
import '../data/provas_db.dart';

/// Arquivos de anexos (fotos e PDFs) guardados na pasta privada do app.
/// Ficam só neste aparelho (a sincronização futura cuidará dos arquivos).
abstract final class ArquivosAnexos {
  /// Nos testes/capturas não há path_provider: aponte para uma pasta.
  static Directory? pastaFixa;

  static Directory? _cache;

  static Future<Directory> pasta() async {
    final fixa = pastaFixa;
    if (fixa != null) return fixa;
    if (_cache != null) return _cache!;
    final docs = await getApplicationDocumentsDirectory();
    final d = Directory('${docs.path}${Platform.pathSeparator}anexos');
    if (!await d.exists()) await d.create(recursive: true);
    return _cache = d;
  }

  static Future<File> arquivo(String nome) async =>
      File('${(await pasta()).path}${Platform.pathSeparator}$nome');

  static String extensao(String nome, {String padrao = 'jpg'}) {
    final i = nome.lastIndexOf('.');
    if (i < 0 || i == nome.length - 1) return padrao;
    return nome.substring(i + 1).toLowerCase();
  }

  /// Copia o arquivo escolhido para a pasta do app e cria o anexo.
  static Future<void> importar({
    required AppDatabase db,
    required String topicoId,
    required XFile origem,
    required String tipo,
    required String nome,
  }) async {
    final ext = extensao(origem.name, padrao: tipo == 'pdf' ? 'pdf' : 'jpg');
    final nomeArquivo = '${novoId()}.$ext';
    final destino = await arquivo(nomeArquivo);
    await origem.saveTo(destino.path);
    await db.adicionarAnexo(
      topicoId: topicoId,
      tipo: tipo,
      nome: nome,
      arquivo: nomeArquivo,
      bytes: await destino.length(),
    );
  }

  /// Print de uma questão de prova (fica só neste aparelho).
  static Future<void> importarPrint({
    required AppDatabase db,
    required String questaoId,
    required XFile origem,
  }) async {
    final nomeArquivo = '${novoId()}.${extensao(origem.name)}';
    final destino = await arquivo(nomeArquivo);
    await origem.saveTo(destino.path);
    await db.adicionarPrint(questaoId, nomeArquivo);
  }

  static Future<void> excluirPrint(AppDatabase db, PrintQuestao p) async {
    await db.excluirPrint(p.id);
    try {
      final f = await arquivo(p.arquivo);
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }

  static Future<void> excluir(AppDatabase db, Anexo a) async {
    await db.excluirAnexo(a.id);
    try {
      final f = await arquivo(a.arquivo);
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }

  /// Apaga do disco arquivos sem anexo (ex.: tópico excluído).
  static Future<void> limparOrfaos(AppDatabase db) async {
    try {
      final usados = await db.arquivosDeAnexos();
      final d = await pasta();
      await for (final e in d.list()) {
        final nome = e.uri.pathSegments.last;
        if (e is File && !usados.contains(nome)) await e.delete();
      }
    } catch (_) {}
  }
}

String tamanhoFmt(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).round()} KB';
  return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
}

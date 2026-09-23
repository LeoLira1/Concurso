import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../logic/flashcards.dart';
import '../state/arquivos.dart';
import '../theme.dart';
import '../util/texto.dart';
import '../widgets/assistir.dart';
import '../widgets/comuns.dart';
import 'cronometro_screen.dart';
import 'flashcards_screen.dart';

/// Um tópico do edital: resumos/mapas mentais anexados e flashcards.
class TopicoScreen extends StatelessWidget {
  const TopicoScreen({super.key, required this.topicoId});
  final String topicoId;

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return Assistir<List<Topico>>(
      chave: topicoId,
      stream: () =>
          (db.select(db.topicos)..where((t) => t.id.equals(topicoId))).watch(),
      builder: (context, l) {
        final t = (l == null || l.isEmpty) ? null : l.first;
        if (t == null) return const Scaffold();
        return Assistir<Materia?>(
          chave: t.materiaId,
          stream: () => db.watchMateria(t.materiaId),
          builder: (context, m) {
            if (m == null) return const Scaffold();
            return Scaffold(
              appBar: AppBar(toolbarHeight: 72),
              body: LayoutBuilder(
                builder: (context, box) {
                  final largo = box.maxWidth >= 1000;
                  final anexos = _CartaoAnexos(topico: t);
                  final cartoes = _CartaoFlashcards(topico: t, materia: m);
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: ListView(
                        padding: EdgeInsets.fromLTRB(
                          largo ? 36 : 24,
                          0,
                          largo ? 36 : 24,
                          40,
                        ),
                        children: [
                          _Cabecalho(topico: t, materia: m),
                          const SizedBox(height: 24),
                          if (largo)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: anexos),
                                const SizedBox(width: 20),
                                Expanded(child: cartoes),
                              ],
                            )
                          else ...[
                            anexos,
                            const SizedBox(height: 20),
                            cartoes,
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _Cabecalho extends StatelessWidget {
  const _Cabecalho({required this.topico, required this.materia});
  final Topico topico;
  final Materia materia;

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Bolinha(Color(materia.cor), tamanho: 14),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                materia.nome.toUpperCase(),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  color: Cores.tintaSuave,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(topico.nome, style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FilterChip(
              avatar: Icon(
                topico.visto
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: topico.visto ? Colors.white : Cores.tinta,
                size: 20,
              ),
              label: Text(
                topico.visto
                    ? 'Visto${topico.vistoEm == null ? '' : ' em ${dataCurta(topico.vistoEm!)}'}'
                    : 'Marcar como visto',
              ),
              selected: topico.visto,
              showCheckmark: false,
              labelStyle: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: topico.visto ? Colors.white : Cores.tinta,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              onSelected: (v) async {
                await db.marcarVisto(topico.id, v);
                if (v && context.mounted) {
                  avisar(
                    context,
                    'Visto! Revisões agendadas para amanhã, em 7 e em 30 dias.',
                  );
                }
              },
            ),
            ActionChip(
              avatar: const Icon(Icons.play_arrow_rounded, size: 20),
              label: const Text('Estudar este tópico'),
              labelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              onPressed: () => abrirCronometro(
                context,
                materiaId: materia.id,
                topicoId: topico.id,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Cartao extends StatelessWidget {
  const _Cartao({
    required this.titulo,
    this.subtitulo,
    required this.acoes,
    required this.child,
  });
  final String titulo;
  final String? subtitulo;
  final List<Widget> acoes;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(24, 20, 20, 24),
    decoration: BoxDecoration(
      border: Border.all(color: Cores.linha, width: 1.5),
      borderRadius: BorderRadius.circular(28),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(titulo, style: Theme.of(context).textTheme.titleLarge),
        if (subtitulo != null)
          Text(
            subtitulo!,
            style: const TextStyle(fontSize: 14, color: Cores.tintaSuave),
          ),
        const SizedBox(height: 14),
        Wrap(spacing: 8, runSpacing: 8, children: acoes),
        const SizedBox(height: 18),
        child,
      ],
    ),
  );
}

// -----------------------------------------------------------------------------
// Anexos
// -----------------------------------------------------------------------------

class _CartaoAnexos extends StatelessWidget {
  const _CartaoAnexos({required this.topico});
  final Topico topico;

  Future<void> _adicionarImagens(
    BuildContext context,
    ImageSource fonte,
  ) async {
    final db = context.read<AppDatabase>();
    final picker = ImagePicker();
    try {
      final List<XFile> fotos;
      if (fonte == ImageSource.camera) {
        final f = await picker.pickImage(
          source: fonte,
          maxWidth: 2400,
          imageQuality: 85,
        );
        fotos = f == null ? const [] : [f];
      } else {
        fotos = await picker.pickMultiImage(maxWidth: 2400, imageQuality: 85);
      }
      final agora = DateTime.now();
      for (final (i, f) in fotos.indexed) {
        await ArquivosAnexos.importar(
          db: db,
          topicoId: topico.id,
          origem: f,
          tipo: 'imagem',
          nome: fonte == ImageSource.camera
              ? 'Foto ${dataCurta(agora)} ${agora.hour.toString().padLeft(2, '0')}:${agora.minute.toString().padLeft(2, '0')}'
              : _semExtensao(f.name, 'Imagem ${i + 1}'),
        );
      }
    } catch (e) {
      if (context.mounted) {
        avisar(context, 'Não foi possível adicionar a imagem');
      }
    }
  }

  Future<void> _adicionarPdf(BuildContext context) async {
    final db = context.read<AppDatabase>();
    try {
      final arquivos = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
      );
      for (final f in arquivos) {
        await ArquivosAnexos.importar(
          db: db,
          topicoId: topico.id,
          origem: f.xFile,
          tipo: 'pdf',
          nome: _semExtensao(f.name, 'PDF'),
        );
      }
    } catch (e) {
      if (context.mounted) avisar(context, 'Não foi possível adicionar o PDF');
    }
  }

  static String _semExtensao(String nome, String padrao) {
    final i = nome.lastIndexOf('.');
    final base = (i > 0 ? nome.substring(0, i) : nome).trim();
    return base.isEmpty ? padrao : base;
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return Assistir<List<Anexo>>(
      chave: topico.id,
      stream: () => db.watchAnexos(topico.id),
      builder: (context, l) {
        final anexos = l ?? const <Anexo>[];
        return _Cartao(
          titulo: 'Resumos e mapas mentais',
          subtitulo: anexos.isEmpty
              ? 'Foto do caderno, imagem ou PDF'
              : '${anexos.length} arquivo${anexos.length == 1 ? '' : 's'}',
          acoes: [
            Pilula(
              icone: Icons.photo_camera_outlined,
              rotulo: 'Foto',
              aoTocar: () => _adicionarImagens(context, ImageSource.camera),
            ),
            Pilula(
              icone: Icons.image_outlined,
              rotulo: 'Galeria',
              aoTocar: () => _adicionarImagens(context, ImageSource.gallery),
            ),
            Pilula(
              icone: Icons.picture_as_pdf_outlined,
              rotulo: 'PDF',
              aoTocar: () => _adicionarPdf(context),
            ),
          ],
          child: anexos.isEmpty
              ? const Text(
                  'Nenhum resumo anexado ainda.',
                  style: TextStyle(fontSize: 15, color: Cores.tintaSuave),
                )
              : Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: [for (final a in anexos) _MiniaturaAnexo(a)],
                ),
        );
      },
    );
  }
}

class _MiniaturaAnexo extends StatelessWidget {
  const _MiniaturaAnexo(this.a);
  final Anexo a;

  Future<void> _abrir(BuildContext context) async {
    final f = await ArquivosAnexos.arquivo(a.arquivo);
    if (!context.mounted) return;
    if (a.tipo == 'imagem') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VisualizadorImagem(anexo: a, arquivo: f),
        ),
      );
    } else {
      final r = await OpenFilex.open(f.path, type: 'application/pdf');
      if (r.type != ResultType.done && context.mounted) {
        avisar(context, 'Instale um leitor de PDF para abrir este arquivo');
      }
    }
  }

  Future<void> _menu(BuildContext context) async {
    final db = context.read<AppDatabase>();
    final v = await showModalBottomSheet<String>(
      context: context,
      constraints: const BoxConstraints(maxWidth: 520),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Renomear'),
              onTap: () => Navigator.pop(ctx, 'renomear'),
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline_rounded,
                color: Cores.acento,
              ),
              title: const Text(
                'Excluir',
                style: TextStyle(color: Cores.acento),
              ),
              onTap: () => Navigator.pop(ctx, 'excluir'),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
    if (!context.mounted) return;
    if (v == 'renomear') {
      final nome = await pedirTexto(
        context,
        titulo: 'Renomear',
        inicial: a.nome,
      );
      if (nome != null) await db.renomearAnexo(a.id, nome);
    } else if (v == 'excluir') {
      final ok = await confirmar(
        context,
        titulo: 'Excluir "${a.nome}"?',
        mensagem: 'O arquivo será apagado do app.',
      );
      if (ok) await ArquivosAnexos.excluir(db, a);
    }
  }

  @override
  Widget build(BuildContext context) {
    const largura = 150.0;
    return SizedBox(
      width: largura,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _abrir(context),
        onLongPress: () => _menu(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: largura,
                height: 170,
                decoration: BoxDecoration(
                  color: Cores.fundoLateral,
                  border: Border.all(color: Cores.linha, width: 1.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: a.tipo == 'imagem'
                    ? _Miniatura(arquivo: a.arquivo)
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.picture_as_pdf_rounded,
                            size: 52,
                            color: Cores.acento,
                          ),
                          SizedBox(height: 6),
                          Text(
                            'PDF',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              a.nome,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            Text(
              tamanhoFmt(a.bytes),
              style: const TextStyle(fontSize: 12, color: Cores.tintaSuave),
            ),
          ],
        ),
      ),
    );
  }
}

/// Imagem em tela cheia com zoom (pinça).
class VisualizadorImagem extends StatelessWidget {
  const VisualizadorImagem({
    super.key,
    required this.anexo,
    required this.arquivo,
  });
  final Anexo anexo;
  final File arquivo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(anexo.nome, style: const TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            tooltip: 'Abrir em outro app',
            icon: const Icon(Icons.open_in_new_rounded),
            onPressed: () => OpenFilex.open(arquivo.path),
          ),
        ],
      ),
      body: InteractiveViewer(
        maxScale: 6,
        child: Center(child: Image.file(arquivo)),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Flashcards
// -----------------------------------------------------------------------------

class _CartaoFlashcards extends StatelessWidget {
  const _CartaoFlashcards({required this.topico, required this.materia});
  final Topico topico;
  final Materia materia;

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return Assistir<List<Flashcard>>(
      chave: topico.id,
      stream: () => db.watchFlashcards(topico.id),
      builder: (context, l) {
        final cartoes = l ?? const <Flashcard>[];
        final hoje = soDia(DateTime.now());
        final paraHoje = cartoes
            .where((c) => !c.proximaRevisao.isAfter(hoje))
            .length;
        return _Cartao(
          titulo: 'Flashcards',
          subtitulo: cartoes.isEmpty
              ? 'Pergunta de um lado, resposta do outro'
              : '${cartoes.length} cartões · $paraHoje para revisar hoje',
          acoes: [
            if (paraHoje > 0)
              FilledButton.icon(
                style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
                onPressed: () => abrirEstudoFlashcards(
                  context,
                  titulo: topico.nome,
                  topicoId: topico.id,
                ),
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text('Revisar $paraHoje'),
              )
            else if (cartoes.isNotEmpty)
              Pilula(
                icone: Icons.replay_rounded,
                rotulo: 'Praticar todos',
                aoTocar: () => abrirEstudoFlashcards(
                  context,
                  titulo: topico.nome,
                  topicoId: topico.id,
                  todos: true,
                ),
              ),
            Pilula(
              icone: Icons.add_rounded,
              rotulo: 'Novo cartão',
              aoTocar: () => editarFlashcard(context, topicoId: topico.id),
            ),
          ],
          child: cartoes.isEmpty
              ? const Text(
                  'Nenhum flashcard ainda.',
                  style: TextStyle(fontSize: 15, color: Cores.tintaSuave),
                )
              : Column(
                  children: [
                    for (final c in cartoes)
                      _LinhaCartao(c, cor: Color(materia.cor)),
                  ],
                ),
        );
      },
    );
  }
}

class _LinhaCartao extends StatelessWidget {
  const _LinhaCartao(this.c, {required this.cor});
  final Flashcard c;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => editarFlashcard(context, topicoId: c.topicoId, cartao: c),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Cores.fundoLateral,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.frente,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    c.verso,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Cores.tintaSuave,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Tooltip(
              message: 'Caixa ${c.caixa} de $caixaMaxima',
              child: Row(
                children: [
                  for (var i = 1; i <= caixaMaxima; i++)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(left: 3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i <= c.caixa ? cor : Cores.linha,
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Excluir',
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Cores.tintaSuave,
              ),
              onPressed: () async {
                final ok = await confirmar(
                  context,
                  titulo: 'Excluir cartão?',
                  mensagem: c.frente,
                );
                if (ok) await db.excluirFlashcard(c.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Cria ou edita um flashcard. "Salvar e criar outro" agiliza a digitação.
Future<void> editarFlashcard(
  BuildContext context, {
  required String topicoId,
  Flashcard? cartao,
}) {
  return showDialog(
    context: context,
    builder: (_) => _EditorCartao(topicoId: topicoId, cartao: cartao),
  );
}

class _EditorCartao extends StatefulWidget {
  const _EditorCartao({required this.topicoId, this.cartao});
  final String topicoId;
  final Flashcard? cartao;

  @override
  State<_EditorCartao> createState() => _EditorCartaoState();
}

class _EditorCartaoState extends State<_EditorCartao> {
  late final _frente = TextEditingController(text: widget.cartao?.frente);
  late final _verso = TextEditingController(text: widget.cartao?.verso);
  final _focoFrente = FocusNode();
  int _criados = 0;

  @override
  void dispose() {
    _frente.dispose();
    _verso.dispose();
    _focoFrente.dispose();
    super.dispose();
  }

  Future<bool> _salvar() async {
    if (_frente.text.trim().isEmpty || _verso.text.trim().isEmpty) {
      avisar(context, 'Preencha a pergunta e a resposta');
      return false;
    }
    await context.read<AppDatabase>().salvarFlashcard(
      id: widget.cartao?.id,
      topicoId: widget.topicoId,
      frente: _frente.text,
      verso: _verso.text,
    );
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final novo = widget.cartao == null;
    return AlertDialog(
      title: Text(
        novo ? 'Novo flashcard' : 'Editar flashcard',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      content: SizedBox(
        width: 560,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_criados > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  '$_criados criado${_criados == 1 ? '' : 's'} ✓',
                  style: const TextStyle(
                    color: Cores.tintaSuave,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            const Text(
              'Frente (pergunta)',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _frente,
              focusNode: _focoFrente,
              autofocus: true,
              minLines: 2,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(fontSize: 18),
              decoration: const InputDecoration(
                hintText: 'Ex.: Quando a crase é facultativa?',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Verso (resposta)',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _verso,
              minLines: 3,
              maxLines: 8,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(fontSize: 18),
              decoration: const InputDecoration(
                hintText: 'Ex.: Antes de nomes próprios femininos, pronomes possessivos e após "até".',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        if (novo)
          TextButton(
            onPressed: () async {
              if (!await _salvar()) return;
              setState(() {
                _criados++;
                _frente.clear();
                _verso.clear();
              });
              _focoFrente.requestFocus();
            },
            child: const Text('Salvar e criar outro'),
          ),
        FilledButton(
          onPressed: () async {
            if (await _salvar() && context.mounted) Navigator.pop(context);
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}

/// Miniatura de imagem: lê os bytes e decodifica reduzida (leve na memória).
class _Miniatura extends StatefulWidget {
  const _Miniatura({required this.arquivo});
  final String arquivo;

  @override
  State<_Miniatura> createState() => _MiniaturaState();
}

class _MiniaturaState extends State<_Miniatura> {
  late final Future<Uint8List> _bytes = ArquivosAnexos.arquivo(widget.arquivo)
      .then((f) => f.readAsBytes());

  @override
  Widget build(BuildContext context) => FutureBuilder<Uint8List>(
    future: _bytes,
    builder: (context, s) => s.data == null
        ? const SizedBox.shrink()
        : Image.memory(
            s.data!,
            fit: BoxFit.cover,
            cacheWidth: 400,
            gaplessPlayback: true,
            errorBuilder: (_, _, _) => const Icon(
              Icons.broken_image_outlined,
              color: Cores.tintaFraca,
            ),
          ),
  );
}

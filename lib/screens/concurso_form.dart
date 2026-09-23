import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../theme.dart';
import '../util/texto.dart';
import '../widgets/comuns.dart';

/// Abre o formulário de concurso (novo ou edição). Retorna o id salvo.
Future<String?> abrirFormConcurso(BuildContext context, {Concurso? concurso}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    constraints: const BoxConstraints(maxWidth: 640),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (_) => _FormConcurso(concurso: concurso),
  );
}

class _FormConcurso extends StatefulWidget {
  const _FormConcurso({this.concurso});
  final Concurso? concurso;

  @override
  State<_FormConcurso> createState() => _FormConcursoState();
}

class _FormConcursoState extends State<_FormConcurso> {
  late final _nome = TextEditingController(text: widget.concurso?.nome);
  late final _banca = TextEditingController(text: widget.concurso?.banca);
  late DateTime? _data = widget.concurso?.dataProva;
  late int _cor = widget.concurso?.cor ?? Cores.paleta.first;
  bool _salvando = false;

  @override
  void dispose() {
    _nome.dispose();
    _banca.dispose();
    super.dispose();
  }

  Future<void> _escolherData() async {
    final hoje = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _data ?? hoje.add(const Duration(days: 90)),
      firstDate: DateTime(hoje.year - 1),
      lastDate: DateTime(hoje.year + 6),
      helpText: 'Data da prova',
    );
    if (d != null) setState(() => _data = d);
  }

  Future<void> _salvar() async {
    if (_nome.text.trim().isEmpty) {
      avisar(context, 'Dê um nome ao concurso');
      return;
    }
    setState(() => _salvando = true);
    final db = context.read<AppDatabase>();
    String id;
    if (widget.concurso == null) {
      id = await db.criarConcurso(
        nome: _nome.text,
        banca: _banca.text,
        dataProva: _data,
        cor: _cor,
      );
    } else {
      id = widget.concurso!.id;
      await db.atualizarConcurso(
        id,
        nome: _nome.text,
        banca: _banca.text,
        dataProva: _data,
        cor: _cor,
      );
    }
    if (mounted) Navigator.pop(context, id);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.concurso == null ? 'Novo concurso' : 'Editar concurso',
              style: t.headlineMedium,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nome,
              autofocus: widget.concurso == null,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              decoration: const InputDecoration(
                hintText: 'Nome (ex.: PM-SP Soldado)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _banca,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(fontSize: 18),
              decoration: const InputDecoration(
                hintText: 'Banca (ex.: Vunesp)',
              ),
            ),
            const SizedBox(height: 12),
            Material(
              color: Cores.fundoLateral,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _escolherData,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
                  child: Row(
                    children: [
                      const Icon(Icons.event_rounded, color: Cores.tintaSuave),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _data == null
                              ? 'Data da prova (opcional)'
                              : dataCurta(_data!),
                          style: TextStyle(
                            fontSize: 18,
                            color: _data == null
                                ? Cores.tintaSuave
                                : Cores.tinta,
                            fontWeight: _data == null
                                ? FontWeight.w400
                                : FontWeight.w700,
                          ),
                        ),
                      ),
                      if (_data != null)
                        IconButton(
                          tooltip: 'Remover data',
                          onPressed: () => setState(() => _data = null),
                          icon: const Icon(Icons.close_rounded),
                        )
                      else
                        const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Cor', style: t.titleMedium),
            const SizedBox(height: 12),
            SeletorCores(valor: _cor, aoMudar: (c) => setState(() => _cor = c)),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _salvando ? null : _salvar,
              child: Text(
                widget.concurso == null ? 'Criar concurso' : 'Salvar',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

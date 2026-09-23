import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/sync/cliente_turso.dart';
import '../state/sincronizacao.dart';
import '../theme.dart';
import '../widgets/comuns.dart';

/// Configurar e acompanhar a sincronização com o Turso.
class SincronizacaoScreen extends StatelessWidget {
  const SincronizacaoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<Sincronizacao>();
    return Scaffold(
      appBar: AppBar(toolbarHeight: 72),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 40),
            children: [
              Text(
                'Sincronização',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 6),
              const Text(
                'Tablet e celular com os mesmos dados, usando um banco gratuito no Turso.',
                style: TextStyle(fontSize: 16, color: Cores.tintaSuave),
              ),
              const SizedBox(height: 24),
              if (s.configurado) _Estado(s: s) else const _Configurar(),
              const SizedBox(height: 24),
              const _Nota(
                icone: Icons.info_outline_rounded,
                texto:
                    'Sincroniza concursos, edital, progresso, ciclo, sessões, revisões e '
                    'flashcards. Fotos e PDFs anexados ficam só no aparelho em que foram '
                    'adicionados. Lembretes e pomodoro são configurados em cada aparelho.',
              ),
              const SizedBox(height: 10),
              const _Nota(
                icone: Icons.merge_type_rounded,
                texto:
                    'Se o mesmo item for alterado nos dois aparelhos antes de sincronizar, '
                    'vale a alteração mais recente. Matérias com o mesmo nome criadas nos dois '
                    'viram uma só.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Estado extends StatelessWidget {
  const _Estado({required this.s});
  final Sincronizacao s;

  String _quando(DateTime d) {
    final agora = DateTime.now();
    final hm =
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    if (d.year == agora.year && d.month == agora.month && d.day == agora.day) {
      return 'hoje às $hm';
    }
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')} às $hm';
  }

  @override
  Widget build(BuildContext context) {
    final erro = s.erro;
    final (icone, cor, titulo) = s.sincronizando
        ? (Icons.cloud_sync_outlined, Cores.tinta, 'Sincronizando…')
        : erro != null
        ? (
            Icons.cloud_off_outlined,
            Cores.acento,
            'Não foi possível sincronizar',
          )
        : (Icons.cloud_done_outlined, const Color(0xFF1F9D55), 'Sincronizado');
    final host = Uri.tryParse(ClienteTurso.normalizarUrl(s.url))?.host ?? s.url;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 22, 20, 18),
      decoration: BoxDecoration(
        border: Border.all(
          color: erro == null ? Cores.tinta : Cores.acento,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icone, size: 40, color: cor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      [
                            if (s.ultima != null)
                              'Última: ${_quando(s.ultima!)}',
                            if (s.pendentes > 0)
                              '${s.pendentes} ${s.pendentes == 1 ? 'alteração' : 'alterações'} para enviar',
                          ]
                          .join('  ·  ')
                          .ifEmpty('Aguardando a primeira sincronização'),
                      style: const TextStyle(
                        fontSize: 15,
                        color: Cores.tintaSuave,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (erro != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEDEC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(erro, style: const TextStyle(fontSize: 14)),
            ),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              const Icon(
                Icons.storage_rounded,
                size: 18,
                color: Cores.tintaSuave,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  host,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, color: Cores.tintaSuave),
                ),
              ),
            ],
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: s.automatica,
            activeTrackColor: Cores.tinta,
            onChanged: s.definirAutomatica,
            title: const Text(
              'Sincronizar automaticamente',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Ao abrir o app, ao voltar para ele e após cada alteração',
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.spaceBetween,
            children: [
              FilledButton.icon(
                onPressed: s.sincronizando ? null : s.sincronizar,
                icon: const Icon(Icons.sync_rounded),
                label: const Text('Sincronizar agora'),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Cores.acento),
                onPressed: () async {
                  final ok = await confirmar(
                    context,
                    titulo: 'Desconectar?',
                    mensagem: 'Os dados continuam neste aparelho e na nuvem; só param de sincronizar.',
                    acao: 'Desconectar',
                  );
                  if (ok) await s.desconectar();
                },
                child: const Text('Desconectar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

extension on String {
  String ifEmpty(String outro) => isEmpty ? outro : this;
}

class _Configurar extends StatefulWidget {
  const _Configurar();

  @override
  State<_Configurar> createState() => _ConfigurarState();
}

class _ConfigurarState extends State<_Configurar> {
  final _url = TextEditingController();
  final _token = TextEditingController();
  bool _conectando = false;
  bool _mostrarToken = false;
  String? _erro;

  @override
  void dispose() {
    _url.dispose();
    _token.dispose();
    super.dispose();
  }

  Future<void> _colar(TextEditingController c) async {
    final d = await Clipboard.getData(Clipboard.kTextPlain);
    if (d?.text != null) setState(() => c.text = d!.text!.trim());
  }

  Future<void> _conectar() async {
    final s = context.read<Sincronizacao>();
    final u = _url.text.trim(), t = _token.text.trim();
    if (u.isEmpty || t.isEmpty) {
      setState(() => _erro = 'Preencha a URL e o token.');
      return;
    }
    setState(() {
      _conectando = true;
      _erro = null;
    });
    try {
      final info = await s.testar(u, t);
      if (!mounted) return;
      ModoConexao? modo;
      if (info.remoto == 0) {
        modo = ModoConexao.enviarTudo;
      } else if (info.local == 0) {
        modo = ModoConexao.juntar;
      } else {
        modo = await _perguntarModo(info);
      }
      if (modo == null) return;
      await s.conectar(u, t, modo);
      if (mounted) avisar(context, 'Sincronização ativada');
    } on ErroTurso catch (e) {
      setState(
        () => _erro = e.autenticacao
            ? 'Token inválido ou sem permissão de escrita. Gere um novo token no Turso.'
            : e.mensagem,
      );
    } catch (e) {
      setState(() => _erro = 'Não foi possível conectar: $e');
    } finally {
      if (mounted) setState(() => _conectando = false);
    }
  }

  Future<ModoConexao?> _perguntarModo(InfoConexao info) {
    return showDialog<ModoConexao>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Os dois lados já têm dados',
          style: Theme.of(ctx).textTheme.headlineSmall,
        ),
        content: SizedBox(
          width: 520,
          child: Text(
            'A nuvem tem ${info.remoto} registros e este aparelho tem ${info.local}.\n\n'
            '• Juntar: envia os deste aparelho e recebe os da nuvem (matérias com o mesmo nome viram uma só).\n\n'
            '• Usar só os da nuvem: apaga os dados deste aparelho e baixa os da nuvem. '
            'Bom para o segundo aparelho, se ele só tiver o exemplo.',
            style: const TextStyle(fontSize: 15, height: 1.4),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx, ModoConexao.usarNuvem),
            child: const Text('Usar só os da nuvem'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ModoConexao.juntar),
            child: const Text('Juntar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 22),
          decoration: BoxDecoration(
            color: Cores.fundoLateral,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Como configurar (uma vez)', style: t.titleLarge),
              const SizedBox(height: 12),
              for (final (i, passo) in const [
                'Crie uma conta grátis em turso.tech (dá para entrar com a conta do GitHub).',
                'Crie um banco de dados ("Create Database"), por exemplo "edital", na região São Paulo (gru) se houver.',
                'Na página do banco, copie a URL — algo como libsql://edital-seunome.turso.io.',
                'Gere um token ("Generate/Create Token") com leitura e escrita, sem expiração, e copie.',
                'Cole os dois abaixo. No outro aparelho, use a mesma URL e o mesmo token.',
              ].indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Cores.tinta,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          passo,
                          style: const TextStyle(fontSize: 15, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text('URL do banco', style: t.titleMedium),
        const SizedBox(height: 8),
        TextField(
          controller: _url,
          keyboardType: TextInputType.url,
          autocorrect: false,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            hintText: 'libsql://edital-seunome.turso.io',
            suffixIcon: IconButton(
              tooltip: 'Colar',
              icon: const Icon(Icons.content_paste_rounded),
              onPressed: () => _colar(_url),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Token', style: t.titleMedium),
        const SizedBox(height: 8),
        TextField(
          controller: _token,
          obscureText: !_mostrarToken,
          autocorrect: false,
          enableSuggestions: false,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            hintText: 'eyJhbGciOi...',
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: _mostrarToken ? 'Esconder' : 'Mostrar',
                  icon: Icon(
                    _mostrarToken
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () =>
                      setState(() => _mostrarToken = !_mostrarToken),
                ),
                IconButton(
                  tooltip: 'Colar',
                  icon: const Icon(Icons.content_paste_rounded),
                  onPressed: () => _colar(_token),
                ),
              ],
            ),
          ),
        ),
        if (_erro != null) ...[
          const SizedBox(height: 12),
          Text(
            _erro!,
            style: const TextStyle(
              color: Cores.acento,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _conectando ? null : _conectar,
          icon: _conectando
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.cloud_outlined),
          label: Text(_conectando ? 'Conectando…' : 'Conectar'),
        ),
        const SizedBox(height: 8),
        const Text(
          'O token fica guardado só neste aparelho.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Cores.tintaSuave),
        ),
      ],
    );
  }
}

class _Nota extends StatelessWidget {
  const _Nota({required this.icone, required this.texto});
  final IconData icone;
  final String texto;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icone, size: 20, color: Cores.tintaSuave),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          texto,
          style: const TextStyle(
            fontSize: 14,
            color: Cores.tintaSuave,
            height: 1.4,
          ),
        ),
      ),
    ],
  );
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'data/database.dart';
import 'screens/home_screen.dart';
import 'state/app_state.dart';
import 'state/arquivos.dart';
import 'state/notificacoes.dart';
import 'state/sessao_ativa.dart';
import 'widgets/ouvinte_notificacoes.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Cores.fundo,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const EditalApp());
}

class EditalApp extends StatelessWidget {
  const EditalApp({super.key, this.database});

  /// Permite injetar um banco em memória nos testes.
  final AppDatabase? database;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppDatabase>(
          create: (_) {
            final db = database ?? AppDatabase();
            if (database == null) ArquivosAnexos.limparOrfaos(db);
            return db;
          },
          dispose: (_, db) => db.close(),
        ),
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(
          create: (ctx) => Notificacoes(db: ctx.read<AppDatabase>())..iniciar(),
        ),
        ChangeNotifierProvider(
          create: (ctx) =>
              SessaoAtiva(notificacoes: ctx.read<Notificacoes>())..restaurar(),
        ),
      ],
      child: MaterialApp(
        title: 'Edital',
        debugShowCheckedModeBanner: false,
        theme: temaEdital(),
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [Locale('pt', 'BR')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const OuvinteNotificacoes(child: HomeScreen()),
      ),
    );
  }
}

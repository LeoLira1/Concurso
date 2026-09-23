import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'data/database.dart';
import 'screens/home_screen.dart';
import 'state/app_state.dart';
import 'state/sessao_ativa.dart';
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
          create: (_) => database ?? AppDatabase(),
          dispose: (_, db) => db.close(),
        ),
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => SessaoAtiva()..restaurar()),
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
        home: const HomeScreen(),
      ),
    );
  }
}

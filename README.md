# edital.

Planner de estudos para concursos públicos, feito em Flutter. Foco em tablet Android, e funciona também no celular.

## Instalar no tablet (sem PC)

A cada push, o GitHub Actions gera o APK e publica em **Releases**:

- Link fixo (branch atual): `https://github.com/LeoLira1/Concurso/releases/download/apk-claude-edital-flutter-planner-gspwbf/edital.apk`
- Para a `main`: `…/releases/download/apk-main/edital.apk`

No tablet: abra o link, baixe e toque em `edital.apk` (autorize "instalar apps desconhecidos" para o navegador na primeira vez). O APK é sempre assinado com a mesma chave (`android/app/edital.keystore`), então as próximas versões instalam por cima sem apagar os dados.

## O que já tem (etapa 1)

- **Meus concursos**: cadastre quantos concursos quiser (nome, banca, data da prova e cor). Um deles fica marcado como **foco atual**.
- **Edital**: matérias → tópicos → subtópicos. Dá para adicionar, renomear, reordenar (arrastando) e excluir. Também dá para colar vários tópicos de uma vez, um por linha, e as linhas que começam com `-` viram subtópicos.
- **Matérias compartilhadas**: nomes iguais (ignorando acento e maiúscula) são a mesma matéria. Tópicos, progresso, revisões e questões de "Português" valem para todos os concursos que têm Português.
- **Tela do mês** (tablet deitado): sidebar com as matérias do concurso em foco (bolinha colorida, nº de tópicos e subtópicos aninhados) e a grade do mês. Dias estudados ficam preenchidos com borda escura (mais escura quando passa de 1h). Tocar numa matéria filtra a grade. "Foco / Tudo junto" alterna entre o concurso em foco e todos juntos. Segurar o dedo numa matéria abre os tópicos dela.
- **Tablet em pé / celular**: grade em tela cheia, matérias no menu ☰ e filtros em pílulas no rodapé.
- Tocar num dia abre o registro manual de estudo. O timer vai fazer isso automaticamente na próxima etapa.
- **Modelo de exemplo** "Guarda Municipal (exemplo)": fica marcado como EXEMPLO e pode ser apagado em Meus concursos.
- Marcar um tópico como visto já agenda as revisões de 1, 7 e 30 dias no banco. A tela de revisões vem na etapa 2.

## Próximas etapas

1. Tela de sessão (retrato/celular): timer pomodoro 25/5 ajustável, tópicos do dia e revisões pendentes. Ao terminar, a sessão é salva e o dia é marcado na grade.
2. Registro de questões por matéria (feitas / acertos / % de acerto).
3. Colar o conteúdo programático do edital e separar automaticamente em matérias e tópicos.
4. Sincronização celular + tablet via Turso (o banco já está preparado: ids UUID + `atualizado_em`; veja `lib/data/sync/`).

## Estrutura

```
lib/
  data/        banco local drift (SQLite), tabelas, exemplo, ponto de sync
  screens/     home (mês + sidebar), meus concursos, edital, matéria
  widgets/     grade do mês, sidebar, folha do dia, componentes
  state/       estado da tela (filtro, mês, foco/tudo)
referencias/   imagens de referência visual
tool/          gerador de capturas de tela (flutter test tool/capturas_test.dart --update-goldens)
```

## Desenvolvimento

```
flutter pub get
dart run build_runner build   # gera lib/data/database.g.dart
flutter test
```

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

## Etapa 2: ciclo de estudos e cronômetro

- **Ciclo de estudos** (menu lateral → "Ciclo de estudos"):
  - Cada matéria tem **peso** e **dificuldade** de 1 a 5, definidos por concurso.
  - O app monta uma fila circular de sessões. O tempo de cada matéria é proporcional a peso + dificuldade.
  - Você ajusta quanto dura uma volta (ex.: 20h) e o tamanho das sessões (30 min a 2h).
  - A fila espalha as sessões e evita repetir a mesma matéria duas vezes seguidas.
  - Se pular um dia, nada atrasa: a fila continua de onde parou.
  - Tocar numa etapa da fila pula direto para ela.
- **Próxima do ciclo**: o botão preto na tela inicial mostra qual matéria estudar agora. Nele você começa, pula a etapa ou vê a fila.
- **Cronômetro** em tela cheia (funciona em pé e deitado):
  - Play/pausa, contando só as horas líquidas.
  - Modo pomodoro opcional (25/5, ajustável). O tempo de pausa não conta.
  - Alarme sonoro com vibração quando bate a meta da sessão e a cada troca foco/pausa.
  - A tela fica acesa enquanto o cronômetro está aberto.
  - O tempo continua certo com o app em segundo plano, e até se o Android fechar o app.
- Ao **finalizar**, a sessão é salva, o dia é marcado na grade e o ciclo avança (dá para desligar o avanço na hora).

## Etapa 3: registro ao finalizar

- Ao finalizar o cronômetro (ou em "Registrar estudo" num dia da grade) você registra:
  - matéria e tópico, com a opção de já marcar o tópico como visto e agendar as revisões;
  - método: videoaula, PDF, questões, revisão ou lei seca;
  - questões feitas e acertos (a % aparece na hora) e páginas;
  - **ponto de parada**, um texto curto.
- **Onde você parou**: na próxima sessão da mesma matéria, o último ponto de parada aparece no cronômetro e na "Próxima do ciclo", com o tópico e o método.
- O tópico da última sessão da matéria já vem sugerido, se ainda não foi visto.
- A folha do dia mostra cada sessão com método, questões, páginas e ponto de parada, e o total do dia com a % de acerto.

## Etapa 4: notificações e revisões

- **Lembretes** (sino ao lado do logo):
  - **Lembrete diário de estudo** no horário que você escolher (padrão 19:00). Mostra a próxima matéria do ciclo e, por padrão, não toca se você já estudou no dia.
  - **Revisões do dia** (padrão 08:00): quantas revisões vencem, com os nomes dos tópicos e quantas estão atrasadas. Só avisa nos dias que têm revisão.
  - Os avisos dos próximos 14 dias são reagendados sozinhos quando algo muda (tópico visto, sessão salva, ciclo andou) e toda vez que o app abre.
  - Botão para enviar uma notificação de teste. No Android 13+ o app pede permissão para notificar.
- **Alarme do cronômetro em segundo plano**: com o app minimizado, a meta da sessão e o fim do foco/pausa chegam como notificação.
- **Revisões** (botão na tela inicial com o contador, ou no menu lateral): atrasadas, de hoje e dos próximos 7 dias.
  - "Revisar" abre o cronômetro já com o tópico e o método "Revisão".
  - ✓ marca a revisão como feita.
  - Salvar uma sessão com método "Revisão" no tópico conclui a revisão sozinho.
- Tocar numa notificação abre a tela certa: revisões, ou o cronômetro em andamento.

## Etapa 5: estatísticas

Menu lateral → "Estatísticas". A tela segue o mesmo escopo da tela inicial: concurso em foco ou tudo junto.

- **Números do dia a dia:**
  - hoje, com a média diária dos últimos 30 dias;
  - esta semana (domingo a sábado), com a variação sobre a semana passada;
  - este mês, com o total do mês passado;
  - sequência de dias seguidos e o recorde. O dia de hoje não quebra a sequência antes de acabar;
  - % de acerto geral, com o total de questões.
- **Horas estudadas:** colunas dos últimos 30 dias, das últimas 12 semanas ou dos últimos 12 meses.
  - O período atual fica destacado.
  - Tocar ou arrastar sobre as colunas mostra o valor de cada uma.
  - Também há uma visão em tabela.
- **Horas por matéria** (com % do total) e **% de acerto por matéria** (acertos/feitas).
- **Contagem regressiva** para a prova mais próxima e os dias até as demais.

## Próximas etapas

1. Anexos (foto/PDF) e flashcards por tópico.
2. Colar o conteúdo programático do edital e separar automaticamente em matérias e tópicos.
3. Sincronização celular + tablet via Turso (o banco já está preparado: ids UUID + `atualizado_em`; veja `lib/data/sync/`).

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

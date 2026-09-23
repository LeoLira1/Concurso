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

## Etapa 6: resumos, mapas mentais e flashcards

- **Tela do tópico**: toque no nome de um tópico (na matéria ou na sidebar) para abrir. O checkbox continua marcando como visto. A tela também tem "Estudar este tópico", que abre o cronômetro já no tópico.
- **Resumos e mapas mentais**:
  - Tire uma **foto** do caderno, escolha imagens da **galeria** ou anexe um **PDF**.
  - As imagens abrem em tela cheia com zoom de pinça. Os PDFs abrem no leitor instalado no tablet.
  - Segure uma miniatura para renomear ou excluir.
  - Os arquivos ficam na pasta do app, neste aparelho.
- **Flashcards por tópico**:
  - Pergunta e resposta, com "Salvar e criar outro" para cadastrar rápido.
  - O estudo é em cartão grande: toque para ver a resposta, depois **Errei** ou **Acertei**.
  - Repetição espaçada (caixas de Leitner): acertou, o cartão volta em 1, 3, 7, 14 e 30 dias; errou, volta para o fim da fila da sessão.
  - Atalhos: "Flashcards · N para revisar" na matéria e o card de flashcards do dia na tela de Revisões.
- Na lista de tópicos, ícones mostram quantos anexos e cartões cada tópico tem.

## Colar o conteúdo programático

No edital do concurso, toque em **"Colar edital"**. Com o edital vazio, também aparece um card com esse atalho.

- Cole o texto copiado do PDF, pelo botão **Colar** ou segurando o dedo no campo. A separação aparece na hora: lado a lado no tablet deitado, ou na aba **Prévia** em pé.
- **O que o app reconhece:**
  - matérias em MAIÚSCULAS ("LÍNGUA PORTUGUESA:"), no formato "Nome: conteúdo" ou numa linha só com o nome;
  - tópicos numerados (1, 1.1, 1.1.1) e algarismos romanos;
  - marcadores (•, -) e frases separadas por ponto ou ponto e vírgula.
- **O que o app ignora ou corrige:**
  - cabeçalhos de grupo, como "CONHECIMENTOS BÁSICOS";
  - quebras de linha e palavras hifenizadas do PDF;
  - números que não são numeração (Lei nº 8.112/1990, art. 5).
- Na prévia dá para **renomear** e **desmarcar** matérias antes de importar.
- Matérias que já existem são reaproveitadas, com a mesma cor e o mesmo progresso. Tópicos com o mesmo nome não são duplicados, então dá para colar de novo sem problema.

## Sincronização (Turso)

Toque no ícone de **nuvem** ao lado do logo e siga os passos. Você só configura uma vez em cada aparelho:

1. Crie uma conta grátis em turso.tech.
2. Crie um banco de dados, por exemplo `edital`.
3. Copie a URL, algo como `libsql://edital-seunome.turso.io`.
4. Gere um token com leitura e escrita, sem expiração.
5. Cole a URL e o token no app. No outro aparelho, use os mesmos.

- **Automática**: sincroniza ao abrir o app, ao voltar para ele, alguns segundos depois de cada alteração e a cada 5 minutos. Offline, as alterações ficam guardadas e vão depois.
- **Primeira conexão**: se a nuvem e o aparelho já têm dados, você escolhe **Juntar** ou **Usar só os da nuvem**. A segunda opção apaga os dados do aparelho; é boa para o segundo aparelho, se ele só tiver o exemplo.
- **Conflitos**: vale a alteração mais recente. Matérias com o mesmo nome criadas nos dois aparelhos viram uma só, com os tópicos e sessões dos dois.
- **O que sincroniza**: concursos, edital, progresso, ciclo, sessões, revisões e flashcards.
- **O que não sincroniza**: fotos e PDFs anexados ficam no aparelho onde foram adicionados. Lembretes e pomodoro são configurados em cada aparelho.

Como funciona: gatilhos do SQLite anotam cada mudança local, inclusive exclusões, em `sync_pendentes`. O app envia essas linhas para uma tabela genérica `registros` no Turso, pela API HTTP (Hrana, `/v2/pipeline`). Cada gravação recebe uma `versao` crescente, e cada aparelho baixa só o que veio depois da última versão que já viu. Veja `lib/data/sync/`.

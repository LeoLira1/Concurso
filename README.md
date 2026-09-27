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
- **Tópicos por edital**: cada concurso mostra só os tópicos do edital dele. O tópico continua um só, com um progresso só, e sabe em quais concursos está:
  - Com um concurso em foco, todas as telas mostram só os tópicos dele: matéria, sidebar, grade, mapa mental, ciclo, revisões, flashcards do dia e estatísticas. Em "Tudo junto", aparece a união.
  - **Na tela do tópico**, as pílulas em "No edital de" mostram os concursos. Toque numa pílula para pôr ou tirar o tópico daquele edital. Os subtópicos seguem o tópico pai.
  - Tópicos criados na tela da matéria entram no edital do concurso em foco. Em "Tudo junto", entram em todos os concursos que têm a matéria.
  - **Excluir um concurso** tira só os vínculos dele. Um tópico que também está em outro edital continua lá, com todo o progresso.
  - **Sem edital**: tópicos que ficam sem nenhum concurso aparecem no fim da tela da matéria, no modo "Tudo junto", com um botão "Apagar todos".
  - Na atualização, cada tópico que já existia entrou no edital de todos os concursos que têm a matéria dele, para ninguém perder nada. A limpeza é feita na tela do tópico.
  - Os vínculos sincronizam com o Turso como o resto, inclusive quando são tirados.
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
  - Para cadastrar muitos de uma vez, veja **Colar flashcards** (etapa 9).
- Na lista de tópicos, ícones mostram quantos anexos e cartões cada tópico tem.

## Etapa 7: mapa mental

Menu lateral → "Mapa mental", ou o botão **Mapa mental** no alto da tela de cada matéria (abre com ela no centro). O mapa segue o mesmo escopo da tela inicial: concurso em foco ou tudo junto.

- **Gerado sozinho a partir do edital**: no centro fica o concurso (ou "Todos"). Em volta ficam as matérias, e cada matéria é o centro de um "balão": os tópicos dela a rodeiam no círculo inteiro, e os subtópicos ficam para fora do tópico, na mesma direção. Você não desenha nada.
- **Organizado**: nenhum nó fica em cima de outro, e nenhuma linha passa por cima de um nó que não seja o dela. As linhas ficam por baixo dos nós. Quando os tópicos não cabem numa volta, eles se alternam entre dois ou mais anéis.
- **Filtro** no alto: "Edital inteiro" ou uma matéria só, que vai para o centro.
- **Mapa de calor do estudo:**
  - não visto: cinza claro;
  - visto em parte (tópico com subtópicos): cor da matéria bem clara;
  - visto: preenchido com a cor da matéria;
  - revisão atrasada: borda vermelha;
  - acerto abaixo de 60% (com pelo menos 10 questões): borda laranja;
  - matéria: barra com a % de tópicos vistos.
  - A **legenda** começa recolhida (só o botão "Legenda") e abre com um toque. O app lembra se ela ficou aberta ou fechada, neste aparelho.
- **Gestos:**
  - pinça para zoom e um dedo para arrastar;
  - botões + e −, **Centralizar** e **Ajustar à tela**;
  - tocar numa matéria, tópico ou subtópico abre o menu rápido (etapa 11), com recolher/expandir e abrir o tópico. O "+30" no canto mostra quantos tópicos estão escondidos;
  - segurar o dedo num nó mostra o nome completo e um resumo: horas estudadas, % de acerto, próxima revisão e nº de flashcards.
- **Nada de tabela nova:** o mapa só lê o que já existe. As matérias recolhidas e a legenda aberta/fechada ficam nas preferências do aparelho, fora do sync do Turso.

Como funciona: `lib/logic/mapa_mental.dart` monta a árvore e calcula o layout em balões. Em volta de cada matéria, o ângulo de cada tópico é proporcional ao número de subtópicos do ramo, no círculo inteiro. Fica só um vão na direção do centro, por onde chega a linha da matéria. O raio de cada anel cresce até as caixas vizinhas não se tocarem e até sobrar espaço para as linhas passarem entre elas. Com muitos nós, eles se alternam entre anéis, como tijolos. No fim, o layout confere cada linha contra cada nó; se algo ainda encostar, os anéis daquele nível se afastam até resolver. Os balões das matérias ficam em volta do centro sem se tocar. O desenho é um `CustomPainter` dentro de um `InteractiveViewer`, sem pacote novo. Textos e ligações ficam em cache, e o texto some quando fica pequeno demais para ler. Um edital com 8 matérias × 30 tópicos × 3 subtópicos (969 nós) calcula em poucas dezenas de milissegundos, e os testes conferem que nenhum nó se sobrepõe e nenhuma linha cruza um nó (inclusive numa matéria com 45 tópicos).

## Etapa 8: banco de questões por tópico

Questões avulsas, ligadas ao tópico ou subtópico do edital. Vale a mesma lógica das matérias compartilhadas: uma questão de Português aparece em todos os concursos que têm Português. (As questões de **Provas**, mais abaixo, continuam separadas, com o Treino e o Simulado delas.)

### Colar questões

Na **tela do tópico** (cartão **Questões**) ou no alto da **tela da matéria**, toque em **Colar questões**. O app aceita uma lista em JSON neste formato:

```json
[{"materia":"Língua Portuguesa","topico":"Conjunções","subtopico":"Adversativas","dificuldade":2,"enunciado":"...","alternativas":{"A":"...","B":"...","C":"...","D":"...","E":"..."},"gabarito":"C","explicacao":"..."}]
```

- `subtopico` e `explicacao` são opcionais. A `dificuldade` vai de 1 a 5 (sem ela, fica 3). Pode ter de 2 a 5 alternativas.
- Na tela do tópico, se o JSON não trouxer `materia` e `topico`, a questão vai para o tópico aberto.
- O JSON pode vir cercado de ```` ``` ```` ou de texto (copiado direto do chat): o app pega só a lista.
- **Prévia antes de importar**, lado a lado no tablet deitado e embaixo do campo em pé. Ela mostra:
  - as questões agrupadas por matéria › tópico › subtópico;
  - selos **Tópico novo no edital**, **Subtópico novo**, **Matéria nova** e **Entra no edital do concurso**;
  - quantas são novas, quantas **já existem** e quantas têm erro, com o motivo ("Questão 3: falta o gabarito", "gabarito "F" não está entre as alternativas"). Só as novas e sem erro entram.
- **Tópico que não existe no edital é criado** (e o subtópico, embaixo dele). Ele entra no edital do concurso em foco; em "Tudo junto", entra em todos os concursos que têm a matéria. Se o tópico já existe, mas só em outro edital, ele ganha o vínculo. Uma matéria nova entra no concurso em foco.
- **Sem duplicar**: o app compara o enunciado ignorando acento, maiúscula, pontuação e espaços. Colar a mesma lista de novo não duplica nada.

### Resolver questões

Botão **Resolver N** no cartão do tópico (inclui os subtópicos) ou na tela da matéria.

- **Uma questão por tela**: toque na alternativa e o app corrige na hora. A certa fica verde, a sua errada fica vermelha, e a **explicação** aparece embaixo. Depois, toque em **Próxima**.
- **Tablet deitado**: o enunciado fica à esquerda e as alternativas e a correção à direita, cada lado com a sua rolagem. **Em pé e no celular**, fica tudo numa coluna.
- Selos na questão: dificuldade, **Nova** e **Voltou: você errou**.
- **Encerrar** sai quando quiser. O que já foi respondido fica registrado.

### Estatísticas

Ao terminar (ou encerrar), o app grava uma sessão de estudo com método **"Questões"** para cada tópico resolvido, com as questões feitas, os acertos e o tempo gasto. Você não precisa preencher nada.

- Isso entra na **% de acerto por matéria** (Estatísticas), na % do tópico, na folha do dia e na grade do mês.
- Se a matéria resolvida é a etapa atual do ciclo, o ciclo avança.
- Cada questão conta **uma vez por sessão**, pela primeira resposta. Refazer a errada na mesma sessão serve para fixar, mas não infla a %.
- O resumo final mostra "X de Y certas (%)" e a lista das erradas, com **Refazer as erradas**.

### Errou, volta mais vezes (Leitner)

É a mesma lógica dos flashcards:

- **acertou**: a questão sobe uma caixa e volta em 1, 3, 7, 14 e 30 dias;
- **errou**: volta para a caixa 0. Reaparece no fim da fila da mesma sessão e continua valendo para hoje.

A fila de cada dia começa pelas vencidas (as de caixa mais baixa, ou seja, as que você mais erra). Depois vêm as novas, da mais fácil para a mais difícil. Se não há nada para hoje, o app oferece **Praticar todas**.

### Gabarito suspeito

- Na questão, o botão com a bandeira (**Gabarito suspeito**) marca a questão para revisar depois. Toque de novo para desmarcar.
- No cartão do tópico e na matéria aparece **"N gabaritos suspeitos"** em laranja. Ele abre a lista já filtrada.
- Na lista (também em **Ver N**), cada questão mostra o gabarito em verde, a explicação, quantas vezes você acertou e errou e quando ela volta. Ali você pode tocar em **Gabarito está certo**, **Trocar gabarito** (que já tira a marca) ou excluir a questão.

### Dados e sync

A tabela nova é `questoes_topico`: tópico, enunciado normalizado (`chave`), dificuldade, alternativas, gabarito, explicação, caixa, próxima revisão, acertos, erros e `suspeito`. Ela entra no sync do Turso com gatilhos em `sync_pendentes`, inclusive nas exclusões. Excluir o tópico apaga as questões dele. As sessões criadas pelo "Resolver" têm `origem = 'questoes_topico'`. Veja `lib/logic/questoes_topico.dart` (leitura do JSON e fila) e `lib/data/questoes_topico_db.dart` (importação, Leitner e sessão). Os testes estão em `test/questoes_topico_test.dart` e `test/questoes_topico_widget_test.dart`; o de tela roda com o tablet deitado e em pé.

## Etapa 9: colar flashcards

Funciona como o **Colar questões** da etapa 8: mesmo campo, mesma prévia e mesma regra de tópicos, só que para flashcards.

### Onde fica

- No cartão **Flashcards** da tela do tópico, ao lado de **Novo cartão**.
- No alto da **tela da matéria**, ao lado de "Flashcards · N para revisar".

### O formato

```json
[{"materia":"Língua Portuguesa","topico":"Concordância nominal e verbal","subtopico":"Verbo haver","frente":"Quando o verbo haver fica no singular?","verso":"Quando significa existir ou indica tempo decorrido. Ex.: Havia muitos candidatos."}]
```

- O `subtopico` é opcional.
- Na tela do tópico, se faltar `materia` ou `topico`, o cartão vai para o tópico aberto. Num subtópico, vai para ele.
- O JSON pode vir cercado de ```` ``` ```` ou de texto copiado do chat. O app pega só a lista.

### A prévia

Tem o mesmo visual do Colar questões: lado a lado no tablet deitado, embaixo do campo em pé.

- Os cartões aparecem agrupados por matéria › tópico › subtópico, com a frente e o começo do verso.
- Selos: **Tópico novo no edital**, **Subtópico novo**, **Matéria nova** e **Entra no edital do concurso**.
- No alto, a contagem de novos, de **já existentes** e de **com erro**. Cada erro diz o motivo, por exemplo: "Cartão 3: falta o verso".
- Só os cartões novos e sem erro entram.

### Regras

- **Tópico que não existe é criado**, como no Colar questões. Ele entra no edital do concurso em foco; em "Tudo junto", em todos os concursos que têm a matéria. Um tópico que já existe só em outro edital ganha o vínculo. Uma matéria nova entra no concurso em foco.
- **Sem duplicar**: o app compara a frente ignorando acento, maiúscula, pontuação e espaços. A comparação vale contra todos os flashcards, inclusive os digitados à mão. Colar a mesma lista de novo não duplica nada.
- **Leitner**: os cartões importados entram na caixa 0, com revisão para hoje, no fim da lista do tópico. Já aparecem em "Revisar" e no card de flashcards do dia.
- **Sync**: são flashcards comuns (tabela `flashcards`), então sincronizam com o Turso como os outros. Não há tabela nova.

### Por dentro

A leitura e a importação são as mesmas das questões:

- `lib/logic/colagem.dart` recorta o JSON, lê matéria › tópico › subtópico, aplica o tópico aberto e marca os repetidos;
- `lib/data/colagem_db.dart` monta a prévia do destino e acha ou cria a matéria, o tópico e o subtópico;
- `lib/screens/colar_screen.dart` é a tela genérica com a prévia.

Cada tipo só descreve o que muda: `lib/logic/flashcards_colados.dart` + `lib/data/flashcards_colagem_db.dart` + `lib/screens/colar_flashcards_screen.dart`, e o equivalente para as questões. Os testes estão em `test/flashcards_colagem_test.dart` e `test/flashcards_colagem_widget_test.dart`; o de tela roda com o tablet deitado e em pé.

## Etapa 10: pedir mais questões

O botão **Pedir mais questões** monta um pedido em texto, pronto para colar no chat do Claude. O Claude devolve questões novas no formato do **Colar questões** (etapa 8) e, se você pedir, flashcards no formato do **Colar flashcards** (etapa 9). Não usa API: o app só monta o texto e copia.

### Onde fica

- No cartão **Questões** da tela do tópico, ao lado de "Colar questões". Num subtópico, o pedido é do tópico de cima, e os itens vão para o subtópico aberto.
- No alto da **tela da matéria**. Aí o pedido é para a matéria inteira.

### Antes de copiar

Uma tela curta com as opções:

- **Quantidade**: 10, 20 ou 30.
- **O que pedir**: questões, flashcards ou os dois. Com os dois, o Claude responde em dois blocos: um para o Colar questões e outro para o Colar flashcards.
- **Foco**: "Equilibrado" ou "Reforçar meus erros".
- O **texto do pedido**, que dá para editar. Mudar uma opção refaz o texto.
- **Copiar** e **Compartilhar**. O Compartilhar abre a folha de compartilhamento do Android, para mandar direto para o app do Claude.

### O que vai no texto (nesta ordem)

1. **Regras**: gerar N questões inéditas com 5 alternativas, gabarito, explicação curta e dificuldade de 1 a 5 bem distribuída. O Claude deve responder só com a lista JSON, num bloco de código, no formato exato da etapa 8 (e da etapa 9 para flashcards). O exemplo do formato já vem com os nomes de verdade. O Claude deve usar os nomes de matéria, tópico e subtópico **exatamente** como escritos, sem inventar tópicos, e não repetir o conceito das questões que já existem, mesmo reescritas.
2. **Contexto**: o concurso em foco e a banca.
3. **Nomes exatos**: matéria, tópico e subtópicos existentes.
4. **Situação do tópico**: total de questões, % de acerto e quantas estão marcadas como gabarito suspeito.
5. **Já existem**: as questões do tópico, cada uma com o enunciado resumido em até 120 caracteres. São no máximo 60, as mais recentes primeiro. Pedindo flashcards, as frentes dos cartões entram também.
6. **Onde eu mais erro**: até 10 questões com mais erros que acertos, com o enunciado completo e a resposta certa. O pedido é de questões novas que cobram o mesmo conceito de outro jeito. No foco "Reforçar meus erros", metade do que você pedir vai para esses conceitos.

### Pedido da matéria inteira

- O pedido lista **todos os tópicos do edital** do concurso em foco (com os subtópicos), cada um com o número de questões e a % de acerto.
- Ele pede para distribuir as questões priorizando os tópicos com **menos questões** e os de **menor acerto**.
- A lista "Já existem" vai só com 15 questões por tópico, para o texto não ficar gigante.

### Por dentro

- `lib/logic/pedido_questoes.dart` monta o texto. É lógica pura, sem banco.
- `lib/data/pedido_db.dart` junta o concurso, os nomes e as questões e flashcards que já existem.
- `lib/screens/pedir_questoes_screen.dart` é a tela. O compartilhamento usa o pacote `share_plus`.
- Não há tabela nova.
- Os testes estão em `test/pedido_questoes_test.dart`: nomes exatos, limites de 60/15 itens e de 120 caracteres, a seção de erros, os dados do banco e a tela.

## Etapa 11: mapa mental interativo

Melhorias no mapa mental da etapa 7. O layout continua o mesmo: nenhum nó fica em cima de outro e nenhuma linha cruza um nó.

### Menu rápido

- **Tocar num tópico ou subtópico** abre um menu embaixo da tela com:
  - **Estudar este tópico**: abre o cronômetro;
  - **Resolver questões**: mostra quantas são para hoje e o total. Sem nenhuma para hoje, pratica todas;
  - **Flashcards**: mostra quantos estão para revisar;
  - **Pedir mais questões** (etapa 10);
  - **Abrir tópico**: é o que o toque fazia antes.
- **Tocar numa matéria** abre as mesmas opções no nível da matéria: estudar, resolver, flashcards, pedir mais questões (para a matéria inteira) e **Abrir matéria**. Nesse menu também ficam o **Recolher/Expandir tópicos** (que antes era o toque na matéria) e **Ver só esta matéria**.
- Segurar o dedo continua mostrando o resumo do nó.

### Indicador de questões

- Cada tópico mostra no canto um **número pequeno** com o total de questões do banco (etapa 8). No tópico, o número soma as questões dos subtópicos.
- Tópico **sem nenhuma questão** fica com **contorno pontilhado**.
- As duas coisas estão na legenda recolhível.
- O número fica dentro da caixa do nó, então o layout não muda.

### Foco agora

O botão **Foco agora** fica no alto do mapa. No celular, só o ícone aparece.

- Ele destaca **no máximo 3 tópicos** do concurso em foco, nesta ordem:
  1. revisão atrasada (a mais antiga primeiro);
  2. acerto abaixo de 60% com 10+ questões (o menor primeiro);
  3. nunca visto (na ordem do edital).
- Acerto baixo e nunca visto contam só as pontas (o subtópico, ou o tópico sem subtópicos), para não repetir o pai e o filho.
- O resto do mapa fica **esmaecido**. Os destacados ganham um anel preto, e o caminho deles até a matéria continua visível.
- O mapa **centraliza e dá zoom no primeiro**. Se ele estiver numa matéria recolhida, ela abre enquanto o foco durar, sem mudar a preferência salva.
- Embaixo aparece o **motivo** de cada um: "revisão atrasada há 3 dias", "acerto 45%" ou "nunca visto". Tocar num item leva o mapa até ele.
- Tocar de novo no botão (ou no ✕) volta ao normal.
- No "Tudo junto", o foco considera só os tópicos do concurso em foco.

### Por dentro

- `escolherFoco` e `TopicoFoco` estão em `lib/logic/mapa_mental.dart`. É lógica pura: recebe a árvore e devolve os tópicos com o motivo.
- `InfoTopico.questoes` guarda o total do banco. Ele vem de `watchQuestoesPorTopico` (`lib/data/questoes_topico_db.dart`).
- O desenho do número, do pontilhado e do véu do foco está em `lib/widgets/mapa_painter.dart`.
- Não há tabela nova.
- Os testes estão em `test/mapa_foco_test.dart`: a escolha do Foco agora (prioridade, limite de 3, pontas, concurso em foco, textos), o indicador (soma, pontilhado, layout igual, sem sobreposição) e a tela (foco, zoom, menu, legenda).
- Os dois testes de `test/mapa_mental_widget_test.dart` que tocavam na matéria e no tópico agora passam pelo menu.

## Etapa 12: mapa do conteúdo por tópico

Um mapa em árvore do conteúdo de cada tópico ou subtópico: conceitos, artigos, exemplos, pegadinhas e dicas. Você pede o mapa ao Claude, cola no app e estuda com o **modo treino**. Ele usa o mesmo layout em balões do mapa mental e a mesma lógica de colar e prévia do Colar questões.

### Onde fica

- Na **tela do tópico** (e do subtópico) há o cartão **Mapa do conteúdo**, com **Colar mapa**, **Abrir mapa** e excluir. O cartão mostra quantos nós há de cada tipo.
- No alto da **tela da matéria** há **Colar mapa**. Por ali, o mapa vai para o tópico que está no JSON.
- Na **lista de tópicos** da matéria, um ícone de árvore mostra quais já têm mapa.

### O formato

```json
{"formato":"edital-mapa-v1","materia":"Crimes contra a Administração Pública","topico":"Peculato (arts. 312 e 313)","subtopico":"","titulo":"Peculato","nos":[{"texto":"Peculato-apropriação","detalhe":"Funcionário se apropria de bem que tem a posse em razão do cargo.","tipo":"conceito","filhos":[{"texto":"Ex.: guarda fica com celular apreendido","tipo":"exemplo","filhos":[]}]}]}
```

- **tipo**: `conceito` (azul), `artigo` (roxo), `exemplo` (verde), `pegadinha` (vermelho, com borda mais grossa) ou `dica` (laranja). Cada tipo tem um ícone. Sem tipo, vale conceito.
- `detalhe` e `subtopico` são opcionais. `filhos` pode faltar.
- Na tela do tópico, se faltar `materia` ou `topico`, o mapa vai para o tópico aberto.
- O JSON pode vir cercado de ```` ``` ```` ou de texto copiado do chat.
- **Limites**: texto com até **70 caracteres**, até **4 níveis** abaixo do título e até **80 nós**. Quem passa disso aparece como erro na prévia, com o motivo, e não entra. Por exemplo: "Nó 'Concussão…': texto com 95 caracteres (máximo 70)".

### A prévia

- Mostra a **árvore em lista recuada**, com o ícone de cada tipo e o detalhe.
- Mostra o total de nós e a **contagem por tipo**.
- Mostra os **erros** com o motivo.
- Segue a mesma regra de tópicos do Colar questões: o nome tem que ser exato (ignorando acento e maiúscula). Se o tópico não existe, aparece o selo **Tópico novo no edital** e o tópico é criado na importação. Vale o mesmo para matéria e subtópico.
- **Um mapa por tópico/subtópico.** Se o tópico já tem mapa, a prévia avisa **"Vai substituir o mapa atual"**, e o Importar pede confirmação.

### A tela do mapa

- O **título** fica no centro e os nós em balões em volta, sem sobreposição e sem linha cruzando nó.
- Dá para usar pinça, arrastar, os botões + e − e **Ajustar à tela**. No celular, o zoom inicial mantém o texto legível e você arrasta para os lados.
- **Tocar num nó** mostra embaixo o tipo, o texto completo e o detalhe. Sem nada selecionado, aparece a legenda dos tipos.
- **Modo treino** (recordação ativa):
  - os nós a partir do 2º nível ficam cobertos, em cinza, com "?";
  - você tenta lembrar e toca para revelar um por um. A barra no alto mostra quantos faltam;
  - **Revelar tudo** mostra todos e **Cobrir de novo** cobre de novo;
  - ao ligar o treino, o mapa se reenquadra abaixo da barra.
- No menu **⋮** ficam **Colar novo mapa** e **Excluir mapa**, com confirmação.

### Pedir mais (etapa 10)

- No pedido de um tópico, **O que pedir** ganha a opção **Mapa do conteúdo**. Ela não aparece no pedido da matéria inteira, porque o mapa é de um tópico só. Com essa opção, quantidade e foco saem da tela.
- O texto do pedido:
  - explica o formato `edital-mapa-v1`, com um exemplo que já traz os nomes exatos da matéria, do tópico e do subtópico;
  - traz as regras dos tipos e dos limites (70 caracteres, 4 níveis, 80 nós), o contexto (concurso e banca) e os nomes exatos;
  - traz as questões em que você mais erra, pedindo que virem nós de pegadinha ou dica.
- **Se o tópico já tem mapa**, o pedido lista os nós atuais (recuados, com o tipo). Ele pede para **ampliar sem repetir**: o Claude devolve o mapa inteiro, com os nós atuais e os novos, porque o app substitui o mapa ao colar.

### Dados e sync

- A tabela nova é `mapas_conteudo`: tópico, título e a árvore dos nós em JSON. A versão do banco passou para a 8.
- O **id da linha é o id do tópico**. Assim, dois aparelhos que colam um mapa no mesmo tópico gravam a mesma linha, e vale o mais recente.
- A tabela entra no sync do Turso, com gatilhos em `sync_pendentes`, inclusive nas exclusões.
- Excluir o tópico apaga o mapa dele.
- A gravação não usa UPSERT. Dentro de um `ON CONFLICT DO UPDATE`, o SQLite troca o `INSERT OR REPLACE` dos gatilhos do sync por ABORT, e a substituição do mapa falhava.

### Por dentro

- `lib/logic/mapa_conteudo.dart`: leitura e validação do JSON (sobre `lerColagem`), limites, contagem por tipo e a árvore para o `calcularLayout` do mapa mental.
- `lib/data/mapa_conteudo_db.dart`: gravar, substituir e excluir, e a importação sobre `importarColagem`, com a mesma regra de tópicos.
- `lib/screens/colar_mapa_screen.dart`: a prévia. Reaproveita o campo de entrada e os selos de destino de `colar_screen.dart`.
- `lib/screens/mapa_conteudo_screen.dart`: a tela, o modo treino e o desenho.
- Os testes estão em `test/mapa_conteudo_test.dart`:
  - leitura e validação;
  - limites de 70 caracteres, 4 níveis e 80 nós;
  - substituição;
  - vínculo ao tópico (tópico novo, subtópico, nome sem acento);
  - sync e exclusão;
  - migração v7→v8;
  - texto do pedido (mapa novo e ampliação);
  - layout de 80 nós sem sobreposição e sem cruzamentos;
  - telas de colar (deitado e em pé) e do mapa (detalhe e modo treino).
- As capturas são a 47 (mapa, treino e celular) e a 48 (prévia).

## Etapa 13: desempenho por tópico

Um painel com o acerto de cada tópico do edital, a tendência e o que revisar primeiro.

### Onde fica

- No **menu lateral**, em **Desempenho por tópico**.
- Em **Estatísticas**, no cartão "% de acerto por matéria", pelo botão **Por tópico**.
- Segue o escopo da tela inicial (concurso em foco ou Tudo junto), com filtro por matéria no alto.

### O painel

- **Revise primeiro**: até 5 tópicos, do mais urgente ao menos, cada um com o motivo:
  - **caiu**: o acerto dos últimos 30 dias ficou 10 pontos ou mais abaixo dos 30 dias anteriores ("caiu 15 pontos em 30 dias");
  - **acerto baixo**: abaixo de 60% com 10 questões ou mais ("acerto 45% em 20 questões");
  - **parado**: sem estudar há 3 semanas ou mais ("parado há 25 dias").
  
  A ordem é em camadas: primeiro o motivo mais grave (caiu, depois acerto baixo, depois parado), então quem caiu nunca perde a vaga para quem só tem acerto baixo. Depois vem quem tem mais motivos, e por último a gravidade (tamanho da queda, quão baixo está o acerto, há quanto tempo está parado). Tópico nunca estudado fica de fora; ele já aparece no "Foco agora" do mapa mental.
- **Todos os tópicos**: para cada tópico, a % de acerto, a tendência, o número de questões e o último estudo. No tablet aparece também uma minilinha com o acerto das últimas 8 semanas.
- A lista pode ser ordenada por **ordem do edital**, **pior acerto**, **maior queda** ou **mais questões**.
- A tendência sempre vem com ícone e texto (subiu, caiu, estável, sem dados), nunca só com cor.
- A tendência só é calculada quando as duas janelas de 30 dias têm pelo menos 5 questões cada. O limite de 10 pontos usa a diferença exata: 9,5 pontos é "estável", mesmo aparecendo arredondado como 10.

### O detalhe do tópico

Toque num tópico, ou numa sugestão, para ver:

- o acerto total, o dos últimos 30 dias e o dos 30 dias anteriores;
- os botões **Resolver questões**, **Estudar** (cronômetro) e **Abrir tópico**;
- o **acerto por semana** das últimas 12 semanas, em colunas, com a linha de 60% tracejada. Toque ou arraste sobre as colunas para ver a semana e o placar ("Semana de 20/09: 42% (5 de 12)"). O gráfico começa na última semana que teve questões. Há também uma visão em **tabela**;
- os **subtópicos**, cada um com o seu acerto e a sua tendência.

### De onde vêm os números

- Das sessões de estudo, as mesmas das Estatísticas: o registro manual, o "Resolver questões" do banco (etapa 8) e as respostas das provas (Treino e Simulado), sem contar nada duas vezes.
- Os subtópicos somam no tópico de cima.
- Uma sessão só com tempo, sem questões, conta como "último estudo".
- Não há tabela nova e nada muda no sync.

### Por dentro

- `lib/logic/desempenho.dart`: as contas (janelas, tendência, semanas, sugestões e ordenação). É lógica pura.
- `lib/screens/desempenho_screen.dart`: o painel, o detalhe, a minilinha e o gráfico semanal.
- Os testes estão em `test/desempenho_test.dart`:
  - janelas de 30 dias e seus limites;
  - subiu, caiu, estável e sem dados;
  - soma dos subtópicos;
  - último estudo;
  - as 12 semanas;
  - a ordem e os motivos do "Revise primeiro";
  - a ordenação;
  - as telas no tablet deitado e no celular (filtro, detalhe e tabela);
  - o toque nas colunas.
- As capturas são a 49 (painel no tablet e no celular) e a 50 (detalhe).

## Colar o conteúdo programático

No edital do concurso, toque em **"Colar edital"**. Com o edital vazio, também aparece um card com esse atalho.

- Cole o texto copiado do PDF, pelo botão **Colar** ou segurando o dedo no campo. A separação aparece na hora: lado a lado no tablet deitado, ou na aba **Prévia** em pé.
- **Modo estruturado** (o jeito mais confiável): escreva cada matéria em MAIÚSCULAS terminando com ":", numa linha só ("LÍNGUA PORTUGUESA:"). Embaixo, um tópico por linha; linhas que começam com "-" são subtópicos do tópico de cima. Linhas em branco só separam as matérias. Com pelo menos uma linha assim, o app entra nesse modo e avisa na prévia:
  - só essas linhas viram matéria, e nenhuma é ignorada;
  - cada linha comum vira um tópico inteiro, sem cortar em ponto, vírgula ou travessão;
  - "(art. 5º, caput)", "Lei 13.022/2014" e "§ 8º" ficam como estão.
- Sem linhas assim (texto bruto copiado do PDF), valem as regras abaixo.
- **O que o app reconhece:**
  - matérias em MAIÚSCULAS ("LÍNGUA PORTUGUESA:"), no formato "Nome: conteúdo" ou numa linha só com o nome;
  - tópicos numerados (1, 1.1, 1.1.1) e algarismos romanos;
  - marcadores (•, -) e frases separadas por ponto ou ponto e vírgula.
- **O que o app ignora ou corrige:**
  - cabeçalhos de grupo, como "CONHECIMENTOS BÁSICOS";
  - quebras de linha e palavras hifenizadas do PDF;
  - números que não são numeração (Lei nº 8.112/1990, art. 5).
- Na prévia dá para **renomear** e **desmarcar** matérias antes de importar.
- Matérias que já existem são reaproveitadas, com a mesma cor e o mesmo progresso. Tópicos com o mesmo nome (ignorando acento e maiúscula) não são duplicados, então dá para colar de novo sem problema.
- Os tópicos colados entram no edital do concurso de destino. Se o tópico já existe na matéria (por exemplo, veio de outro concurso), ele só ganha o vínculo, mantendo progresso, revisões e flashcards.

## Provas (banco de questões)

Menu lateral → **Provas**. Lá ficam três telas: **Colar prova**, **Resolver** e **Estatísticas das provas**, e embaixo a lista **Minhas provas**. Na tela inicial, o botão **⚡ (Treino rápido: 10 questões)** abre direto 10 questões do concurso em foco: primeiro as que você nunca fez, depois as que errou.

### Como transformar um PDF de prova em questões (fluxo com o Sonnet)

1. Abra o Claude (Sonnet) e envie o PDF da prova e o do gabarito.
2. Peça: *"Extraia esta prova no formato edital-prova-v1"*, colando junto a descrição do formato (abaixo) e a lista de matérias.
3. Se a prova for grande, o Sonnet pode entregar em partes. Tudo bem: copie cada parte.
4. No app: **Provas → Colar prova → Colar**. Para a continuação, toque em **Colar** de novo (ou cole numa outra hora: o app completa a mesma prova).
5. Toque em **Conferir**. A prévia mostra o que o app entendeu. Corrija o que precisar e toque em **Importar**.

### O formato "edital-prova-v1"

```json
{
  "formato": "edital-prova-v1",
  "prova": {
    "banca": "…", "orgao": "…", "cargo": "…", "ano": 2019,
    "gabarito": "definitivo",          // ou "preliminar"
    "num_alternativas": 4,             // 4 ou 5
    "total_questoes": 40,
    "gabarito_lido": { "1": "C", "2": "A", "7": "X" },   // TODAS as questões
    "descartadas": [ { "numero": 11, "motivo": "…" } ]
  },
  "textos": [ { "id": "T1", "titulo": "…", "conteudo": "…" } ],
  "questoes": [
    {
      "numero": 1, "texto_id": "T1",      // ou null
      "materia": "Língua Portuguesa", "topico": "Interpretação de texto",
      "enunciado": "…",
      "alternativas": { "A": "…", "B": "…", "C": "…", "D": "…" },
      "resposta": "C",                    // "X" só se o status tiver "anulada"
      "status": [],                       // anulada, imagem, revisar, desatualizada
      "obs": "…"
    }
  ]
}
```

Matérias possíveis: Língua Portuguesa; Matemática e Raciocínio Lógico; Noções de Informática; Direitos e Deveres Individuais e Coletivos; Cidadania e Segurança Pública; Ética no Serviço Público; Legislação de Trânsito; Crimes contra a Administração Pública; Leis Penais Especiais; Direito Constitucional; Direito Administrativo; Direito Penal; Noções de Segurança e Vigilância.

### O que o app confere antes de importar

Mensagens em português simples, dizendo qual questão tem problema:

- JSON válido (em erro de digitação, diz a linha) e `"formato": "edital-prova-v1"`;
- cada questão com todas as alternativas (4 ou 5, conforme a prova), resposta entre as letras válidas e "X" só em anulada;
- `texto_id` que exista em `textos` e números sem repetição;
- questões + descartadas = total da prova (se não bater, só avisa: pode faltar uma continuação);
- **resposta × gabarito lido**: se forem diferentes, a questão fica em vermelho ("Resposta A, mas o gabarito lido diz D") e o botão Importar só libera depois que você escolher qual vale.

### A prévia

- Cabeçalho (banca, órgão, cargo, ano, preliminar/definitivo), contagem por matéria (com "nova" nas que ainda não existem), por status e a lista de descartadas com o motivo.
- Cada questão mostra o tópico, os status e o "obs". **Toque numa questão** para mudar matéria, tópico, status e resposta.
- **Tópicos**: o app procura o tópico mais parecido na matéria (ignora acento, maiúscula e palavras como "de", "lei"; compara palavras-chave). Se a semelhança é boa, liga sozinho: "Estatuto das Guardas – princípios mínimos de atuação" cai em "Estatuto Geral das Guardas Municipais (Lei 13.022/2014)". Se não, fica **sem tópico** e a edição mostra sugestões, "Criar tópico novo" e "Deixar sem tópico". O texto original do tópico é sempre guardado.
- Matéria nova criada pela importação **não entra** em nenhum concurso (adicione no edital, se quiser).

### Sem duplicar

- A mesma prova é banca + órgão + cargo + ano; a questão é essa prova + o número. Colar de novo não duplica nada.
- Se a prova salva tem gabarito **preliminar** e você cola o **definitivo**, o app atualiza respostas e status e mostra o que mudou ("Questão 7: resposta B → X, anulada").

### Resolver

- **Treino**: uma questão por vez, com a correção na hora. **Simulado**: você escolhe quantas questões e o tempo (sugestão: 4 minutos por questão), com cronômetro e a correção só no final.
- Filtros: concurso (ou "Tudo junto"), matéria, tópico, banca, ano, "só as que errei" e "só as nunca feitas".
- Ficam **fora do sorteio** por padrão: anuladas, desatualizadas e "revisar" ainda não conferidas. Cada uma tem uma chave para incluir.
- Com um concurso em foco, entra a questão cujo tópico está no edital dele; questão "sem tópico" entra se a matéria dela faz parte do concurso.
- Na questão: botão **Ler o texto** (abre o texto-base por cima, sem sair); **"Conferi, está certa"** nas marcadas "revisar"; aviso de **imagem** com a descrição e botões para anexar um print (câmera ou galeria), que aparece junto do enunciado; selo laranja **"Lei mudou"** com a explicação; selo **"Prova de 2019: confira a lei atual"** em legislação com mais de 4 anos.
- Depois de responder, aparece o "obs". Ao errar, o app pergunta o motivo: **Não sabia**, **Desatenção** ou **Pegadinha** (dá para pular).

### Estatísticas

- Cada resposta guarda a questão, a letra marcada, se acertou, o tempo, o motivo do erro, a data e o modo. **Anuladas nunca contam** como acerto nem erro.
- As respostas entram na % de acerto do **tópico** e da **matéria** usada pelo mapa mental (borda laranja abaixo de 60% com 10+ questões), na tela do tópico e nas estatísticas gerais.
- Cada Treino ou Simulado vira uma **sessão de estudo com método "Questões"** (uma por matéria, com o tempo gasto), aparece na grade do mês e faz o ciclo avançar se a matéria da vez foi estudada.
- **Estatísticas das provas**: % por matéria, tópico e banca; evolução semanal (12 semanas); tempo médio por questão; erros por motivo; e o **Caderno de erros** (questões erradas na última tentativa, com "Refazer" e "Refazer todas").

### Minhas provas

Toque numa prova para ver detalhes (matérias, descartadas, questões). A lixeira exclui a prova inteira, com confirmação: questões, respostas e prints saem, e as respostas saem das estatísticas (o tempo estudado continua).

### Dados e sync

Tabelas novas: `provas`, `textos_base`, `questoes_prova` (a tabela `questoes` já existia para o registro manual de questões) e `respostas`, todas no sync do Turso com gatilhos em `sync_pendentes`, inclusive exclusões. Os prints (`prints_questao`) ficam só no aparelho, como os resumos. As sessões ganharam a coluna `origem` (`provas` nas criadas por Treino/Simulado). Veja `lib/logic/provas.dart` (leitura, validação, semelhança de tópicos, sorteio) e `lib/data/provas_db.dart` (banco e estatísticas). Testes: `test/provas_test.dart` e `test/provas_widget_test.dart`, com a prova real de Araucária-PR 2019 em `test/dados/`.

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
- **O que sincroniza**: concursos, edital (inclusive em quais concursos cada tópico está), progresso, ciclo, sessões, revisões, flashcards, provas, questões e respostas, o banco de questões por tópico (com caixas do Leitner e gabaritos suspeitos), os flashcards colados e os mapas do conteúdo.
- **O que não sincroniza**: fotos e PDFs anexados (e os prints das questões) ficam no aparelho onde foram adicionados. Lembretes e pomodoro são configurados em cada aparelho.

Como funciona: gatilhos do SQLite anotam cada mudança local, inclusive exclusões, em `sync_pendentes`. O app envia essas linhas para uma tabela genérica `registros` no Turso, pela API HTTP (Hrana, `/v2/pipeline`). Cada gravação recebe uma `versao` crescente, e cada aparelho baixa só o que veio depois da última versão que já viu. Veja `lib/data/sync/`.

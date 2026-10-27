# PRODUCT_SPEC.md

## 1. Visão do produto

**Nome provisório:** Trilha de Aprovação  
**Tipo:** aplicativo pessoal de organização e acompanhamento de estudos para concursos públicos.  
**Plataforma inicial:** Windows desktop.  
**Plataforma planejada:** Android, reaproveitando a maior parte do código e das regras de negócio.

O aplicativo ajuda a pessoa candidata a planejar o estudo a partir do edital, executar sessões, acompanhar questões e identificar o próximo melhor passo. Não deve ser somente um calendário ou cronômetro: deve ligar planejamento, execução e evidências de aprendizagem.

### Proposta de valor

Ao abrir o aplicativo, a pessoa deve entender rapidamente:

1. O que planejou para hoje.
2. O que já concluiu e quanto tempo líquido estudou.
3. Quais assuntos precisam de atenção, com base em dados visíveis.
4. Qual é a próxima ação sugerida e por que ela foi sugerida.

### Princípios do produto

- **Prático:** registrar uma sessão ou uma questão deve exigir poucos passos.
- **Transparente:** recomendações devem explicar os fatores usados.
- **Honesto com os dados:** tempo estudado não deve ser apresentado como domínio do conteúdo.
- **Offline-first:** as funcionalidades essenciais devem funcionar sem conexão.
- **Sem pressão artificial:** sequências e metas devem motivar sem punir ou envergonhar a pessoa usuária.
- **Portável:** regras de negócio e dados não devem ficar presos a widgets ou a uma plataforma específica.

## 2. Público e problema

### Público-alvo inicial

Uma pessoa que estuda para um ou mais concursos e precisa gerenciar editais, matérias, tópicos, tempo, revisões e resultados de questões em um único lugar.

### Problemas que o produto procura resolver

- Planejamento feito em várias planilhas, cadernos e aplicativos.
- Dificuldade para saber se o estudo planejado realmente foi executado.
- Revisões esquecidas e caderno de erros inconsistente.
- Falta de visibilidade sobre desempenho por matéria e tópico.
- Cronograma que deixa de funcionar quando um dia de estudo é perdido.

## 3. Plataformas e experiência

### Primeira entrega

- Aplicativo Flutter para Windows.
- Interface em português brasileiro.
- Tema escuro padrão; cores de destaque verde-musgo e dourado, com contraste legível.
- Layout desktop com navegação lateral e conteúdo principal responsivo à largura da janela.
- Banco local; o primeiro uso não exige login.

### Preparação para Android

- Usar widgets responsivos e evitar pressupor mouse, hover ou janelas largas.
- Manter navegação, regras de domínio e contratos dos repositórios independentes da plataforma.
- Não implementar sincronização de nuvem na primeira fase.

### Direção visual provisória

- Fundo carvão/grafite, superfícies em tons próximos e bordas discretas.
- Verde-musgo para ações principais e estados positivos; dourado para destaque e prioridade, sem usar cor como único indicador.
- Tipografia clara, hierarquia visual consistente e espaçamento generoso.
- Gráficos com rótulos e valores acessíveis; não depender somente de cores para comunicar resultados.

## 4. Escopo do MVP

O MVP será entregue em etapas pequenas. O primeiro incremento precisa produzir um aplicativo que compile e rode, tenha navegação real e persista dados localmente.

### Fase 1A: fundação funcional

- Projeto Flutter/Dart com alvos Windows e Android habilitados quando o ambiente permitir.
- Tema, navegação principal e estados de carregamento, vazio e erro.
- Banco SQLite local com migração versionada.
- CRUD básico de concursos, matérias e tópicos do edital.
- Registro de sessão de estudo com início, pausa/retomada e conclusão, ou um fluxo manual confiável de registro caso o cronômetro completo fique para o próximo incremento.
- Painel inicial com dados reais calculados do banco, sem valores fictícios hardcoded.
- Testes de lógica e persistência.

### Fase 1B: planejamento diário

- Definir meta de minutos e questões por dia para um concurso.
- Criar itens planejados por data, matéria e tópico.
- Marcar item como concluído, ignorado ou reprogramado.
- Mostrar planejado versus realizado.
- Permitir navegação entre datas e visualização de tarefas pendentes.

### Fase 2: questões e erros

- Registrar tentativa de questão individual, origem, banca, assunto, resultado e tempo gasto.
- Visualizar taxa de acerto por matéria e tópico.
- Caderno de erros com motivo opcional e anotação.
- Filtros e resumo por período.
- Simulados podem ser representados como uma sessão/coleção numa iteração posterior.

### Fase 3: revisões e análise

- Criar revisões e controlar data prevista, data realizada e status.
- Implementar agendamento de revisão simples e explicável; intervalos configuráveis em vez de alegar precisão científica.
- Recomendar tópicos com base em regras transparentes, como baixa taxa de acerto, revisão vencida, peso da matéria e tempo sem contato.
- Importar edital/material somente depois de especificar o fluxo de extração, confirmação humana e tratamento de PDFs.

### Fase 4: sincronização opcional

- Avaliar autenticação, backup e sincronização entre dispositivos.
- Resolver conflitos e migração de dados antes de ativar sincronização.
- A nuvem não pode ser necessária para abrir ou usar os recursos locais.

## 5. Fora do escopo do MVP

- Integração automática com sites de bancas ou plataformas de questões.
- Captura/raspagem de questões protegidas por direitos autorais.
- Geração de respostas oficiais ou garantia de aprovação.
- IA que altere o cronograma sem explicar a mudança.
- Assinaturas, pagamentos, rede social ou ranking público.
- Sincronização online e login obrigatórios.
- Leitura automática integral de PDFs sem revisão e confirmação do usuário.
- Notificações móveis como requisito de lançamento inicial.

## 6. Módulos e requisitos funcionais

### RF-01: concursos

- Cadastrar nome, banca organizadora opcional, data da prova opcional e status ativo/arquivado.
- Permitir mais de um concurso.
- Um concurso arquivado permanece consultável, mas não deve aparecer como opção ativa por padrão.

**Aceite:** um concurso criado permanece no banco após fechar e reabrir o aplicativo.

### RF-02: matérias e edital

- Cada matéria pertence a um concurso.
- Cada matéria pode conter tópicos e subtópicos.
- Tópicos suportam ordenação, dificuldade estimada opcional, tempo estimado e status de estudo.
- Estados iniciais de tópico: `not_started`, `in_progress`, `completed`, `needs_review`.
- A pessoa pode corrigir nomes, ordem e status sem perder as sessões históricas.

**Aceite:** é possível criar, editar, listar e remover logicamente matérias e tópicos; a remoção não deve apagar silenciosamente o histórico de estudo.

### RF-03: sessões de estudo

- Registrar concurso, matéria, tópico opcional, tipo de atividade, início, fim, duração líquida e observações.
- Tipos iniciais: estudo, revisão, questões e simulado.
- Estados iniciais: `running`, `paused`, `completed`, `interrupted` (a persistência pode guardar pausas separadamente se necessário).
- O app não deve perder a sessão ativa silenciosamente ao fechar.
- Duração armazenada em segundos inteiros; formatação em horas/minutos acontece na apresentação.

**Aceite:** sessões concluídas geram totais corretos por data e matéria; sessões interrompidas não são contadas como concluídas sem regra explícita.

### RF-04: metas e plano diário

- Meta diária configurável por concurso: minutos e quantidade de questões.
- Itens de plano guardam data, duração planejada, matéria, tópico opcional, prioridade e status.
- Estados de item: `planned`, `completed`, `skipped`, `carried_over`.
- Reprogramar deve manter registro suficiente para não duplicar o item silenciosamente.

**Aceite:** painel distingue planejado, realizado e restante; ausência de meta deve ser mostrada como “não definida”, não como zero de forma enganosa.

### RF-05: questões

- Guardar tentativas individuais com data, resultado correto/incorreto, tempo opcional, origem/banca opcional, referência opcional, dificuldade opcional e categoria de erro opcional.
- Não armazenar enunciados de terceiros automaticamente. Um campo de referência/anotação basta na primeira versão.
- Permitir marcar um erro para revisão.

**Aceite:** a taxa de acerto é `corretas / tentativas válidas`; se não houver tentativas, mostrar estado sem dados, nunca 0% como se houvesse desempenho medido.

### RF-06: revisões

- Permitir agendar revisão de um tópico ou de uma questão errada.
- Estados: `scheduled`, `completed`, `skipped`, `cancelled`.
- Mostrar revisões vencidas e próximas.

**Aceite:** completar revisão registra data de realização e preserva o histórico necessário para as estatísticas.

### RF-07: notas

- Anotações associadas opcionalmente a concurso, matéria e tópico.
- Salvamento explícito ou automático com indicação clara do estado de gravação.

### RF-08: painel

- Mostrar concurso ativo, plano de hoje, minutos estudados, progresso da meta, sessões recentes, tópicos em atenção e revisões devidas, quando esses dados existirem.
- Mostrar estados vazios úteis para quem está começando.
- Todas as métricas devem vir de consultas reais ao repositório.

### RF-09: dados e configurações

- Os recursos principais devem funcionar offline.
- Datas de calendário para planejamento usam data local (`YYYY-MM-DD`); timestamps de eventos usam ISO 8601 com fuso ou UTC consistente.
- Preparar estrutura para exportação/backup futuro, sem implementar serviço de nuvem no MVP.

## 7. Regras de negócio e métricas

- **Tempo líquido estudado:** soma de `duration_seconds` de sessões concluídas e válidas, agrupada pela data local relevante. Sessões não podem ser contadas duas vezes.
- **Meta de tempo:** minutos realizados divididos pela meta de minutos. Se a meta for nula ou zero, exibir “sem meta definida”.
- **Taxa de acerto:** questões corretas divididas pelo total de tentativas avaliáveis. Sempre mostrar o tamanho da amostra quando possível.
- **Progresso do edital:** não inferir domínio só a partir de um tópico marcado concluído. Mostrar claramente que é progresso autodeclarado, distinto do aproveitamento nas questões.
- **Recomendação inicial:** depois de haver dados suficientes, priorizar revisão vencida e tópicos com amostra de questões baixa ou taxa de acerto menor. Explicar os fatores que influenciaram a recomendação.
- **Sem dados:** usar mensagem como “Registre sua primeira sessão para começar a acompanhar sua evolução”. Não criar dados demonstrativos como se fossem reais.
- **Dados de teste:** podem existir em testes automatizados ou em uma opção explícita de demonstração, nunca misturados à base real sem consentimento.

## 8. Requisitos não funcionais

- **RNF-01 Confiabilidade:** operações de gravação devem ser transacionais quando alterarem entidades relacionadas.
- **RNF-02 Manutenibilidade:** separar interface, domínio, persistência e infraestrutura.
- **RNF-03 Testabilidade:** regras de domínio e cálculos principais devem ser testáveis sem executar a UI.
- **RNF-04 Desempenho:** consultas do painel devem usar agregações SQL ou cálculos eficientes e não carregar todo o histórico sem necessidade.
- **RNF-05 Privacidade:** não enviar dados pessoais ou de estudo para serviços externos no MVP.
- **RNF-06 Migrações:** mudanças de banco devem ser versionadas e testadas do esquema anterior para o novo.
- **RNF-07 Acessibilidade:** controles com rótulos, navegação por teclado no desktop, contraste legível e informação não dependente apenas de cor.
- **RNF-08 Responsividade:** telas utilizáveis em desktop e adaptáveis a mobile, mesmo que a primeira validação seja no Windows.
- **RNF-09 Localização:** textos, datas e durações devem respeitar `pt-BR`; armazenar datas e números em formatos não localizados.
- **RNF-10 Erros:** informar erros em linguagem clara e não descartar dados silenciosamente.

## 9. Navegação inicial

Navegação lateral no desktop:

1. **Visão geral**
2. **Concursos e edital**
3. **Planejamento**
4. **Sessão de estudo**
5. **Questões**
6. **Revisões**
7. **Relatórios**
8. **Configurações**

Na primeira implementação, os itens ainda não desenvolvidos devem aparecer desabilitados ou com uma mensagem honesta de “Em desenvolvimento”. Não simular funcionalidades que não existem.

## 10. Critérios de pronto (Definition of Done)

Uma funcionalidade está pronta quando:

- O comportamento respeita este documento ou a alteração foi registrada neste documento.
- A interface contempla carregamento, sucesso, estado vazio e erro quando aplicável.
- Dados persistem após reiniciar o app.
- Regras de negócio têm testes automatizados relevantes.
- O esquema de banco foi atualizado por migração versionada quando necessário.
- `dart format` não aponta mudanças pendentes.
- `flutter analyze` não apresenta erros novos.
- `flutter test` passa, ou qualquer bloqueio ambiental está descrito precisamente.
- O Codex resume arquivos alterados, decisões e comandos realmente executados. Não afirmar que testes passaram se não foram executados.

## 11. Decisões em aberto para fases futuras

- Nome e identidade visual definitivos.
- Se a primeira versão móvel será Android apenas ou Android e iOS.
- Algoritmo de repetição espaçada e possibilidade de personalizar os intervalos.
- Estratégia e formato de exportação/importação de backup.
- Serviço de sincronização, se desejado.
- Regras para importar editais de PDFs e resolver tópicos duplicados.

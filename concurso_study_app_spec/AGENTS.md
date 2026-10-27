# AGENTS.md

## Missão

Desenvolva o app de estudos para concursos conforme `PRODUCT_SPEC.md` e `DATA_MODEL.md`. Antes de implementar, leia esses documentos e verifique o estado real do repositório. O objetivo é entregar incrementos pequenos, funcionais, testáveis e persistentes, não apenas telas ilustrativas.

## Regras obrigatórias

1. Não invente que uma funcionalidade, comando ou teste foi executado. Informe exatamente o que foi verificado.
2. Não implemente tudo de uma vez. Conclua uma fatia vertical pequena, compile, teste e reporte antes de ampliar o escopo.
3. Não substitua ou apague trabalho existente sem inspecionar o repositório e justificar a mudança.
4. Não inclua credenciais, segredos, tokens, dados pessoais reais ou arquivos locais de banco no Git.
5. Não use dados fictícios no painel de produção. Dados de demonstração devem ser explicitamente opt-in.
6. Não deixe botões principais sem ação. Se uma rota ainda não foi implementada, sinalize isso honestamente.
7. Não amarre regras de negócio a widgets Flutter, nem acesso ao banco diretamente aos widgets de interface.
8. Evite abstrações excessivas. Crie interfaces quando ajudam a testar, trocar infraestrutura ou separar responsabilidades.
9. Para mudanças de banco, crie migração versionada e testes de migração; nunca dependa somente de apagar o banco local.
10. Faça perguntas somente se uma informação ausente bloquear uma decisão irreversível. Caso contrário, adote a menor suposição razoável, documente-a e prossiga.

## Stack e plataformas

- Flutter e Dart estáveis disponíveis no ambiente.
- Windows é o primeiro alvo de validação; manter compatibilidade arquitetural com Android.
- Persistência local SQLite.
- Selecionar dependências nas versões estáveis compatíveis com o Flutter/Dart instalados; não copiar versões antigas sem verificar compatibilidade.
- Isolar a implementação de abertura do banco por plataforma. Verificar a orientação atual dos pacotes usados para suportar Windows e dispositivos móveis.
- Usar `path_provider` ou mecanismo compatível para gravar o banco no diretório de dados de aplicação, nunca no diretório de trabalho atual.
- Não introduzir backend, autenticação ou sincronização remota no MVP.

## Arquitetura recomendada

Organizar por funcionalidade e manter camadas explícitas, adaptando à escala real do app. Exemplo possível:

```text
lib/
  app/
    app.dart
    router.dart
    theme/
  core/
    database/
    errors/
    utils/
    widgets/
  features/
    dashboard/
      data/
      domain/
      presentation/
    contests/
      data/
      domain/
      presentation/
    study_sessions/
      data/
      domain/
      presentation/
    planning/
    questions/
    reviews/
    notes/
  main.dart

test/
  core/
  features/
```

Esta árvore é orientação, não obrigação cega. Se uma funcionalidade ainda não existe, não crie dezenas de arquivos vazios só para preencher pastas.

## Estado e navegação

- Escolha uma única solução de estado compatível com o projeto (preferencialmente Riverpod, se não houver padrão existente) e use-a de forma consistente.
- Use rotas nomeadas ou uma configuração central de navegação.
- Não recrie a conexão ao banco em cada widget. Injete repositórios/serviços pelo mecanismo de dependência escolhido.
- UI apresenta estados de carregamento, vazio, sucesso e erro; lógica não fica escondida em `build()`.

## Persistência e integridade

- Banco SQLite local; habilitar `PRAGMA foreign_keys = ON` em cada conexão quando suportado.
- Criar índices para filtros e ordenações comuns, especialmente contest, subject, topic e datas.
- Usar transações para operações que envolvam múltiplas alterações.
- IDs devem ser estáveis e gerados na camada de domínio/dados (UUID ou estratégia equivalente), não baseados no índice visual da lista.
- Armazenar durações em segundos inteiros. Para sessões com cronômetro, `active_since` representa o início da janela ativa atual; ao pausar/retomar/concluir, acumule cada janela uma só vez e nunca conte períodos pausados.
- Datas de planejamento usam `YYYY-MM-DD` como data de calendário local; timestamps de eventos devem ter política consistente e explicitamente documentada.
- Fazer validação de domínio antes da persistência e usar constraints no banco como segunda linha de defesa.
- Nunca excluir registros históricos por cascata sem conferir as regras definidas no `DATA_MODEL.md`.
- Não guardar informações deriváveis se uma consulta simples e consistente for suficiente. Se um total for armazenado por desempenho, documentar como evitar divergências.

## Design e conteúdo

- Idioma padrão `pt-BR`.
- Tema escuro padrão com superfícies grafite, verde-musgo e dourado de destaque.
- Contraste e legibilidade vêm antes da decoração. Cor não deve ser o único sinal de estado.
- Layout responsivo e componentes reutilizáveis quando isso reduz inconsistências reais.
- Não usar conteúdo de terceiros ou enunciados protegidos como dados de exemplo.
- Formatar datas, percentuais e durações para apresentação; manter os valores armazenados em forma canônica.

## Testes e qualidade

Sempre que aplicável, executar e reportar:

```bash
dart format .
flutter analyze
flutter test
```

- Testar regras de cálculo (minutos, metas, taxa de acerto, agrupamento por data).
- Testar CRUD e integridade de chave estrangeira do banco.
- Testar estado vazio e erros importantes da UI quando a tela for criada.
- Usar banco em memória ou diretório temporário nos testes; nunca apontar testes para os dados pessoais do usuário.
- Se um comando falhar por ferramenta ausente ou configuração do ambiente, registrar a mensagem relevante e não mascarar a falha.

## Fluxo de trabalho por tarefa

1. Leia os documentos pertinentes e inspecione arquivos/estado do Git.
2. Declare uma estratégia curta e um critério de aceite verificável.
3. Implemente a menor fatia vertical necessária.
4. Atualize testes e documentação.
5. Formate e execute análise/testes disponíveis.
6. Revise `git diff` para detectar arquivos gerados, segredos ou mudanças não solicitadas.
7. Responda com: o que mudou, como executar, quais comandos foram executados, resultados reais, limitações e próximo passo sugerido.

## Limites de escopo da primeira tarefa

A primeira tarefa está descrita em `CODEX_INITIAL_PROMPT.md`. Não implementar agora importação de PDF, sincronização online, IA, notificações, pagamentos ou todos os módulos futuros. Primeiro entregar uma base que rode, grave dados e prove isso por testes.

# Kit inicial do app de estudos para concursos

Este pacote reúne a especificação do produto e as instruções para iniciar o desenvolvimento com Codex.

## Arquivos

- `PRODUCT_SPEC.md`: visão do produto, escopo do MVP, requisitos, fluxos e critérios de aceite.
- `AGENTS.md`: regras persistentes que o Codex deve seguir ao trabalhar no repositório.
- `DATA_MODEL.md`: entidades, relacionamentos, decisões de persistência e métricas.
- `database/schema.sql`: proposta inicial do esquema SQLite, versão 1.
- `CODEX_INITIAL_PROMPT.md`: prompt pronto para iniciar a implementação da primeira fase.

## Premissas adotadas

- Nome provisório do projeto: **Trilha de Aprovação**. O nome pode ser alterado depois.
- Primeiro alvo: Windows; Android deve continuar possível sem reescrever o domínio.
- Interface em português brasileiro (`pt-BR`), tema escuro como padrão, verde-musgo e dourado como cores de destaque.
- Uso offline-first, com persistência local e sem exigir conta ou serviço de nuvem no MVP.
- Flutter e Dart, com dados em SQLite e uma camada de repositório para evitar acoplamento entre interface e banco.

## Como usar

1. Crie um repositório Git vazio ou abra a pasta que será a raiz do projeto.
2. Copie os arquivos deste pacote para a raiz do repositório, mantendo a pasta `database/`.
3. Abra a raiz do projeto no Codex.
4. Cole o conteúdo de `CODEX_INITIAL_PROMPT.md` como a primeira tarefa.
5. Revise as alterações, execute os testes e confirme que o aplicativo inicia antes de avançar para outras fases.

## Ambiente Windows

Para desenvolver e compilar Flutter para Windows, instale o Flutter SDK, Git e o Visual Studio com a carga de trabalho **Desenvolvimento para desktop com C++**. Valide a instalação com `flutter doctor -v` e confira os dispositivos com `flutter devices`.

Documentação oficial:

- Flutter para Windows: https://docs.flutter.dev/platform-integration/windows/setup
- Suporte a desktop no Flutter: https://docs.flutter.dev/platform-integration/desktop
- `sqflite_common_ffi`: https://pub.dev/packages/sqflite_common_ffi

> Este é um kit de especificação. Ele ainda não contém o aplicativo Flutter implementado.

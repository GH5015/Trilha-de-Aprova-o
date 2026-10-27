# Prompt inicial para o Codex

Copie o texto abaixo para o Codex com a pasta do repositório aberta.

---

Você é o engenheiro de software responsável por iniciar o aplicativo **Trilha de Aprovação**, um organizador de estudos para concursos públicos.

Antes de escrever código:

1. Leia `AGENTS.md`, `PRODUCT_SPEC.md` e `DATA_MODEL.md` por completo.
2. Inspecione o repositório, o status do Git, os arquivos existentes e as versões disponíveis de Flutter e Dart. Não sobrescreva trabalho existente.
3. Se o repositório ainda não for um projeto Flutter, inicialize um projeto Flutter adequado à pasta atual, preservando estes documentos e a pasta `database/`. O alvo prioritário é Windows, mantendo Android viável. Se Flutter não estiver instalado ou faltar ferramenta nativa, pare nessa etapa, reporte o bloqueio exato e ainda conclua/documente o que for possível sem fingir que compilou.
4. Verifique a compatibilidade atual das dependências antes de escolhê-las. Não fixe versões antigas sem motivo. Para a persistência, use SQLite por trás de uma camada de acesso a dados que funcione no Windows e possa ser usada no Android. Inicialize o caminho do banco no diretório de dados da aplicação, nunca no diretório de trabalho atual.

## Objetivo desta tarefa

Entregar a **primeira fatia vertical funcional da Fase 1A**, não o produto inteiro. Ao terminar, o app deve abrir, navegar, persistir concursos/matérias/tópicos e apresentar um painel baseado em dados reais.

### Escopo obrigatório

1. Criar/ajustar estrutura do projeto, tema escuro, componentes e navegação principal conforme `PRODUCT_SPEC.md`.
2. Montar um layout desktop claro e funcional, em `pt-BR`, com navegação lateral e as áreas principais: Visão geral, Concursos e edital, Planejamento, Sessão de estudo, Questões, Revisões, Relatórios e Configurações. Nas áreas fora do escopo atual, mostrar estado “Em desenvolvimento” de maneira honesta, sem botões falsos.
3. Implementar SQLite com migração versionada inicial a partir de `database/schema.sql` ou de uma migração equivalente sob controle do projeto. Não mantenha duas fontes conflitantes de verdade para o esquema.
4. Implementar CRUD básico persistente para:
   - concursos (nome obrigatório; banca/data opcionais; ativo/arquivado);
   - matérias vinculadas a concurso;
   - tópicos vinculados a matéria, com suporte a tópico pai/subtópico.
5. Implementar estados de carregamento, vazio, erro, confirmação e validação dos formulários.
6. Implementar um cronômetro de sessão funcional: selecionar concurso e matéria (tópico opcional), iniciar, pausar, retomar e concluir sessão. Persistir estado e segundos acumulados no SQLite, excluindo pausas e recuperando com segurança uma sessão que estava ativa antes de reiniciar o app. Na retomada do app, não conte automaticamente o tempo em que ele ficou fechado: apresente uma recuperação segura, mantendo os segundos já acumulados e exigindo ação explícita para retomar ou concluir.
7. Implementar painel com consultas reais. No mínimo: concurso ativo, quantidade de matérias/tópicos, minutos estudados a partir de sessões concluídas, e mensagem útil quando a base estiver vazia. Nunca mostrar minutos fictícios.
8. Adotar uma solução de gerenciamento de estado consistente (preferencialmente Riverpod, a menos que o repositório existente tenha outro padrão adequado) e separar apresentação, domínio e persistência. Evitar criar abstrações sem uso concreto.
9. Adicionar testes automatizados para a migração, CRUD e pelo menos as validações principais. Os testes devem usar banco isolado/em memória/temporário, nunca os dados reais locais.
10. Atualizar README com pré-requisitos reais, comandos para executar no Windows e comandos de teste. Não declarar uma ferramenta disponível sem verificar.
11. Preservar o conteúdo dos documentos de produto. Se uma decisão necessária divergir deles, documente a razão e faça a menor mudança possível.

### Diretrizes de implementação

- Basear-se em `AGENTS.md`, `PRODUCT_SPEC.md` e `DATA_MODEL.md`.
- Usar IDs estáveis e timestamps consistentes.
- Habilitar foreign keys na conexão SQLite.
- Não permitir que a camada UI acesse SQL diretamente.
- Usar transações quando houver múltiplas alterações dependentes.
- Evitar exclusão em cascata de dados históricos; preferir arquivamento ou impedir remoção quando houver vínculos.
- Criar migrações para mudanças de esquema, sem simplesmente apagar o banco.
- Calcular métricas do painel a partir dos dados reais e tratar denominador zero/ausência de dados corretamente.
- Não adicionar login, nuvem, sincronização, IA, leitura de PDFs, compras ou serviços externos.
- Não incluir dados de demonstração automaticamente. Se criar seed para desenvolvimento, que seja explícito e separado dos dados de produção.
- Mantenha o layout responsivo para que a interface possa ser adaptada ao Android mais adiante.
- Garanta que botões de criar, editar, arquivar e navegar executem ações reais.

### Critérios de aceite

- O projeto Flutter está inicializado corretamente, ou um bloqueio ambiental exato foi documentado.
- O app inicia no Windows se a toolchain estiver disponível.
- É possível cadastrar concurso, matéria e tópico; editar e arquivar concurso; reabrir o app e confirmar que os dados continuam presentes.
- As validações impedem nomes vazios e vínculos inválidos.
- Uma tentativa de apontar tópico para matéria/concurso incompatível é recusada no domínio ou pelo banco.
- O painel não usa métricas inventadas e tem estado vazio utilizável.
- Uma sessão pode ser iniciada, pausada, retomada e concluída; o tempo pausado não entra no tempo líquido e a sessão não é contada duas vezes.
- Os documentos continuam presentes na raiz.
- Foram executados, quando possíveis: `dart format .`, `flutter analyze` e `flutter test`. Relate o resultado de cada comando com honestidade.

### Método de trabalho

Implemente em passos pequenos. Primeiro verifique o ambiente e crie a estrutura. Depois conclua banco/migração e testes. Em seguida implemente CRUD de concurso/matéria/tópico. Por fim integre painel e navegação, rode validações e revise o diff. Não pare apenas em planejamento: implemente o máximo possível dentro desse escopo nesta tarefa.

### Relatório final obrigatório

Ao concluir, informe:

1. O que foi implementado.
2. Arquivos mais relevantes criados/alterados.
3. Como executar o app no Windows.
4. Comandos executados e resultados reais.
5. Limitações ou bloqueios restantes.
6. O próximo incremento recomendado, sem começar fases fora de escopo.

---

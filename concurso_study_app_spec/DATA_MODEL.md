# DATA_MODEL.md

## 1. Objetivo

Definir o modelo local de dados para planejamento e acompanhamento pessoal de estudos. O armazenamento inicial é SQLite e deve funcionar offline. O SQL correspondente à versão 1 está em `database/schema.sql`.

## 2. Convenções

- IDs em `TEXT`, gerados pela aplicação como UUID (ou identificador estável equivalente).
- `created_at` e `updated_at`: timestamps ISO 8601 em UTC, por exemplo `2026-10-27T21:00:00Z`.
- `started_at`, `ended_at`, `answered_at`, `due_at` e `last_reviewed_at`: timestamps ISO 8601 com política de fuso documentada. Preferir armazenar UTC e converter para o fuso local na interface.
- `planned_date` e `goal_date`: datas de calendário locais em `YYYY-MM-DD`, sem conversão de fuso.
- Duração: inteiro em segundos.
- Percentuais e fatores: valores numéricos limitados e validados no domínio.
- Valores de estado são strings com conjunto finito definido neste documento e no esquema.
- Habilitar integridade referencial em cada conexão SQLite.

## 3. Entidades

### `contests`
Representa um concurso ou processo seletivo acompanhado.

- Campos essenciais: `id`, `name`, `examining_board`, `exam_date`, `status`, timestamps.
- Um concurso possui matérias, tópicos indiretamente, sessões, metas, plano, tentativas de questões, revisões e notas.
- `status`: `active` ou `archived`.

### `subjects`
Matérias de um concurso.

- `contest_id` é obrigatório.
- `weight` representa um peso relativo opcional e não precisa somar 100.
- `target_accuracy_pct` é a meta de acerto opcional.
- `sort_order` preserva a ordem preferida na interface.
- Nome único dentro do concurso.

### `topics`
Tópicos e subtópicos do edital.

- `subject_id` é obrigatório; `parent_topic_id` é opcional e permite hierarquia.
- `estimated_minutes` e `difficulty` são estimativas subjetivas, não medições objetivas.
- `status`: `not_started`, `in_progress`, `completed`, `needs_review`.
- Evitar ciclos na hierarquia; a camada de domínio deve validar que o pai não é o próprio tópico nem um descendente.

### `study_sessions`
Registros de tempo/atividade efetivamente estudada.

- Associação obrigatória com concurso e matéria; tópico pode ser nulo.
- `session_type`: `study`, `review`, `questions`, `mock_exam`.
- `status`: `running`, `paused`, `completed`, `interrupted`.
- `duration_seconds` guarda os segundos líquidos já acumulados, excluindo a janela indicada por `active_since`.
- `active_since` fica preenchido apenas durante uma janela de execução ativa; ao pausar, calcular e acumular o delta e limpar `active_since`; ao retomar, preencher com o instante atual. Ao concluir, acumular a última janela, limpar `active_since` e preencher `ended_at`.
- Para uma sessão ativa, persistir estado suficiente para recuperação após reinício. Não presumir que a aplicação ficará sempre aberta.
- Não permitir que a mesma sessão seja finalizada ou contabilizada duas vezes.

### `daily_goals`
Metas diárias por concurso.

- Uma linha por concurso e data.
- `target_minutes` e `target_questions` podem ser nulos para indicar meta ainda não definida; se fornecidos, devem ser não negativos.
- O realizado é calculado de sessões e tentativas, não duplicado na tabela de metas.

### `study_plan_items`
Itens planejados para uma data.

- Contém concurso, matéria, tópico opcional, data, minutos planejados, prioridade e status.
- `status`: `planned`, `completed`, `skipped`, `carried_over`.
- `session_id` opcional associa o planejamento à sessão que cumpriu a atividade.
- Reprogramar exige decidir explicitamente se o item é movido ou se um novo item é criado. Não duplicar silenciosamente.

### `question_attempts`
Tentativas individuais de questões.

- Contém concurso, matéria, tópico opcional, horário da tentativa, resultado e metadados opcionais.
- `is_correct` deve ser booleano/0 ou 1. Questões sem avaliação não devem ser registradas como erradas; se necessário, modele um estado separado numa evolução futura.
- `source` pode identificar plataforma, prova, caderno próprio ou outro registro de origem.
- `question_ref` pode ser uma URL ou referência textual. Não pressupõe autorização para copiar enunciados.
- `error_category` opcional: falta de conteúdo, interpretação, distração, cálculo, tempo ou outro. Não restringir a taxonomia a esses valores no aplicativo se o usuário puder inserir categoria própria; no esquema, manter texto opcional.

### `review_items`
Revisões programadas.

- Pode referenciar um tópico, uma tentativa incorreta ou ambos conforme a origem.
- `due_at` indica quando rever; `last_reviewed_at` guarda a última revisão concluída.
- `status`: `scheduled`, `completed`, `skipped`, `cancelled`.
- `interval_days`, `ease_factor` e `repetition_count` apoiam algoritmo simples de repetição espaçada; manter defaults e regra transparente. Esses campos não constituem garantia de retenção.
- O esquema restringe a exclusão de uma tentativa ou sessão que ainda seja a única origem de uma revisão. Antes de remover esses registros, a aplicação deve exigir que a revisão seja reassociada ou tratada explicitamente, preservando histórico.

### `notes`
Anotações livres.

- `title` e `content` são obrigatórios, podendo o título ter um default simples.
- Vínculos com concurso, matéria ou tópico são opcionais.
- Uma nota deve continuar utilizável sem associação a um tópico.

## 4. Relacionamentos

- `contests 1:N subjects`
- `subjects 1:N topics`
- `topics 1:N topics` por `parent_topic_id`
- `contests 1:N study_sessions`
- `subjects 1:N study_sessions`
- `contests 1:N daily_goals`
- `contests 1:N study_plan_items`
- `study_sessions 0..1:N study_plan_items` pela referência opcional de sessão; uma sessão pode cumprir no máximo um item na primeira versão se o domínio assim validar.
- `contests 1:N question_attempts`
- `contests 1:N review_items`
- `contests 1:N notes`, com associações opcionais a matéria/tópico.

O esquema inclui chaves estrangeiras simples e índices. A camada de domínio deve validar que as combinações concurso/matéria/tópico sejam coerentes, pois uma referência isolada a um tópico não prova que ele pertence à matéria selecionada.

## 5. Métricas derivadas

- **Minutos líquidos por dia:** somar `duration_seconds` de sessões `completed` válidas e dividir por 60; regras de arredondamento ficam na apresentação.
- **Questões por dia:** contar tentativas válidas por `answered_at` convertida para a data local do usuário.
- **Taxa de acerto:** `COUNT(is_correct = 1) / COUNT(tentativas avaliadas) * 100`. Retornar ausência de métrica quando o denominador for zero.
- **Progresso autodeclarado do edital:** tópicos com status `completed` em relação a tópicos aplicáveis. Mostrar separado da taxa de acerto.
- **Cumprimento de metas:** realizar / meta; para meta nula ou zero, mostrar “sem meta definida” e evitar divisão por zero.
- **Revisões vencidas:** itens `scheduled` com `due_at` anterior ao instante atual.

## 6. Exclusão, histórico e integridade

- Arquivar concurso em vez de excluir como comportamento padrão.
- Evitar cascata destrutiva em sessões, tentativas e histórico de revisão.
- Quando houver remoção de matéria/tópico, oferecer confirmação e estabelecer política explícita: impedir remoção se há histórico ou arquivar/desassociar preservando os registros. Não apagar histórico automaticamente.
- Usar transações para concluir sessões e atualizar itens de plano. Para sessões baseadas em cronômetro, respeitar o contrato de `active_since` e não contar janelas pausadas.
- Índices devem cobrir filtros por concurso/data, matéria/data e estado/data.

## 7. Evoluções futuras

- Perfil e preferências do usuário.
- Catálogo de bancas e taxonomia de erros normalizada.
- Tabelas de pausas de sessões se exigidas por relatório detalhado.
- Exportação e importação de backup com validação de versão.
- IDs de sincronização, tombstones e política de resolução de conflito apenas se sincronização for aprovada.
- Anexos e metadados de importação de PDFs, após desenhar o fluxo de privacidade e direitos autorais.

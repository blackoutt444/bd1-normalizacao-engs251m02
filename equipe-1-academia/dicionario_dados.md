# Dicionário de dados

Dicionário de **todas** as tabelas finais do banco `normalizacao_academia`, com os tipos do MySQL usados no [`01_ddl.sql`](01_ddl.sql). As três planilhas originais (`planilha`, `planilha_fnbc` e `planilha_4fn`) continuam no banco só como origem da migração e da prova, e não fazem parte do modelo final.

Convenções: **PK** = chave primária, **FK** = chave estrangeira, **UK** = chave alternativa única. Todas as tabelas usam InnoDB e `utf8mb4`.

---

**Tabela: `plano`**: planos que a academia vende. Vem de `planilha` (`cod_plano → nome_plano, valor_plano`).

| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição | Restrição / domínio |
| --- | --- | --- | --- | --- | --- | --- |
| cod_plano | CHAR | 2 | Não | PK | Código do plano | Ex.: P1, P2, P3 |
| nome_plano | VARCHAR | 20 | Não | UK | Nome do plano | Único (Mensal, Trimestral, Anual) |
| valor_plano | DECIMAL | 8,2 | Não |  | Valor do plano em R$ | Maior que 0 (`ck_plano_valor`) |

---

**Tabela: `aluno`**: cadastro de alunos. Vem de `planilha` (`matricula → nome_aluno, cod_plano`).

| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição | Restrição / domínio |
| --- | --- | --- | --- | --- | --- | --- |
| matricula | INT | — | Não | PK | Número de matrícula do aluno | Maior que 0 (`ck_aluno_matricula`) |
| nome_aluno | VARCHAR | 60 | Não |  | Nome completo do aluno | Nesta base, nomes não se repetem (`04_validacoes.sql`) |
| cod_plano | CHAR | 2 | Não | FK → plano | Plano assinado pelo aluno | Deve existir em `plano`; atualização em cascata, exclusão restrita |

---

**Tabela: `aluno_telefone`**: telefones do aluno, um por linha (1FN do campo `telefones`).

| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição | Restrição / domínio |
| --- | --- | --- | --- | --- | --- | --- |
| matricula | INT | — | Não | PK, FK → aluno | Aluno dono do telefone | Deve existir em `aluno`; apagar o aluno apaga seus telefones |
| posicao | TINYINT UNSIGNED | — | Não | PK | Ordem do telefone na célula original (1, 2, ...) | Maior ou igual a 1; usada para remontar a lista na mesma ordem |
| telefone | VARCHAR | 20 | Não | UK com matricula | Número de telefone | Formato `(DD) 9XXXX-XXXX`; o mesmo aluno não repete telefone |

---

**Tabela: `aula`**: aulas oferecidas. Vem de `planilha` (`cod_aula → nome_aula, horario, dias`).

| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição | Restrição / domínio |
| --- | --- | --- | --- | --- | --- | --- |
| cod_aula | CHAR | 2 | Não | PK | Código da aula | Ex.: A1 a A4 |
| nome_aula | VARCHAR | 30 | Não |  | Nome da aula | Ex.: Musculação, Spinning |
| horario | TIME | — | Não |  | Horário de início da aula | Hora válida (a planilha guardava texto `HH:MM`) |

---

**Tabela: `aula_dia`**: dias da semana em que cada aula acontece, um por linha (1FN do campo `dias`).

| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição | Restrição / domínio |
| --- | --- | --- | --- | --- | --- | --- |
| cod_aula | CHAR | 2 | Não | PK, FK → aula | Aula | Deve existir em `aula`; apagar a aula apaga seus dias |
| posicao | TINYINT UNSIGNED | — | Não | PK | Ordem do dia no texto original (`Seg/Qua/Sex`) | Maior ou igual a 1 |
| dia | CHAR | 3 | Não | UK com cod_aula | Dia da semana abreviado | `Dom`, `Seg`, `Ter`, `Qua`, `Qui`, `Sex`, `Sáb` |

---

**Tabela: `matricula_aula`**: matrícula de um aluno em uma aula (cada linha da `planilha` original).

| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição | Restrição / domínio |
| --- | --- | --- | --- | --- | --- | --- |
| matricula | INT | — | Não | PK, FK → aluno | Aluno matriculado | Deve existir em `aluno`; exclusão restrita |
| cod_aula | CHAR | 2 | Não | PK, FK → aula | Aula em que o aluno está matriculado | Deve existir em `aula`; exclusão restrita |

---

**Tabela: `instrutor`**: instrutores e a modalidade que cada um ensina (FNBC: `instrutor → modalidade`).

| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição | Restrição / domínio |
| --- | --- | --- | --- | --- | --- | --- |
| nome_instrutor | VARCHAR | 60 | Não | PK | Nome do instrutor | Nesta base, o nome identifica o instrutor |
| modalidade | VARCHAR | 30 | Sim |  | Única modalidade que o instrutor ensina | Ex.: Musculação, Natação, Dança; NULL só para instrutor sem modalidade informada |

---

**Tabela: `aluno_instrutor`**: qual instrutor atende o aluno (a outra chave candidata da `planilha_fnbc`).

| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição | Restrição / domínio |
| --- | --- | --- | --- | --- | --- | --- |
| matricula | INT | — | Não | PK, FK → aluno | Aluno | Deve existir em `aluno`; exclusão restrita |
| nome_instrutor | VARCHAR | 60 | Não | PK, FK → instrutor | Instrutor que atende o aluno | Deve existir em `instrutor`; regra: um instrutor por aluno em cada modalidade (vigiada em `04_validacoes.sql`) |

---

**Tabela: `instrutor_certificacao`**: certificações de cada instrutor (4FN: `instrutor →→ certificacao`).

| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição | Restrição / domínio |
| --- | --- | --- | --- | --- | --- | --- |
| nome_instrutor | VARCHAR | 60 | Não | PK, FK → instrutor | Instrutor | Deve existir em `instrutor`; apagar o instrutor apaga as certificações |
| certificacao | VARCHAR | 40 | Não | PK | Certificação do instrutor | Ex.: CREF, Salva-vidas, Treinamento Funcional |

---

**Tabela: `instrutor_disponibilidade`**: dias em que cada instrutor está disponível (4FN: `instrutor →→ dia_disponivel`).

| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição | Restrição / domínio |
| --- | --- | --- | --- | --- | --- | --- |
| nome_instrutor | VARCHAR | 60 | Não | PK, FK → instrutor | Instrutor | Deve existir em `instrutor`; apagar o instrutor apaga a disponibilidade |
| dia_disponivel | VARCHAR | 10 | Não | PK | Dia da semana disponível | `Domingo`, `Segunda`, `Terça`, `Quarta`, `Quinta`, `Sexta`, `Sábado` |

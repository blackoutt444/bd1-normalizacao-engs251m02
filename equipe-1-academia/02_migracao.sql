-- Migração dos dados das planilhas para as tabelas novas (INSERT ... SELECT)
-- Equipe Academia (Equipe 1) - Academia FitMais
-- Nenhum dado é digitado de novo: tudo vem das três planilhas originais.
-- A sequência numérica (WITH RECURSIVE) só gera as posições 1, 2, 3... usadas para separar as listas.
-- Pré-requisito: 00_planilha.sql e 01_ddl.sql já executados, com as tabelas novas vazias.
USE normalizacao_academia;

-- ============================================================
-- planilha -> 3FN
-- ============================================================

-- Planos: cod_plano -> nome_plano, valor_plano.
-- Se o mesmo código tivesse nome ou valor diferentes em duas linhas, a PK recusaria a carga.
INSERT INTO plano (cod_plano, nome_plano, valor_plano)
SELECT DISTINCT cod_plano, nome_plano, valor_plano
FROM planilha;

-- Alunos: matricula -> nome_aluno, cod_plano.
INSERT INTO aluno (matricula, nome_aluno, cod_plano)
SELECT DISTINCT matricula, nome_aluno, cod_plano
FROM planilha;

-- Telefones: separa a célula "telefones" no ";" (SUBSTRING_INDEX), um telefone por linha,
-- guardando a posição original de cada um.
INSERT INTO aluno_telefone (matricula, posicao, telefone)
WITH RECURSIVE seq (n) AS (
  SELECT 1
  UNION ALL
  SELECT n + 1 FROM seq WHERE n < 20
),
lista AS (
  SELECT DISTINCT matricula, telefones
  FROM planilha
  WHERE telefones IS NOT NULL AND TRIM(telefones) <> ''
)
SELECT l.matricula,
       s.n,
       TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(l.telefones, ';', s.n), ';', -1))
FROM lista AS l
JOIN seq AS s
  ON s.n <= 1 + CHAR_LENGTH(l.telefones) - CHAR_LENGTH(REPLACE(l.telefones, ';', ''));

-- Aulas: cod_aula -> nome_aula, horario. O horário "07:00" vira o tipo TIME.
INSERT INTO aula (cod_aula, nome_aula, horario)
SELECT DISTINCT cod_aula, nome_aula, CAST(horario AS TIME)
FROM planilha;

-- Dias da aula: separa "Seg/Qua/Sex" na "/", um dia por linha, com a posição original.
INSERT INTO aula_dia (cod_aula, posicao, dia)
WITH RECURSIVE seq (n) AS (
  SELECT 1
  UNION ALL
  SELECT n + 1 FROM seq WHERE n < 7
),
lista AS (
  SELECT DISTINCT cod_aula, dias
  FROM planilha
  WHERE dias IS NOT NULL AND TRIM(dias) <> ''
)
SELECT l.cod_aula,
       s.n,
       TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(l.dias, '/', s.n), '/', -1))
FROM lista AS l
JOIN seq AS s
  ON s.n <= 1 + CHAR_LENGTH(l.dias) - CHAR_LENGTH(REPLACE(l.dias, '/', ''));

-- Matrículas nas aulas: o que sobra da chave (matricula, cod_aula).
INSERT INTO matricula_aula (matricula, cod_aula)
SELECT DISTINCT matricula, cod_aula
FROM planilha;

-- ============================================================
-- planilha_fnbc -> FNBC
-- ============================================================

-- Instrutores: instrutor -> modalidade.
-- Se um instrutor aparecesse com duas modalidades, a PK recusaria a carga (a regra seria violada).
INSERT INTO instrutor (nome_instrutor, modalidade)
SELECT DISTINCT instrutor, modalidade
FROM planilha_fnbc;

-- Instrutores que só aparecem na planilha_4fn (nesta base: nenhum).
INSERT INTO instrutor (nome_instrutor, modalidade)
SELECT DISTINCT p.instrutor, NULL
FROM planilha_4fn AS p
WHERE NOT EXISTS (
  SELECT 1 FROM planilha_fnbc AS f WHERE f.instrutor = p.instrutor
);

-- Aluno x instrutor: o aluno é localizado pelo nome no cadastro de alunos.
-- O 04_validacoes.sql confere que todo aluno da planilha_fnbc foi encontrado.
INSERT INTO aluno_instrutor (matricula, nome_instrutor)
SELECT DISTINCT a.matricula, f.instrutor
FROM planilha_fnbc AS f
JOIN aluno AS a
  ON a.nome_aluno = f.aluno;

-- ============================================================
-- planilha_4fn -> 4FN
-- ============================================================

-- Certificações: instrutor ->> certificacao.
INSERT INTO instrutor_certificacao (nome_instrutor, certificacao)
SELECT DISTINCT instrutor, certificacao
FROM planilha_4fn;

-- Disponibilidade: instrutor ->> dia_disponivel.
INSERT INTO instrutor_disponibilidade (nome_instrutor, dia_disponivel)
SELECT DISTINCT instrutor, dia_disponivel
FROM planilha_4fn;

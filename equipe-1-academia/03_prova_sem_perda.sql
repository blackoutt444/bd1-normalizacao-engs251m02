-- Consultas que remontam cada planilha a partir das tabelas novas e comparam com a original
-- Equipe Academia (Equipe 1) - Academia FitMais
-- Pré-requisito: 00_planilha.sql, 01_ddl.sql e 02_migracao.sql já executados.
-- A comparação é feita coluna a coluna, byte a byte (CAST ... AS BINARY), para que diferenças de
-- acento ou de maiúsculas/minúsculas não passem despercebidas pela collation do banco.
USE normalizacao_academia;

-- ============================================================
-- 1. Remontagem de cada planilha (JOIN das tabelas novas)
-- ============================================================

-- planilha: junta matrícula x aluno x plano x aula e remonta as duas listas com GROUP_CONCAT,
-- na ordem original (posicao).
CREATE OR REPLACE VIEW vw_planilha_reconstruida AS
SELECT a.matricula,
       a.nome_aluno,
       tel.telefones,
       p.cod_plano,
       p.nome_plano,
       p.valor_plano,
       au.cod_aula,
       au.nome_aula,
       TIME_FORMAT(au.horario, '%H:%i') AS horario,
       dd.dias
FROM matricula_aula AS ma
JOIN aluno AS a  ON a.matricula = ma.matricula
JOIN plano AS p  ON p.cod_plano = a.cod_plano
JOIN aula  AS au ON au.cod_aula = ma.cod_aula
LEFT JOIN (
  SELECT matricula,
         GROUP_CONCAT(telefone ORDER BY posicao SEPARATOR '; ') AS telefones
  FROM aluno_telefone
  GROUP BY matricula
) AS tel ON tel.matricula = a.matricula
LEFT JOIN (
  SELECT cod_aula,
         GROUP_CONCAT(dia ORDER BY posicao SEPARATOR '/') AS dias
  FROM aula_dia
  GROUP BY cod_aula
) AS dd ON dd.cod_aula = au.cod_aula;

-- planilha_fnbc: aluno x instrutor, com a modalidade vinda do instrutor.
CREATE OR REPLACE VIEW vw_planilha_fnbc_reconstruida AS
SELECT a.nome_aluno     AS aluno,
       i.modalidade,
       i.nome_instrutor AS instrutor
FROM aluno_instrutor AS ai
JOIN aluno     AS a ON a.matricula = ai.matricula
JOIN instrutor AS i ON i.nome_instrutor = ai.nome_instrutor;

-- planilha_4fn: certificações x dias disponíveis do mesmo instrutor.
CREATE OR REPLACE VIEW vw_planilha_4fn_reconstruida AS
SELECT c.nome_instrutor AS instrutor,
       c.certificacao,
       d.dia_disponivel
FROM instrutor_certificacao AS c
JOIN instrutor_disponibilidade AS d ON d.nome_instrutor = c.nome_instrutor;

-- Para mostrar as planilhas remontadas na apresentação:
SELECT * FROM vw_planilha_reconstruida ORDER BY matricula, cod_aula;
SELECT * FROM vw_planilha_fnbc_reconstruida ORDER BY aluno, modalidade;
SELECT * FROM vw_planilha_4fn_reconstruida ORDER BY instrutor, certificacao, dia_disponivel;

-- ============================================================
-- 2. Prova: original x remontada (faltando = 0 e sobrando = 0)
-- ============================================================
SELECT 'planilha' AS tabela,
       (SELECT COUNT(*) FROM planilha) AS linhas_original,
       (SELECT COUNT(*) FROM vw_planilha_reconstruida) AS linhas_reconstruida,
       (SELECT COUNT(*) FROM planilha AS o
         WHERE NOT EXISTS (
           SELECT 1 FROM vw_planilha_reconstruida AS r
           WHERE r.matricula <=> o.matricula
             AND CAST(r.nome_aluno AS BINARY) <=> CAST(o.nome_aluno AS BINARY)
             AND CAST(r.telefones  AS BINARY) <=> CAST(o.telefones  AS BINARY)
             AND CAST(r.cod_plano  AS BINARY) <=> CAST(o.cod_plano  AS BINARY)
             AND CAST(r.nome_plano AS BINARY) <=> CAST(o.nome_plano AS BINARY)
             AND r.valor_plano <=> o.valor_plano
             AND CAST(r.cod_aula   AS BINARY) <=> CAST(o.cod_aula   AS BINARY)
             AND CAST(r.nome_aula  AS BINARY) <=> CAST(o.nome_aula  AS BINARY)
             AND CAST(r.horario    AS BINARY) <=> CAST(o.horario    AS BINARY)
             AND CAST(r.dias       AS BINARY) <=> CAST(o.dias       AS BINARY))) AS faltando,
       (SELECT COUNT(*) FROM vw_planilha_reconstruida AS r
         WHERE NOT EXISTS (
           SELECT 1 FROM planilha AS o
           WHERE r.matricula <=> o.matricula
             AND CAST(r.nome_aluno AS BINARY) <=> CAST(o.nome_aluno AS BINARY)
             AND CAST(r.telefones  AS BINARY) <=> CAST(o.telefones  AS BINARY)
             AND CAST(r.cod_plano  AS BINARY) <=> CAST(o.cod_plano  AS BINARY)
             AND CAST(r.nome_plano AS BINARY) <=> CAST(o.nome_plano AS BINARY)
             AND r.valor_plano <=> o.valor_plano
             AND CAST(r.cod_aula   AS BINARY) <=> CAST(o.cod_aula   AS BINARY)
             AND CAST(r.nome_aula  AS BINARY) <=> CAST(o.nome_aula  AS BINARY)
             AND CAST(r.horario    AS BINARY) <=> CAST(o.horario    AS BINARY)
             AND CAST(r.dias       AS BINARY) <=> CAST(o.dias       AS BINARY))) AS sobrando
UNION ALL
SELECT 'planilha_fnbc',
       (SELECT COUNT(*) FROM planilha_fnbc),
       (SELECT COUNT(*) FROM vw_planilha_fnbc_reconstruida),
       (SELECT COUNT(*) FROM planilha_fnbc AS o
         WHERE NOT EXISTS (
           SELECT 1 FROM vw_planilha_fnbc_reconstruida AS r
           WHERE CAST(r.aluno      AS BINARY) <=> CAST(o.aluno      AS BINARY)
             AND CAST(r.modalidade AS BINARY) <=> CAST(o.modalidade AS BINARY)
             AND CAST(r.instrutor  AS BINARY) <=> CAST(o.instrutor  AS BINARY))),
       (SELECT COUNT(*) FROM vw_planilha_fnbc_reconstruida AS r
         WHERE NOT EXISTS (
           SELECT 1 FROM planilha_fnbc AS o
           WHERE CAST(r.aluno      AS BINARY) <=> CAST(o.aluno      AS BINARY)
             AND CAST(r.modalidade AS BINARY) <=> CAST(o.modalidade AS BINARY)
             AND CAST(r.instrutor  AS BINARY) <=> CAST(o.instrutor  AS BINARY)))
UNION ALL
SELECT 'planilha_4fn',
       (SELECT COUNT(*) FROM planilha_4fn),
       (SELECT COUNT(*) FROM vw_planilha_4fn_reconstruida),
       (SELECT COUNT(*) FROM planilha_4fn AS o
         WHERE NOT EXISTS (
           SELECT 1 FROM vw_planilha_4fn_reconstruida AS r
           WHERE CAST(r.instrutor      AS BINARY) <=> CAST(o.instrutor      AS BINARY)
             AND CAST(r.certificacao   AS BINARY) <=> CAST(o.certificacao   AS BINARY)
             AND CAST(r.dia_disponivel AS BINARY) <=> CAST(o.dia_disponivel AS BINARY))),
       (SELECT COUNT(*) FROM vw_planilha_4fn_reconstruida AS r
         WHERE NOT EXISTS (
           SELECT 1 FROM planilha_4fn AS o
           WHERE CAST(r.instrutor      AS BINARY) <=> CAST(o.instrutor      AS BINARY)
             AND CAST(r.certificacao   AS BINARY) <=> CAST(o.certificacao   AS BINARY)
             AND CAST(r.dia_disponivel AS BINARY) <=> CAST(o.dia_disponivel AS BINARY)));

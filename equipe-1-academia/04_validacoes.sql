-- Validações extras e desafio da decomposição errada
-- Equipe Academia (Equipe 1) - Academia FitMais
-- Pré-requisito: 00_planilha.sql, 01_ddl.sql e 02_migracao.sql já executados.
-- Nada aqui altera dados: são só consultas.
USE normalizacao_academia;

-- ============================================================
-- 1. As dependências usadas na normalização valem nos dados originais
--    (cada linha conta as violações encontradas; o esperado é 0 em todas)
-- ============================================================
SELECT 'planilha: (matricula, cod_aula) identifica a linha' AS verificacao,
       COUNT(*) - COUNT(DISTINCT matricula, cod_aula) AS violacoes
FROM planilha
UNION ALL
SELECT 'planilha: matricula -> nome_aluno, telefones, cod_plano',
       COUNT(*) FROM (
         SELECT matricula FROM planilha
         GROUP BY matricula
         HAVING COUNT(DISTINCT nome_aluno, telefones, cod_plano) > 1
       ) AS x
UNION ALL
SELECT 'planilha: cod_plano -> nome_plano, valor_plano',
       COUNT(*) FROM (
         SELECT cod_plano FROM planilha
         GROUP BY cod_plano
         HAVING COUNT(DISTINCT nome_plano, valor_plano) > 1
       ) AS x
UNION ALL
SELECT 'planilha: cod_aula -> nome_aula, horario, dias',
       COUNT(*) FROM (
         SELECT cod_aula FROM planilha
         GROUP BY cod_aula
         HAVING COUNT(DISTINCT nome_aula, horario, dias) > 1
       ) AS x
UNION ALL
SELECT 'planilha_fnbc: instrutor -> modalidade',
       COUNT(*) FROM (
         SELECT instrutor FROM planilha_fnbc
         GROUP BY instrutor
         HAVING COUNT(DISTINCT modalidade) > 1
       ) AS x
UNION ALL
SELECT 'planilha_fnbc: (aluno, modalidade) -> instrutor',
       COUNT(*) FROM (
         SELECT aluno, modalidade FROM planilha_fnbc
         GROUP BY aluno, modalidade
         HAVING COUNT(DISTINCT instrutor) > 1
       ) AS x
UNION ALL
SELECT 'planilha_fnbc: (aluno, instrutor) também identifica a linha',
       COUNT(*) - COUNT(DISTINCT aluno, instrutor)
FROM planilha_fnbc
UNION ALL
-- Dependência multivalorada: para cada instrutor, as linhas são todas as combinações
-- certificação x dia (linhas = certificações distintas x dias distintos).
SELECT 'planilha_4fn: instrutor ->> certificacao | dia_disponivel',
       COUNT(*) FROM (
         SELECT instrutor FROM planilha_4fn
         GROUP BY instrutor
         HAVING COUNT(*) <> COUNT(DISTINCT certificacao) * COUNT(DISTINCT dia_disponivel)
       ) AS x
UNION ALL
-- Hipótese da integração: o nome identifica o aluno e todo aluno da planilha_fnbc está no cadastro.
SELECT 'aluno: nomes repetidos no cadastro',
       COUNT(*) - COUNT(DISTINCT nome_aluno)
FROM aluno
UNION ALL
SELECT 'planilha_fnbc: aluno sem matrícula correspondente',
       COUNT(*)
FROM planilha_fnbc AS f
WHERE NOT EXISTS (SELECT 1 FROM aluno AS a WHERE a.nome_aluno = f.aluno)
UNION ALL
-- A FNBC não preserva (aluno, modalidade) -> instrutor nas tabelas finais; esta consulta vigia a regra.
SELECT 'tabelas finais: aluno com dois instrutores na mesma modalidade',
       COUNT(*) FROM (
         SELECT ai.matricula, i.modalidade
         FROM aluno_instrutor AS ai
         JOIN instrutor AS i ON i.nome_instrutor = ai.nome_instrutor
         GROUP BY ai.matricula, i.modalidade
         HAVING COUNT(*) > 1
       ) AS x;

-- ============================================================
-- 2. Quantidade de linhas em cada tabela final
-- ============================================================
SELECT 'plano' AS tabela, COUNT(*) AS linhas FROM plano
UNION ALL SELECT 'aluno', COUNT(*) FROM aluno
UNION ALL SELECT 'aluno_telefone', COUNT(*) FROM aluno_telefone
UNION ALL SELECT 'aula', COUNT(*) FROM aula
UNION ALL SELECT 'aula_dia', COUNT(*) FROM aula_dia
UNION ALL SELECT 'matricula_aula', COUNT(*) FROM matricula_aula
UNION ALL SELECT 'instrutor', COUNT(*) FROM instrutor
UNION ALL SELECT 'aluno_instrutor', COUNT(*) FROM aluno_instrutor
UNION ALL SELECT 'instrutor_certificacao', COUNT(*) FROM instrutor_certificacao
UNION ALL SELECT 'instrutor_disponibilidade', COUNT(*) FROM instrutor_disponibilidade;

-- ============================================================
-- 3. Desafio: decomposição ERRADA da planilha_fnbc
--    R1(aluno, modalidade) e R2(modalidade, instrutor), juntadas por modalidade.
--    modalidade não é chave de nenhuma das duas, então a junção inventa linhas.
-- ============================================================

-- 3.1 As duas tabelas da decomposição errada
SELECT DISTINCT aluno, modalidade FROM planilha_fnbc ORDER BY aluno, modalidade;
SELECT DISTINCT modalidade, instrutor FROM planilha_fnbc ORDER BY modalidade, instrutor;

-- 3.2 A junção, marcando quais linhas não existem na planilha original
WITH r1 AS (SELECT DISTINCT aluno, modalidade FROM planilha_fnbc),
     r2 AS (SELECT DISTINCT modalidade, instrutor FROM planilha_fnbc)
SELECT r1.aluno,
       r1.modalidade,
       r2.instrutor,
       CASE WHEN EXISTS (
              SELECT 1 FROM planilha_fnbc AS o
              WHERE o.aluno = r1.aluno AND o.modalidade = r1.modalidade AND o.instrutor = r2.instrutor)
            THEN 'original' ELSE 'ESPÚRIA' END AS situacao
FROM r1
JOIN r2 ON r2.modalidade = r1.modalidade
ORDER BY situacao DESC, r1.modalidade, r1.aluno, r2.instrutor;

-- 3.3 Resumo do desafio
WITH r1 AS (SELECT DISTINCT aluno, modalidade FROM planilha_fnbc),
     r2 AS (SELECT DISTINCT modalidade, instrutor FROM planilha_fnbc),
     juncao AS (
       SELECT r1.aluno, r1.modalidade, r2.instrutor
       FROM r1 JOIN r2 ON r2.modalidade = r1.modalidade
     )
SELECT (SELECT COUNT(*) FROM planilha_fnbc) AS linhas_original,
       (SELECT COUNT(*) FROM juncao) AS linhas_juncao,
       (SELECT COUNT(*) FROM juncao AS j
         WHERE NOT EXISTS (
           SELECT 1 FROM planilha_fnbc AS o
           WHERE o.aluno = j.aluno AND o.modalidade = j.modalidade AND o.instrutor = j.instrutor)
       ) AS tuplas_espurias;

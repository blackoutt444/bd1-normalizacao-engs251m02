-- MySQL 8.0.16+ / 8.4. Prova estrita de igualdade de multiconjuntos.
-- Compara todas as colunas, inclusive ordem dos telefones e multiplicidades.
USE normalizacao_oficina;
SET SESSION group_concat_max_len = 4096;

CREATE OR REPLACE VIEW vw_telefones_reconstruidos AS
SELECT cpf_cliente,
       GROUP_CONCAT(telefone ORDER BY posicao SEPARATOR '; ') AS telefones
FROM cliente_telefone GROUP BY cpf_cliente;

CREATE OR REPLACE VIEW vw_planilha_reconstruida AS
SELECT os.num_os, os.data_os, v.placa, v.modelo, c.cpf_cliente, c.nome_cliente,
       t.telefones, s.cod_servico, s.descricao AS servico, s.preco_servico, i.horas
FROM item_os AS i
JOIN ordem_servico AS os ON os.num_os = i.num_os
JOIN veiculo AS v ON v.placa = os.placa
JOIN cliente AS c ON c.cpf_cliente = v.cpf_cliente
JOIN vw_telefones_reconstruidos AS t ON t.cpf_cliente = c.cpf_cliente
JOIN servico AS s ON s.cod_servico = i.cod_servico;

CREATE OR REPLACE VIEW vw_fnbc_reconstruida AS
SELECT om.num_os, m.especialidade, m.mecanico
FROM os_mecanico AS om JOIN mecanico AS m USING (mecanico);

CREATE OR REPLACE VIEW vw_4fn_reconstruida AS
SELECT mc.mecanico, mc.curso, mt.turno
FROM mecanico_curso AS mc JOIN mecanico_turno AS mt USING (mecanico);

-- Os textos sao convertidos para BINARY na comparacao: diferencas de
-- caixa, acentos ou bytes nao sao escondidas pela collation do banco.
-- As CTEs agrupam linhas iguais e contam sua multiplicidade.
WITH
o0_base AS (
  SELECT num_os, data_os, CAST(placa AS BINARY) AS placa, CAST(modelo AS BINARY) AS modelo, CAST(cpf_cliente AS BINARY) AS cpf_cliente, CAST(nome_cliente AS BINARY) AS nome_cliente, CAST(telefones AS BINARY) AS telefones, CAST(cod_servico AS BINARY) AS cod_servico, CAST(servico AS BINARY) AS servico, preco_servico, horas
  FROM planilha
),
o0 AS (
  SELECT num_os, data_os, placa, modelo, cpf_cliente, nome_cliente, telefones, cod_servico, servico, preco_servico, horas, COUNT(*) AS quantidade
  FROM o0_base
  GROUP BY num_os, data_os, placa, modelo, cpf_cliente, nome_cliente, telefones, cod_servico, servico, preco_servico, horas
),
r0_base AS (
  SELECT num_os, data_os, CAST(placa AS BINARY) AS placa, CAST(modelo AS BINARY) AS modelo, CAST(cpf_cliente AS BINARY) AS cpf_cliente, CAST(nome_cliente AS BINARY) AS nome_cliente, CAST(telefones AS BINARY) AS telefones, CAST(cod_servico AS BINARY) AS cod_servico, CAST(servico AS BINARY) AS servico, preco_servico, horas
  FROM vw_planilha_reconstruida
),
r0 AS (
  SELECT num_os, data_os, placa, modelo, cpf_cliente, nome_cliente, telefones, cod_servico, servico, preco_servico, horas, COUNT(*) AS quantidade
  FROM r0_base
  GROUP BY num_os, data_os, placa, modelo, cpf_cliente, nome_cliente, telefones, cod_servico, servico, preco_servico, horas
),
o1_base AS (
  SELECT num_os, CAST(especialidade AS BINARY) AS especialidade, CAST(mecanico AS BINARY) AS mecanico
  FROM planilha_fnbc
),
o1 AS (
  SELECT num_os, especialidade, mecanico, COUNT(*) AS quantidade
  FROM o1_base
  GROUP BY num_os, especialidade, mecanico
),
r1_base AS (
  SELECT num_os, CAST(especialidade AS BINARY) AS especialidade, CAST(mecanico AS BINARY) AS mecanico
  FROM vw_fnbc_reconstruida
),
r1 AS (
  SELECT num_os, especialidade, mecanico, COUNT(*) AS quantidade
  FROM r1_base
  GROUP BY num_os, especialidade, mecanico
),
o2_base AS (
  SELECT CAST(mecanico AS BINARY) AS mecanico, CAST(curso AS BINARY) AS curso, CAST(turno AS BINARY) AS turno
  FROM planilha_4fn
),
o2 AS (
  SELECT mecanico, curso, turno, COUNT(*) AS quantidade
  FROM o2_base
  GROUP BY mecanico, curso, turno
),
r2_base AS (
  SELECT CAST(mecanico AS BINARY) AS mecanico, CAST(curso AS BINARY) AS curso, CAST(turno AS BINARY) AS turno
  FROM vw_4fn_reconstruida
),
r2 AS (
  SELECT mecanico, curso, turno, COUNT(*) AS quantidade
  FROM r2_base
  GROUP BY mecanico, curso, turno
)
SELECT 'planilha' AS tabela,
  (SELECT COUNT(*) FROM planilha) AS linhas_original,
  (SELECT COUNT(*) FROM vw_planilha_reconstruida) AS linhas_reconstruida,
  (SELECT COALESCE(SUM(GREATEST(o.quantidade - COALESCE(r.quantidade, 0), 0)), 0)
   FROM o0 AS o LEFT JOIN r0 AS r ON o.num_os <=> r.num_os
      AND o.data_os <=> r.data_os
      AND o.placa <=> r.placa
      AND o.modelo <=> r.modelo
      AND o.cpf_cliente <=> r.cpf_cliente
      AND o.nome_cliente <=> r.nome_cliente
      AND o.telefones <=> r.telefones
      AND o.cod_servico <=> r.cod_servico
      AND o.servico <=> r.servico
      AND o.preco_servico <=> r.preco_servico
      AND o.horas <=> r.horas) AS faltando,
  (SELECT COALESCE(SUM(GREATEST(r.quantidade - COALESCE(o.quantidade, 0), 0)), 0)
   FROM r0 AS r LEFT JOIN o0 AS o ON o.num_os <=> r.num_os
      AND o.data_os <=> r.data_os
      AND o.placa <=> r.placa
      AND o.modelo <=> r.modelo
      AND o.cpf_cliente <=> r.cpf_cliente
      AND o.nome_cliente <=> r.nome_cliente
      AND o.telefones <=> r.telefones
      AND o.cod_servico <=> r.cod_servico
      AND o.servico <=> r.servico
      AND o.preco_servico <=> r.preco_servico
      AND o.horas <=> r.horas) AS sobrando
UNION ALL
SELECT 'planilha_fnbc' AS tabela,
  (SELECT COUNT(*) FROM planilha_fnbc) AS linhas_original,
  (SELECT COUNT(*) FROM vw_fnbc_reconstruida) AS linhas_reconstruida,
  (SELECT COALESCE(SUM(GREATEST(o.quantidade - COALESCE(r.quantidade, 0), 0)), 0)
   FROM o1 AS o LEFT JOIN r1 AS r ON o.num_os <=> r.num_os
      AND o.especialidade <=> r.especialidade
      AND o.mecanico <=> r.mecanico) AS faltando,
  (SELECT COALESCE(SUM(GREATEST(r.quantidade - COALESCE(o.quantidade, 0), 0)), 0)
   FROM r1 AS r LEFT JOIN o1 AS o ON o.num_os <=> r.num_os
      AND o.especialidade <=> r.especialidade
      AND o.mecanico <=> r.mecanico) AS sobrando
UNION ALL
SELECT 'planilha_4fn' AS tabela,
  (SELECT COUNT(*) FROM planilha_4fn) AS linhas_original,
  (SELECT COUNT(*) FROM vw_4fn_reconstruida) AS linhas_reconstruida,
  (SELECT COALESCE(SUM(GREATEST(o.quantidade - COALESCE(r.quantidade, 0), 0)), 0)
   FROM o2 AS o LEFT JOIN r2 AS r ON o.mecanico <=> r.mecanico
      AND o.curso <=> r.curso
      AND o.turno <=> r.turno) AS faltando,
  (SELECT COALESCE(SUM(GREATEST(r.quantidade - COALESCE(o.quantidade, 0), 0)), 0)
   FROM r2 AS r LEFT JOIN o2 AS o ON o.mecanico <=> r.mecanico
      AND o.curso <=> r.curso
      AND o.turno <=> r.turno) AS sobrando;

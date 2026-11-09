-- Resultados esperados: todas as quantidades de violacoes iguais a zero.
USE normalizacao_oficina;

SELECT 'chave_original_os_servico' AS regra, COUNT(*) AS violacoes
FROM (SELECT num_os, cod_servico FROM planilha
      GROUP BY num_os, cod_servico HAVING COUNT(*) > 1) AS d
UNION ALL
SELECT 'cliente_determina_nome_e_telefones', COUNT(*)
FROM (SELECT cpf_cliente FROM planilha GROUP BY cpf_cliente
      HAVING COUNT(DISTINCT nome_cliente) <> 1 OR COUNT(DISTINCT telefones) <> 1) AS d
UNION ALL
SELECT 'placa_determina_modelo_e_cliente', COUNT(*)
FROM (SELECT placa FROM planilha GROUP BY placa
      HAVING COUNT(DISTINCT modelo) <> 1 OR COUNT(DISTINCT cpf_cliente) <> 1) AS d
UNION ALL
SELECT 'os_determina_data_e_veiculo', COUNT(*)
FROM (SELECT num_os FROM planilha GROUP BY num_os
      HAVING COUNT(DISTINCT data_os) <> 1 OR COUNT(DISTINCT placa) <> 1) AS d
UNION ALL
SELECT 'servico_determina_descricao_e_preco', COUNT(*)
FROM (SELECT cod_servico FROM planilha GROUP BY cod_servico
      HAVING COUNT(DISTINCT servico) <> 1 OR COUNT(DISTINCT preco_servico) <> 1) AS d
UNION ALL
SELECT 'um_mecanico_por_os_e_especialidade', COUNT(*)
FROM (SELECT om.num_os, m.especialidade
      FROM os_mecanico AS om JOIN mecanico AS m USING (mecanico)
      GROUP BY om.num_os, m.especialidade HAVING COUNT(*) > 1) AS d
UNION ALL
SELECT 'mecanicos_da_4fn_sem_especialidade', COUNT(*)
FROM (SELECT DISTINCT p.mecanico FROM planilha_4fn AS p
      WHERE NOT EXISTS (SELECT 1 FROM mecanico AS m
                        WHERE m.mecanico = p.mecanico)) AS d;

-- Contagens finais, uteis para a apresentacao.
SELECT 'cliente' AS tabela, COUNT(*) AS linhas FROM cliente
UNION ALL SELECT 'cliente_telefone', COUNT(*) FROM cliente_telefone
UNION ALL SELECT 'veiculo', COUNT(*) FROM veiculo
UNION ALL SELECT 'ordem_servico', COUNT(*) FROM ordem_servico
UNION ALL SELECT 'servico', COUNT(*) FROM servico
UNION ALL SELECT 'item_os', COUNT(*) FROM item_os
UNION ALL SELECT 'mecanico', COUNT(*) FROM mecanico
UNION ALL SELECT 'os_mecanico', COUNT(*) FROM os_mecanico
UNION ALL SELECT 'mecanico_curso', COUNT(*) FROM mecanico_curso
UNION ALL SELECT 'mecanico_turno', COUNT(*) FROM mecanico_turno;

-- Desafio: decomposicao INCORRETA, apenas como consulta, sem alterar dados.
-- Projetar (OS, especialidade) e (especialidade, mecanico) perde a associacao
-- entre a OS e o seu mecanico. A juncao produz 10 linhas, 2 delas espurias.
WITH os_especialidade AS (
  SELECT DISTINCT num_os, especialidade FROM planilha_fnbc
), especialidade_mecanico AS (
  SELECT DISTINCT especialidade, mecanico FROM planilha_fnbc
), juncao_errada AS (
  SELECT oe.num_os, oe.especialidade, em.mecanico
  FROM os_especialidade AS oe
  JOIN especialidade_mecanico AS em USING (especialidade)
)
SELECT je.num_os, je.especialidade, je.mecanico
FROM juncao_errada AS je
WHERE NOT EXISTS (
  SELECT 1 FROM planilha_fnbc AS p
  WHERE p.num_os = je.num_os AND p.especialidade = je.especialidade
    AND p.mecanico = je.mecanico
)
ORDER BY je.num_os, je.mecanico;

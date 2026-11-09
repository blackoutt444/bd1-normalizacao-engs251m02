-- Toda carga e INSERT ... SELECT; nenhum dado de negocio e redigitado.
-- Executar uma vez, depois de 00 e 01, com as tabelas finais vazias.
USE normalizacao_oficina;

START TRANSACTION;

INSERT INTO cliente (cpf_cliente, nome_cliente)
SELECT DISTINCT cpf_cliente, nome_cliente FROM planilha;

-- A sequencia 1..100 e auxiliar para SUBSTRING_INDEX, nao dado de negocio.
-- A coluna original tem 60 caracteres, portanto 100 posicoes sao suficientes.
-- Guardar a posicao permite remontar a lista na ordem original.
INSERT INTO cliente_telefone (cpf_cliente, posicao, telefone)
SELECT DISTINCT p.cpf_cliente, n.posicao,
       TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(p.telefones, ';', n.posicao), ';', -1))
FROM planilha AS p
JOIN (
  SELECT 1 + unidades.n + 10 * dezenas.n AS posicao
  FROM (SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
        UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6
        UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) AS unidades
  CROSS JOIN (SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
        UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6
        UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) AS dezenas
) AS n ON n.posicao <= 1 + CHAR_LENGTH(p.telefones)
                                  - CHAR_LENGTH(REPLACE(p.telefones, ';', ''));

INSERT INTO veiculo (placa, modelo, cpf_cliente)
SELECT DISTINCT placa, modelo, cpf_cliente FROM planilha;

INSERT INTO ordem_servico (num_os, data_os, placa)
SELECT DISTINCT num_os, data_os, placa FROM planilha;

INSERT INTO servico (cod_servico, descricao, preco_servico)
SELECT DISTINCT cod_servico, servico, preco_servico FROM planilha;

INSERT INTO item_os (num_os, cod_servico, horas)
SELECT num_os, cod_servico, horas FROM planilha;

INSERT INTO mecanico (mecanico, especialidade)
SELECT DISTINCT mecanico, especialidade FROM planilha_fnbc;

INSERT INTO os_mecanico (num_os, mecanico)
SELECT num_os, mecanico FROM planilha_fnbc;

INSERT INTO mecanico_curso (mecanico, curso)
SELECT DISTINCT mecanico, curso FROM planilha_4fn;

INSERT INTO mecanico_turno (mecanico, turno)
SELECT DISTINCT mecanico, turno FROM planilha_4fn;

COMMIT;


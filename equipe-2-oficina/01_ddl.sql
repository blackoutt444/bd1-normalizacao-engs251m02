-- Modelo final: 3FN, FNBC e 4FN. Executar depois de 00_planilha.sql.
-- As tres tabelas originais permanecem intactas para a prova.
USE normalizacao_oficina;

CREATE TABLE cliente (
  cpf_cliente CHAR(14) NOT NULL,
  nome_cliente VARCHAR(60) NOT NULL,
  PRIMARY KEY (cpf_cliente)
) ENGINE=InnoDB;

CREATE TABLE cliente_telefone (
  cpf_cliente CHAR(14) NOT NULL,
  posicao TINYINT UNSIGNED NOT NULL,
  telefone VARCHAR(60) NOT NULL,
  PRIMARY KEY (cpf_cliente, posicao),
  UNIQUE KEY uk_cliente_telefone (cpf_cliente, telefone),
  CONSTRAINT ck_telefone_posicao CHECK (posicao > 0),
  CONSTRAINT ck_telefone_nao_vazio CHECK (CHAR_LENGTH(TRIM(telefone)) > 0),
  CONSTRAINT fk_telefone_cliente FOREIGN KEY (cpf_cliente)
    REFERENCES cliente (cpf_cliente)
) ENGINE=InnoDB;

CREATE TABLE veiculo (
  placa CHAR(7) NOT NULL,
  modelo VARCHAR(30) NOT NULL,
  cpf_cliente CHAR(14) NOT NULL,
  PRIMARY KEY (placa),
  CONSTRAINT fk_veiculo_cliente FOREIGN KEY (cpf_cliente)
    REFERENCES cliente (cpf_cliente)
) ENGINE=InnoDB;

CREATE TABLE ordem_servico (
  num_os INT NOT NULL,
  data_os DATE NOT NULL,
  placa CHAR(7) NOT NULL,
  PRIMARY KEY (num_os),
  CONSTRAINT fk_os_veiculo FOREIGN KEY (placa) REFERENCES veiculo (placa)
) ENGINE=InnoDB;

CREATE TABLE servico (
  cod_servico CHAR(2) NOT NULL,
  descricao VARCHAR(40) NOT NULL,
  preco_servico DECIMAL(8,2) NOT NULL,
  PRIMARY KEY (cod_servico),
  CONSTRAINT ck_preco_servico CHECK (preco_servico >= 0)
) ENGINE=InnoDB;

CREATE TABLE item_os (
  num_os INT NOT NULL,
  cod_servico CHAR(2) NOT NULL,
  horas DECIMAL(4,1) NOT NULL,
  PRIMARY KEY (num_os, cod_servico),
  CONSTRAINT ck_horas CHECK (horas > 0),
  CONSTRAINT fk_item_os FOREIGN KEY (num_os) REFERENCES ordem_servico (num_os),
  CONSTRAINT fk_item_servico FOREIGN KEY (cod_servico) REFERENCES servico (cod_servico)
) ENGINE=InnoDB;

-- FNBC: mecanico -> especialidade. O nome identifica o mecanico
-- apenas neste conjunto didatico; um sistema real usaria um identificador.
CREATE TABLE mecanico (
  mecanico VARCHAR(60) NOT NULL,
  especialidade VARCHAR(30) NOT NULL,
  PRIMARY KEY (mecanico)
) ENGINE=InnoDB;

CREATE TABLE os_mecanico (
  num_os INT NOT NULL,
  mecanico VARCHAR(60) NOT NULL,
  PRIMARY KEY (num_os, mecanico),
  CONSTRAINT fk_responsavel_os FOREIGN KEY (num_os) REFERENCES ordem_servico (num_os),
  CONSTRAINT fk_responsavel_mecanico FOREIGN KEY (mecanico) REFERENCES mecanico (mecanico)
) ENGINE=InnoDB;

-- 4FN: cursos e turnos sao fatos independentes sobre o mecanico.
CREATE TABLE mecanico_curso (
  mecanico VARCHAR(60) NOT NULL,
  curso VARCHAR(40) NOT NULL,
  PRIMARY KEY (mecanico, curso),
  CONSTRAINT fk_curso_mecanico FOREIGN KEY (mecanico) REFERENCES mecanico (mecanico)
) ENGINE=InnoDB;

CREATE TABLE mecanico_turno (
  mecanico VARCHAR(60) NOT NULL,
  turno VARCHAR(10) NOT NULL,
  PRIMARY KEY (mecanico, turno),
  CONSTRAINT fk_turno_mecanico FOREIGN KEY (mecanico) REFERENCES mecanico (mecanico)
) ENGINE=InnoDB;

-- A DF (num_os, especialidade) -> mecanico nao e preservada
-- localmente pela decomposicao em FNBC. PK/FK sozinhas nao a garantem.
-- O arquivo 04_validacoes.sql identifica violacoes dessa regra.


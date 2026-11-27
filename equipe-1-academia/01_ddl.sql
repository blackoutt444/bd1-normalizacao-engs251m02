-- Modelo normalizado: CREATE TABLE de todas as tabelas, com PK e FK
-- Equipe Academia (Equipe 1) - Academia FitMais
-- Testado no MySQL Community Server 8.4.13 (as restrições CHECK exigem MySQL 8.0.16 ou posterior).
-- Pré-requisito: rodar antes o 00_planilha.sql, que cria o banco e as três planilhas originais.
USE normalizacao_academia;

-- Permite rodar o DDL de novo sem apagar as planilhas originais (filhas primeiro, por causa das FKs).
DROP TABLE IF EXISTS instrutor_disponibilidade;
DROP TABLE IF EXISTS instrutor_certificacao;
DROP TABLE IF EXISTS aluno_instrutor;
DROP TABLE IF EXISTS instrutor;
DROP TABLE IF EXISTS matricula_aula;
DROP TABLE IF EXISTS aula_dia;
DROP TABLE IF EXISTS aula;
DROP TABLE IF EXISTS aluno_telefone;
DROP TABLE IF EXISTS aluno;
DROP TABLE IF EXISTS plano;

-- ============================================================
-- planilha -> 3FN
-- ============================================================

-- cod_plano -> nome_plano, valor_plano (dependência transitiva retirada de aluno)
CREATE TABLE plano (
  cod_plano   CHAR(2)       NOT NULL,
  nome_plano  VARCHAR(20)   NOT NULL,
  valor_plano DECIMAL(8,2)  NOT NULL,
  CONSTRAINT pk_plano PRIMARY KEY (cod_plano),
  CONSTRAINT uk_plano_nome UNIQUE (nome_plano),
  CONSTRAINT ck_plano_valor CHECK (valor_plano > 0)
);

-- matricula -> nome_aluno, cod_plano (dependência parcial retirada da planilha)
CREATE TABLE aluno (
  matricula  INT          NOT NULL,
  nome_aluno VARCHAR(60)  NOT NULL,
  cod_plano  CHAR(2)      NOT NULL,
  CONSTRAINT pk_aluno PRIMARY KEY (matricula),
  CONSTRAINT ck_aluno_matricula CHECK (matricula > 0),
  CONSTRAINT fk_aluno_plano FOREIGN KEY (cod_plano)
    REFERENCES plano (cod_plano) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- 1FN: o campo multivalorado "telefones" vira uma linha por telefone.
-- posicao guarda a ordem em que o telefone aparecia na célula original.
CREATE TABLE aluno_telefone (
  matricula INT               NOT NULL,
  posicao   TINYINT UNSIGNED  NOT NULL,
  telefone  VARCHAR(20)       NOT NULL,
  CONSTRAINT pk_aluno_telefone PRIMARY KEY (matricula, posicao),
  CONSTRAINT uk_aluno_telefone UNIQUE (matricula, telefone),
  CONSTRAINT ck_aluno_telefone_posicao CHECK (posicao >= 1),
  CONSTRAINT fk_aluno_telefone_aluno FOREIGN KEY (matricula)
    REFERENCES aluno (matricula) ON UPDATE CASCADE ON DELETE CASCADE
);

-- cod_aula -> nome_aula, horario, dias (dependência parcial retirada da planilha)
CREATE TABLE aula (
  cod_aula  CHAR(2)      NOT NULL,
  nome_aula VARCHAR(30)  NOT NULL,
  horario   TIME         NOT NULL,
  CONSTRAINT pk_aula PRIMARY KEY (cod_aula)
);

-- 1FN: o campo "dias" (ex.: Seg/Qua/Sex) também é uma lista; vira uma linha por dia.
CREATE TABLE aula_dia (
  cod_aula CHAR(2)           NOT NULL,
  posicao  TINYINT UNSIGNED  NOT NULL,
  dia      CHAR(3)           NOT NULL,
  CONSTRAINT pk_aula_dia PRIMARY KEY (cod_aula, posicao),
  CONSTRAINT uk_aula_dia UNIQUE (cod_aula, dia),
  CONSTRAINT ck_aula_dia_posicao CHECK (posicao >= 1),
  CONSTRAINT ck_aula_dia_dia CHECK (dia IN ('Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb')),
  CONSTRAINT fk_aula_dia_aula FOREIGN KEY (cod_aula)
    REFERENCES aula (cod_aula) ON UPDATE CASCADE ON DELETE CASCADE
);

-- O que sobra da chave (matricula, cod_aula): a matrícula do aluno em cada aula.
CREATE TABLE matricula_aula (
  matricula INT      NOT NULL,
  cod_aula  CHAR(2)  NOT NULL,
  CONSTRAINT pk_matricula_aula PRIMARY KEY (matricula, cod_aula),
  CONSTRAINT fk_matricula_aula_aluno FOREIGN KEY (matricula)
    REFERENCES aluno (matricula) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_matricula_aula_aula FOREIGN KEY (cod_aula)
    REFERENCES aula (cod_aula) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ============================================================
-- planilha_fnbc -> FNBC
-- ============================================================

-- instrutor -> modalidade (o determinante passa a ser chave).
-- modalidade aceita NULL só para instrutor que apareça na planilha_4fn sem modalidade informada.
CREATE TABLE instrutor (
  nome_instrutor VARCHAR(60)  NOT NULL,
  modalidade     VARCHAR(30)  NULL,
  CONSTRAINT pk_instrutor PRIMARY KEY (nome_instrutor)
);

-- (aluno, instrutor): a outra chave candidata da planilha_fnbc.
-- O aluno é identificado pela matrícula do cadastro de alunos (ver hipóteses no README).
CREATE TABLE aluno_instrutor (
  matricula      INT          NOT NULL,
  nome_instrutor VARCHAR(60)  NOT NULL,
  CONSTRAINT pk_aluno_instrutor PRIMARY KEY (matricula, nome_instrutor),
  CONSTRAINT fk_aluno_instrutor_aluno FOREIGN KEY (matricula)
    REFERENCES aluno (matricula) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_aluno_instrutor_instrutor FOREIGN KEY (nome_instrutor)
    REFERENCES instrutor (nome_instrutor) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ============================================================
-- planilha_4fn -> 4FN (as duas dependências multivaloradas em tabelas separadas)
-- ============================================================

-- instrutor ->> certificacao
CREATE TABLE instrutor_certificacao (
  nome_instrutor VARCHAR(60)  NOT NULL,
  certificacao   VARCHAR(40)  NOT NULL,
  CONSTRAINT pk_instrutor_certificacao PRIMARY KEY (nome_instrutor, certificacao),
  CONSTRAINT fk_instrutor_certificacao_instrutor FOREIGN KEY (nome_instrutor)
    REFERENCES instrutor (nome_instrutor) ON UPDATE CASCADE ON DELETE CASCADE
);

-- instrutor ->> dia_disponivel
CREATE TABLE instrutor_disponibilidade (
  nome_instrutor VARCHAR(60)  NOT NULL,
  dia_disponivel VARCHAR(10)  NOT NULL,
  CONSTRAINT pk_instrutor_disponibilidade PRIMARY KEY (nome_instrutor, dia_disponivel),
  CONSTRAINT ck_instrutor_disponibilidade_dia
    CHECK (dia_disponivel IN ('Domingo', 'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado')),
  CONSTRAINT fk_instrutor_disponibilidade_instrutor FOREIGN KEY (nome_instrutor)
    REFERENCES instrutor (nome_instrutor) ON UPDATE CASCADE ON DELETE CASCADE
);

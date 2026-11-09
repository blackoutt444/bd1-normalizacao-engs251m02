# Dicionário de dados — Oficina AutoCerto

Todas as colunas finais são NOT NULL. PKs compostas usam os atributos assinalados na mesma tabela. As FKs usam comportamento restritivo padrão de InnoDB; não há DELETE em cascata. Tamanhos de CHAR/VARCHAR são em caracteres; DECIMAL indica precisão e escala.

## cliente

Cadastro independente de clientes.

| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição | Restrição / domínio |
| --- | --- | --- | --- | --- | --- | --- |
| cpf_cliente | CHAR | 14 | Não | PK | Identificador do cliente no exercício | Formato fornecido na origem; único. |
| nome_cliente | VARCHAR | 60 | Não |  | Nome do cliente | Dependente somente do CPF. |

## cliente_telefone

Uma ocorrência de telefone por cliente; a posição preserva a ordem da lista original.

| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição | Restrição / domínio |
| --- | --- | --- | --- | --- | --- | --- |
| cpf_cliente | CHAR | 14 | Não | PK, FK → cliente(cpf_cliente) | Titular do telefone | Cliente deve existir. |
| posicao | TINYINT UNSIGNED | 1 byte | Não | PK | Ordem do número na lista original | Maior que zero. |
| telefone | VARCHAR | 60 | Não | UK com cpf_cliente | Número de telefone | Não vazio após TRIM; par CPF/telefone único. |

## veiculo

Veículo e seu dono no recorte do enunciado.

| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição | Restrição / domínio |
| --- | --- | --- | --- | --- | --- | --- |
| placa | CHAR | 7 | Não | PK | Placa do veículo | Única; formato do conjunto fornecido. |
| modelo | VARCHAR | 30 | Não |  | Modelo do veículo | Determinado pela placa. |
| cpf_cliente | CHAR | 14 | Não | FK → cliente(cpf_cliente) | Dono do veículo | Cliente deve existir. |

## ordem_servico

Cabeçalho da ordem de serviço.

| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição | Restrição / domínio |
| --- | --- | --- | --- | --- | --- | --- |
| num_os | INT | 4 bytes | Não | PK | Identificador da OS | Único. |
| data_os | DATE | 3 bytes | Não |  | Data da OS | Data válida no MySQL. |
| placa | CHAR | 7 | Não | FK → veiculo(placa) | Veículo atendido | Exatamente um veículo por OS. |

## servico

Catálogo de serviços, com o preço do cenário.

| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição | Restrição / domínio |
| --- | --- | --- | --- | --- | --- | --- |
| cod_servico | CHAR | 2 | Não | PK | Código do serviço | Único. |
| descricao | VARCHAR | 40 | Não |  | Descrição; corresponde à coluna original servico | Determinada pelo código. |
| preco_servico | DECIMAL | 8,2 | Não |  | Preço de catálogo em reais | Maior ou igual a zero; decimal exato. |

## item_os

Execução de um serviço em uma OS.

| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição | Restrição / domínio |
| --- | --- | --- | --- | --- | --- | --- |
| num_os | INT | 4 bytes | Não | PK, FK → ordem_servico(num_os) | OS da execução | OS deve existir. |
| cod_servico | CHAR | 2 | Não | PK, FK → servico(cod_servico) | Serviço executado | Serviço deve existir; um registro por serviço/OS. |
| horas | DECIMAL | 4,1 | Não |  | Duração da execução em horas | Maior que zero; depende da chave completa. |

## mecanico

Projeção em FNBC: cada mecânico determina uma especialidade.

| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição | Restrição / domínio |
| --- | --- | --- | --- | --- | --- | --- |
| mecanico | VARCHAR | 60 | Não | PK | Nome identificador no conjunto didático | Não pressupõe que nomes sejam identificadores adequados em produção. |
| especialidade | VARCHAR | 30 | Não |  | Especialidade do mecânico | Uma por mecânico; vários mecânicos podem compartilhar a especialidade. |

## os_mecanico

Associação entre OS e mecânico; projeção em FNBC.

| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição | Restrição / domínio |
| --- | --- | --- | --- | --- | --- | --- |
| num_os | INT | 4 bytes | Não | PK, FK → ordem_servico(num_os) | OS atendida | OS deve existir. |
| mecanico | VARCHAR | 60 | Não | PK, FK → mecanico(mecanico) | Responsável | Mecânico deve existir; a regra por especialidade exige validação adicional. |

## mecanico_curso

Fato independente em 4FN: cursos de um mecânico.

| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição | Restrição / domínio |
| --- | --- | --- | --- | --- | --- | --- |
| mecanico | VARCHAR | 60 | Não | PK, FK → mecanico(mecanico) | Titular do curso | Mecânico deve existir. |
| curso | VARCHAR | 40 | Não | PK | Curso realizado | Não duplica o mesmo curso para o mesmo mecânico. |

## mecanico_turno

Fato independente em 4FN: turnos de trabalho.

| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição | Restrição / domínio |
| --- | --- | --- | --- | --- | --- | --- |
| mecanico | VARCHAR | 60 | Não | PK, FK → mecanico(mecanico) | Mecânico escalado | Mecânico deve existir. |
| turno | VARCHAR | 10 | Não | PK | Turno de trabalho | Não duplica o mesmo turno para o mesmo mecânico. |

## Regra entre relações

A DF `(num_os, especialidade) → mecanico` não é uma restrição declarativa local de `os_mecanico`. `04_validacoes.sql` detecta suas violações. O README explica por que uma decomposição em FNBC pode ter junção sem perda e, ainda assim, não preservar todas as dependências funcionais.

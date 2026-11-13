# Equipe 1: Academia FitMais

**Nome do time:** Equipe Academia

| Nome | Usuário do GitHub |
| --- | --- |
| Pedro Vale de Lima Bezerra | [@blackoutt444](https://github.com/blackoutt444) |
| Eduardo | A confirmar |
| Jonhonatan | A confirmar |
| Quarto integrante (nome a confirmar) | A confirmar |

## O cenário

O sistema da Academia FitMais hoje é uma planilha. Rode o `00_planilha.sql` no MySQL: ele cria o banco `normalizacao_academia` com 3 tabelas que reproduzem a planilha (também em `planilha.xlsx`).

| Tabela | O que guarda |
| --- | --- |
| `planilha` | Cada linha é a matrícula de um aluno em uma aula. Um aluno tem um plano e pode ter mais de um telefone. |
| `planilha_fnbc` | Regra: em cada modalidade, o aluno tem um único instrutor; cada instrutor ensina uma única modalidade. |
| `planilha_4fn` | Cada instrutor tem várias certificações e vários dias disponíveis, que não têm relação entre si. |

> Apague as instruções entre colchetes e preencha cada seção.

## 1. Anomalias

[Usando linhas reais da `planilha`, dê um exemplo de cada anomalia.]

| Anomalia | Exemplo na planilha |
| --- | --- |
| Inserção |  |
| Exclusão |  |
| Modificação |  |

## 2. Dependências funcionais da `planilha`

| Determinante | Determina | Tipo (total, parcial ou transitiva) |
| --- | --- | --- |
|  |  |  |

**Chave primária da `planilha`:** [ ]

## 3. Normalização passo a passo

**1FN:** [o que não era atômico e como ficou]

**2FN:** [quais dependências parciais e como ficou]

**3FN:** [quais dependências transitivas e como ficou]

**Esquema final em 3FN:** [Tabela(atributos), com PK sublinhada ou em negrito e FK indicada]

## 4. FNBC: `planilha_fnbc`

- Chaves candidatas: [ ]
- Dependência que viola a FNBC: [ ]
- Decomposição: [ ]

## 5. 4FN: `planilha_4fn`

- Dependências multivaloradas: [ ]
- Decomposição: [ ]

## 6. Modelagem

### 6.1 Modelo conceitual (Peter Chen)

[Entidades, atributos (identificador sublinhado; multivalorado com elipse dupla), relacionamentos com nome e cardinalidade (mín, máx).]

![Modelo conceitual](modelo_conceitual.png)

### 6.2 Modelo lógico (James Martin, pé de galinha)

[Todas as tabelas finais com seus atributos, PK e FK, e as linhas de relacionamento com a cardinalidade nas pontas.]

![Modelo lógico](modelo_logico.png)

## 7. Dicionário de dados

Preencha o arquivo [`dicionario_dados.md`](dicionario_dados.md) com **todas** as tabelas finais.

## 8. Prova de junção sem perda

[Cole aqui o resultado do `03_prova_sem_perda.sql`: para cada planilha, linhas da original, linhas da reconstruída, faltando = 0 e sobrando = 0.]

```
(cole o resultado)
```

## 9. Desafio: uma decomposição errada

[Mostre uma decomposição da `planilha_fnbc` que **perde** informação: as duas tabelas, a consulta de junção e quantas linhas falsas (tuplas espúrias) ela gera.]

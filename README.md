# Trabalho Final de Normalização: da planilha ao banco

**Disciplina:** Banco de Dados I (ENGS251M02)  
**Equipes:** 4, uma por cenário  
**Entrega e apresentação:** 27/11/2026

equipe academia
eduardo baçal
Jonhonatan uchoa
Pedro vale
Daniel Villar
## O trabalho

Cada equipe recebe uma planilha mal montada de um sistema real e precisa transformá-la em um banco de dados normalizado no MySQL, **sem perder nenhum dado**.

| Equipe | Cenário | Pasta |
| --- | --- | --- |
| 1 | Academia FitMais | [equipe-1-academia](equipe-1-academia/) |
| 2 | Oficina AutoCerto | [equipe-2-oficina](equipe-2-oficina/) |
| 3 | Biblioteca Saber | [equipe-3-biblioteca](equipe-3-biblioteca/) |
| 4 | Semana de Tecnologia | [equipe-4-eventos](equipe-4-eventos/) |

Cada pasta tem 3 planilhas, como tabelas do MySQL:

| Tabela | Conteúdo da aula |
| --- | --- |
| `planilha` | 1FN, 2FN e 3FN: campo multivalorado, dependências parciais e transitivas |
| `planilha_fnbc` | FNBC: duas chaves candidatas que se sobrepõem |
| `planilha_4fn` | 4FN: fatos independentes misturados na mesma tabela |

## Etapas

1. **Carregar:** rode o `00_planilha.sql` da sua pasta no MySQL.
2. **Analisar:** no `README.md` da pasta, aponte as anomalias e as dependências funcionais.
3. **Normalizar:** leve a `planilha` até a 3FN, a `planilha_fnbc` até a FNBC e a `planilha_4fn` até a 4FN.
4. **Modelar:** desenhe o modelo conceitual em **Peter Chen** (`modelo_conceitual.png`) e o modelo lógico em **James Martin**, o pé de galinha (`modelo_logico.png`).
5. **Documentar:** preencha o `dicionario_dados.md` com todas as tabelas finais: tipo, tamanho, nulo, chave, descrição e restrições.
6. **Criar:** escreva o `01_ddl.sql` com todas as tabelas, PKs e FKs.
7. **Migrar:** escreva o `02_migracao.sql`, que copia os dados das planilhas para as tabelas novas usando **somente** `INSERT ... SELECT`. Não vale digitar os dados de novo.
8. **Provar:** escreva o `03_prova_sem_perda.sql`. Para cada planilha, uma consulta com JOIN remonta a planilha original a partir das tabelas novas e compara com ela.

Ferramentas sugeridas para os diagramas: brModelo (conceitual e lógico), draw.io ou MySQL Workbench (lógico, pelo *Reverse Engineer* do banco criado).

## A prova de junção sem perda

A decomposição está certa quando a junção das tabelas novas devolve **exatamente** a planilha original: o mesmo número de linhas, nenhuma faltando e nenhuma sobrando (sem tuplas espúrias). O formato esperado do resultado é:

| tabela | linhas_original | linhas_reconstruida | faltando | sobrando |
| --- | --- | --- | --- | --- |
| planilha | 12 | 12 | 0 | 0 |

Dicas para a prova:
- Para remontar o campo multivalorado, use `GROUP_CONCAT(... ORDER BY ... SEPARATOR '; ')`.
- Para contar o que falta, use `NOT EXISTS` comparando todas as colunas.
- Para separar o campo multivalorado na migração, use `SUBSTRING_INDEX`.

## Como entregar

1. **Um integrante** clica em **Fork** e depois em **Create fork**.
2. No fork, em **Settings → Collaborators → Add people**, ele adiciona os colegas.
3. No README da **pasta da sua equipe**, preencham o nome do time e os integrantes.
4. Trabalhem **somente na pasta da sua equipe**. Cada integrante faz pelo menos **3 commits**.
5. Até **27/11**, abram o **Pull Request**: **Contribute → Open pull request**, com o título `Equipe N – Cenário`.

⚠️ Não editem o repositório do professor nem a pasta de outra equipe.

## Apresentação (27/11)

1. A planilha original e as anomalias encontradas.
2. A normalização até a 3FN, a FNBC e a 4FN.
3. Os modelos conceitual e lógico e o dicionário de dados.
4. Ao vivo: rodar o DDL, a migração e a prova de junção sem perda.

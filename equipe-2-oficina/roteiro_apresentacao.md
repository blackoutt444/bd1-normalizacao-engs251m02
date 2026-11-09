# Roteiro de apresentação — Oficina AutoCerto

## 1. Problema e chave — cerca de 1 minuto

Mostre as nove linhas originais. Explique que uma linha é um serviço em uma OS, identificado por `(num_os, cod_servico)`. Use Marcos Reis para mostrar repetição e a OS 5002 para mostrar a anomalia de exclusão.

## 2. Primeira à terceira forma normal — cerca de 2 minutos

Mostre o campo de telefones com dois valores. Explique a tabela de telefones e a posição que preserva a ordem. Separe os fatos da OS, do serviço e da execução; use S3 e S4 para demonstrar que as horas não dependem só do serviço. Depois siga a cadeia OS → veículo → cliente e mostre onde as dependências transitivas foram eliminadas.

## 3. FNBC e 4FN — cerca de 2 minutos

Escreva as duas chaves candidatas da relação OS/especialidade/mecânico. Explique `mecanico → especialidade` e a decomposição correta. Mostre as duas tuplas falsas que aparecem se o JOIN errado for feito por especialidade. Diga explicitamente que a DF por OS/especialidade não é preservada só por PK/FK e mostre a consulta de validação.

Em seguida, use Carlos: dois cursos × dois turnos = quatro combinações independentes. Explique por que as duas projeções em 4FN remontam os dados sem inventar combinações, sob a regra de independência do enunciado.

## 4. Modelos e dicionário — cerca de 1 minuto

Abra `modelo_conceitual.png` e reconheça retângulos, losangos, identificadores sublinhados e elipses duplas. Abra `modelo_logico.png` e percorra PKs, FKs e cardinalidades das dez tabelas. Consulte o dicionário para explicar DECIMAL, NOT NULL e as restrições.

## 5. Demonstração ao vivo — cerca de 2 minutos

Numa instância destinada ao exercício, execute `00_planilha.sql` (ele recria o banco de demonstração), depois `01_ddl.sql`, `02_migracao.sql`, `03_prova_sem_perda.sql` e `04_validacoes.sql`.

O resultado principal precisa ser: planilha 9/9/0/0, FNBC 8/8/0/0 e 4FN 8/8/0/0. Explique que comparar apenas o número de linhas seria insuficiente: por isso a prova compara todas as colunas e suas multiplicidades.

## Perguntas para ensaiar

- Por que `horas` fica em `item_os`?
- Por que a especialidade não pode ser a chave de `mecanico`?
- Qual interseção garante a junção sem perda na decomposição em FNBC?
- Por que cursos e turnos podem ser separados, mas curso e nota de uma avaliação não poderiam ser separados da mesma forma?
- Qual regra precisa de validação adicional após a decomposição em FNBC?
- Como a prova detecta uma alteração mesmo que a contagem continue nove contra nove?

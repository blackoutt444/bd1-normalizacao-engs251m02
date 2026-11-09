# Validacao executada

**Motor real:** MySQL Community Server 8.4.13.

**Ambiente:** instancia descartavel, porta 33307, dados isolados da instalacao do usuario.

| tabela | linhas_original | linhas_reconstruida | faltando | sobrando |
| --- | ---: | ---: | ---: | ---: |
| planilha | 9 | 9 | 0 | 0 |
| planilha_fnbc | 8 | 8 | 0 | 0 |
| planilha_4fn | 8 | 8 | 0 | 0 |

## Verificacoes

- PASSOU: Reconstrucao exata das 3 planilhas: 9/9, 8/8 e 8/8; zero faltando e zero sobrando.
- PASSOU: Dependencias e referencias fornecidas validas; contagem das 10 tabelas conferida.
- PASSOU: Decomposicao errada: exatamente 2 tuplas espurias (5002/Freios/Gabriel e 5004/Freios/Igor).
- PASSOU: PK impede item duplicado.
- PASSOU: FK impede item de OS inexistente.
- PASSOU: CHECK impede horas nao positivas.
- PASSOU: CHECK impede preco negativo.
- PASSOU: UK impede telefone repetido do mesmo cliente.
- PASSOU: Prova detecta exclusao de um item.
- PASSOU: Prova detecta uma linha extra.
- PASSOU: Prova detecta alteracao de horas com contagem de linhas igual.
- PASSOU: Prova compara textos com diferenca de caixa, independentemente da collation.
- PASSOU: Prova detecta a ordem trocada dos telefones.
- PASSOU: Prova considera multiplicidade de linhas duplicadas na fonte.
- PASSOU: Diagnostico identifica a DF nao preservada pela FNBC; PK/FK sozinhas nao a impõem.
- PASSOU: Todas as mutacoes foram desfeitas; o banco terminou no estado correto.

As verificacoes de defeitos sao testes locais com ROLLBACK. Nao alteram os dados finais nem a atividade no Classroom.

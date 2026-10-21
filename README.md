# Desnormalização: quando a redundância compensa

Artigo técnico + back end de demonstração (Modelagem de Banco de Dados, Braz Cubas).

- **Página:** ([URL da Vercel](https://projectblog.vercel.app/?utm_source=chatgpt.com))
- **Autores:** (Felipe Carvalho Pereira, Maria Queiroz, João Pedro Forastieri)
- **SGBD:** PostgreSQL 17 (Supabase)

## Estrutura
- `index.html`, `css/`: página estática (hoje, console de teste da API).
- `01_modelo_normalizado.sql`: tabelas clientes, produtos, pedidos, itens_pedido + dados fictícios.
- `02_tabela_achatada_gatilhos.sql`: `vendas_flat`, gatilhos de sincronização, coluna derivada e visão materializada
- `03_api_e_seguranca.sql`: RLS somente leitura e funções RPC.
- `style.css`: Estilização da página web.

## Rodar os scripts do zero
Em um Postgres 15+ limpo (ou no SQL Editor do Supabase), execute `01`, `02` e `03` nesta ordem.

## API (Supabase RPC)
`POST https://awfdhtcajfxpljypupjr.supabase.co/rest/v1/rpc/<função>` com header `apikey`.

| Função | O que mostra |
|---|---|
| `comparar_consultas()` | tempo e plano de execução: 3 JOINs vs tabela achatada |
| `verificar_consistencia()` | divergências entre a redundância e a fonte da verdade |
| `demo_custo_atualizacao(p_produto_id)` | custo de escrita: 1 linha normalizada vs N linhas achatadas (revertido) |
| `resumo_mensal()` | leitura da visão materializada |

## Segurança
Tabelas com RLS e apenas `SELECT` público. A chave publishable pode ficar no front end. Nunca publique a `service_role`.

## Créditos
Dados fictícios gerados por `generate_series`. Referências:

CODD, E. F. A relational model of data for large shared data banks. Communications of the ACM, New York, v. 13, n. 6, p. 377–387, jun. 1970. Disponível em: https://doi.org/10.1145/362384.362685. Acesso em: 20 out. 2026.
POSTGRESQL GLOBAL DEVELOPMENT GROUP. PostgreSQL 17 Documentation: CREATE MATERIALIZED VIEW. Disponível em: https://www.postgresql.org/docs/17/sql-creatematerializedview.html. Acesso em: 20 out. 2026.
POSTGRESQL GLOBAL DEVELOPMENT GROUP. PostgreSQL 17 Documentation: Materialized Views. Disponível em: https://www.postgresql.org/docs/17/rules-materializedviews.html. Acesso em: 20 out. 2026.
POSTGRESQL GLOBAL DEVELOPMENT GROUP. PostgreSQL 17 Documentation: Trigger Functions (PL/pgSQL). Disponível em: https://www.postgresql.org/docs/17/plpgsql-trigger.html. Acesso em: 20 out. 2026.
POSTGRESQL GLOBAL DEVELOPMENT GROUP. PostgreSQL 17 Documentation: Using EXPLAIN. Disponível em: https://www.postgresql.org/docs/17/using-explain.html. Acesso em: 20 out. 2026.
WIKIPEDIA. Denormalization. Disponível em: https://en.wikipedia.org/wiki/Denormalization. Acesso em: 20 out. 2026.


## Quadro de observação

O grupo analisou duas referências técnicas e registrou
as principais decisões tomadas durante o desenvolvimento.

Consulte o [Quadro de Observação](QUADRO_OBSERVACÃO.md).


## Licença

O código-fonte deste projeto está disponível sob a Licença MIT.

Copyright (c) 2026 Felipe Carvalho Pereira, Maria Queiroz e João Pedro Forastieri.

Consulte o arquivo [LICENSE](LICENSE) para mais informações.

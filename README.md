# Desnormalização: quando a redundância compensa

Artigo técnico + back end de demonstração (Modelagem de Banco de Dados, Braz Cubas).

- **Página:** (URL da Vercel)
- **Autores:** (nomes e perfis, com autorização de cada integrante)
- **SGBD:** PostgreSQL 17 (Supabase)

## Estrutura
- `index.html`, `css/`: página estática (hoje, console de teste da API)
- `sql/01_modelo_normalizado.sql`: tabelas clientes, produtos, pedidos, itens_pedido + dados fictícios
- `sql/02_tabela_achatada_gatilhos.sql`: `vendas_flat`, gatilhos de sincronização, coluna derivada e visão materializada
- `sql/03_api_e_seguranca.sql`: RLS somente leitura e funções RPC

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
Dados fictícios gerados por `generate_series`. Referências: (preencher).

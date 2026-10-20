-- PostgreSQL 17 (Supabase). Dados 100% fictícios.
-- Modelo normalizado (OLTP): clientes, produtos, pedidos, itens_pedido
create table public.clientes (
  id bigint generated always as identity primary key,
  nome text not null,
  cidade text not null,
  estado char(2) not null
);
create table public.produtos (
  id bigint generated always as identity primary key,
  nome text not null,
  categoria text not null,
  preco_centavos integer not null check (preco_centavos > 0)
);
create table public.pedidos (
  id bigint generated always as identity primary key,
  cliente_id bigint not null references public.clientes(id),
  data_pedido date not null,
  total_centavos bigint not null default 0  -- coluna derivada (desnormalização)
);
create table public.itens_pedido (
  id bigint generated always as identity primary key,
  pedido_id bigint not null references public.pedidos(id) on delete cascade,
  produto_id bigint not null references public.produtos(id),
  quantidade integer not null check (quantidade > 0),
  preco_unit_centavos integer not null check (preco_unit_centavos > 0)
);
create index idx_pedidos_cliente on public.pedidos(cliente_id);
create index idx_itens_pedido on public.itens_pedido(pedido_id);
create index idx_itens_produto on public.itens_pedido(produto_id);

-- Dados de exemplo: 500 clientes, 60 produtos, 30 mil pedidos, 75 mil itens
insert into public.clientes (nome, cidade, estado)
select (array['Ana','Bruno','Carla','Diego','Elisa','Fábio','Gabriela','Hugo','Isabela','João'])[1 + (n % 10)]
       || ' ' || (array['Silva','Souza','Lima','Costa','Pereira','Alves','Rocha','Dias'])[1 + ((n / 10) % 8)],
       (array['São Paulo','Rio de Janeiro','Belo Horizonte','Curitiba','Porto Alegre','Salvador','Recife','Fortaleza'])[1 + (n % 8)],
       (array['SP','RJ','MG','PR','RS','BA','PE','CE'])[1 + (n % 8)]
from generate_series(1, 500) n;

insert into public.produtos (nome, categoria, preco_centavos)
select cat || ' modelo ' || lpad(n::text, 3, '0'), cat, 1990 + (n * 937) % 48000
from (select n, (array['Eletrônicos','Livros','Casa','Esporte','Papelaria','Games'])[1 + (n % 6)] as cat
      from generate_series(1, 60) n) s;

insert into public.pedidos (cliente_id, data_pedido)
select 1 + floor(random() * 500)::int, date '2025-01-01' + floor(random() * 650)::int
from generate_series(1, 30000);

insert into public.itens_pedido (pedido_id, produto_id, quantidade, preco_unit_centavos)
select s.pedido_id, s.produto_id, s.qtd, pr.preco_centavos
from (select pe.id as pedido_id,
             1 + floor(random() * 60)::int as produto_id,
             1 + floor(random() * 3)::int as qtd
      from public.pedidos pe
      cross join lateral generate_series(1, 1 + (pe.id % 4)::int) g) s
join public.produtos pr on pr.id = s.produto_id;

update public.pedidos p set total_centavos = t.total
from (select pedido_id, sum(quantidade::bigint * preco_unit_centavos) as total
      from public.itens_pedido group by pedido_id) t
where t.pedido_id = p.id;

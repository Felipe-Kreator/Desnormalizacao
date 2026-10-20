-- Desnormalização: tabela achatada, gatilhos de sincronização e visão materializada
create table public.vendas_flat (
  item_id bigint primary key,
  pedido_id bigint not null,
  data_pedido date not null,
  cliente_id bigint not null,
  cliente_nome text not null,
  cidade text not null,
  estado char(2) not null,
  produto_id bigint not null,
  produto_nome text not null,
  categoria text not null,
  quantidade integer not null,
  preco_unit_centavos integer not null,
  valor_total_centavos bigint not null
);

insert into public.vendas_flat
select i.id, pe.id, pe.data_pedido, c.id, c.nome, c.cidade, c.estado,
       pr.id, pr.nome, pr.categoria, i.quantidade, i.preco_unit_centavos,
       i.quantidade::bigint * i.preco_unit_centavos
from public.itens_pedido i
join public.pedidos pe on pe.id = i.pedido_id
join public.clientes c on c.id = pe.cliente_id
join public.produtos pr on pr.id = i.produto_id;

create index idx_flat_cidade_cat on public.vendas_flat(cidade, categoria);
create index idx_flat_data on public.vendas_flat(data_pedido);
create index idx_flat_produto on public.vendas_flat(produto_id);
create index idx_flat_cliente on public.vendas_flat(cliente_id);
create index idx_flat_pedido on public.vendas_flat(pedido_id);

-- 1) coluna derivada: total do pedido
create function public.fn_recalcula_total_pedido() returns trigger
language plpgsql set search_path = public as $$
declare v_pedido bigint := coalesce(new.pedido_id, old.pedido_id);
begin
  update pedidos
     set total_centavos = coalesce((select sum(quantidade::bigint * preco_unit_centavos)
                                    from itens_pedido where pedido_id = v_pedido), 0)
   where id = v_pedido;
  return null;
end $$;
create trigger trg_total_pedido
after insert or update or delete on public.itens_pedido
for each row execute function public.fn_recalcula_total_pedido();

-- 2) itens -> tabela achatada
create function public.fn_sync_flat_item() returns trigger
language plpgsql set search_path = public as $$
begin
  if tg_op in ('UPDATE','DELETE') then
    delete from vendas_flat where item_id = old.id;
  end if;
  if tg_op in ('INSERT','UPDATE') then
    insert into vendas_flat
    select i.id, pe.id, pe.data_pedido, c.id, c.nome, c.cidade, c.estado,
           pr.id, pr.nome, pr.categoria, i.quantidade, i.preco_unit_centavos,
           i.quantidade::bigint * i.preco_unit_centavos
    from itens_pedido i
    join pedidos pe on pe.id = i.pedido_id
    join clientes c on c.id = pe.cliente_id
    join produtos pr on pr.id = i.produto_id
    where i.id = new.id;
  end if;
  return null;
end $$;
create trigger trg_flat_item
after insert or update or delete on public.itens_pedido
for each row execute function public.fn_sync_flat_item();

-- 3) dimensões -> tabela achatada (o custo da redundância)
create function public.fn_sync_flat_produto() returns trigger
language plpgsql set search_path = public as $$
begin
  update vendas_flat set produto_nome = new.nome, categoria = new.categoria
   where produto_id = new.id;
  return null;
end $$;
create trigger trg_flat_produto
after update of nome, categoria on public.produtos
for each row execute function public.fn_sync_flat_produto();

create function public.fn_sync_flat_cliente() returns trigger
language plpgsql set search_path = public as $$
begin
  update vendas_flat set cliente_nome = new.nome, cidade = new.cidade, estado = new.estado
   where cliente_id = new.id;
  return null;
end $$;
create trigger trg_flat_cliente
after update of nome, cidade, estado on public.clientes
for each row execute function public.fn_sync_flat_cliente();

create function public.fn_sync_flat_pedido() returns trigger
language plpgsql set search_path = public as $$
begin
  update vendas_flat f
     set data_pedido = new.data_pedido, cliente_id = c.id,
         cliente_nome = c.nome, cidade = c.cidade, estado = c.estado
    from clientes c
   where f.pedido_id = new.id and c.id = new.cliente_id;
  return null;
end $$;
create trigger trg_flat_pedido
after update of data_pedido, cliente_id on public.pedidos
for each row execute function public.fn_sync_flat_pedido();

-- 4) visão materializada (pré-agregação)
create materialized view public.resumo_vendas_mensal as
select date_trunc('month', data_pedido)::date as mes,
       categoria,
       count(distinct pedido_id) as pedidos,
       sum(quantidade) as unidades,
       sum(valor_total_centavos) as receita_centavos
from public.vendas_flat
group by 1, 2;
create unique index idx_resumo_mes_cat on public.resumo_vendas_mensal(mes, categoria);

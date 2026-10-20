-- Segurança: leitura pública, nenhuma escrita direta
alter table public.clientes enable row level security;
alter table public.produtos enable row level security;
alter table public.pedidos enable row level security;
alter table public.itens_pedido enable row level security;
alter table public.vendas_flat enable row level security;

create policy leitura_publica on public.clientes for select to anon, authenticated using (true);
create policy leitura_publica on public.produtos for select to anon, authenticated using (true);
create policy leitura_publica on public.pedidos for select to anon, authenticated using (true);
create policy leitura_publica on public.itens_pedido for select to anon, authenticated using (true);
create policy leitura_publica on public.vendas_flat for select to anon, authenticated using (true);

revoke all on public.clientes, public.produtos, public.pedidos, public.itens_pedido, public.vendas_flat from anon, authenticated;
grant select on public.clientes, public.produtos, public.pedidos, public.itens_pedido, public.vendas_flat to anon, authenticated;
revoke all on public.resumo_vendas_mensal from anon, authenticated;

revoke execute on function public.fn_recalcula_total_pedido(), public.fn_sync_flat_item(),
  public.fn_sync_flat_produto(), public.fn_sync_flat_cliente(), public.fn_sync_flat_pedido() from public, anon, authenticated;

-- RPC 1: compara plano e tempo das duas consultas
create function public.comparar_consultas()
returns table(variante text, consulta text, tempo_ms numeric, plano jsonb)
language plpgsql set search_path = public as $$
declare q_norm text; q_flat text; p jsonb;
begin
  q_norm := 'select c.cidade, pr.categoria, sum(i.quantidade::bigint * i.preco_unit_centavos) as receita_centavos
from itens_pedido i
join pedidos pe on pe.id = i.pedido_id
join clientes c on c.id = pe.cliente_id
join produtos pr on pr.id = i.produto_id
group by 1, 2';
  q_flat := 'select cidade, categoria, sum(valor_total_centavos) as receita_centavos
from vendas_flat
group by 1, 2';

  execute 'explain (analyze, format json) ' || q_norm into p;
  variante := 'normalizado (4 tabelas, 3 JOINs)'; consulta := q_norm;
  tempo_ms := (p->0->>'Execution Time')::numeric; plano := p; return next;

  execute 'explain (analyze, format json) ' || q_flat into p;
  variante := 'achatado (1 tabela, sem JOIN)'; consulta := q_flat;
  tempo_ms := (p->0->>'Execution Time')::numeric; plano := p; return next;
end $$;

-- RPC 2: confere se a redundância continua consistente
create function public.verificar_consistencia()
returns table(verificacao text, divergencias bigint)
language sql stable set search_path = public as $$
  select 'itens sem linha na tabela achatada', count(*)
    from itens_pedido i left join vendas_flat f on f.item_id = i.id where f.item_id is null
  union all
  select 'nome de produto divergente', count(*)
    from vendas_flat f join produtos p on p.id = f.produto_id where f.produto_nome <> p.nome
  union all
  select 'cidade de cliente divergente', count(*)
    from vendas_flat f join clientes c on c.id = f.cliente_id where f.cidade <> c.cidade
  union all
  select 'total de pedido divergente', count(*)
    from pedidos pe
    where pe.total_centavos <> coalesce((select sum(quantidade::bigint * preco_unit_centavos)
                                         from itens_pedido where pedido_id = pe.id), 0);
$$;

-- RPC 3: custo de escrita da redundância (a alteração é desfeita no fim)
create function public.demo_custo_atualizacao(p_produto_id bigint default 1)
returns table(linhas_normalizado integer, linhas_achatada bigint, tempo_ms numeric)
language plpgsql security definer set search_path = public as $$
declare t0 timestamptz; t1 timestamptz; v_flat bigint := 0; v_existe boolean;
begin
  select exists(select 1 from produtos where id = p_produto_id) into v_existe;
  if not v_existe then return; end if;
  begin
    t0 := clock_timestamp();
    update produtos set nome = nome || ' (renomeado)' where id = p_produto_id;
    t1 := clock_timestamp();
    select count(*) into v_flat from vendas_flat
     where produto_id = p_produto_id and produto_nome like '%(renomeado)';
    raise exception 'desfazer_demo' using errcode = 'P0001';
  exception when raise_exception then
    null;  -- subtransação revertida: nada muda de verdade
  end;
  linhas_normalizado := 1;
  linhas_achatada := v_flat;
  tempo_ms := round((extract(epoch from (t1 - t0)) * 1000)::numeric, 3);
  return next;
end $$;

-- RPC 4: leitura da visão materializada
create function public.resumo_mensal()
returns setof public.resumo_vendas_mensal
language sql security definer set search_path = public as $$
  select * from resumo_vendas_mensal order by mes, categoria;
$$;

-- RPC 5: atualização manual do resumo (somente service_role)
create function public.atualizar_resumo() returns void
language sql security definer set search_path = public as $$
  refresh materialized view concurrently public.resumo_vendas_mensal;
$$;

revoke execute on function public.comparar_consultas(), public.verificar_consistencia(),
  public.demo_custo_atualizacao(bigint), public.resumo_mensal(), public.atualizar_resumo() from public;
grant execute on function public.comparar_consultas(), public.verificar_consistencia(),
  public.demo_custo_atualizacao(bigint), public.resumo_mensal() to anon, authenticated;
grant execute on function public.atualizar_resumo() to service_role;

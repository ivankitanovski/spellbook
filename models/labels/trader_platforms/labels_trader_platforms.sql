{{
    config(
        alias='trader_platforms',
        post_hook='{{ expose_spells(\'
        ["ethereum", "fantom", "arbitrum", "avalanche_c", "gnosis", "bnb", "optimism", "polygon"]\', 
        "sector", 
        "labels", 
        \'["gentrexha", "Henrystats"]\') }}'
    )
}}

with
 trader_platforms as (
    select
        taker as address,
        MIN(block_time) as first_trade,
        COUNT(*) as num_txs, -- to optimize query 
        project,
        blockchain
    from (
        select blockchain, taker, project, block_time
        from {{ ref('dex_aggregator_trades') }}
        UNION ALL
        select blockchain, taker, project, block_time
        from {{ ref('dex_trades') }}
    )
    group by taker, project, blockchain 
    order by first_trade
 )

select
  array(blockchain) as blockchain,
  address,
  array_join(array_distinct(collect_list(concat(upper(substring(project,1,1)),substring(project,2)))), ', ') ||' User' as name,
  "trader_platforms" AS category,
  "gentrexha" AS contributor,
  "query" AS source,
  timestamp('2022-12-21') as created_at,
  now() as updated_at
from
  trader_platforms
where address is not null
group by address, blockchain 
; 

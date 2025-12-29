{{ config(materialized='table') }}

select distinct
    coin,
    split_part(coin, 'USDT', 1)        as base_asset,
    'USDT'                              as quote_asset, 
    'spot'                              as market_type,
    true                                as is_active,
    current_timestamp                   as created_at,
    interval
    current_timestamp                   as created_at
from {{ ref('fact_1h_klines') }}

{{ config(materialized='table') }}

select distinct
    coin,
    split_part(coin, 'USDT', 1)        as base_asset,
    'USDT'                              as quote_asset, 
    'spot'                              as market_type,
    true                                as is_active,
<<<<<<< HEAD
    current_timestamp                   as created_at,
    interval
=======
    current_timestamp                   as created_at
>>>>>>> d2337f45e5b73ec0fc2d9635bd2b953643fc4642
from {{ ref('fact_1h_klines') }}

{{ config(
    materialized='incremental',
    unique_key=['coin', 'open_timestamp'],
    on_schema_change='sync_all_columns'
) }}

-- 1️⃣ Base fact table
with base as (
    select * 
    from {{ ref('fact_1h_klines') }}
),

-- 2️⃣ Incremental staging with buffer
staged as (
    select * 
    from {{ ref('stage_binance_klines') }}
    {% if is_incremental() %}
    where open_timestamp > (
        select coalesce(
            max(open_timestamp) - interval '23 hour',
            '2000-01-01'::timestamp_ntz
        )
        from {{ this }}
    )
    {% endif %}
),

-- 3️⃣ Deduplicate (latest ingestion wins)
deduped as (
    select *
    from (
        select *,
            row_number() over (
                partition by coin, open_timestamp
                order by ingestion_timestamp desc
            ) as rn
        from staged
    )
    where rn = 1
),

-- 4️⃣ Compute previous close for each coin
returns as (
    select 
        coin,
        open_timestamp,
        close_price,
        lag(close_price) over (
            partition by coin 
            order by open_timestamp
        ) as prev_close
    from deduped
),

-- 5️⃣ Compute percentage return and log return
returns_calc as (
    select 
        *,
        (close_price - prev_close) / prev_close as return_pct,
        ln(close_price / prev_close) as log_return
    from returns
),

-- 6️⃣ Compute rolling volatility
volatility as (
    select 
        *,
        stddev(return_pct) over (
            partition by coin 
            order by open_timestamp 
            rows between 23 preceding and current row
        ) as rolling_vol_24h
    from returns_calc
),

-- 7️⃣ Compute volatility regime
volatility_reg as (
    select 
        *,
        CASE
            WHEN rolling_vol_24h > 1.5 * avg(rolling_vol_24h) OVER (
                PARTITION BY coin 
                ORDER BY open_timestamp 
                ROWS BETWEEN 23 PRECEDING AND CURRENT ROW
            ) THEN 'High'
            WHEN rolling_vol_24h > avg(rolling_vol_24h) OVER (
                PARTITION BY coin 
                ORDER BY open_timestamp 
                ROWS BETWEEN 23 PRECEDING AND CURRENT ROW
            ) THEN 'Medium'
            ELSE 'Low'
        END AS volatility_regime
    from volatility
)

select *
from volatility_reg

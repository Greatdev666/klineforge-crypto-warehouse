{{
    config(
        materialized='incremental',
        unique_key=['coin', 'open_timestamp'],
        incremental_strategy='merge',
        on_schema_change='sync_all_columns'
    )
}}

with

{% if is_incremental() %}
-- 1️⃣ Per-coin watermarks (ONLY during incremental runs)
coin_watermarks as (
    select
        coin,
        max(open_timestamp) as max_open_timestamp
    from {{ this }}
    group by coin
),
{% endif %}

-- 2️⃣ Read staging data
staged as (
    select *
    from {{ ref('stage_binance_klines') }}
),

-- 3️⃣ Filter new rows (coin-aware)
filtered as (
    select
        s.*
    from staged s
    {% if is_incremental() %}
    left join coin_watermarks w
        on s.coin = w.coin
    where
        w.coin is null                 -- brand-new coin
        or s.open_timestamp > w.max_open_timestamp
    {% endif %}
),

-- 4️⃣ Deduplicate (latest ingestion wins)
deduped as (
    select *
    from (
        select
            *,
            row_number() over (
                partition by coin, open_timestamp
                order by ingestion_timestamp desc
            ) as rn
        from filtered
    )
    where rn = 1
)

select *
from deduped

{{ config(
    materialized='incremental',
    unique_key=['coin', 'open_timestamp'],
    on_schema_change='sync_all_columns'
) }}

WITH base AS (
    SELECT
        coin,
        open_timestamp,
        return_pct,
        log_return,
        rolling_vol_24h
    FROM {{ ref('mart_returns_1h') }}
),

-- 1️⃣ Compute average volume over last 24h (we only have rolling_vol_24h, so it's ready)
volume_stats AS (
    SELECT
        *,
        -- Volume spike ratio
        rolling_vol_24h / NULLIF(AVG(rolling_vol_24h) OVER (
            PARTITION BY coin ORDER BY open_timestamp ROWS BETWEEN 23 PRECEDING AND CURRENT ROW
        ), 0) AS volume_spike_ratio
    FROM base
),

-- 2️⃣ Rank movers using absolute return * volume spike
top_movers AS (
    SELECT
        coin,
        open_timestamp,
        return_pct,
        log_return,
        rolling_vol_24h,
        volume_spike_ratio,
        abs(return_pct) * volume_spike_ratio AS mover_signal
    FROM volume_stats
)

SELECT *
FROM top_movers

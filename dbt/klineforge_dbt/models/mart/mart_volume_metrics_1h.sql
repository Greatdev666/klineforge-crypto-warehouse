{{ config(
    materialized='incremental',
    unique_key=['coin', 'open_timestamp'],
    on_schema_change='sync_all_columns'
) }}
WITH base AS (

    -- 1️⃣ Read clean hourly candles
    SELECT
        coin,
        open_timestamp,
        close_price,
        volume
    FROM {{ ref('fact_1h_klines') }}

),
-- 2️⃣ Compute rolling volume metrics
volume_stats AS (
    SELECT *,
         -- Rolling 24h total volume
        SUM(volume) OVER(PARTITION BY coin ORDER BY open_timestamp ROWS BETWEEN 23 PRECEDING AND CURRENT ROW) AS rolling_volume_24h,
         -- Rolling 24h average volume
         AVG(volume) OVER( PARTITION BY coin ORDER BY open_timestamp ROWS BETWEEN 23 PRECEDING AND CURRENT ROW) AS avg_volume_24h
    FROM base
),
-- 3️⃣ Detect volume spikes 
volume_spikes AS (
    SELECT 
        *,
        -- Volume spike ratio
        volume / NULLIF(avg_volume_24h, 0) AS volume_spike_ratio,
        -- Simple spike flag
        CASE 
            WHEN volume > avg_volume_24h * 2 THEN TRUE
            ELSE FALSE
        END volume_stats 
    FROM volume_stats
),
-- 4️⃣ VWAP calculation (rolling)
vwap_calc AS (
    SELECT 
        *,
        -- Rolling WVAP (price weighted by volume)
        SUM(close_price * volume) OVER(PARTITION BY coin ORDER BY open_timestamp ROWS BETWEEN 23 PRECEDING AND CURRENT ROW) / 
        NULLIF(SUM(volume) OVER(PARTITION BY coin ORDER BY open_timestamp ROWS BETWEEN 23 PRECEDING AND CURRENT ROW), 0)  AS vwap_24h
    FROM volume_spikes
)

SELECT * FROM vwap_calc
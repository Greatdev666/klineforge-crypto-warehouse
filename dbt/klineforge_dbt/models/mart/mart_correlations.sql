{{ config(
    materialized='incremental',
    unique_key=['base_coin', 'related_coin', 'open_timestamp'],
    on_schema_change='sync_all_columns'
) }}

WITH returns AS (
    SELECT
        coin,
        open_timestamp,
        return_pct
    FROM {{ ref('mart_returns_1h') }}
    {% if is_incremental() %}
    WHERE open_timestamp >= (
        SELECT max(open_timestamp) - interval '23 hour'
        FROM {{ this }}
    )
    {% endif %}
),

paired AS (
    SELECT 
        r1.coin AS base_coin,
        r2.coin AS related_coin,
        r1.open_timestamp,
        r1.return_pct AS base_return,
        r2.return_pct AS related_return
    FROM returns r1
    JOIN returns r2
      ON r1.open_timestamp = r2.open_timestamp
     AND r1.coin < r2.coin
),

rolling_stats AS (
    SELECT
        base_coin,
        related_coin,
        open_timestamp,

        avg(base_return) OVER (
            PARTITION BY base_coin, related_coin
            ORDER BY open_timestamp
            ROWS BETWEEN 23 PRECEDING AND CURRENT ROW
        ) AS avg_x,

        avg(related_return) OVER (
            PARTITION BY base_coin, related_coin
            ORDER BY open_timestamp
            ROWS BETWEEN 23 PRECEDING AND CURRENT ROW
        ) AS avg_y,

        avg(base_return * related_return) OVER (
            PARTITION BY base_coin, related_coin
            ORDER BY open_timestamp
            ROWS BETWEEN 23 PRECEDING AND CURRENT ROW
        ) AS avg_xy,

        avg(base_return * base_return) OVER (
            PARTITION BY base_coin, related_coin
            ORDER BY open_timestamp
            ROWS BETWEEN 23 PRECEDING AND CURRENT ROW
        ) AS avg_x2,

        avg(related_return * related_return) OVER (
            PARTITION BY base_coin, related_coin
            ORDER BY open_timestamp
            ROWS BETWEEN 23 PRECEDING AND CURRENT ROW
        ) AS avg_y2

    FROM paired
),
corr_24hs AS (
    SELECT
        base_coin,
        related_coin,
        open_timestamp,

        (avg_xy - avg_x * avg_y)
        /
        NULLIF(sqrt(
            (avg_x2 - avg_x * avg_x)
            *
            (avg_y2 - avg_y * avg_y)
        ), 0) AS corr_24h
    FROM rolling_stats
),
corr_regime AS (
    SELECT *,
        CASE
            WHEN abs(corr_24h) >= 0.8 THEN 'High'
            WHEN abs(corr_24h) >= 0.5 THEN 'Medium' 
            WHEN abs(corr_24h) >= 0.3 THEN 'Low'
            ELSE 'Uncorrelated'
        END AS correlation_regime,
        CASE 
            WHEN abs(corr_24h - lag(corr_24h) 
            OVER(PARTITION BY base_coin, related_coin ORDER BY open_timestamp)) > 0.5 THEN TRUE
            ELSE FALSE
        END AS corr_breakdown_alerts
    FROM corr_24hs
)
SELECT * FROM corr_regime
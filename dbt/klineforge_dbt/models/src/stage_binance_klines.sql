WITH staged_table AS(
    SELECT * FROM {{ source('bronze', 'kline') }}
)

SELECT 
    coin,
    interval,
    {{ safe_ts_from_epoch('open_time') }} as open_timestamp,
    open as open_price,
    high as high_price,
    low as low_price,
    close as close_price,
    volume,
    {{ safe_ts_from_epoch('close_time') }} as close_timestamp,
    quote_volume,
    taker_buy_base,
    taker_buy_quote,
    count,
    {{ safe_ingestion_ts('ingestion_ts') }} as ingestion_timestamp


FROM staged_table
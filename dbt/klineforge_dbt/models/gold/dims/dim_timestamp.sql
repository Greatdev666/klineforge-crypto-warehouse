{{ config(materialized='table') }}

with base as (
    select distinct
        open_timestamp as ts
    from {{ ref('fact_1h_klines') }}
)

select
    ts,
    date(ts)                        as date,
    extract(hour from ts)           as hour,
    extract(day from ts)            as day,
    extract(month from ts)          as month,
    extract(year from ts)           as year,
    extract(dow from ts)            as day_of_week,
    dayname(ts)                     as day_name,
    week(ts)                        as week,
    extract(dow from ts) in (0,6) as is_weekend,

    -- Trading sessions (UTC-based)
    case when hour between 0 and 7 then true else false end  as asia_session,
    case when hour between 7 and 15 then true else false end as eu_session,
    case when hour between 13 and 20 then true else false end as us_session

from base

{% macro safe_ts_from_epoch(col) %}
    case
        -- seconds
        when {{ col }} between 946684800 and 4102444800
        then to_timestamp_ntz({{ col }})

        -- milliseconds
        when {{ col }} between 946684800000 and 4102444800000
        then to_timestamp_ntz({{ col }} / 1000)

        -- microseconds (Binance daily data)
        when {{ col }} between 946684800000000 and 4102444800000000
        then to_timestamp_ntz({{ col }} / 1000000)

        else null
    end
{% endmacro %}






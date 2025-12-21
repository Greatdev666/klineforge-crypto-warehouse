{% macro safe_ingestion_ts(col) %}
    case
        when {{ col }} is not null
             and {{ col }} >= '2000-01-01'
             and {{ col }} <= current_timestamp
        then {{ col }}
        else current_timestamp
    end
{% endmacro %}

"""
To add a daily schedule that materializes your dbt assets, uncomment the following lines.
"""
from dagster import ScheduleDefinition, define_asset_job, AssetSelection
from .assets import binance_klines_daily, klineforge_dbt_dbt_assets

# Job that runs ingestion + dbt
daily_crypto_job = define_asset_job(
    name="daily_crypto_pipeline",
    selection=(
        AssetSelection.keys("binance_klines_daily")
        | AssetSelection.assets(klineforge_dbt_dbt_assets)
    ),
)
daily_schedule = ScheduleDefinition(
    job=daily_crypto_job,
    cron_schedule="24 12 * * *",
)
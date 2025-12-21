from dagster import Definitions
from dagster_dbt import DbtCliResource
from .assets import klineforge_dbt_dbt_assets, binance_klines_daily
from .project import klineforge_dbt_project
from .schedules import daily_schedule

defs = Definitions(
    assets=[klineforge_dbt_dbt_assets, binance_klines_daily],
    schedules=[daily_schedule],
    resources={
        "dbt": DbtCliResource(project_dir=klineforge_dbt_project),
    },
)
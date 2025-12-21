from dagster import asset, AssetExecutionContext
from dagster_dbt import DbtCliResource, dbt_assets
from .project import klineforge_dbt_project
import sys
from pathlib import Path

# =====================================================
# Make project root importable (for src/)
# =====================================================
PROJECT_ROOT = Path(__file__).resolve().parents[2]
if str(PROJECT_ROOT) not in sys.path:
    sys.path.append(str(PROJECT_ROOT))


# =====================================================
# Import ingestion logic
# =====================================================
from src.ingestion.klines_ingest import run_ingestion

# =====================================================
# 1️⃣ Binance ingestion asset (landing layer)
# =====================================================
@asset(
    name="binance_klines_daily",
    description="Ingests Binance klines data into Snowflake landing table"
)
def binance_klines_daily(context: AssetExecutionContext):
    context.log.info("Starting Binance klines ingestion")
    run_ingestion()
    context.log.info("Binance klines ingestion completed")

# =====================================================
# 2️⃣ dbt assets (bronze → silver → gold)
# =====================================================
@dbt_assets(
    manifest=klineforge_dbt_project.manifest_path
)
def klineforge_dbt_dbt_assets(
    context: AssetExecutionContext,
    dbt: DbtCliResource
):
    yield from dbt.cli(["build"], context=context).stream()

from pathlib import Path

from dagster_dbt import DbtProject

klineforge_dbt_project = DbtProject(
    project_dir=Path(__file__).joinpath("..", "..", "..", "dbt", "klineforge_dbt").resolve(),
    packaged_project_dir=Path(__file__).joinpath("..", "..", "dbt-project").resolve(),
)
klineforge_dbt_project.prepare_if_dev()
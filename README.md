# KlineForge – Crypto Analytics Data Warehouse
KlineForge is a production-grade crypto analytics warehouse that transforms raw Binance klines into trustable, pre-aggregated analytics ready for BI, risk analysis, and exploration.

[![GitHub stars](https://img.shields.io/github/stars/Greatdev666/klineforge-crypto-warehouse?style=social)](https://github.com/Greatdev666/klineforge-crypto-warehouse/stargazers)
[![dbt version](https://img.shields.io/badge/dbt-1.5+-orange)](https://getdbt.com)
[![Snowflake](https://img.shields.io/badge/Snowflake-blue)](https://snowflake.com)
[![Dagster](https://img.shields.io/badge/Dagster-1.8+-purple)](https://dagster.io)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
------------
## Architecture Overview

![Architecture Diagram](https://github.com/Greatdev666/klineforge-crypto-warehouse/blob/main/pipeline_Architecture_Diagrams/Screenshots/KlineForge_Overview_Medallion_Architecture_Diagram.png)

#### The pipeline follows a medallion architecture: 
 * *Ingestion* (Python) → *Bronze* (raw stage table) → *Silver* (fact_1h_klines) → *Gold* (dim_coins, dim_timestamp) → *Marts* (returns, volume, top movers, correlations) → BI / Analytics(Power BI - upcoming).

### Dagster Live Lineage (Bronze → Silver → Gold)

![Dagster Live Lineage](https://github.com/Greatdev666/klineforge-crypto-warehouse/blob/main/pipeline_Architecture_Diagrams/Screenshots/Dagster_live_lineage.png)

* Orchestrated by Dagster (daily at 7 AM UTC) with GitHub Actions CI/CD for testing on push.
---

## Dashboard Preview (2 of 5)

![coin_deep_dive](https://github.com/Greatdev666/klineforge-crypto-warehouse/blob/main/dashboards/screeshots/Coin_Deep_Dive.png)

![investment_simulator](https://github.com/Greatdev666/klineforge-crypto-warehouse/blob/main/dashboards/screeshots/Investment_Simulator.png)

* Full live dashboard live: [klineforge Crypto Dashboard Live](https://github.com/Greatdev666/klineforge-crypto-warehouse/releases/download/dashboards/klineforge_crypto.pbix)
* Dashboard pdf: [Klineforge Crypto Dashboard PDF](https://github.com/Greatdev666/klineforge-crypto-warehouse/releases/download/dashboards/klineforge_crypto.pdf)


## Project Overview

KlineForge is an end-to-end crypto analytics data platform designed to ingest, transform, and model high‑frequency cryptocurrency market data into analytics‑ready datasets. The project focuses on **robust incremental ingestion,** **cost‑efficient transformations,** and **pre‑aggregated analytical marts** suitable for risk metrics, quantitative analysis and BI consumption

The pipeline is designed with **production-grade data engineering principles**: incremental processing, idempotency, cost-aware modeling, orchestrating workflows with Dagster, testing, and CI/CD.

---

## Project Mission & Objectives

**Aim:**
KlineForge transforms raw Binance spot kline data into a production-ready analytics platform. Our mission is to empower traders—from beginners to degens—with actionable insights that go beyond basic charts, providing a trusted foundation for risk management, opportunity detection, and portfolio diversification through modern ELT practices.

**Technical Objectives:**

​To achieve this vision, the platform is engineered to:
* ​Robust Ingestion: Safely ingest large volumes of historical and incremental kline data with crash-safe, resumable checkpoints.
* ​Data Integrity: Standardize, cleanse, and deduplicate time-series data to ensure "Gold-standard" accuracy.
* ​Advanced Modeling: Architect analytics-ready Fact, Dimension, and Mart tables using a Medallion architecture.
* ​Optimization: Utilize dbt and Snowflake/BigQuery to optimize transformations for both performance and cost-efficiency.
* ​Reliable Orchestration: Schedule and monitor end-to-end pipelines using Dagster to ensure data freshness.
* ​Enable Intelligence: Provide the clean data layer necessary for downstream BI (Power BI/Streamlit) and quantitative strategy development.

  ---


    ## Tech Stack

    | Layer               | Tool               | Purpose                                 |
    | ------------------- | ------------------ | --------------------------------------- |
    | Data Source         | Binance API        | Raw market (kline) data                 |
    | Ingestion           | Python             | Incremental, checkpoint-based ingestion |
    | Data Warehouse      | Snowflake          | Storage & analytics engine              |
    | Transformation      | dbt (SQL + Jinja)  | Modeling, testing, documentation        |
    | Orchestration       | Dagster            | Asset-based orchestration & scheduling  |
    | CI/CD               | GitHub Actions     | Automated dbt testing & builds          |
    | Visualization       | Power BI | Analytics & dashboards                  |
    | Architecture Design | Draw.io            | System architecture diagrams            |
    | Development         | VS Code            | Local development environment           |
    | Assistance          | ChatGPT            | Design, debugging, documentation        |

    ---

## Data Layers & Modeling Strategy

### Bronze Layer – Raw Ingestion

**Purpose:**
Store raw Binance kline data with minimal transformation.

**Key Characteristics:**

* Append-only ingestion
* Historical backfill for new coins
* Raw epoch timestamps
* Ingestion metadata
* No business logic applied

**Key Tables:**

* `binance_klines_daily`
* `binance_ingestion_checkpoints`

#### Ingestion Design

* Incremental ingestion per coin
* Checkpoint table tracks last successfully ingested timestamp per coin
* Idempotent design allows safe re-runs

**Generated Columns:**

* `coin`
* `interval`
* `ingestion_ts`

**Challenges And Solutions:**  
- Slow sequential downloads (10+ hours) — Solution: Batched 60 days + parallelized with ThreadPoolExecutor.  
- Partial ingestion due to day/hour grain mismatch — Solution: Hour-level checkpoints + recent re-ingestion.  
- Discoveries: Binance data has epoch in milliseconds; needed to handle microseconds for future-proofing.
---

### Silver Layer – Staging & Standardization

**Purpose:**
Clean, normalize, and standardize raw data before analytics.

**Key Transformations:**

* Epoch → standard timestamp conversion
* Timezone consistency (UTC)
* Deduplication using ingestion timestamp
* Column renaming & typing

**Key Table:**

* `stage_binance_klines`

**Deduplication Logic:**

```sql
row_number() over (
  partition by coin, open_timestamp
  order by ingestion_ts desc
)
```

---

### Gold Layer – Core Fact & Dimensions

#### Fact Table: `fact_1h_klines`

**Grain:**
`coin, open_timestamp`

**Why 1-Hour Fact:**

* Canonical time grain for downstream analytics
* Single source of truth for price & volume metrics

**Incremental Strategy:**

* Coin-aware incremental logic
* Per-coin watermarks
* Historical backfill for new coins
* Append-only for existing coins

---

### Dimensions

#### `dim_coins`

* Coin metadata
* Symbol normalization

#### `dim_timestamp`

**Why this dimension exists:**
Binance provides raw UTC epochs; analytics require rich temporal context.

**Attributes:**

* date, hour, day, month, year
* day_of_week, day_name
* week_of_year
* is_weekend
* Asia / EU / US trading sessions

**Design Note:**
Trading sessions are analytical constructs derived from UTC hours and belong in a dimension, not facts.

---

## Analytical Marts

Marts are built **on top of the fact table**, not raw data, to:

* Reduce repeated heavy computations
* Lower warehouse cost
* Improve BI performance

---

### Mart: Returns (1h) – `mart_returns_1h`

**Purpose:**
Price-based performance and risk analytics.

**Key Metrics:**

* Close price
* Previous close
* Return %: `(close - prev_close) / prev_close * 100` — Profit/loss.  
* Log return: `ln(close / prev_close)` — For compounding.  
* Rolling volatility (24h): `stddev(return_pct) over 24 hours` — Risk measure.
* Volatility regime: High/Medium/Low based on avg thresholds — Alerts shifts.

**Why:**
Provides core metrics required for trading strategies and portfolio analysis. Spots trends; traders avoid high volatility.

**Challenges:** Rolling windows in incremental mode — Solution: 23-hour buffer. 


---

### Mart: Volume Metrics (1h) – `mart_volume_metrics_1h`

**Purpose:**
Liquidity and activity analysis.

**Key Metrics:**

* Volume
* Rolling volume (24h): `sum(volume) over 24 hours` — Trends.  
* Volume spike ratio: `rolling_volume / avg_volume` — Flags surges.  
* VWAP (24h): `sum(quote_volume) / sum(volume)` — True paid price.  

**Why:** Separates noise from real moves; high spikes signal interest.

**Challenges:** Duplicates inflated volume — Solution: Dedup in fact layer. 

**Why built on returns mart:**
Uses pre-aggregated metrics to reduce compute and simplify joins.

---

### Mart: Top Movers – `mart_top_movers`

**Purpose:**
Opportunity scanner.

**Key Metrics:**

* Return %
* Log return
* Rolling volatility
* Volume spike ratio
* Mover signal: `abs(return_pct) * volume_spike_ratio` — Ranks by impact.  

---

### Mart: Correlations (1h) – `mart_correlations_1h`

**Purpose:**
Cross-asset relationship, Risk & diversification analysis.

**Key Metrics:**

* 24h correlation: `(avg_xy - avg_x * avg_y) / sqrt((avg_x2 - avg_x^2) * (avg_y2 - avg_y^2))` — Pearson rolling.  
* Correlation regime: High/Medium/Low (abs(corr) thresholds) — Diversification check.  
* Correlation breakdown alerts: `abs(current_corr - prev_corr) > 0.5` — Sudden shifts.  

**Key Challenges Solved:**

* Manual rolling correlation (Snowflake-compatible)
* Canonical coin-pair ordering
* Strict timestamp alignment
* Incremental scalability

---

## Analytics & Dashboards

KlineForge includes a fully documented analytics suite built on top of curated warehouse models.

The dashboards translate raw crypto market data into:
- Market regime awareness
- Asset-level behavioral insights
- Cross-asset risk visibility
- Investment outcome simulation

All metrics are pre-computed in dbt marts to ensure:
- Consistency across views
- Fast query performance
- Transparent business logic

📊 Dashboard documentation and exports can be found in the [`/dashboards`](./dashboards) directory.


## Orchestration – Dagster

**Why Dagster:**

* Asset-based orchestration
* Native dbt integration
* Clear lineage & observability

**Responsibilities:**

* Schedule ingestion (daily)
* Trigger dbt assets
* Monitor failures & retries

---

## CI/CD

**Tool:** GitHub Actions

**Pipeline Capabilities:**
* Python installation and setup
* dbt deps
* dbt build
* Isolated CI schemas
* Secrets-based authentication

Ensures transformations remain correct before deployment.

---
## Data Grain

- Fact tables: 1 row per (coin, open_timestamp)
- Dimensions: One row per entity (coin, timestamp)
- Marts: Derived at the same hourly grain

---

## Data Quality & Testing

Implemented using dbt `schema.yml`:

* Not null tests
* Unique constraints
* Accepted values
* Relationship tests 

Ensures trust in analytical outputs.

---

## Analytics & Dashboards

KlineForge includes a fully documented analytics suite built on top of curated warehouse models.

The dashboards translate raw crypto market data into:
- Market regime awareness
- Asset-level behavioral insights
- Cross-asset risk visibility
- Investment outcome simulation

All metrics are pre-computed in dbt marts to ensure:
- Consistency across views
- Fast query performance
- Transparent business logic

📊 Dashboard documentation and exports can be found in the [`/dashboards`](./dashboards) directory.

---

## Performance Optimizations

* Replaced correlated subqueries with joins
* Precomputed watermarks for incremental models
* Built marts on facts instead of raw data
* Reduced repeated window function usage

---

## Key Challenges & Learnings

* Incremental pipelines must be **entity-aware**
* Epoch timestamps require careful handling (ms vs µs)
* Deduplication is mandatory for idempotency
* Grain alignment (hour vs day) is critical
* Pre-aggregation saves cost and compute



---
## Running the Project Locally

1. Clone the repository
2. Set up Python virtual environment
3. Configure Snowflake credentials in `profiles.yml`
4. Run ingestion:
   python src/ingestion/klines_ingest.py
5. Run dbt:
   dbt deps
   dbt build
6. Start Dagster:
   dagster dev


---

## Future Enhancements (v2)

* Airbyte for ingestion
*Multi-source (Binance + Bybit, OKX, Others ..) with dim_exchange for unified marts.
* Migration to BigQuery Sandbox: Free, permanent public access.
* Streamlit analytics app: Live/near-real-time view 
* WebSocket ingestion: Switch to per-hour/minute for fresher data without overloading sandbox.
* Advanced alerting

---

## Collaboration & Networking

​This project is an open ecosystem designed for collaboration. I am actively looking for partners to help bridge the gap between Data Engineering and Market Intelligence.

Feel free to reach out for:

* ​Data Engineering: Discussions on pipeline optimization, Airbyte connectors, and medallion architecture.
* ​Analytics Engineering: Feedback on dbt modeling, testing frameworks, and data quality standards.
* Data Analysis: I am looking for analysts to build compelling visualizations and exploratory reports. If you want to practice building crypto dashboards in Power BI, Tableau, or Streamlit using high-quality, pre-modeled marts, let's connect.
* ​Crypto Use-Cases: Sharing alpha on new exchanges, coins, or on-chain data sources.
* ​Machine Learning (ML): I am providing a feature-rich, clean data foundation (Gold Marts). If you are looking for a high-integrity dataset for time-series forecasting, volatility prediction, or sentiment analysis, let’s collaborate to build predictive models on top of this warehouse.

**"Rome wasn't built in a day but we are laying bricks every hour"**

---

## Author

**Built by Muhammad Bashir (Delex), Dec 2025**

Data Engineering / Analytics Engineering. From API chaos to trader edge — let's make crypto smarter
* **Github:** https://github.com/Greatdev666
* **LinkdIn:** https://www.linkedin.com/in/delexcode29/
* **X:** https://x.com/delexcode29
* **Gmail:** codedelex@gmail.com

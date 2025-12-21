# =====================================================
# CRASH-SAFE, FAST, TRUE-INCREMENTAL BINANCE DAILY INGESTION
# + LATE-DATA SAFE WITH CHECKPOINTS
# =====================================================

import requests
import zipfile
import io
import pandas as pd
from datetime import datetime, timedelta, timezone
import snowflake.connector
from snowflake.connector.pandas_tools import write_pandas
from cryptography.hazmat.primitives import serialization

# ======================
# Config
# ======================
COINS = [
    "BTCUSDT", "ETHUSDT", "BNBUSDT", "ADAUSDT", "XRPUSDT",
    "SOLUSDT", "DOTUSDT", "DOGEUSDT", "LTCUSDT", "LINKUSDT",
    "ALGOUSDT", "FTMBNB", "TRXUSDT", "MATICUSDT", "AVAXUSDT"
]

INTERVAL = "1h"
START_DATE = datetime(2019, 1, 1).date()
END_DATE = datetime.now(timezone.utc).date()

REINGEST_DAYS = 1       # <-- re-fetch last N days for late data safety
BATCH_DAYS = 60

BASE_URL = "https://data.binance.vision/data/spot/daily/klines"

SNOWFLAKE_CONFIG = {
    "account": "KKVJJZY-EE58658",
    "user": "PIPELINE_USER",
    "private_key_path": "D:/USER/Documents/klineforge-crypto-warehouse/rsa keys/rsa_key.p8",
    "role": "PIPELINE_ROLE",
    "warehouse": "WH_PIPELINE",
    "database": "CRYPTO_DWH",
    "schema": "BRONZE"
}

DATA_TABLE = "BINANCE_KLINES_DAILY"
CHECKPOINT_TABLE = "BINANCE_INGESTION_CHECKPOINTS"

# ======================
# Snowflake connection
# ======================
def get_conn():
    with open(SNOWFLAKE_CONFIG["private_key_path"], "rb") as f:
        key = serialization.load_pem_private_key(f.read(), password=None)

    return snowflake.connector.connect(
        account=SNOWFLAKE_CONFIG["account"],
        user=SNOWFLAKE_CONFIG["user"],
        private_key=key.private_bytes(
            encoding=serialization.Encoding.DER,
            format=serialization.PrivateFormat.PKCS8,
            encryption_algorithm=serialization.NoEncryption()
        ),
        role=SNOWFLAKE_CONFIG["role"],
        warehouse=SNOWFLAKE_CONFIG["warehouse"],
        database=SNOWFLAKE_CONFIG["database"],
        schema=SNOWFLAKE_CONFIG["schema"]
    )

# ======================
# Tables
# ======================
def create_tables(conn):
    with conn.cursor() as cur:
        cur.execute(f"""
        CREATE TABLE IF NOT EXISTS {DATA_TABLE} (
            OPEN_TIME BIGINT,
            OPEN FLOAT,
            HIGH FLOAT,
            LOW FLOAT,
            CLOSE FLOAT,
            VOLUME FLOAT,
            CLOSE_TIME BIGINT,
            QUOTE_VOLUME FLOAT,
            COUNT INTEGER,
            TAKER_BUY_BASE FLOAT,
            TAKER_BUY_QUOTE FLOAT,
            IGNORE STRING,
            COIN STRING,
            INTERVAL STRING,
            INGESTION_TS TIMESTAMP_NTZ
        );
        """)

        cur.execute(f"""
        CREATE TABLE IF NOT EXISTS {CHECKPOINT_TABLE} (
            COIN STRING PRIMARY KEY,
            LAST_INGESTED_DATE DATE,
            UPDATED_AT TIMESTAMP_NTZ
        );
        """)

# ======================
# Checkpoint helpers
# ======================
def get_checkpoint(conn, coin):
    with conn.cursor() as cur:
        cur.execute(f"SELECT LAST_INGESTED_DATE FROM {CHECKPOINT_TABLE} WHERE COIN=%s", (coin,))
        row = cur.fetchone()
        return row[0] if row else None

def update_checkpoint(conn, coin, day):
    with conn.cursor() as cur:
        cur.execute(f"""
        MERGE INTO {CHECKPOINT_TABLE} t
        USING (SELECT %s COIN, %s LAST_DATE) s
        ON t.COIN = s.COIN
        WHEN MATCHED THEN
          UPDATE SET LAST_INGESTED_DATE = s.LAST_DATE, UPDATED_AT = CURRENT_TIMESTAMP
        WHEN NOT MATCHED THEN
          INSERT (COIN, LAST_INGESTED_DATE, UPDATED_AT)
          VALUES (s.COIN, s.LAST_DATE, CURRENT_TIMESTAMP)
        """, (coin, day))

# ======================
# Fetch one day
# ======================
def fetch_day(coin, day):
    fname = f"{coin}-{INTERVAL}-{day:%Y-%m-%d}.zip"
    url = f"{BASE_URL}/{coin}/{INTERVAL}/{fname}"

    r = requests.get(url, timeout=20)
    if r.status_code != 200:
        return None

    with zipfile.ZipFile(io.BytesIO(r.content)) as z:
        df = pd.read_csv(z.open(z.namelist()[0]), header=None)

    df.columns = [
        "OPEN_TIME", "OPEN", "HIGH", "LOW", "CLOSE", "VOLUME",
        "CLOSE_TIME", "QUOTE_VOLUME", "COUNT",
        "TAKER_BUY_BASE", "TAKER_BUY_QUOTE", "IGNORE"
    ]

    df["COIN"] = coin
    df["INTERVAL"] = INTERVAL
    return df

# ======================
# Batch insert
# ======================
def insert_batch(conn, frames):
    if not frames:
        return

    df = pd.concat(frames, ignore_index=True)
    df["INGESTION_TS"] = datetime.now(timezone.utc).replace(tzinfo=None)

    write_pandas(
        conn,
        df,
        DATA_TABLE,
        database=SNOWFLAKE_CONFIG["database"],
        schema=SNOWFLAKE_CONFIG["schema"],
        auto_create_table=False,
        overwrite=False,
        quote_identifiers=False
    )

# ======================
# Main
# ======================
def main():
    conn = get_conn()
    try:
        create_tables(conn)

        for coin in COINS:
            last = get_checkpoint(conn, coin)

            # If checkpoint exists, reingest last REINGEST_DAYS days to handle late data
            start = (last - timedelta(days=REINGEST_DAYS)) if last else START_DATE
            start = max(start, START_DATE)  # prevent going before 2019-01-01

            print(f"\n🚀 {coin}: {start} → {END_DATE}")

            batch = []
            d = start

            while d <= END_DATE:
                df = fetch_day(coin, d)
                if df is not None:
                    batch.append(df)

                if len(batch) >= BATCH_DAYS:
                    insert_batch(conn, batch)
                    # checkpoint is last day in batch
                    update_checkpoint(conn, coin, d)
                    batch.clear()

                d += timedelta(days=1)

            if batch:
                insert_batch(conn, batch)
                update_checkpoint(conn, coin, d - timedelta(days=1))

        print("\n✅ TRUE incremental + late-data-safe ingestion complete")

    finally:
        conn.close()

# ======================
# Run
# ======================
if __name__ == "__main__":
    main()
# ======================
# Dagster entrypoint
# ======================
def run_ingestion():
    """
    Dagster-friendly wrapper around main ingestion logic
    """
    main()
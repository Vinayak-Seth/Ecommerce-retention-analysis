"""Step 1: Load the raw Olist CSVs into a SQLite database and build the analysis tables.

Run from the project root:
    python scripts/01_load_data.py
"""
import sqlite3
from pathlib import Path

import pandas as pd

ROOT = Path(__file__).resolve().parent.parent
RAW = ROOT / "data" / "raw"
DB = ROOT / "data" / "olist.db"

# CSV file name -> table name in the database
TABLES = {
    "olist_customers_dataset.csv": "customers",
    "olist_orders_dataset.csv": "orders",
    "olist_order_items_dataset.csv": "order_items",
    "olist_order_payments_dataset.csv": "order_payments",
    "olist_order_reviews_dataset.csv": "order_reviews",
    "olist_products_dataset.csv": "products",
    "olist_sellers_dataset.csv": "sellers",
    "product_category_name_translation.csv": "category_translation",
}


def main():
    missing = [f for f in TABLES if not (RAW / f).exists()]
    if missing:
        raise SystemExit(f"Missing files in {RAW}:\n  " + "\n  ".join(missing)
                         + "\nDownload the Olist dataset and unzip it into data/raw (see README).")

    DB.unlink(missing_ok=True)
    con = sqlite3.connect(DB)

    for file, table in TABLES.items():
        df = pd.read_csv(RAW / file, encoding="utf-8-sig")  # utf-8-sig strips the hidden BOM in one file
        df.to_sql(table, con, index=False)
        print(f"loaded {table:<22} {len(df):>8,} rows")

    # Build the two analysis tables (order_facts, customer_facts)
    con.executescript((ROOT / "sql" / "00_build_model.sql").read_text(encoding="utf-8"))
    for t in ("order_facts", "customer_facts"):
        n = con.execute(f"SELECT COUNT(*) FROM {t}").fetchone()[0]
        print(f"built  {t:<22} {n:>8,} rows")

    con.close()
    print(f"\nDatabase ready: {DB}")


if __name__ == "__main__":
    main()

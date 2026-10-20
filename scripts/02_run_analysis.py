"""Step 2: Run every analysis query in sql/ and save each result as a CSV in outputs/.

The CSVs are what you load into Power BI. Run from the project root:
    python scripts/02_run_analysis.py
"""
import sqlite3
from pathlib import Path

import pandas as pd

ROOT = Path(__file__).resolve().parent.parent
DB = ROOT / "data" / "olist.db"
SQL_DIR = ROOT / "sql"
OUT = ROOT / "outputs"

pd.set_option("display.width", 160)
pd.set_option("display.max_columns", 20)


def main():
    if not DB.exists():
        raise SystemExit("Database not found. Run: python scripts/01_load_data.py")
    OUT.mkdir(exist_ok=True)
    con = sqlite3.connect(DB)

    # Analysis queries (00_build_model.sql is run by the loader, so skip it)
    for sql_file in sorted(SQL_DIR.glob("[0-9][0-9]_*.sql")):
        if sql_file.name.startswith("00_"):
            continue
        df = pd.read_sql_query(sql_file.read_text(encoding="utf-8"), con)
        out_file = OUT / f"{sql_file.stem}.csv"
        df.to_csv(out_file, index=False)
        print(f"\n=== {sql_file.stem}  ({len(df):,} rows -> outputs/{out_file.name})")
        if len(df) <= 25:
            print(df.to_string(index=False))
        else:
            print(df.head(5).to_string(index=False), "\n...")

    # Full fact tables for Power BI (lets you slice and filter freely)
    for table in ("order_facts", "customer_facts"):
        pd.read_sql_query(f"SELECT * FROM {table}", con).to_csv(OUT / f"{table}.csv", index=False)
        print(f"\nexported outputs/{table}.csv")

    con.close()
    print("\nDone. Next: open Power BI Desktop and load the CSVs in outputs/ (see README step 5).")


if __name__ == "__main__":
    main()

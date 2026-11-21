import csv
import os
import mysql.connector

CONFIG = {
    "host": os.getenv("MYSQL_HOST", "localhost"),
    "user": os.getenv("MYSQL_USER", "root"),
    "password": os.getenv("MYSQL_PASSWORD", ""),
    "database": "sales_intelligence",
}
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA = os.path.join(ROOT, "data")

def load_csv(conn, filename, table, columns, batch_size=1000):
    path = os.path.join(DATA, filename)
    placeholders = ",".join(["%s"] * len(columns))
    sql = f"INSERT INTO {table} ({','.join(columns)}) VALUES ({placeholders})"
    batch = []
    with open(path, newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            batch.append(tuple(row[c] for c in columns))
            if len(batch) >= batch_size:
                with conn.cursor() as cur:
                    cur.executemany(sql, batch)
                conn.commit()
                batch = []
    if batch:
        with conn.cursor() as cur:
            cur.executemany(sql, batch)
        conn.commit()
    print(f"Loaded {filename} into {table}")

def main():
    conn = mysql.connector.connect(**CONFIG)
    try:
        load_csv(conn, "regions.csv", "regions", ["region_id","region_name","city","zone"])
        load_csv(conn, "customers.csv", "customers", ["customer_id","customer_name","email","segment","signup_date","region_id"])
        load_csv(conn, "products.csv", "products", ["product_id","product_name","category","unit_price","unit_cost"])
        load_csv(conn, "orders.csv", "orders", ["order_id","customer_id","order_date","status","sales_channel"])
        load_csv(conn, "order_items.csv", "order_items", ["order_item_id","order_id","product_id","quantity","unit_price","discount_pct"])
    finally:
        conn.close()

if __name__ == "__main__":
    main()

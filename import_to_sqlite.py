import sqlite3
import pandas as pd

# File paths
csv_path = "data/raw/bank_transactions.csv"
db_path = "sql/banking.db"

# Read CSV
df = pd.read_csv(csv_path)

# Connect to SQLite
conn = sqlite3.connect(db_path)

# Insert data into existing table
df.to_sql("bank_transactions", conn, if_exists="append", index=False)

# Verify
count = pd.read_sql("SELECT COUNT(*) AS total FROM bank_transactions", conn)

print("Import Successful!")
print(count)

conn.close()
-- Banking Fraud Analytics Database Schema

DROP TABLE IF EXISTS bank_transactions;

CREATE TABLE bank_transactions (

    transaction_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    timestamp TEXT,

    merchant_id INTEGER,
    merchant_name TEXT,
    merchant_category TEXT,

    payment_method TEXT,
    channel TEXT,

    amount REAL,

    age INTEGER,
    city TEXT,
    account_type TEXT,
    account_balance REAL,

    year INTEGER,
    month INTEGER,
    month_name TEXT,
    day INTEGER,
    weekday TEXT,
    hour INTEGER,

    risk_score REAL,
    is_fraud INTEGER
);
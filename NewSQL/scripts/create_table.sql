-- Habilitar extensión para UUID (PostgreSQL compatible)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Countries Table (Pequeña, no requiere sharding manual)
DROP TABLE IF EXISTS countries CASCADE;
CREATE TABLE countries (
    country_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    iso_code CHAR(3) UNIQUE
);

-- 2. Customers Table
DROP TABLE IF EXISTS customers CASCADE;
CREATE TABLE customers (
    customer_id UUID PRIMARY KEY, 
    full_name TEXT NOT NULL,
    country_id INT REFERENCES countries(country_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

-- 3. Accounts Table
DROP TABLE IF EXISTS accounts CASCADE;
CREATE TABLE accounts (
    account_id UUID PRIMARY KEY,
    customer_id UUID REFERENCES customers(customer_id),
    country_id INT REFERENCES countries(country_id),
    account_type TEXT NOT NULL,
    currency VARCHAR(3) NOT NULL,
    balance NUMERIC(18, 2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CHECK (balance >= 0)
);

-- 4. Transactions Table
DROP TABLE IF EXISTS transactions CASCADE;
CREATE TABLE transactions (
    transaction_id UUID PRIMARY KEY,
    source_account_id UUID REFERENCES accounts(account_id),
    destination_account_id UUID REFERENCES accounts(account_id),
    amount NUMERIC(18, 2) NOT NULL,
    currency VARCHAR(3) NOT NULL,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    transaction_type TEXT NOT NULL
);

--- Índices Secundarios (YugabyteDB usa HASH por defecto para índices)
CREATE INDEX idx_customers_country ON customers(country_id);
CREATE INDEX idx_accounts_customer ON accounts(customer_id);
CREATE INDEX idx_transactions_date ON transactions(transaction_date);
CREATE INDEX idx_transactions_source ON transactions(source_account_id);
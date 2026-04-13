-- countries: 20
-- customers: 1 Million
-- accounts: 3 Million
-- transactions: 10 million

-- 1. Preparación de la sesión
SET session_replication_role = 'replica';
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Limpieza (Opcional, ten cuidado)
TRUNCATE TABLE transactions, accounts, customers, countries RESTART IDENTITY CASCADE;

-- 3. Países (20 América)
INSERT INTO countries (name, iso_code) VALUES
('United States', 'USA'), ('Canada', 'CAN'), ('Mexico', 'MEX'), 
('Brazil', 'BRA'), ('Argentina', 'ARG'), ('Colombia', 'COL'), 
('Chile', 'CHL'), ('Peru', 'PER'), ('Venezuela', 'VEN'), 
('Ecuador', 'ECU'), ('Guatemala', 'GTM'), ('Cuba', 'CUB'), 
('Haiti', 'HTI'), ('Dominican Republic', 'DOM'), ('Honduras', 'HND'), 
('Paraguay', 'PRY'), ('El Salvador', 'SLV'), ('Nicaragua', 'NIC'), 
('Costa Rica', 'CRI'), ('Panama', 'PAN');

DO $$
DECLARE
    -- Ajuste de volúmenes
    total_customers CONSTANT INT := 50000;
    total_accounts CONSTANT INT := 200000;
    total_transactions CONSTANT INT := 800000;
    
    batch_size CONSTANT INT := 5000;
    i INT;
BEGIN
    -- 4. Ingesta de Clientes (50,000)
    RAISE NOTICE 'Iniciando carga de Clientes...';
    FOR i IN 0..((total_customers / batch_size) - 1) LOOP
        INSERT INTO customers (customer_id, full_name, country_id, created_at)
        SELECT 
            gen_random_uuid(),
            'Customer_' || md5(random()::text),
            (1 + floor(random() * 20))::int,
            NOW() - (random() * 1000) * INTERVAL '1 day'
        FROM generate_series(1, batch_size);
    END LOOP;
    RAISE NOTICE 'Clientes completados.';

    -- 5. Ingesta de Cuentas (200,000)
    RAISE NOTICE 'Iniciando carga de Cuentas...';
    FOR i IN 0..((total_accounts / batch_size) - 1) LOOP
        INSERT INTO accounts (account_id, customer_id, country_id, account_type, currency, balance, created_at)
        SELECT 
            gen_random_uuid(),
            (SELECT customer_id FROM customers OFFSET floor(random() * 49999) LIMIT 1),
            (1 + floor(random() * 20))::int,
            CASE WHEN random() < 0.7 THEN 'savings' ELSE 'checking' END,
            CASE WHEN random() < 0.5 THEN 'USD' ELSE 'COP' END,
            (500 + random() * 10000)::numeric(18,2),
            NOW() - (random() * 365) * INTERVAL '1 day'
        FROM generate_series(1, batch_size);
        
        IF (i + 1) % 10 = 0 THEN RAISE NOTICE 'Cuentas: % procesadas', (i + 1) * batch_size; END IF;
    END LOOP;

    -- 6. Ingesta de Transacciones (800,000)
    RAISE NOTICE 'Iniciando carga de Transacciones...';
    FOR i IN 0..((total_transactions / batch_size) - 1) LOOP
        INSERT INTO transactions (
            transaction_id, source_account_id, destination_account_id, 
            amount, currency, transaction_date, transaction_type
        )
        SELECT 
            gen_random_uuid(),
            src,
            dst,
            (10 + random() * 1000)::numeric(18,2),
            'USD',
            NOW() - (random() * 90) * INTERVAL '1 day',
            'transfer'
        FROM (
            SELECT 
                (SELECT account_id FROM accounts OFFSET floor(random() * 199999) LIMIT 1) as src,
                (SELECT account_id FROM accounts OFFSET floor(random() * 199999) LIMIT 1) as dst
            FROM generate_series(1, batch_size)
        ) AS sub;

        IF (i + 1) % 20 = 0 THEN RAISE NOTICE 'Transacciones: % procesadas', (i + 1) * batch_size; END IF;
    END LOOP;

    RAISE NOTICE 'Proceso finalizado con éxito.';
END $$;

-- 7. Restaurar integridad
SET session_replication_role = 'origin';
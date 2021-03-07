/*SQL Statements to create the Star Schema

Transaction Dimension*/
BEGIN;
CREATE TABLE d_transaction (
    transaction_id              BIGSERIAL NOT NULL
        CONSTRAINT pk_d_transaction
            PRIMARY KEY,
    hash                        TEXT,
    nonce                       BIGINT,
    transaction_index           BIGINT,
    from_address                TEXT,
    to_address                  TEXT,
    value                       NUMERIC(38),
    gas                         BIGINT,
    gas_price                   BIGINT,
    input                       TEXT,
    receipt_cumulative_gas_used BIGINT,
    receipt_gas_used            BIGINT,
    receipt_contract_address    TEXT,
    receipt_root                TEXT,
    receipt_status              BIGINT,
    block_timestamp             TIMESTAMP,
    block_number                BIGINT,
    block_hash                  TEXT
);

/* Block Dimension*/
CREATE TABLE d_block (
    block_id          BIGSERIAL NOT NULL
        CONSTRAINT pk_d_block
            PRIMARY KEY,
    timestamp         TIMESTAMP,
    number            BIGINT,
    hash              TEXT,
    parent_hash       TEXT,
    nonce             TEXT,
    sha3_uncles       TEXT,
    logs_bloom        TEXT,
    transactions_root TEXT,
    state_root        TEXT,
    receipts_root     TEXT,
    miner             TEXT,
    difficulty        NUMERIC(38),
    total_difficulty  NUMERIC(38),
    size              BIGINT,
    extra_data        TEXT,
    gas_limit         BIGINT,
    gas_used          BIGINT,
    transaction_count BIGINT
);


/*Date Dimension*/
CREATE TABLE d_date (
    date         DATE NOT NULL
        CONSTRAINT pk_d_date
            PRIMARY KEY,
    year         INTEGER,
    month        INTEGER,
    day          INTEGER,
    weekday      INTEGER,
    day_in_chars TEXT,
    week         INTEGER
);

/*Time Dimension*/
CREATE TABLE d_time (
    time    TIME NOT NULL
        CONSTRAINT pk_d_time
            PRIMARY KEY,
    hours   INTEGER,
    minutes INTEGER,
    seconds INTEGER
);

/*Account Dimension*/
CREATE TABLE d_account (
    account_id      BIGSERIAL NOT NULL,
    address         TEXT
        CONSTRAINT pk_d_account
            PRIMARY KEY,
    eth_sent        NUMERIC(38),
    eth_received    NUMERIC(38),
    account_balance NUMERIC(38)
);

/*Fact Table*/
CREATE TABLE f_blockchain (
    CONSTRAINT pk_f_blockchain
        PRIMARY KEY (block_id, transaction_id, account_from_address, account_to_address, date, time),
    block_id             BIGINT NOT NULL
        CONSTRAINT fk_d_block
            REFERENCES d_block,
    transaction_id       BIGINT NOT NULL
        CONSTRAINT fk_d_Transaction
            REFERENCES d_transaction,
    account_from_address TEXT   NOT NULL
        CONSTRAINT fk_d_account_from
            REFERENCES d_account,
    account_to_address   TEXT   NOT NULL
        CONSTRAINT fk_d_account_to
            REFERENCES d_account,
    date                 DATE   NOT NULL
        CONSTRAINT fk_d_date
            REFERENCES d_date,
    time                 TIME   NOT NULL
        CONSTRAINT fk_d_time
            REFERENCES d_time
);

COMMIT;
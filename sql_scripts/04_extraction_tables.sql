-- noinspection SqlNoDataSourceInspectionForFile

/*  ETL
    Prerequisites:
        - Transactions and blocks table have been populated with
          data using Ethereum ETL
        - Star schema has been set up using star_schema.sql
*/

/* EXTRACTION */
/* Extraction Table Transactions */
BEGIN;
CREATE TABLE IF NOT EXISTS e_d_transaction (
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
    block_timestamp             TIMESTAMP(0),
    block_number                BIGINT,
    block_hash                  TEXT
);

TRUNCATE TABLE e_d_transaction;

/* Extraction Table Blocks */
CREATE TABLE IF NOT EXISTS e_d_block (
    number            BIGINT PRIMARY KEY,
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
    timestamp         TIMESTAMP(0),
    transaction_count BIGINT
);

TRUNCATE TABLE e_d_block;

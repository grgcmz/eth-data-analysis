/* SQL statements to create transactions and blocks tables if they don't already exist.
These Tables are needed for Ethereum ETL to work correctly. They are the extraction location
where all transaction and block data goes into right after having been exported.
The Tables are then truncated before each new extraction.
*/
CREATE TABLE IF NOT EXISTS transactions (
  hash                        TEXT PRIMARY KEY,
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

TRUNCATE TABLE transactions;

CREATE TABLE IF NOT EXISTS blocks (
  number            BIGINT,
  hash              TEXT PRIMARY KEY,
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
  timestamp         TIMESTAMP,
  transaction_count BIGINT
);

TRUNCATE TABLE blocks;

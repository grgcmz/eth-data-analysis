CREATE TABLE transactions (
  hash                        text primary key,
  nonce                       bigint,
  transaction_index           bigint,
  from_address                text,
  to_address                  text,
  value                       numeric(38),
  gas                         bigint,
  gas_price                   bigint,
  input                       text,
  receipt_cumulative_gas_used bigint,
  receipt_gas_used            bigint,
  receipt_contract_address    text,
  receipt_root                text,
  receipt_status              bigint,
  block_timestamp             text,
  block_number                bigint,
  block_hash                  text
);

CREATE TABLE blocks (
  number            bigint,
  hash              text primary key,
  parent_hash       text,
  nonce             text,
  sha3_uncles       text,
  logs_bloom        text,
  transactions_root text,
  state_root        text,
  receipts_root     text,
  miner             text,
  difficulty        numeric(38),
  total_difficulty  numeric(38),
  size              bigint,
  extra_data        text,
  gas_limit         bigint,
  gas_used          bigint,
  timestamp         text,
  transaction_count bigint
);
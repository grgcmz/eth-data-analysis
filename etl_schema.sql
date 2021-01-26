create table transactions
(
  hash varchar(66) primary key,
  nonce bigint,
  transaction_index bigint,
  from_address varchar(42),
  to_address varchar(42),
  value numeric(38),
  gas bigint,
  gas_price bigint,
  input text,
  receipt_cumulative_gas_used bigint,
  receipt_gas_used bigint,
  receipt_contract_address varchar(42),
  receipt_root varchar(66),
  receipt_status bigint,
  block_timestamp text,
  block_number bigint,
  block_hash varchar(66)
);

create table blocks
(
  number bigint,
  hash varchar(66) primary key,
  parent_hash text,
  nonce text,
  sha3_uncles text,
  logs_bloom text,
  transactions_root text,
  state_root text,
  receipts_root text,
  miner varchar(42),
  difficulty numeric(38),
  total_difficulty numeric(38),
  size bigint,
  extra_data text,
  gas_limit bigint,
  gas_used bigint,
  timestamp text,
  transaction_count bigint
);

create table token_transfers
(
  token_address varchar(42),
  from_address varchar(42),
  to_address varchar(42),
  value numeric(38),
  transaction_hash varchar(66) primary key,
  log_index bigint,
  block_number bigint
);

create table receipts
(
  transaction_hash varchar(66) primary key ,
  transaction_index bigint,
  block_hash text,
  block_number bigint,
  cumulative_gas_used bigint,
  gas_used bigint,
  contract_address varchar(42),
  root text,
  status bigint
);

create table logs
(
  log_index bigint unique
  transaction_hash varchar(66) primary key
  transaction_index bigint
  address varchar(42
  data text
  topic0 varchar(66
  topic1 varchar(66
  topic2 varchar(66
  topic3 varchar(66
  block_timestamp timestamp
  block_number bigint
  block_hash varchar(66
  CONSTRAINT 
  FOREIGN KEY(transaction_hash
  REFERENCES transactions(hash
  CONSTRAINT 
  FOREIGN KEY(block_hash
  REFERENCES blocks(hash)
);

create table traces
(
  transaction_hash varchar(66),
  transaction_index bigint,
  from_address varchar(42),
  to_address varchar(42),
  value numeric(38),
  input text,
  output text,
  trace_type varchar(16),
  call_type varchar(16),
  reward_type varchar(16),
  gas bigint,
  gas_used bigint,
  subtraces bigint,
  trace_address varchar(8192),
  error text,
  status int,
  block_timestamp timestamp,
  block_number bigint,
  block_hash varchar(66),
  trace_id text
);

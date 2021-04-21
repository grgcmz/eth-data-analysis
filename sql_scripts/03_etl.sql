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

INSERT INTO e_d_transaction (hash,
                             nonce,
                             transaction_index,
                             from_address,
                             to_address,
                             value,
                             gas,
                             gas_price,
                             input,
                             receipt_cumulative_gas_used,
                             receipt_gas_used,
                             receipt_contract_address,
                             receipt_root,
                             receipt_status,
                             block_timestamp,
                             block_number,
                             block_hash)

SELECT hash,
       nonce,
       transaction_index,
       from_address,
       to_address,
       value,
       gas,
       gas_price,
       input,
       receipt_cumulative_gas_used,
       receipt_gas_used,
       receipt_contract_address,
       receipt_root,
       receipt_status,
       block_timestamp,
       block_number,
       block_hash
  FROM transactions;

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

INSERT INTO e_d_block (number,
                       hash,
                       parent_hash,
                       nonce,
                       sha3_uncles,
                       logs_bloom,
                       transactions_root,
                       state_root,
                       receipts_root,
                       miner,
                       difficulty,
                       total_difficulty,
                       size,
                       extra_data,
                       gas_limit,
                       gas_used,
                       timestamp,
                       transaction_count)
SELECT number,
       hash,
       parent_hash,
       nonce,
       sha3_uncles,
       logs_bloom,
       transactions_root,
       state_root,
       receipts_root,
       miner,
       difficulty,
       total_difficulty,
       size,
       extra_data,
       gas_limit,
       gas_used,
       timestamp,
       transaction_count
  FROM blocks;

/* TRANSFORMATION */
/* Transformation table for transactions */
CREATE TABLE IF NOT EXISTS t_d_transaction (
    transaction_id              BIGSERIAL NOT NULL
        CONSTRAINT pk_t_d_transaction
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
    block_timestamp             TIMESTAMP(0),
    block_number                BIGINT,
    block_hash                  TEXT
);

TRUNCATE TABLE t_d_transaction;

INSERT INTO t_d_transaction (hash,
                             nonce,
                             transaction_index,
                             from_address,
                             to_address,
                             value,
                             gas,
                             gas_price,
                             input,
                             receipt_cumulative_gas_used,
                             receipt_gas_used,
                             receipt_contract_address,
                             receipt_root,
                             receipt_status,
                             block_timestamp,
                             block_number,
                             block_hash)
SELECT hash,
       nonce,
       transaction_index,
       from_address,
       CASE
           WHEN to_address IS NULL
               THEN '0x0000000000000000000000000000000000000000' --avoid problems in fact table
           ELSE to_address
           END,
       value,
       gas,
       gas_price,
       input,
       receipt_cumulative_gas_used,
       receipt_gas_used,
       receipt_contract_address,
       receipt_root,
       receipt_status,
       block_timestamp,
       block_number,
       block_hash
  FROM e_d_transaction;

/* Transformation table Blocks */
CREATE TABLE IF NOT EXISTS t_d_block (
    block_id          BIGSERIAL NOT NULL
        CONSTRAINT "pk_t_d_block"
            PRIMARY KEY,
    timestamp         TIMESTAMP(0),
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

TRUNCATE TABLE t_d_block;

INSERT INTO t_d_block (timestamp,
                       number,
                       hash,
                       parent_hash,
                       nonce,
                       sha3_uncles,
                       logs_bloom,
                       transactions_root,
                       state_root,
                       receipts_root,
                       miner,
                       difficulty,
                       total_difficulty,
                       size,
                       extra_data,
                       gas_limit,
                       gas_used,
                       transaction_count)

SELECT timestamp,
       number,
       hash,
       parent_hash,
       nonce,
       sha3_uncles,
       logs_bloom,
       transactions_root,
       state_root,
       receipts_root,
       miner,
       difficulty,
       total_difficulty,
       size,
       extra_data,
       gas_limit,
       gas_used,
       transaction_count
  FROM e_d_block;

/* Transformation Table Date */
CREATE TABLE IF NOT EXISTS t_d_date (
    date         DATE NOT NULL
        CONSTRAINT pk_t_d_date
            PRIMARY KEY,
    year         INTEGER,
    month        INTEGER,
    day          INTEGER,
    weekday      INTEGER,
    day_in_chars TEXT,
    week         INTEGER
);

TRUNCATE TABLE t_d_date;

INSERT INTO t_d_date (date,
                      year,
                      month,
                      day,
                      weekday,
                      day_in_chars,
                      week)

-- https://www.postgresql.org/docs/9.1/functions-datetime.html
SELECT distinct block_timestamp::date,
                extract(isoyear from block_timestamp), -- use isoyear to avid problems with early jan dates
                extract(month from block_timestamp),
                extract(day from block_timestamp),
                extract(isodow from block_timestamp),
                to_char(block_timestamp, 'Day'),
                extract(week from block_timestamp)
  FROM t_d_transaction;

/* Transformation Table Time */
CREATE TABLE IF NOT EXISTS t_d_time (
    time    TIME NOT NULL
        CONSTRAINT pk_t_d_time
            PRIMARY KEY,
    hours   INTEGER,
    minutes INTEGER,
    seconds INTEGER
);

TRUNCATE TABLE t_d_time;

INSERT INTO t_d_time(time,
                     hours,
                     minutes,
                     seconds)

SELECT distinct block_timestamp::time,
                extract(hour from block_timestamp),
                extract(minute from block_timestamp),
                extract(second from block_timestamp)
  FROM t_d_transaction;

/* Account Transformation Tables */
CREATE TABLE IF NOT EXISTS t_d_account_from (
    address TEXT NOT NULL,
    eth_out NUMERIC(38)
);

TRUNCATE TABLE t_d_account_from;

INSERT INTO t_d_account_from (address,
                              eth_out)

SELECT from_address,
       eth_out

  FROM (SELECT from_address,
               (value + receipt_gas_used::NUMERIC(38) * gas_price::NUMERIC(38)) *
               -1 as eth_out -- Multiply by -1 so that later it gets subtracted from the eth received

          FROM e_d_transaction AS edt) out;

CREATE TABLE IF NOT EXISTS t_d_account_to (
    address      TEXT NOT NULL,
    eth_received NUMERIC(38)
);
TRUNCATE TABLE t_d_account_to;

INSERT INTO t_d_account_to (address,
                            eth_received)
SELECT to_address,
       value
  FROM e_d_transaction
 WHERE to_address IS NOT NULL;

/*Put from and to together for balances*/
CREATE TABLE IF NOT EXISTS t_d_account (
    account_id      BIGSERIAL,
    address         TEXT
        CONSTRAINT pk_t_d_account
            PRIMARY KEY,
    eth_sent        NUMERIC(38),
    eth_received    NUMERIC(38),
    account_balance NUMERIC(38)
);

TRUNCATE TABLE t_d_account;

INSERT INTO t_d_account (address,
                         eth_sent,
                         eth_received,
                         account_balance)
SELECT sums.address,
       SUM(eth_out),
       SUM(eth) + SUM(eth_out),
       SUM(eth)
  FROM (SELECT tdaf.address        AS address,
               tdaf.eth_out        AS eth,
               (tdaf.eth_out * -1) AS eth_out -- Reconvert to positive amount
          FROM t_d_account_from AS tdaf

         UNION ALL

        SELECT tdat.address      as address,
               tdat.eth_received AS eth,
               tdat.eth_received AS eth_in -- Just here to match rows for union all
          FROM t_d_account_to AS tdat) sums
 GROUP BY address;

/* LOADING */
/* Loading transaction dimension */
INSERT INTO d_transaction(transaction_id,
                          hash,
                          nonce,
                          transaction_index,
                          from_address,
                          to_address,
                          value,
                          gas,
                          gas_price,
                          input,
                          receipt_cumulative_gas_used,
                          receipt_gas_used,
                          receipt_contract_address,
                          receipt_root,
                          receipt_status,
                          block_timestamp,
                          block_number,
                          block_hash)
SELECT transaction_id,
       hash,
       nonce,
       transaction_index,
       from_address,
       to_address,
       value,
       gas,
       gas_price,
       input,
       receipt_cumulative_gas_used,
       receipt_gas_used,
       receipt_contract_address,
       receipt_root,
       receipt_status,
       block_timestamp,
       block_number,
       block_hash
  FROM t_d_transaction;

/* Loading block dimension */
INSERT INTO d_block (block_id,
                     timestamp,
                     number,
                     hash,
                     parent_hash,
                     nonce,
                     sha3_uncles,
                     logs_bloom,
                     transactions_root,
                     state_root,
                     receipts_root,
                     miner,
                     difficulty,
                     total_difficulty,
                     size,
                     extra_data,
                     gas_limit,
                     gas_used,
                     transaction_count)
SELECT block_id,
       timestamp,
       number,
       hash,
       parent_hash,
       nonce,
       sha3_uncles,
       logs_bloom,
       transactions_root,
       state_root,
       receipts_root,
       miner,
       difficulty,
       total_difficulty,
       size,
       extra_data,
       gas_limit,
       gas_used,
       transaction_count
  FROM t_d_block;

/* Loading date dimension */
INSERT INTO d_date (date,
                    year,
                    month,
                    day,
                    weekday,
                    day_in_chars,
                    week)
SELECT date,
       year,
       month,
       day,
       weekday,
       day_in_chars,
       week
  FROM t_d_date
    ON CONFLICT DO NOTHING;
-- Avoid conflicts with duplicate dates

/* Loading time dimension */

INSERT INTO d_time (time,
                    hours,
                    minutes,
                    seconds)
SELECT time,
       hours,
       minutes,
       seconds
  FROM t_d_time
    ON CONFLICT DO NOTHING;
-- Avoid conflicts with duplicate timestamps

/* Loading account dimension */
INSERT INTO d_account (address,
                       eth_sent,
                       eth_received,
                       account_balance)
SELECT address,
       eth_sent,
       eth_received,
       account_balance
  FROM t_d_account
-- On conflict add the changes to the account balances
    ON CONFLICT (address) DO UPDATE
        SET eth_sent        = d_account.eth_sent + EXCLUDED.eth_sent,
            eth_received    = d_account.eth_received + EXCLUDED.eth_received,
            account_balance = d_account.account_balance + EXCLUDED.account_balance;


/* Loading blockchain fact table */
INSERT INTO f_blockchain (block_id,
                          transaction_id,
                          account_from_address,
                          account_to_address,
                          date,
                          time)
SELECT tdb.block_id,
       tdt.transaction_id,
       tdt.from_address,
       tdt.to_address,
       tdd.date,
       tdti.time
  FROM t_d_transaction AS tdt,
       t_d_block AS tdb,
       t_d_account AS tda,
       t_d_date AS tdd,
       t_d_time AS tdti
 WHERE tdt.block_timestamp::date = tdd.date
   AND tdt.block_timestamp::time = tdti.time
   AND tdt.block_hash = tdb.hash
   AND tdt.from_address = tda.address;
COMMIT;

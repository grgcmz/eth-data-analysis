/*  ETL
    Prerequisites:
        - Transaction and Block Table have been populated with
          data using Ethereum ETL
        - Star schema has been set up using star_schema.sql
*/

/* EXTRACTION */
-- Extraction Table Transactions

CREATE TABLE IF NOT EXISTS e_d_transaction
(
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
CREATE TABLE IF NOT EXISTS e_d_block
(
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
    timestamp         TIMESTAMP(0),
    transaction_count BIGINT
);

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
CREATE TABLE IF NOT EXISTS t_d_transaction
(
    transaction_id              bigserial NOT NULL
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
  FROM e_d_transaction;


/* Transformation table Blocks */
CREATE TABLE IF NOT EXISTS t_d_block
(
    block_id          bigserial NOT NULL
        CONSTRAINT "pk_t_d_block"
            PRIMARY KEY,
    timestamp         timestamp(0),
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
CREATE TABLE t_d_date
(
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

INSERT INTO t_d_date (date,
                      year,
                      month,
                      day,
                      weekday,
                      day_in_chars,
                      week)

SELECT distinct block_timestamp::date,
                extract(year from block_timestamp),
                extract(month from block_timestamp),
                extract(day from block_timestamp),
                extract(isodow from block_timestamp),
                to_char(block_timestamp, 'Day'),
                extract(week from block_timestamp)
  FROM t_d_transaction;

-- Transformation Table Time
CREATE TABLE t_d_time (
    time    TIME NOT NULL
        CONSTRAINT pk_t_d_time
            PRIMARY KEY,
    hours   INTEGER,
    minutes INTEGER,
    seconds INTEGER
);

INSERT INTO t_d_time(time,
                     hours,
                     minutes,
                     seconds)

SELECT distinct block_timestamp::time,
                extract(hour from block_timestamp),
                extract(minute from block_timestamp),
                extract(second from block_timestamp)
  FROM t_d_transaction;

/* Transformation Table Timestamp
   This table is not used, but might be useful
   Would enable to take date and time for those dimensions
   from this table instead of from transaction table
*/
CREATE TABLE t_d_timestamp (
    timestamp TIMESTAMP(0) NOT NULL
        CONSTRAINT pk_t_d_timestamp
            PRIMARY KEY
);


/* LOADING
   Loading transaction dimension
 */
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

/* Loading timestamp dimension
   This is not used for now
 */
/*INSERT INTO d_timestamp (timestamp)
SELECT timestamp
FROM t_d_timestamp;*/

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
  FROM t_d_date;

/* Loading time dimension */

INSERT INTO d_time (time,
                    hours,
                    minutes,
                    seconds)
SELECT time,
       hours,
       minutes,
       seconds
  FROM t_d_time;

/* Loading blockchain fact table */

INSERT INTO f_blockchain (block_id,
                          transaction_id,
                          date,
                          time)
SELECT tdb.block_id,
       tdt.transaction_id,
       tdd.date,
       tdti.time
  FROM t_d_transaction AS tdt,
       t_d_block AS tdb,
       t_d_date as tdd,
       t_d_time as tdti
 WHERE tdt.block_timestamp::date = tdd.date
   AND tdt.block_timestamp::time = tdti.time
   AND tdt.block_hash = tdb.hash;
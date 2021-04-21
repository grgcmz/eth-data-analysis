/* Example queries described in the thesis in Chapter 4 */

-- Show average gas price weekly (5.9s)
SELECT year,
       week,
       AVG(gas_price) AS average
  FROM f_blockchain
           INNER JOIN d_date dd ON dd.date = f_blockchain.date
           INNER JOIN d_transaction dt ON dt.transaction_id = f_blockchain.transaction_id
 GROUP BY year, week;


-- Daily Average number of transactions per block rounded to two decimal places (5.2s)
SELECT date, ROUND(AVG(tx_count), 2) AS average
  FROM (
           SELECT date, COUNT(*) AS tx_count
             from f_blockchain
            GROUP BY date, block_id) AS sub
 GROUP BY date;


-- Average number of transactions per account (3s)
SELECT AVG(nbr_txs)
  FROM (SELECT account_from_address, COUNT(*) AS nbr_txs
          FROM f_blockchain
         GROUP BY account_from_address
         ORDER BY nbr_txs DESC) AS sub;


-- Median number of transactions per account (2.7s)
SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY nbr_txs) AS median
  FROM (SELECT COUNT(*) AS nbr_txs
          FROM f_blockchain
         GROUP BY account_from_address) AS sub;

/* More examples queries */

-- Number of transactions made on each day of the week per month (4.9s)
SELECT year,
       month,
       weekday,
       day_in_chars,
       count(weekday) AS nb_tx
  FROM f_blockchain f

           INNER JOIN d_date AS dd
                      ON f.date = dd.date

           INNER JOIN d_transaction AS dt
                      ON f.transaction_id = dt.transaction_id
 GROUP BY year, month, weekday, day_in_chars
 ORDER BY year, month, weekday;

-- Output Accounts and their balances (descending order)
SELECT *
  FROM f_blockchain f
           INNER JOIN d_account da
                      ON f.account_from_address = da.address;

-- Show average gas price monthly [Wei]
SELECT year,
       month,
       AVG(gas_price)
  FROM f_blockchain
           INNER JOIN d_date dd on dd.date = f_blockchain.date
           INNER JOIN d_transaction dt on dt.transaction_id = f_blockchain.transaction_id
 GROUP BY year, month;

-- Show average gas price daily [Wei]
SELECT f_blockchain.date,
       AVG(gas_price) as average
  FROM f_blockchain
           INNER JOIN d_date dd on dd.date = f_blockchain.date
           INNER JOIN d_transaction dt on dt.transaction_id = f_blockchain.transaction_id
 GROUP BY f_blockchain.date;

-- Number of transactions with same address pairs in specific ranges
SELECT range, COUNT(*) AS amount
  FROM (SELECT CASE
                   WHEN nbr_tx = 1 THEN '1'
                   WHEN nbr_tx > 1 AND nbr_tx <= 5 THEN '2 - 5'
                   WHEN nbr_tx > 5 AND nbr_tx <= 10 THEN '5 - 10'
                   WHEN nbr_tx > 10 AND nbr_tx <= 20 THEN '11 - 20'
                   WHEN nbr_tx > 20 AND nbr_tx <= 50 THEN '21 - 50'
                   WHEN nbr_tx > 50 AND nbr_tx <= 100 THEN '51 - 100'
                   WHEN nbr_tx > 100 AND nbr_tx <= 200 THEN '101 - 200'
                   WHEN nbr_tx > 200 AND nbr_tx <= 1000 THEN '201 - 1000'
                   WHEN nbr_tx > 1000 AND nbr_tx <= 10000 THEN '1001 - 10000'
                   ELSE '> 10001'
                   END AS range
          FROM (SELECT account_from_address,
                       account_to_address,
                       COUNT(*) AS nbr_tx
                  FROM f_blockchain
                 GROUP BY account_from_address, account_to_address) AS sub) as sub2
 GROUP BY range
 ORDER BY amount DESC;

-- Find out if there are any blocks with the same timestamp
SELECT timestamp        as t,
       count(timestamp) AS nb_blocks
  FROM d_block
 GROUP by t
HAVING count(timestamp) > 1;

-- Show transactions that are in the same block
SELECT block_timestamp        AS bt,
       count(block_timestamp) as nb_tx
  FROM transactions
 GROUP by bt;

-- 149 Transactions that are in the same block
SELECT *
  FROM d_transaction
 WHERE block_timestamp = '2015-08-25 06:22:17';


/* Show how many transactions where made on each day of the week */
SELECT weekday,
       day_in_chars,
       count(weekday) AS nb_tx
  FROM f_blockchain f
           INNER JOIN d_block AS db
                      ON db.block_id = f.block_id

           INNER JOIN d_date AS dd
                      ON dd.date = f.date

           INNER JOIN d_time AS dti
                      ON dti.time = f.time

           INNER JOIN d_transaction AS dt
                      ON dt.transaction_id = f.transaction_id

 GROUP by weekday, day_in_chars;

-- Output Fact Table
SELECT *
  FROM f_blockchain
order by date, time;

-- Output Accounts and their balances (Descending order) after the first day of Ethereum being active
SELECT *
  FROM f_blockchain f
           INNER JOIN d_account da
               on f.account_from_address = da.address;

Select *
FROM d_account;
Select * from d_block ORDER BY number ;

-- Output Accounts Dimension
SELECT * FROM d_account;
Where address = '0x55192e9eef50b024e6800e4657590f33d1070545';
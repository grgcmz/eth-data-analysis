# ETH Data Analysis
Python scripts to set up a multidimensional model for Ethereuem data analysis.

## General Information
This is a step-by-step guide on how to
1.  set up an OpenEthereum (formerly known as Parity) archive node
2.  extract block and transaction data to a PostgreSQL database using [Ethereum ETL](https://github.com/blockchain-etl/ethereum-etl)
3.  transform and load the data into a star schema
4.  query the data

Listed below are the Technical Details of the Machine this was tested on:
-   Thinkpad T14 Gen 1
-   AMD Ryzen 7 PRO 4750U
-   32GB DDR4 RAM
-   1000GB NVMe SSD
-   Pop!_OS 20.10 with Kernel 5.8.0-7630-generic

## 0 Dependencies
Please first of all install the below listed dependencies with your distribution's package manager, otherwise you might run into errors.
``` bash
python3-dev libpq-dev
```

Then also pip install psycopg2 with the following command:
``` bash
pip3 install psycopg2
```

## 1 Setting up an Archive Node
### 1.1 Installing OpenEthereum
The Ethereum client OpenEthereum must also be installed. Binaries are provided in the [releases section](https://github.com/openethereum/openethereum/releases) of the project's repository on GitHub. They are available for Mac, Windows and Linux. There is also the possibility to download and run the program as a Docker image. For this project, OpenEthereum v3.2.1 was used. For further information about the installation process, please visit the OpenEthereum [github repository](https://github.com/openethereum/openethereum) or read OpenEthereum's [read the documentation.](https://openethereum.github.io/)..

**NB:** Make all binaries executable and move them to `/usr/local/bin/` in order to be able to call OpenEthereum from anywhere. 

### 1.2 Running OpenEthereum

#### 1.2.1 To Archive or not to Archive
To have all possible information about every transaction on the Ethereum blockchain readily available (without the need for further computation), it is important to run an archive node. In addition to what is usually stored in a full node, an archive node stores all states in the state-trie, all traces and additional information about accounts ([click here](https://ethereum.org/en/developers/docs/nodes-and-clients/) for more information). This means that e.g., it is possible to query the balance of any account at any point in time. Synchronizing an archive node is a very time and resource intensive process that can take up to several months to complete (for the Main Ethereum Network) and use multiple Terabytes of storage. If you are sure to never need the extra data provided by an archive node, you can go ahead and start the node with normal state pruning, no traces and without the fat-db option. Please note that it is not possible to retroactively switch to an archive node from a normal full node, so it is important to evaluate prior to the synchronization what your needs are (and what they are going to be).

#### 1.2.2 Starting the Synchronization process
For the purpose of this proof of concept, only a small part of the Ethereum blockchain was synchronized. The same concepts can be applied to a much larger data set. Also note that the archive node in this specific case, is mostly used for future proofing the node. For the time being, all data used can also be obtained using a full node.

The command used in testing to start synchronizing with the main Ethereum Network is the following:

`openethereum --mode active --tracing on --pruning archive --fat-db on --no-warp`

Listed below are the meanings of each flag that was set in the command:

-   `--mode active` continuously synchronize the chain. Can also be set to `offline` if no more synchronization is wished or needed
-   `--tracing on` the transaction's execution should be fully traced
-   `--pruning archive` keeps the complete state-trie and thus ensures the highest level of detail
-   `--fat-db on` Stores metadata about accounts and keys that would otherwise not be stored.
-   `--no-warp` Disables warp mode, which would otherwise synchronize starting from a snapshot

While OpenEthereum is running, an inter process communication file is created named `jsonrpc.ipc`. By default, it is located in `~/.local/share/openethereum/`. This path will later be needed for the ETL process.

Below is a screenshot of OpenEthereum running in a terminal window. Marked in red is the location of the database (and as such the location of the IPC file), and the options chosen for the node. 

![Terminal window showing OpenEthereum running](/images/terminal_openeth.png)

## 2 Automated ETL

To extract data from the OpenEthereum node and stream it into a PostgreSQL database, [Ethereum ETL](https://github.com/blockchain-etl/ethereum-etl) will be used. Ethereum ETL is an open source tool developed by Evgeny Medvedev and the D5 team. It is a collection of Python scripts that interface with an Ethereum node (either Geth, OpenEthereum or Infura) to extract data and load it into a PostgreSQL database or export it to a CSV file. Please visit their GitHub repository to learn more about the tool. 

### 2.1 Installing Ethereum ETL

The only prerequisite for installing Ethereum ETL is Python 3.5.3 or newer installed on your machine. Then running the following commands will install Ethereum ETL and the streaming mode:
```
pip3 install ethereum-etl
pip3 install ethereum-etl[streaming]
```

by running the following command you can ensure that it was successfully installed and see which version is running:
`ethereumetl --version`

**NB**: You might see the following message in the terminal when running Ethereum ETL: `Symbolic Execution not available: No module named  'mythril.ether'`. This can be ignored. As stated by Evgeny Medvedev in a now closed [issue](https://github.com/blockchain-etl/ethereum-etl/issues/173) about this topic, "You can safely ignore "Symbolic Execution not available" warning. Symbolic execution is not used by ethereum-etl.[...]".

### 2.2 Streaming Data to PostgreSQL

In order to stream data into a PostgreSQL database you need to have a database setup with the correct schema in place. This will all be taken care of by a handy Python script we created. For instructions on how to do this manually, please read through the [section about manually streaming to your database](https://github.com/grgcmz/eth-data-analysis/blob/main/README.md#31-manually-streaming-data-to-your-database). Once a database is up and running and OpenEthereum is also syncing, you have two options. You can manually do the rest of the work as described in the next section, or you can use the automation script. Here is a short instruction on how to use the script.

First off, make sure you have installed the dependencies listed at the top of the README. Then clone this repository and cd into that directory by running the following commands:
```bash 
git clone https://github.com/grgcmz/eth-data-analysis.git ~/eth-data-analysis
cd ~/eth-data-analysis
```

![eth_etl_wrapper.gif](/images/eth_etl_wrapper.gif)

Now run the script using Python3. You will be asked if you want to create the database.ini file by answering either yes (y) or no (n) - I suggest you answer "y" for yes. This file is used later to connect to the database, set up the schema and do all the transformation and loading needed for the multidimensional model.
```bash
python3 eth_etl_wrapper.py
```

You will then be asked to provide some information about your database, as well as the location to the IPC file of your running OpenEthereum client (see [this section](https://github.com/grgcmz/eth-data-analysis/blob/main/README.md#122-starting-the-synchronization-process) for more information). When asked about from where to start the extraction, choose the first option and enter the block number you would like to start extracting from. If you have run Ethereum ETL before, you might have a last_synced_block.txt file, which you can use by choosing the second option. If you have such a file, but wish to start the extraction from a specific block, please delete the file. Otherwise, Ethereum ETL will fail with an error message. 

This information is then provided to the call to Ethereum ETL. You will be then asked if you wish to have the script create the extraction schema for you. I suggest you answer yes, as the script will also truncate the `transactions` and `blocks` table in case you still have data inside from a past extraction (especially important before updating the database!). Type '1', hit Enter, then '5' to commit and hit Enter again. If everything is correct, you will see a(n unreadable) stream of messages signaling that Ethereum ETL is working correctly. You can check in your database the last imported block by running a query like the following:
```sql
SELECT block_number
  FROM blocks
 ORDER BY block_number DESC;
```
 Once you have reached the desired block, type <kbd> ctrl </kbd> + <kbd>c</kbd> to stop the extraction process. 
The command that was generated by the script is stored in a file called ethereum_etl_command.txt. This command can then also be used to manually run Ethereum ETL. At this point the `last_synced_block.txt` file will also have been generated by Ethereum ETL.


**NB:** The first 50'000 blocks or so do not contain any transactions, so it will take some time (5-10 minutes depending on hardware) before you see data in the transactions table.

### 2.3 Transformation and Loading
Now there should be two tables in your database: `transactions` and `blocks`. They should be both populated with data. 
The next step is to run another Python script that will help in creating all the tables needed, transform the data into different dimensions and load them in the final star schema.  
Start by running the Python script as follows:
```bash
python3 etl_postgres.py 
```

The script will start by asking if you want to create a `database.ini` file. If you did already in the last step, just type 'n' and ENTER, else type 'y' and answer follow the displayed instructions. Once a 'database.ini' file has been created (or once you have pressed 'n') you will be asked which tables you want to create: 
```text
1. Table for Ethereum ETL
2. Star Schema
3. ETL Tables
4. All Tables
5. Commit and Quit
```
Choose number 2 to create the star schema and then number 3 to extract, transform and load the data into the corresponding tables.

**NB*: if you were to choose option 1 or 4 now, you would truncate the transactions and blocks table and thus loose the data you have extracted in the last step...

Now everything will be set up and you can start querying the data.

### 2.4 Updating the Database
In order to update the database, you must run Ethereum ETL again, redo the transformations and load the data into the database. For this, make sure that there is an OpenEthereum node running. Then, run `eth_etl_wrapper.py` again as explained [here](https://github.com/grgcmz/eth-data-analysis/blob/main/README.md#22-streaming-data-to-postgresql). When prompted to choose what to do, choose option 1 and then option 5 to commit the changes. 

Afterwards, run `etl_postgres.py` as described [here](https://github.com/grgcmz/eth-data-analysis/blob/main/README.md#23-transformation-and-loading). **IMPORTANT**: This time, only choose option 3 when prompted and commit using option 5. DO NOT select option 2, as it will set up the star schema from scratch, i.e. it will delete all the data already loaded. 

## 3 Manual ETL
Make sure you have installed Ethereum ETL. If you have not, please go through [section 2.1](https://github.com/grgcmz/eth-data-analysis/blob/main/README.md#122-starting-the-synchronization-process) and do it before moving on. 
### 3.1 Manually streaming data to your database

If you wish to manually run Ethereum ETL, make sure that you have the correct schema set up. You can run the sql statements specified [here](01_extraction_tables.sql) on your database, which will create two tables: transactions and blocks. Then you can run the following command, which will start extracting data from the node, transforming it and loading it into the tables of the database:

```ethereumetl stream --provider-uri file://$HOME/.local/share/openethereum/jsonrpc.ipc --start-block 0 --output postgresql+pg8000://[user]:[password]@[IP_Address]:[Port]/[database_name]```

On MacOS the path to the ipc file will be different, but the rest of the command should stay the same.

In our specific case the database is running locally on the default port, it is called 'ethereum' and belongs to the user 'postgres' with the password 'postgres'. This is the command used:

```ethereumetl stream --provider-uri file://$HOME/.local/share/openethereum/jsonrpc.ipc --start-block 0 --output postgresql+pg8000://postgres:postgres@127.0.0.1:5432/ethereum -e transaction,block```

The above command tells Ethereum ETL to use the data provided by our local OpenEthereum node, to start syncing from block 0 and to load that data into the PostgreSQL database running on localhost on port 5432. By default, blocks, transactions, logs and token transfers are extracted, transformed and loaded. By using the `-e` flag followed by any combination of entities, one can extract only the data needed. As of now, only blocks, transactions, traces, token transfers, receipts and logs can be streamed using the stream command. Contract and token data can only be obtained in a CSV format for now.

If the command is stopped before finishing, or once it has finished, a file called `last_synced_block.txt` is created in the current directory. This will be used in the case where the stream command is run again without providing the `--start-block` flag. There are further options that can be specified for this command which can be found [here](https://github.com/blockchain-etl/ethereum-etl/blob/develop/docs/commands.md#stream).

### 3.2 Creating the Extraction Schema
Ethereum ETL needs a specific Database Schema to work properly. By running the `CREATE TABLE` statements specified in [01_extraction_tables.sql](/sql_scripts/01_extraction_tables.sql) in a postgreSQL database, the correct schema for the ETL process will be set up.

### 3.3 Star Schema
Before starting the ETL process, the star schema must be created. To do this, we have to run [02_star_schema.sql](/sql_scripts/02_star_schema.sql). This will set up the star schema as shown in the image below. 

![Star schema](/images/star_schema.png)

### 3.4 ETL Process
The final step consists of extracting the data from the extraction schema, carrying out transformations of the data and loading the data into the final star schema. All required SQL statements are specified in [03_etl.sql](/sql_scripts/03_etl.sql). 

## 4 Querying Data
Now the data should be in the star schema, and queries can be carried out. Some example queries are provided in [queries.sql](/sql_scripts/queries.sql). Running the below query for example, gives us a daily average of the number of transactions per block.

```sql
SELECT date, ROUND(AVG(tx_count), 2) AS average
  FROM (
           SELECT date, COUNT(*) AS tx_count
             from f_blockchain
            GROUP BY date, block_id) AS sub
 GROUP BY date;
```

Copying the results of the query into a spreadsheet, and plotting them gives us the graph shown in the image below. The results here are based on a reduced data set spanning the first nine month after the lunch of the Ethereum network. 

![Result of example Query](/images/results_query_tx_per_block.png)

# ETH Data Analysis

## General Information
This is a step-by-step instruction on how to
1.  Set up an OpenEthereum (formerly known as Parity) archive node
2.  Extract, Transform and Load Block and Transaction data to a PostgreSQL database using Ethereum-ETL
3.  Query the data

Listed below are the Technical Details of the Machine this was tested on:
-   Thinkpad T14 Gen 1
-   AMD Ryzen 7 PRO 4750U
-   32GB DDR4 RAM
-   1000GB NVMe SSD
-   Pop!_OS 20.10 with Kernel 5.8.0-7630-generic


## 1 Setting up an Archive Node
### 1.1 Installing OpenEthereum

OpenEthereum can be installed by downloading the binaries provided in the [Releases Section](https://github.com/openethereum/openethereum/releases) of the Repository. They are available for Mac, Windows and Linux. There is also the possibility to download and run it as a Docker Image. For this project, OpenEthereum v3.1.1-rc.1 was used. For further information about the installation process, please visit the OpenEthereum [Github Repository](https://github.com/openethereum/openethereum) or [read the documentation.](https://openethereum.github.io/)

### 1.2 Running OpenEthereum

#### To Archive or not to Archive
To have all possible information about every transaction on the Ethereum blockchain readily available (without further computation), it is important to run an archive node. In addition to what is usually stored in a full node, an archive node stores all states in the state-trie, all traces and additional information about accounts. Synchronizing an archive node is a very time and resource intensive process that can take up to several months to complete (for the Main Ethereum Network) and use multiple Tera Bytes of storage. If you are sure to never need the extra data provided by an archive node, you can go ahead and start the node with normal state pruning, no traces and without the fat-db option. Please note that it is not possible to retroactively switch to an archive node from a normal full node, so it is important to evaluate prior to the synchronization what your needs are (and what they are going to be). 

#### Starting the Synchronization process
For the purpose of this proof-of-concept, only a small part of the Ethereum Blockchain was synchronized. The same concepts can be applied to a much larger dataset. Also note that the archive node in this specific case, is mostly used for future proofing the node. For the time being, all data used can also be obtained using a full node.

The command used in testing to start synchronizing with the main Ethereum Network is the following:

`openethereum mode=active tracing=on pruning=archive fat-db=on no-warp`

Listed below are the meanings of each flag that was set in the command:

-   `mode=active` continuously synchronize the chain. Can also be set to `offline` if no more synchronization is wished or needed
-   `tracing=on` the transaction&rsquo;s execution should be fully traced
-   `pruning=archive` keeps the complete state trie and thus ensures the highest level of detail
-   `fat-db=on` Stores metadata about accounts and keys that would otherwise not be stored.
-   `no-warp` Disables warp mode, which would otherwise synchronize starting from a snapshot

While OpenEthereum is running, an inter process communication file is created named `jsonrpc.ipc`. By default, it is located in `~/.local/share/openethereum/`. This path will later be needed for the ETL process.

## 2 ETL process

For the ETL process, Ethereum ETL will be used, which can be found [here](https://github.com/blockchain-etl/ethereum-etl). Ethereum ETL is an open source tool developed by Evgeny Medvedev and the D5 team. It is a collection of python scripts that interface with an ethereum node (either Geth, OpenEthereum or Infura) and extract data, transform it and load it into a PostgreSQL database or export it to a CSV file.

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

In order to stream data into a PostgreSQL database you need to have a database setup with the correct Schema in place. This will all be taken care of by a handy python script. For instructions on how to do this manually, please read through the section about databases. Once a database is up and running and OpenEthereum is also syncing, you have two options. You can manually do the rest of the work as described in the next section, or you can use my automation script. Here is a short instruction on how to use the script.

First start off by cloning this repository and cd into that directory by running the following commands:
```bash
git clone https://github.com/grgcmz/eth-data-analysis.git ~
cd ~/eth-data-analysis
```
Now run the script using python3. You will be asked if you want to create the database.ini file by answering either yes (y) or no (n) - I suggest you do.
```bash
python3 eth_etl.py
```

You will then be asked to provide some information about your database, and the location to the IPC file of your running OpenEthereum client (see [this section]() for more information). When asked about from where to start the extraction, choose the first option and enter the block number you would like to start extracting from. If you have run Ethereum ETL before, you might have a last_synced_block.txt file, which you can use by choosing the second option. 

This information is then provided to the call to Ethereum ETL. Then, you will be asked if you wish to have the script create the extraction schema for you. Unless you have it already setup, I suggest you answer yes. Choose the first option and hit Enter. If everything goes right, you will see a stream of messages signaling that Ethereum ETL is (probably) working correctly.

**NB:** The first 50'000 blocks or so do not contain any transactions, so it will take some time (around 10 minutes depending on hardware) before you see data in the transactions table. 

### 2.3 Manually Streaming Data to PostgreSQL

If you wish to manually run Ethereum ETL, make sure that you have the correct schema set up. You can run the sql statements specified [here](01_extraction_tables.sql) on your database, which will create two tables: transactions and blocks. Then you can run the following command, which will start extracting data from the node, transforming it and loading it into the tables of the database:

```ethereumetl stream --provider-uri file://$HOME/.local/share/openethereum/jsonrpc.ipc --start-block 0 --output postgresql+pg8000://[user]:[password]@[IP_Address]:[Port]/[database_name]```
On macOS the path to the .ipc file will be different, but the rest of the command should stay the same.

In my specific case the database is running locally on the default port, it is called etl and belongs to the user postgres with the password postgres. This is the command used:

```ethereumetl stream --provider-uri file://$HOME/.local/share/openethereum/jsonrpc.ipc --start-block 0 --output postgresql+pg8000://postgres:postgres@127.0.0.1:5432/etl -e transaction,block```

The above command tells Ethereum ETL to use the data provided by our local OpenEthereum node, to start syncing from block 0 and to load that data into the postgres database running on localhost on port 5432. By default, blocks, transactions, logs and token transfers are extracted, transformed and loaded. By using the `-e` flag followed by any combination of entity names, one can extract only the data needed. As of now, only blocks, transactions, traces, token transfers, receipts and logs can be streamed using the stream command. Contract and Token data can only be obtained in a CSV format for now.

If the command is stopped before finishing or once it has finished, a file called `last_synced_block.txt` is created in the current directory. This will be used in the case where the stream command is run again without providing the `--start-block` flag. There are further options that can be specified for this command which can be found [here](https://github.com/blockchain-etl/ethereum-etl/blob/develop/docs/commands.md#stream).

## 3 PostgreSQL Database
### 3.1 Installing PostgreSQL

### 3.2 Creating the Extraction Schema
Ethereum ETL needs a specific Database Schema to work properly. By running the `CREATE TABLE` statements specified in [01_extraction_tables.sql](/sql_scripts/01_extraction_tables.sql) in a postgreSQL database, the correct schema for the etl process will be set up.

### 3.3 Star Schema
- Script for [Star schema](/sql_scripts/02_star_schema.sql)
- Script for [ETL](/sql_scripts/03_etl.sql)

![Star schema](/images/star_schema.png)

## 4 Querying Data
[Queries](/sql_scripts/queries.sql)

Result of a test query on a small dataset:

![Result of test Query](/images/results_query_weekday.png)

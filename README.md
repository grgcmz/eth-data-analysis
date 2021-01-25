# ETH Data Analysis

## General Information
This is a step-by-step instruction on how to
1.  Set up an OpenEthereum (formerly known as Parity) archive node
2.  Extract, Transform and Load Block and Transaction data to a PostgreSQL database using Ethereum-ETL
3.  Query the data

Listed below are the Techincal Details of the Machine this was tested on:
-   Thinkpad T14 Gen 1
-   AMD Ryzen 7 PRO 4750U
-   32GB DDR4 RAM
-   1000GB NVMe SSD
-   Pop!_OS 20.10 with Kernel 5.8.0-7630-generic

## 1 Setting up an Archive Node
### 1.1 Installing OpenEthereum

OpenEthereum can be installed by downloading the binaries provided in the [Releases Section](https://github.com/openethereum/openethereum/releases) of the Repository. They are available for Mac, Windows and Linux. There is also the possibility to download and run it as a Docker Image. For this project, OpenEthereum v3.1.1-rc.1 was used. For further information about the installation process, please visit the OpenEthereum [Github Repository](https://github.com/openethereum/openethereum) or [read the documentation.](https://openethereum.github.io/)

### 1.2 Running OpenEthereum

To have access to all possible information stored in the Ethereum blockchain it is important to run an archive node. This is a very time and resource intensive process that can take up ot several months to complete and use multiple Tera Byte of storage. For the purpose of this proof-of-concept, only a small part of the Etheruem Blockchain was syncronized.
The command used in testing to start syncronizing with the mains network is the following:
`openethereum mode=active tracing=on pruning=archive fat-db=on no-warp`
The options specified in the command are not all strictly necessary since some are implied. Listed below are the meanings of each flag that was set in the command:

-   `mode=active`: continuosly syncronize the chain. Can also be set to `offline` if no more syncronization is wished or needed
-   `tracing=on`: the transaction&rsquo;s execution should be fully traced
-   `pruning=archive`: keeps the complete state trie and thus ensures highest level of detail
-   `fat-db=on`:
-   `no-warp`: Disables warp mode, which would syncronize starting from a snapshot

While OpenEthereum is running, an inter process communication file is created named `jsonrpc.ipc`. By default it is located in `~/.local/share/openethereum/`. This path will later be needed for the ETL process.

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
NB: You might see the following message in the terminal when running ethereumetl: `Symbolic Execution not available: No module named  'mythril.ether'`. This can be ignored. As stated by Evgeny Medvedev in a now closed [issue](https://github.com/blockchain-etl/ethereum-etl/issues/173) about this topic, "You can safely ignore "Symbolic Execution not available" warning. Symbolic execution is not used by ethereum-etl.[...]".


### 2.2 Streaming Data to PostgreSQL

In order to stream data into a PostgreSQL database you need to have one setup with the correct Schema in place. For instructions, please read through the section about databases. Once the database is up and running and OpenEthereum is also running, running the following command will start extracting data from the node, transforming it and loading it into the tables of the database:

**Linux**

```ethereumetl stream --provider-uri file://$HOME/.local/share/openethereum/jsonrpc.ipc --start-block 0 --output postgresql+pg8000://[user]:[password]@[IP_Address]:[Port]/[database_name]```

In my specific case the database is running locally on the default port and it is called etl and belongs to the user postgres with the password postgres. This is the command used:

```ethereumetl stream --provider-uri file://$HOME/.local/share/openethereum/jsonrpc.ipc --start-block 0 --output postgresql+pg8000://postgres:postgres@127.0.0.1:5432/etl```

**MacOS**

The path to the .ipc file will be different, but the rest of the command should stay the same.

The above command tells Ethereum ETL to use the data provided by our local openethereum node, to start syncing from block 0 and to load that data into the postgres database running on localhost on port 5432. By default blocks, transactions, logs and token transfers are extracted, transformed and loaded. By using the `-e` flag followed by any combination of entity names, one extract only the data needed. As of now, only blocks, transactions, traces, token transfers, receipts and logs can be streamed using the stream command. Contract and Token data can only be obtained in a CSV format for now.

If the command is stopped before finishing or once it has finished, a file called `last_synced_block.txt` is created in the current directory. This will be used in the case where the stream command is run again without providing the `--start-block` flag. There are further options that can be specified for this command which can be found [here](https://github.com/blockchain-etl/ethereum-etl/blob/develop/docs/commands.md#stream).

## 3 PostgreSQL Database
### 3.1 Installing PostgreSQL

### 3.2 Creating the Temporary Schema
Ethereum ETL needs a specific Database Schema to work properly. By running the file etl_schema.sql in a postgreSQL database, the correct schema for the etl process will be set up. You just need to know the database name,  

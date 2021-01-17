
# Table of Contents

1.  [eth-data-analysis](#org9aa3b5d)
    1.  [0. General Information](#org0ab341e)
    2.  [1. Setting up an archive node](#orgb92184e)
        1.  [1.1 Installing OpenEthereum](#orga96cf11)
        2.  [1.2 Running OpenEthereum](#org8edd989)
    3.  [2. ETL process](#org3320015)
        1.  [2.1 Installing Ethereum ETL](#orga6e2da0)
        2.  [2.2 Streaming Data to PostgreSQL](#org9d01acc)



<a id="org9aa3b5d"></a>

# eth-data-analysis

This is a step-by-step instruction on how to

1.  Set up an OpenEthereum (formerly known as Parity) archive node
2.  Extract, Transform and Load Block and Transaction data to a PostgreSQL database using Ethereum-ETL
3.  Query the data


<a id="org0ab341e"></a>

## 0. General Information

Listed below are the Techincal Details of the Machine this was tested on:

-   Thinkpad T14 Gen 1
-   AMD Ryzen 7 PRO 4750U
-   32GB DDR4 RAM
-   1000GB NVMe SSD
-   Pop!<sub>OS</sub> 20.10 with Kernel 5.8.0-7630-generic


<a id="orgb92184e"></a>

## 1. Setting up an archive node


<a id="orga96cf11"></a>

### 1.1 Installing OpenEthereum

OpenEthereum can be installed by downloading the binaries provided in the [Releases Section](https://github.com/openethereum/openethereum/releases) of the Repository. They are available for Mac, Windows and Linux. There is also the possibility to download and run it as a Docker Image. For this project, OpenEthereum v3.1.1-rc.1 was used. For further information about the installation process, please visit the OpenEthereum [Github Repository](https://github.com/openethereum/openethereum) or [read the documentation.](https://openethereum.github.io/)


<a id="org8edd989"></a>

### 1.2 Running OpenEthereum

To have access to all possible information stored in the Ethereum blockchain it is important to run an archive node. This is a very time and resource intensive process that can take up ot several months to complete and use multiple Tera Byte of storage. For the purpose of this proof-of-concept, only a small part of the Etheruem Blockchain was syncronized.
The command used in testing to start syncronizing with the mains network is the following:
\`openethereum &#x2013;mode=active &#x2013;tracing=on &#x2013;pruning=archive &#x2013;fat-db=on &#x2013;no-warp\`
The options specified in the command are not all strictly necessary since some are implied. Listed below are the meanings of each flag that was set in the command:

-   \`mode=active\`: continuosly syncronize the chain. Can also be set to \`offline\` if no more syncronization is wished or needed
-   \`tracing=on\`: the transaction&rsquo;s execution should be fully traced
-   \`pruning=archive\`: keeps the complete state trie and thus ensures highest level of detail
-   \`fat-db=on\`:
-   \`no-warp\`: Disables warp mode, which would syncronize starting from a snapshot

While OpenEthereum is running, an inter process communication file is created named \`jsonrpc.ipc\`. By default it is located in \`~/.local/share/openethereum/\`. This path will later be needed for the ETL process.


<a id="org3320015"></a>

## 2. ETL process

For the ETL process, Ethereum ETL will be used, which can be found [here](https://github.com/blockchain-etl/ethereum-etl). Ethereum ETL is an open source tool developed by Evgeny Medvedev and the D5 team. It is a collection of python scripts that interface with an ethereum node (either Geth, OpenEthereum or Infura) and extract data, transform it and load it into a PostgreSQL database or export it to a CSV file.


<a id="orga6e2da0"></a>

### 2.1 Installing Ethereum ETL

The only prerequisite for installing Ethereum ETL is Python 3.5.3 or newer installed on your machine. Then running the following command will install Ethereum ETL:
\`pip3 install ethereum-etl\`
by running the following command you can ensure that it was successfully installed and see which version is running:
\`ethereumetl &#x2013;version\`
NB: You might see the following message in the terminal when running ethereumetl: \`Symbolic Execution not available: No module named &rsquo;mythril&rsquo;\`. This can be ignored. As stated by Evgeny Medvedev in a now closed [issue](https://github.com/blockchain-etl/ethereum-etl/issues/173) about this topic, &ldquo;You can safely ignore &rdquo;Symbolic Execution not available&rsquo; warning. Symbolic execution is not used by ethereum-etl. This warning is output by a dependency library used in ethereum-etl <https://github.com/tintinweb/ethereum-dasm/blob/master/ethereum_dasm/evmdasm.py>.&ldquo;


<a id="org9d01acc"></a>

### 2.2 Streaming Data to PostgreSQL

In order to stream data into a PostgreSQL database you need to have one setup with the correct Schema in place. For instructions, please read through the section about databases.


## Dataset

Ethereum data from June 2021

- Blocks 12545219 to 12738508
- Block timestamps 2021-06-01 00:00:05 to 2021-06-30 23:59:51

## ResearchHub and Research Coin (RSC)

RSC token

- ERC-20 standard
- Address 0xd101dcc414f310268c37eeb4cd376ccfa507f571
- Contains all on-chain transfers between RSC holders and exchanges
- Documentation
  - https://www.researchhub.com/about
  - https://www.notion.so/ResearchCoin-21d1af8428824915a4d1f7c0b6b77cb4
  - https://www.researchhub.com/paper/819400/the-researchcoin-whitepaper

## Queries of interest

- Amounts over time
- On the web platform, what is the number of publications and authors?
- On the blockchain, what is the number of account holders who interacted with the token contract?
- Account holders transactions and balances
  - Number of transactions
  - Amounts
- Account holders use of research coin and possible motivations
  - RSC sent and received from exchanges
  - Number of accounts which sent and received from exchanges and did not send to exchanges
  - Velocity of RSC, i.e. the average duration until coins are exchanged
  - Activity of users, time or frequency of transactions

## Analysis

Template for the retrieval of data of transactions made in June 2021 with all transactions at the most granular level

```
select  	*
from 		f_blockchain fb
				inner join d_block db on fb.block_id = db.block_id
				inner join d_transaction dt on fb.transaction_id = dt.transaction_id
				inner join d_account daf on fb.account_from_address = daf.address 
				inner join d_account dat on fb.account_to_address = dat.address 
				inner join d_date dd on fb.date = dd.date
				inner join d_time dti on fb.time = dti.time
where 		to_address = '0xd101dcc414f310268c37eeb4cd376ccfa507f571';
```

### Basic analysis

Total transactions in June 2021

```
select  	count(*)
from 		f_blockchain fb
where 		account_to_address = '0xd101dcc414f310268c37eeb4cd376ccfa507f571';
```

```
29
```

### Token transfers

#### Analysis using method_id and method_parameters contained in the input data field of transactions.

##### ERC-20 token methods 

```
select  	method_id, count(method_id)
from 		f_blockchain fb 
			inner join d_transaction dt on fb.transaction_id = dt.transaction_id 
where 		to_address = '0xd101dcc414f310268c37eeb4cd376ccfa507f571'
group by 	method_id
order by 	method_id asc;
```

```
0x095ea7b3	15
0xa9059cbb	14
```

Methods used

- 0x095ea7b3 is the approve method of ERC-20
  - approve(address spender, uint256 amount) → bool
  - Source: https://docs.openzeppelin.com/contracts/3.x/api/token/erc20#IERC20-Transfer-address-address-uint256-
- 0xa9059cbb is the transfer method of ERC-20
  - transfer(address recipient, uint256 amount) → bool
  - Source: https://docs.openzeppelin.com/contracts/3.x/api/token/erc20#IERC20-approve-address-uint256-


##### ERC-20 functions and parameters

###### Example for 0xa9059cbb (transfer)

```
select  hash, substr(method_id,1,64) as method, substr(method_parameters,1) as parameters
from 	f_blockchain fb 
		inner join d_transaction dt on fb.transaction_id = dt.transaction_id 
where 	to_address = '0xd101dcc414f310268c37eeb4cd376ccfa507f571';
```

```
0x135cfbf83302438aad8949cb4916d3c84aadbe1176b86d8f40cdaed2dd186001	0xa9059cbb	000000000000000000000000e34eaba455a7aec993a3d750c9c9c8750bc5df2d0000000000000000000000000000000000000000000022eb3f35a25b1a100000
```

Result:

- Transaction hash 0x135cfbf83302438aad8949cb4916d3c84aadbe1176b86d8f40cdaed2dd186001
- Method ID 0xa9059cbb
- Parameter 1: 000000000000000000000000e34eaba455a7aec993a3d750c9c9c8750bc5df2d
  - To address 0xe34eaba455a7aec993a3d750c9c9c8750bc5df2d
  - Address of an RSC account holder
- Parameter 2: 0000000000000000000000000000000000000000000022eb3f35a25b1a100000
  - Amount 22eb3f35a25b1a100000_16
  - RSC contract is configured with 18 decimal places
  - Conversion:  Amount_16 /10^18 
    - 22EB3F35A25B1A100000_16 = 164900000000000000000000 / 10^18 = 164900

Note: for hex conversions within PostgreSQL see https://stackoverflow.com/questions/8316164/convert-hex-in-text-representation-to-deciml-number .

###### Token swap transactions

For exchanges between RSC and other coins or tokens to occur, the account holder sends an approve transaction to the RSC contract with the exchange smart contract address as *spender* parameter:

> Transaction with method 0x095ea7b3 (approve)

```
select  hash, block_number, from_address, 
		substr(method_id,1,64) as method, substr(method_parameters,1) as parameters
from 	f_blockchain fb 
		inner join d_transaction dt on fb.transaction_id = dt.transaction_id 
where 	to_address = '0xd101dcc414f310268c37eeb4cd376ccfa507f571'
and     method_id  = '0x095ea7b3';
```

```
0xdb40d0c6fb80ccee28060dc9171429264b27ba57a03dbfbfe4b31e46fb0cf013 12694950	0xbde541cb55047b09daf92ea29837a184b5103d6a	0x095ea7b3	0000000000000000000000007a250d5630b4cf539739df2c5dacb4c659f2488dffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
```

Result:

- Transaction hash 0xdb40d0c6fb80ccee28060dc9171429264b27ba57a03dbfbfe4b31e46fb0cf013
- Block 12694950
- From account holder 0xbde541cb55047b09daf92ea29837a184b5103d6a
- Method ID 0x095ea7b3
- Parameter 1: 0000000000000000000000007a250d5630b4cf539739df2c5dacb4c659f2488d
  - Spender address 0x7a250d5630b4cf539739df2c5dacb4c659f2488d
  - Well-known address of Uniswap decentralized exchange
- Parameter 2: ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
  - Approval of an unlimited amount for future token exchanges through uniswap



Secondly, the account holder sends a transaction to the exchange smart contract, any time after the approval transaction. This transaction is the token exchange with parameters such as the amount in *amountIn*, the *to* address where to send the exchanged tokens, and a *path* which is an array of multiple addresses of ERC-20 smart contracts. Each pair of addresses specifies an exchange.

> Retrieve token exchange transactions from the account holder to the exchange after block 12694950

```
select  hash, substr(method_id,1,64) as method, substr(method_parameters,1) as parameters
from 	f_blockchain fb 
		inner join d_transaction dt on fb.transaction_id = dt.transaction_id 
where 	from_address = '0xbde541cb55047b09daf92ea29837a184b5103d6a' and
		to_address = '0x7a250d5630b4cf539739df2c5dacb4c659f2488d' and
		block_number > 12694950;
```

```
0xf08ced33fe23772836d3f7b8b69b067e2aae9b874ac6e000a413130ca8b5a1f3	0x38ed1739	0000000000000000000000000000000000000000000000a2a15d09519be000000000000000000000000000000000000000000000000000000000000003142f6900000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000bde541cb55047b09daf92ea29837a184b5103d6a0000000000000000000000000000000000000000000000000000000060d41a0a0000000000000000000000000000000000000000000000000000000000000003000000000000000000000000d101dcc414f310268c37eeb4cd376ccfa507f571000000000000000000000000c02aaa39b223fe8d0a0e5c4f27ead9083c756cc2000000000000000000000000a0b86991c6218b36c1d19d4a2e9eb0ce3606eb48
```

Result:

- Transaction 0xf08ced33fe23772836d3f7b8b69b067e2aae9b874ac6e000a413130ca8b5a1f3
- Method 0x38ed1739 of the uniswap exchange smart contract
  - Refers to swapExactTokensForTokens(uint256 amountIn, uint256 amountOutMin, address[] path, address to, uint256 deadline)
- Parameters: When decoding the parameters, the handling of datatypes and arrays in the EVM/Solidity needs to be taken into account. The array parameter with an a priori unknown number of entries is given last.

  1. amountIn: a2a15d09519be00000
  2. amountOutMin: 03142f69
     The minimal amount guaranteed by the exchange
  3. To: bde541cb55047b09daf92ea29837a184b5103d6a
  4. Deadline: 60d41a0a
     Timeout to prevent larger price changes
  5. Path: Exchange through three ERC-20 tokens
     1. d101dcc414f310268c37eeb4cd376ccfa507f571
        Exchange from RSC at address 0xd101dcc414f310268c37eeb4cd376ccfa507f571
     2. c02aaa39b223fe8d0a0e5c4f27ead9083c756cc2
        Exchange to WETH at address 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
     3. a0b86991c6218b36c1d19d4a2e9eb0ce3606eb48
        Exchange to USDC at address 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
- Summary: 3000 RSC exchanged to WETH, exchanged to USDC
  - In the end, 3000 RSC are exchanged for 0.027299364194487752 WETH and 51.998654 USDC
  - https://etherscan.io/tx/0xf08ced33fe23772836d3f7b8b69b067e2aae9b874ac6e000a413130ca8b5a1f3


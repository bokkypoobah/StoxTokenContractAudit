# Stox Token Contract Audit

Status: Work in progress

From the [whitepaper](https://www.stox.com/assets/stox-whitepaper.pdf):

> [Stox](https://www.stox.com) is an open source, Ethereum based platform for prediction markets where people can trade the outcome of events in almost
> any imaginable category - sports, celebrity marriages, election results and even the weather. The platform targets mainstream
> audiences and provides a haven for investors to find refuge from traditional financial instruments and participate in prediction
> events with the purpose of making profit, leveraging their knowledge in almost any imaginable field.

Bok Consulting Pty Ltd was commissioned to perform an audit on the crowdsale and token Ethereum smart contract for the upcoming
Stox crowdsale.

This audit has been conducted on the Stox source code in commits [ee616a27](https://github.com/stx-technologies/stox-token/tree/ee616a272594190774946834f75d8d6cbeff07b4),
[b4702686](https://github.com/stx-technologies/stox-token/tree/b4702686748bbd2e00c6f85c375e0f8164d448bf) and
[3ebb5a2d](https://github.com/stx-technologies/stox-token/tree/3ebb5a2d9d393d0e39d824707518fdc3c87bad67).

I am currently merging the changes for [20925fd8](https://github.com/stx-technologies/stox-token/tree/20925fd8b97746f085b95af03173d65a2ddaa504).

<br />

### Potential Vulnerabilities

No potential vulnerabilities have been identified in the crowdsale and token contract.

<br />

### Crowdsale Contract

Ethers contributed by participants to the crowdsale contract will result in the STX tokens being allocated to the participant's 
account. The ethers are immediately transferred to the crowdsale multisig wallet, reducing the risk of the loss of ethers in the
customised crowdsale and token contract.

<br />

### Token Contract

The *StoxSmartToken* contract is built upon the Bancor *SmartToken*, and the Bancor *SmartToken* has a few issues that potential investors should be
aware of:

* The transfer of tokens can be disabled and re-enabled by the owner by executing the `SmartToken.disableTransfers(...)` function declared in the
  Bancor *SmartToken* contract.
* The owner of the *StoxSmartToken* contract has the ability to execute `SmartToken.issue(...)` to mint any number of new tokens for any account, at
  any time
* The owner of the *StoxSmartToken* contract has the ability to execute `SmartToken.destroy(...)` to destroy the tokens for any account, at any time
* The Bancor GitHub repository files have been updated recently. There is a possibility that some of these files have not been fully
  tested. Please make sure that you are using the correct version of the Bancor source code. In this audit, I have reviewed the 
  *crowdsale_audit* branch, as these most closely match the Bancor SmartToken deployed on the Ethereum Mainnet.

The token contract is ERC20 compliant with the following notes:

* `decimals` is defined as `uint8` instead of `uint256`
* `transfer(...)` and `transferFrom(...)` will throw instead of returning false if there is an error
* `transfer(...)` and `transferFrom(...)` have not been built with a check on the size of the data being passed
* `approve(...)` requires that the approval limit is currently set to 0 before a limit can be set.

Transferring the tokens to the *StoxSmartToken* contract will burn the tokens, reducing the `totalSupply`

<br />

### Trustee Contract

The *Trustee* contract will lock the tokens for an account to prevent the tokens from being transferred. For the accounts used as examples in the
source code, the trustee grant is specified as **revocable**. This allows the *Trustee* contract owner to revoke the tokens assigned to the account
and these revoked tokens are transferred into the owner's token balance.

<br />

<hr />

## Table Of Contents

* [Summary](#summary)
* [Table Of Contents](#table-of-contents)
* [Recommendations](#recommendations)
* [Potential Vulnerabilities](#potential-vulnerabilities)
* [Scope](#scope)
* [Limitations](#limitations)
* [Due Diligence](#due-diligence)
* [Risks](#risks)
* [Trustlessness Of The Contract](#trustlessness-of-the-contract)
* [TODO](#todo)
* [Notes](#notes)
* [Code Review](#code-review)
* [Bancor Contracts Code Review](#bancor-contracts-code-review)

<br />

<hr />

## Recommendations

### First Review

* Stox's code uses code from Bancor's code repository. These have recently been updated (1 h ago), and the changes may not have been tested fully. I would
  include a good tested version of Bancor's code in Stox's repository, so you don't end up deploying Bancor's untested code with Stox's Mainnet
  deployment. The SmartToken source code could also be copied from the deployed code at
  [0x1f573d6fb3f13d689ff844b4ce37794d79a7ff1c](https://etherscan.io/address/0x1f573d6fb3f13d689ff844b4ce37794d79a7ff1c#code).

  * [x] In discussion, the Bancor 0.2 contracts are used. In this audit the
    [crowdsale_audit](https://github.com/bancorprotocol/contracts/tree/72da5dde2fa9a383a27da0584c7da289c7d18fd2/solidity/contracts) branch is used.

* There was some discussion outside this code base on how the *VestingTrustee* contract will be deployed in the crowdsale `finalize()` method. Deploying
  new contracts will require much more gas than other kinds of operations. To minimise the risk of the `finalize()` method finalising but failing
  to deploy the *VestingTrustee* contract, try deploying the *VestingTrustee* contract when the crowdsale+token contracts are first deployed
  to the blockchain, and the crowdsale `finalize()` method can call a *VestingTrustee* method to perform any final calculations.

### Second Review

* **NOT IMPORTANT** The calculations for `StoxSmartTokenSale.TOKEN_SALE_CAP` could be more accurate by moving the terms around. Copy and paste
  the following code into [Remix](http://remix.ethereum.org) to view the results:

      contract Test {
          uint256 public constant vNotSoGood = (uint256(30 * 10**6) / 227 * 200 * 10**18) - (4 * 10**6 * 10**18);
          // 22,431,600,000,000,000,000,000,000
          uint256 public constant vGood = uint256(30 * 10**6 * 10**18) * 200 / 227 - (4 * 10**6 * 10**18);
          // 22,431,718,061,674,008,810,572,687
      }

  The Excel calculations results in 22,431,718.0616740000000 .

  You may however prefer to use the "rounded" number.

  * [ ] Stox may choose to re-order the expression for more accurate calculations

* There are some differences in the variables keeping track of the `crowdsale.tokensSold= 4000000` and `token.totalSupply=6000000`.

      Deploy StoxSmartTokenSale
      saleAddress=0x0a91add9e3e97057980da7826043aab2a2d4c35b gas=4000000 gasUsed=3802397 costETH=0.068443146 costUSD=14.061781231992 @ ETH/USD=205.452 gasPrice=18000000000 block=1222 txId=0xe43a5a149b2d2a157cc6bbd4102873481bd0e8f2a533c755d91ee6e01b1bbbaa
       # Account                                             EtherBalanceChange                          Token Name
      -- ------------------------------------------ --------------------------- ------------------------------ ---------------------------
       0 0xa00af22d07c87d96eeeb0ed583f8f6ac7812827e       25.068443146000000000           0.000000000000000000 Account #0 - Miner
       1 0xa11aae29840fbb5c86e6fd4cf809eba183aef433       -0.068443146000000000           0.000000000000000000 Account #1 - Contract Owner
       2 0xa22ab8a9d641ce77e06d98b7d7065d324d3d6976        0.000000000000000000           0.000000000000000000 Account #2 - Multisig
       3 0xa33a6c312d9ad0e0f2e95541beed0cc081621fd0        0.000000000000000000           0.000000000000000000 Account #3
       4 0xa44a08d3f6933c69212114bb66e2df1813651844        0.000000000000000000           0.000000000000000000 Account #4
       5 0xa55a151eb00fded1634d27d1127b4be4627079ea        0.000000000000000000           0.000000000000000000 Account #5
       6 0xa66a85ede0cbe03694aa9d9de0bb19c99ff55bd9        0.000000000000000000           0.000000000000000000 Account #6
       7 0xa77a2b9d4b1c010a22a7c565dc418cef683dbcec        0.000000000000000000           0.000000000000000000 Account #7
       8 0xa88a05d2b88283ce84c8325760b72a64591279a2        0.000000000000000000           0.000000000000000000 Account #8
       9 0xa99a0ae3354c06b1459fd441a32a3f71005d7da0        0.000000000000000000           0.000000000000000000 Account #9
      10 0xaaaa9de1e6c564446ebca0fd102d8bd92093c756        0.000000000000000000           0.000000000000000000 Account #10
      11 0x0010230123012010312300102301230120103121        0.000000000000000000     1000000.000000000000000000 Account #11 - Partner 1 / Invest.com 12.5%
      12 0x0010230123012010312300102301230120103122        0.000000000000000000     1000000.000000000000000000 Account #12 - Partner 2 / Stox 10%
      13 0x0010230123012010312300102301230120103123        0.000000000000000000     1999950.000000000000000000 Account #13 - Partner 3
      14 0x0010230123012010312300102301230120103124        0.000000000000000000          50.000000000000000000 Account #14 - Partner 4
      15 0x0010230123012010312300102301230120103125        0.000000000000000000     2000000.000000000000000000 Account #15 - Partner 5
      16 0x0a91add9e3e97057980da7826043aab2a2d4c35b        0.000000000000000000           0.000000000000000000 StoxSmartTokenSale
      17 0x1659cd96bfd76bf53f155fbd858c3136ed9b2650        0.000000000000000000           0.000000000000000000 StoxSmartToken
      -- ------------------------------------------ --------------------------- ------------------------------ ---------------------------
                                                                                    6000000.000000000000000000 Total Token Balances
      -- ------------------------------------------ --------------------------- ------------------------------ ---------------------------
      
      PASS Deploy StoxSmartTokenSale
      crowdsaleContractAddress=0x0a91add9e3e97057980da7826043aab2a2d4c35b
      crowdsale.isFinalized=false
      crowdsale.stox=0x1659cd96bfd76bf53f155fbd858c3136ed9b2650
      crowdsale.trustee=0x0000000000000000000000000000000000000000
      crowdsale.startBlock=1223
      crowdsale.endBlock=1235
      crowdsale.fundingRecipient=0xa22ab8a9d641ce77e06d98b7d7065d324d3d6976
      crowdsale.tokensSold=4000000
      crowdsale.ETH_PRICE_USD=227
      crowdsale.EXCHANGE_RATE=200
      crowdsale.PARTNER_TOKENS=4000000
      crowdsale.PARTNER_BONUS=2000000
      crowdsale.TOKEN_SALE_CAP=22431600
      TokensIssued 0 #1222: {"_to":"0x0010230123012010312300102301230120103121","_tokens":"1e+24"}
      TokensIssued 1 #1222: {"_to":"0x0010230123012010312300102301230120103122","_tokens":"1e+24"}
      TokensIssued 2 #1222: {"_to":"0x0010230123012010312300102301230120103123","_tokens":"1.99995e+24"}
      TokensIssued 3 #1222: {"_to":"0x0010230123012010312300102301230120103124","_tokens":"50000000000000000000"}
      TokensIssued 4 #1222: {"_to":"0x0010230123012010312300102301230120103125","_tokens":"2e+24"}
      tokenContractAddress=0x1659cd96bfd76bf53f155fbd858c3136ed9b2650
      token.owner=0x0a91add9e3e97057980da7826043aab2a2d4c35b
      token.newOwner=0x0000000000000000000000000000000000000000
      token.symbol=STX
      token.name=Stox Token
      token.decimals=18
      token.totalSupply=6000000
      token.transfersEnabled=false
      NewSmartToken 0 #1222: {"_token":"0x1659cd96bfd76bf53f155fbd858c3136ed9b2650"}
      Issuance 0 #1222: _amount=1000000
      Issuance 1 #1222: _amount=1000000
      Issuance 2 #1222: _amount=1999950
      Issuance 3 #1222: _amount=50
      Issuance 4 #1222: _amount=2000000
      Transfer 0 #1222: _from=0x1659cd96bfd76bf53f155fbd858c3136ed9b2650 _to=0x0010230123012010312300102301230120103121 _value=1000000
      Transfer 1 #1222: _from=0x1659cd96bfd76bf53f155fbd858c3136ed9b2650 _to=0x0010230123012010312300102301230120103122 _value=1000000
      Transfer 2 #1222: _from=0x1659cd96bfd76bf53f155fbd858c3136ed9b2650 _to=0x0010230123012010312300102301230120103123 _value=1999950
      Transfer 3 #1222: _from=0x1659cd96bfd76bf53f155fbd858c3136ed9b2650 _to=0x0010230123012010312300102301230120103124 _value=50
      Transfer 4 #1222: _from=0x1659cd96bfd76bf53f155fbd858c3136ed9b2650 _to=0x0010230123012010312300102301230120103125 _value=2000000

  * [ ] Is this expected?


<br />

<hr />

## Token Distribution

* Following is the token distribution when 0 ETH are contributed in the public crowdsale:

      Finalise Crowdsale
      finaliseTx gas=4000000 gasUsed=1016418 costETH=0.018295524 costUSD=3.758851996848 @ ETH/USD=205.452 gasPrice=18000000000 block=1817 txId=0x3426901d6e0c3ef5444aab0e422ceb287c887ddfe49e246b8887feb6086abd4e
       # Account                                             EtherBalanceChange                          Token Name
      -- ------------------------------------------ --------------------------- ------------------------------ ---------------------------
       0 0xa00af22d07c87d96eeeb0ed583f8f6ac7812827e      120.086738670000000000           0.000000000000000000 Account #0 - Miner
       1 0xa11aae29840fbb5c86e6fd4cf809eba183aef433       -0.086738670000000000           0.000000000000000000 Account #1 - Contract Owner
       2 0xa22ab8a9d641ce77e06d98b7d7065d324d3d6976        0.000000000000000000           0.000000000000000000 Account #2 - Multisig
       3 0xa33a6c312d9ad0e0f2e95541beed0cc081621fd0        0.000000000000000000           0.000000000000000000 Account #3
       4 0xa44a08d3f6933c69212114bb66e2df1813651844        0.000000000000000000           0.000000000000000000 Account #4
       5 0xa55a151eb00fded1634d27d1127b4be4627079ea        0.000000000000000000           0.000000000000000000 Account #5
       6 0xa66a85ede0cbe03694aa9d9de0bb19c99ff55bd9        0.000000000000000000           0.000000000000000000 Account #6
       7 0xa77a2b9d4b1c010a22a7c565dc418cef683dbcec        0.000000000000000000           0.000000000000000000 Account #7
       8 0xa88a05d2b88283ce84c8325760b72a64591279a2        0.000000000000000000           0.000000000000000000 Account #8
       9 0xa99a0ae3354c06b1459fd441a32a3f71005d7da0        0.000000000000000000           0.000000000000000000 Account #9
      10 0xaaaa9de1e6c564446ebca0fd102d8bd92093c756        0.000000000000000000           0.000000000000000000 Account #10
      11 0x0010230123012010312300102301230120103121        0.000000000000000000     1000000.000000000000000000 Account #11 - Partner 1 / Invest.com 12.5%
      12 0x0010230123012010312300102301230120103122        0.000000000000000000     1000000.000000000000000000 Account #12 - Partner 2 / Stox 10%
      13 0x0010230123012010312300102301230120103123        0.000000000000000000     1999950.000000000000000000 Account #13 - Partner 3
      14 0x0010230123012010312300102301230120103124        0.000000000000000000          50.000000000000000000 Account #14 - Partner 4
      15 0x0010230123012010312300102301230120103125        0.000000000000000000     2000000.000000000000000000 Account #15 - Partner 5
      16 0x0010230123012010312300102301230120103129        0.000000000000000000      200000.000000000000000000 Account #15 - Partner 6 - Strategic Partnership
      17 0x32a391d90fed661cc45de0590654bef58f9d6c29        0.000000000000000000           0.000000000000000000 StoxSmartTokenSale
      18 0x738d1a667565fc053f5e5642a01c3ab2c159fad5        0.000000000000000000           0.000000000000000000 StoxSmartToken
      19 0x98eae0f6ccf06b0c2558a7efeb4278a8495b294c        0.000000000000000000     1800000.000000000000000000 Trustee
      -- ------------------------------------------ --------------------------- ------------------------------ ---------------------------
                                                                                    8000000.000000000000000000 Total Token Balances
      -- ------------------------------------------ --------------------------- ------------------------------ ---------------------------
      
      PASS Finalise Crowdsale
      crowdsaleContractAddress=0x32a391d90fed661cc45de0590654bef58f9d6c29
      crowdsale.isFinalized=true
      crowdsale.stox=0x738d1a667565fc053f5e5642a01c3ab2c159fad5
      crowdsale.trustee=0x98eae0f6ccf06b0c2558a7efeb4278a8495b294c
      crowdsale.startBlock=1802
      crowdsale.endBlock=1814
      crowdsale.fundingRecipient=0xa22ab8a9d641ce77e06d98b7d7065d324d3d6976
      crowdsale.tokensSold=4000000
      crowdsale.ETH_PRICE_USD=227
      crowdsale.EXCHANGE_RATE=200
      crowdsale.PARTNER_TOKENS=4000000
      crowdsale.PARTNER_BONUS=2000000
      crowdsale.TOKEN_SALE_CAP=22431600
      tokenContractAddress=0x738d1a667565fc053f5e5642a01c3ab2c159fad5
      token.owner=0x32a391d90fed661cc45de0590654bef58f9d6c29
      token.newOwner=0x0000000000000000000000000000000000000000
      token.symbol=STX
      token.name=Stox Token
      token.decimals=18
      token.totalSupply=8000000
      token.transfersEnabled=true
      Issuance 0 #1817: _amount=200000
      Issuance 1 #1817: _amount=1800000
      Transfer 0 #1817: _from=0x738d1a667565fc053f5e5642a01c3ab2c159fad5 _to=0x0010230123012010312300102301230120103129 _value=200000
      Transfer 1 #1817: _from=0x738d1a667565fc053f5e5642a01c3ab2c159fad5 _to=0x98eae0f6ccf06b0c2558a7efeb4278a8495b294c _value=1800000

* Following is the token distribution when 30,000 ETH are contributed in the public crowdsale:

      Finalise Crowdsale
      finaliseTx gas=4000000 gasUsed=1016418 costETH=0.018295524 costUSD=3.758851996848 @ ETH/USD=205.452 gasPrice=18000000000 block=1683 txId=0xfb99f2aa244117208beb81dcae6b95f6a5ab0a6947002fc9ebd0b732b341ec65
       # Account                                             EtherBalanceChange                          Token Name
      -- ------------------------------------------ --------------------------- ------------------------------ ---------------------------
       0 0xa00af22d07c87d96eeeb0ed583f8f6ac7812827e      135.087916518000000000           0.000000000000000000 Account #0 - Miner
       1 0xa11aae29840fbb5c86e6fd4cf809eba183aef433       -0.086738670000000000           0.000000000000000000 Account #1 - Contract Owner
       2 0xa22ab8a9d641ce77e06d98b7d7065d324d3d6976    30000.000000000000000000           0.000000000000000000 Account #2 - Multisig
       3 0xa33a6c312d9ad0e0f2e95541beed0cc081621fd0   -30000.001177848000000000     6000000.000000000000000000 Account #3
       4 0xa44a08d3f6933c69212114bb66e2df1813651844        0.000000000000000000           0.000000000000000000 Account #4
       5 0xa55a151eb00fded1634d27d1127b4be4627079ea        0.000000000000000000           0.000000000000000000 Account #5
       6 0xa66a85ede0cbe03694aa9d9de0bb19c99ff55bd9        0.000000000000000000           0.000000000000000000 Account #6
       7 0xa77a2b9d4b1c010a22a7c565dc418cef683dbcec        0.000000000000000000           0.000000000000000000 Account #7
       8 0xa88a05d2b88283ce84c8325760b72a64591279a2        0.000000000000000000           0.000000000000000000 Account #8
       9 0xa99a0ae3354c06b1459fd441a32a3f71005d7da0        0.000000000000000000           0.000000000000000000 Account #9
      10 0xaaaa9de1e6c564446ebca0fd102d8bd92093c756        0.000000000000000000           0.000000000000000000 Account #10
      11 0x0010230123012010312300102301230120103121        0.000000000000000000     1000000.000000000000000000 Account #11 - Partner 1 / Invest.com 12.5%
      12 0x0010230123012010312300102301230120103122        0.000000000000000000     1000000.000000000000000000 Account #12 - Partner 2 / Stox 10%
      13 0x0010230123012010312300102301230120103123        0.000000000000000000     1999950.000000000000000000 Account #13 - Partner 3
      14 0x0010230123012010312300102301230120103124        0.000000000000000000          50.000000000000000000 Account #14 - Partner 4
      15 0x0010230123012010312300102301230120103125        0.000000000000000000     2000000.000000000000000000 Account #15 - Partner 5
      16 0x0010230123012010312300102301230120103129        0.000000000000000000     3500000.000000000000000000 Account #15 - Partner 6 - Strategic Partnership
      17 0xb3c7d39fdd2e7dcd02b660b1a317ae06c7c915cc        0.000000000000000000           0.000000000000000000 StoxSmartTokenSale
      18 0xa1b42c6ad2e1d69eee56532557480c20697aa3b5        0.000000000000000000           0.000000000000000000 StoxSmartToken
      19 0xe150c0d407af489209f164860123ef00442a9ff0        0.000000000000000000     4500000.000000000000000000 Trustee
      -- ------------------------------------------ --------------------------- ------------------------------ ---------------------------
                                                                                   20000000.000000000000000000 Total Token Balances
      -- ------------------------------------------ --------------------------- ------------------------------ ---------------------------
      
      PASS Finalise Crowdsale
      crowdsaleContractAddress=0xb3c7d39fdd2e7dcd02b660b1a317ae06c7c915cc
      crowdsale.isFinalized=true
      crowdsale.stox=0xa1b42c6ad2e1d69eee56532557480c20697aa3b5
      crowdsale.trustee=0xe150c0d407af489209f164860123ef00442a9ff0
      crowdsale.startBlock=1668
      crowdsale.endBlock=1680
      crowdsale.fundingRecipient=0xa22ab8a9d641ce77e06d98b7d7065d324d3d6976
      crowdsale.tokensSold=10000000
      crowdsale.ETH_PRICE_USD=227
      crowdsale.EXCHANGE_RATE=200
      crowdsale.PARTNER_TOKENS=4000000
      crowdsale.PARTNER_BONUS=2000000
      crowdsale.TOKEN_SALE_CAP=22431600
      tokenContractAddress=0xa1b42c6ad2e1d69eee56532557480c20697aa3b5
      token.owner=0xb3c7d39fdd2e7dcd02b660b1a317ae06c7c915cc
      token.newOwner=0x0000000000000000000000000000000000000000
      token.symbol=STX
      token.name=Stox Token
      token.decimals=18
      token.totalSupply=20000000
      token.transfersEnabled=true
      Issuance 0 #1683: _amount=3500000
      Issuance 1 #1683: _amount=4500000
      Transfer 0 #1683: _from=0xa1b42c6ad2e1d69eee56532557480c20697aa3b5 _to=0x0010230123012010312300102301230120103129 _value=3500000
      Transfer 1 #1683: _from=0xa1b42c6ad2e1d69eee56532557480c20697aa3b5 _to=0xe150c0d407af489209f164860123ef00442a9ff0 _value=4500000

* Following is the token distribution when 80,000 ETH are contributed in the public crowdsale:

      Finalise Crowdsale
      finaliseTx gas=4000000 gasUsed=1016418 costETH=0.018295524 costUSD=3.758851996848 @ ETH/USD=205.452 gasPrice=18000000000 block=1616 txId=0xae1045016e0ed5847cb5232277a1a7e209e538c9fb266eec769c1401ef8f1333
       # Account                                             EtherBalanceChange                          Token Name
      -- ------------------------------------------ --------------------------- ------------------------------ ---------------------------
       0 0xa00af22d07c87d96eeeb0ed583f8f6ac7812827e      120.089094366000000000           0.000000000000000000 Account #0 - Miner
       1 0xa11aae29840fbb5c86e6fd4cf809eba183aef433       -0.086738670000000000           0.000000000000000000 Account #1 - Contract Owner
       2 0xa22ab8a9d641ce77e06d98b7d7065d324d3d6976    80000.000000000000000000           0.000000000000000000 Account #2 - Multisig
       3 0xa33a6c312d9ad0e0f2e95541beed0cc081621fd0   -30000.001177848000000000     6000000.000000000000000000 Account #3
       4 0xa44a08d3f6933c69212114bb66e2df1813651844   -50000.001177848000000000    10000000.000000000000000000 Account #4
       5 0xa55a151eb00fded1634d27d1127b4be4627079ea        0.000000000000000000           0.000000000000000000 Account #5
       6 0xa66a85ede0cbe03694aa9d9de0bb19c99ff55bd9        0.000000000000000000           0.000000000000000000 Account #6
       7 0xa77a2b9d4b1c010a22a7c565dc418cef683dbcec        0.000000000000000000           0.000000000000000000 Account #7
       8 0xa88a05d2b88283ce84c8325760b72a64591279a2        0.000000000000000000           0.000000000000000000 Account #8
       9 0xa99a0ae3354c06b1459fd441a32a3f71005d7da0        0.000000000000000000           0.000000000000000000 Account #9
      10 0xaaaa9de1e6c564446ebca0fd102d8bd92093c756        0.000000000000000000           0.000000000000000000 Account #10
      11 0x0010230123012010312300102301230120103121        0.000000000000000000     1000000.000000000000000000 Account #11 - Partner 1 / Invest.com 12.5%
      12 0x0010230123012010312300102301230120103122        0.000000000000000000     1000000.000000000000000000 Account #12 - Partner 2 / Stox 10%
      13 0x0010230123012010312300102301230120103123        0.000000000000000000     1999950.000000000000000000 Account #13 - Partner 3
      14 0x0010230123012010312300102301230120103124        0.000000000000000000          50.000000000000000000 Account #14 - Partner 4
      15 0x0010230123012010312300102301230120103125        0.000000000000000000     2000000.000000000000000000 Account #15 - Partner 5
      16 0x0010230123012010312300102301230120103129        0.000000000000000000     9000000.000000000000000000 Account #15 - Partner 6 - Strategic Partnership
      17 0x354059c8c025b0bb359d8a9a6afaf1e550b2ea4b        0.000000000000000000           0.000000000000000000 StoxSmartTokenSale
      18 0x519172068aa711e6e53dc3982b63e1df5b482be9        0.000000000000000000           0.000000000000000000 StoxSmartToken
      19 0x93a1809729063bfd2e172e24b5d4ca4719d2f56e        0.000000000000000000     9000000.000000000000000000 Trustee
      -- ------------------------------------------ --------------------------- ------------------------------ ---------------------------
                                                                                   40000000.000000000000000000 Total Token Balances
      -- ------------------------------------------ --------------------------- ------------------------------ ---------------------------

      PASS Finalise Crowdsale
      crowdsaleContractAddress=0x354059c8c025b0bb359d8a9a6afaf1e550b2ea4b
      crowdsale.isFinalized=true
      crowdsale.stox=0x519172068aa711e6e53dc3982b63e1df5b482be9
      crowdsale.trustee=0x93a1809729063bfd2e172e24b5d4ca4719d2f56e
      crowdsale.startBlock=1601
      crowdsale.endBlock=1613
      crowdsale.fundingRecipient=0xa22ab8a9d641ce77e06d98b7d7065d324d3d6976
      crowdsale.tokensSold=20000000
      crowdsale.ETH_PRICE_USD=227
      crowdsale.EXCHANGE_RATE=200
      crowdsale.PARTNER_TOKENS=4000000
      crowdsale.PARTNER_BONUS=2000000
      crowdsale.TOKEN_SALE_CAP=22431600
      tokenContractAddress=0x519172068aa711e6e53dc3982b63e1df5b482be9
      token.owner=0x354059c8c025b0bb359d8a9a6afaf1e550b2ea4b
      token.newOwner=0x0000000000000000000000000000000000000000
      token.symbol=STX
      token.name=Stox Token
      token.decimals=18
      token.totalSupply=40000000
      token.transfersEnabled=true
      Issuance 0 #1616: _amount=9000000
      Issuance 1 #1616: _amount=9000000
      Transfer 0 #1616: _from=0x519172068aa711e6e53dc3982b63e1df5b482be9 _to=0x0010230123012010312300102301230120103129 _value=9000000
      Transfer 1 #1616: _from=0x519172068aa711e6e53dc3982b63e1df5b482be9 _to=0x93a1809729063bfd2e172e24b5d4ca4719d2f56e _value=9000000


* The token distribution differences, marked with `*`, are:

      0 ETH Contributed
       # Account                                             EtherBalanceChange                          Token Name
      -- ------------------------------------------ --------------------------- ------------------------------ ---------------------------
       0 0xa00af22d07c87d96eeeb0ed583f8f6ac7812827e      120.086738670000000000           0.000000000000000000 Account #0 - Miner
       1 0xa11aae29840fbb5c86e6fd4cf809eba183aef433       -0.086738670000000000           0.000000000000000000 Account #1 - Contract Owner
       2 0xa22ab8a9d641ce77e06d98b7d7065d324d3d6976        0.000000000000000000           0.000000000000000000 Account #2 - Multisig
       3 0xa33a6c312d9ad0e0f2e95541beed0cc081621fd0        0.000000000000000000  *        0.000000000000000000 Account #3
       4 0xa44a08d3f6933c69212114bb66e2df1813651844        0.000000000000000000  *        0.000000000000000000 Account #4
      ...
      11 0x0010230123012010312300102301230120103121        0.000000000000000000     1000000.000000000000000000 Account #11 - Partner 1 / Invest.com 12.5%
      12 0x0010230123012010312300102301230120103122        0.000000000000000000     1000000.000000000000000000 Account #12 - Partner 2 / Stox 10%
      13 0x0010230123012010312300102301230120103123        0.000000000000000000     1999950.000000000000000000 Account #13 - Partner 3
      14 0x0010230123012010312300102301230120103124        0.000000000000000000          50.000000000000000000 Account #14 - Partner 4
      15 0x0010230123012010312300102301230120103125        0.000000000000000000     2000000.000000000000000000 Account #15 - Partner 5
      16 0x0010230123012010312300102301230120103129        0.000000000000000000  *   200000.000000000000000000 Account #15 - Partner 6 - Strategic Partnership
      17 0x32a391d90fed661cc45de0590654bef58f9d6c29        0.000000000000000000           0.000000000000000000 StoxSmartTokenSale
      18 0x738d1a667565fc053f5e5642a01c3ab2c159fad5        0.000000000000000000           0.000000000000000000 StoxSmartToken
      19 0x98eae0f6ccf06b0c2558a7efeb4278a8495b294c        0.000000000000000000  *  1800000.000000000000000000 Trustee
      -- ------------------------------------------ --------------------------- ------------------------------ ---------------------------
                                                                                 *  8000000.000000000000000000 Total Token Balances
      -- ------------------------------------------ --------------------------- ------------------------------ ---------------------------

      30,000 ETH Contributed
       # Account                                             EtherBalanceChange                          Token Name
      -- ------------------------------------------ --------------------------- ------------------------------ ---------------------------
       0 0xa00af22d07c87d96eeeb0ed583f8f6ac7812827e      135.087916518000000000           0.000000000000000000 Account #0 - Miner
       1 0xa11aae29840fbb5c86e6fd4cf809eba183aef433       -0.086738670000000000           0.000000000000000000 Account #1 - Contract Owner
       2 0xa22ab8a9d641ce77e06d98b7d7065d324d3d6976    30000.000000000000000000           0.000000000000000000 Account #2 - Multisig
       3 0xa33a6c312d9ad0e0f2e95541beed0cc081621fd0   -30000.001177848000000000  *  6000000.000000000000000000 Account #3
       4 0xa44a08d3f6933c69212114bb66e2df1813651844        0.000000000000000000  *        0.000000000000000000 Account #4
      ...
      11 0x0010230123012010312300102301230120103121        0.000000000000000000     1000000.000000000000000000 Account #11 - Partner 1 / Invest.com 12.5%
      12 0x0010230123012010312300102301230120103122        0.000000000000000000     1000000.000000000000000000 Account #12 - Partner 2 / Stox 10%
      13 0x0010230123012010312300102301230120103123        0.000000000000000000     1999950.000000000000000000 Account #13 - Partner 3
      14 0x0010230123012010312300102301230120103124        0.000000000000000000          50.000000000000000000 Account #14 - Partner 4
      15 0x0010230123012010312300102301230120103125        0.000000000000000000     2000000.000000000000000000 Account #15 - Partner 5
      16 0x0010230123012010312300102301230120103129        0.000000000000000000  *  3500000.000000000000000000 Account #15 - Partner 6 - Strategic Partnership
      17 0xb3c7d39fdd2e7dcd02b660b1a317ae06c7c915cc        0.000000000000000000           0.000000000000000000 StoxSmartTokenSale
      18 0xa1b42c6ad2e1d69eee56532557480c20697aa3b5        0.000000000000000000           0.000000000000000000 StoxSmartToken
      19 0xe150c0d407af489209f164860123ef00442a9ff0        0.000000000000000000  *  4500000.000000000000000000 Trustee
      -- ------------------------------------------ --------------------------- ------------------------------ ---------------------------
                                                                                 * 20000000.000000000000000000 Total Token Balances
      -- ------------------------------------------ --------------------------- ------------------------------ ---------------------------

      80,000 ETH Contributed
       # Account                                             EtherBalanceChange                          Token Name
      -- ------------------------------------------ --------------------------- ------------------------------ ---------------------------
       0 0xa00af22d07c87d96eeeb0ed583f8f6ac7812827e      120.089094366000000000           0.000000000000000000 Account #0 - Miner
       1 0xa11aae29840fbb5c86e6fd4cf809eba183aef433       -0.086738670000000000           0.000000000000000000 Account #1 - Contract Owner
       2 0xa22ab8a9d641ce77e06d98b7d7065d324d3d6976    80000.000000000000000000           0.000000000000000000 Account #2 - Multisig
       3 0xa33a6c312d9ad0e0f2e95541beed0cc081621fd0   -30000.001177848000000000  *  6000000.000000000000000000 Account #3
       4 0xa44a08d3f6933c69212114bb66e2df1813651844   -50000.001177848000000000  * 10000000.000000000000000000 Account #4
      ...
      11 0x0010230123012010312300102301230120103121        0.000000000000000000     1000000.000000000000000000 Account #11 - Partner 1 / Invest.com 12.5%
      12 0x0010230123012010312300102301230120103122        0.000000000000000000     1000000.000000000000000000 Account #12 - Partner 2 / Stox 10%
      13 0x0010230123012010312300102301230120103123        0.000000000000000000     1999950.000000000000000000 Account #13 - Partner 3
      14 0x0010230123012010312300102301230120103124        0.000000000000000000          50.000000000000000000 Account #14 - Partner 4
      15 0x0010230123012010312300102301230120103125        0.000000000000000000     2000000.000000000000000000 Account #15 - Partner 5
      16 0x0010230123012010312300102301230120103129        0.000000000000000000  *  9000000.000000000000000000 Account #15 - Partner 6 - Strategic Partnership
      17 0x354059c8c025b0bb359d8a9a6afaf1e550b2ea4b        0.000000000000000000           0.000000000000000000 StoxSmartTokenSale
      18 0x519172068aa711e6e53dc3982b63e1df5b482be9        0.000000000000000000           0.000000000000000000 StoxSmartToken
      19 0x93a1809729063bfd2e172e24b5d4ca4719d2f56e        0.000000000000000000  *  9000000.000000000000000000 Trustee
      -- ------------------------------------------ --------------------------- ------------------------------ ---------------------------
                                                                                 * 40000000.000000000000000000 Total Token Balances
      -- ------------------------------------------ --------------------------- ------------------------------ ---------------------------

<br />

<hr />

## Potential Vulnerabilities

No potential vulnerabilities have been identified in the crowdsale and token contract.

<br />

<hr />

## Scope

This audit is into the technical aspects of the crowdsale contracts. The primary aim of this audit is to ensure that funds contributed to
these contracts is not easily attacked or stolen by third parties. The secondary aim of this audit is that ensure the coded algorithms work
as expected. This audit does not guarantee that that the code is bugfree, but intends to highlight any areas of weaknesses.

<br />

<hr />

## Limitations

This audit makes no statements or warranties about the viability of the Stox's business proposition, the individuals involved in
this business or the regulatory regime for the business model.

<br />

<hr />

## Due Diligence

As always, potential participants in any crowdsale are encouraged to perform their due diligence on the business proposition before funding
any crowdsales.

Potential participants are also encouraged to only send their funds to the official crowdsale Ethereum address, published on the
crowdsale beneficiary's official communication channel.

Scammers have been publishing phishing address in the forums, twitter and other communication channels, and some go as far as duplicating
crowdsale websites. Potential participants should NOT just click on any links received through these messages. Scammers have also hacked
the crowdsale website to replace the crowdsale contract address with their scam address.
 
Potential participants should also confirm that the verified source code on EtherScan.io for the published crowdsale address matches the
audited source code, and that the deployment parameters are correctly set, including the constant parameters.

<br />

<hr />

## Risks

* The risk of a large amount of funds getting stolen or hacked from the *StoxSmartTokenSale* is low as contributed ETH are directly transferred
  to an external multisig, hardware or regular wallet in the same transaction.

<br />

<hr />

## Trustlessness Of The Contracts

* The owner of the *StoxSmartToken* contract have the following abilities:

  * Disable and re-enable transfer of tokens
  * Mint new tokens
  * Burn any account's tokens

<br />

<hr />

## TODO

* [ ] Test out ownership changing functions in *StoxSmartTokenSale* as this depends on whether contracts own the other contracts

<br />

<hr />

## Notes

* `StoxSmartTokenSale.finalize()` has `trustee.grants(...)` which are revocable. Any revoked tokens are transferred to the owner of the *Trustee*
  contract.

  * [ ] Is this intended?

<br />

<hr />

## Code Review

Commit [https://github.com/stx-technologies/stox-token/tree/ee616a272594190774946834f75d8d6cbeff07b4/contracts](https://github.com/stx-technologies/stox-token/tree/ee616a272594190774946834f75d8d6cbeff07b4/contracts):

* [x] [code-review/Ownable.md](code-review/Ownable.md)
  * [x] contract Ownable 
* [x] [code-review/SaferMath.md](code-review/SaferMath.md)
  * [x] library SaferMath
* [x] [code-review/StoxSmartToken.md](code-review/StoxSmartToken.md)
  * [x] contract StoxSmartToken is SmartToken 
* [x] [code-review/Trustee.md](code-review/Trustee.md)
  * [x] contract Trustee is Ownable 
* [x] [code-review/StoxSmartTokenSale.md](code-review/StoxSmartTokenSale.md)
  * [x] contract StoxSmartTokenSale is Ownable 

<br />

Outside scope:

* [ ] [code-review/Migrations.md](code-review/Migrations.md)
  * [ ] contract Migrations 
* [ ] [code-review/MultiSigWallet.md](code-review/MultiSigWallet.md)
  * [ ] contract MultiSigWallet 

<br />

<hr />

## Bancor Contracts Code Review

The Stox "SmartToken" contract is built on the "SmartToken" contract from the Bancor repository. Contracts from the "crowdsale_audit" branch, commit
[55031d86...](https://github.com/bancorprotocol/contracts/tree/55031d86e6e277c38276aedbabaabaa7e3aa4fb6/solidity/contracts) have been reviewed below:

* [x] [bancor-code-review/SafeMath.md](bancor-code-review/SafeMath.md)
  * [x] contract SafeMath 
* [x] [bancor-code-review/IOwned.md](bancor-code-review/IOwned.md)
  * [x] contract IOwned 
* [x] [bancor-code-review/Owned.md](bancor-code-review/Owned.md)
  * [x] contract Owned is IOwned 
* [x] [bancor-code-review/ITokenHolder.md](bancor-code-review/ITokenHolder.md)
  * [x] contract ITokenHolder is IOwned 
* [x] [bancor-code-review/TokenHolder.md](bancor-code-review/TokenHolder.md)
  * [x] contract TokenHolder is Owned 
* [x] [bancor-code-review/IERC20Token.md](bancor-code-review/IERC20Token.md)
  * [x] contract IERC20Token 
* [x] [bancor-code-review/ERC20Token.md](bancor-code-review/ERC20Token.md)
  * [x] contract ERC20Token is IERC20Token, SafeMath 
* [x] [bancor-code-review/ISmartToken.md](bancor-code-review/ISmartToken.md)
  * [x] contract ISmartToken is ITokenHolder, IERC20Token 
* [x] [bancor-code-review/SmartToken.md](bancor-code-review/SmartToken.md)
  * [x] contract SmartToken is ISmartToken, ERC20Token, Owned, TokenHolder 

<br />

### Difference In Bancor GitHub Source And Deployed Source

The Bancor SmartToken is deployed to [0x1f573d6fb3f13d689ff844b4ce37794d79a7ff1c](https://etherscan.io/address/0x1f573d6fb3f13d689ff844b4ce37794d79a7ff1c#code)
and a copy of the deployed source code is available in [bancor-contracts/DeployedSmartToken.sol](bancor-contracts/DeployedSmartToken.sol).

A copy of the individual files have been combined using the command
`cat SafeMath.sol IOwned.sol Owned.sol ITokenHolder.sol TokenHolder.sol IERC20Token.sol ERC20Token.sol ISmartToken.sol SmartToken.sol > MyCombinedSmartToken.sol`
to create a combined file [bancor-contracts/MyCombinedSmartToken.sol](bancor-contracts/MyCombinedSmartToken.sol).

The differences between the deployed Bancor SmartToken and the combined source code follows:

```diff
$ diff DeployedSmartToken.sol MyCombinedSmartToken.sol | egrep -v "pragma|import" 
53c53,54
< } 
---
> }
64a66,67
105c108
<         OwnerUpdate(owner, newOwner);
---
>         address prevOwner = owner;
107a111
>         OwnerUpdate(prevOwner, owner);
109a114,116
116a124,126
125c135
< contract TokenHolder is ITokenHolder, Owned {
---
> contract TokenHolder is Owned {
137a148,153
>     // verifies that an amount is greater than zero
>     modifier validAmount(uint256 _amount) {
>         require(_amount > 0);
>         _;
>     }
> 
157a174
>         validAmount(_amount)
161a179
178a197,199
215a237,242
>     // verifies that an amount is greater than zero
>     modifier validAmount(uint256 _amount) {
>         require(_amount > 0);
>         _;
>     }
> 
218c245
<         throws on any error rather then return a false flag to minimize user errors
---
>         note that the function slightly deviates from the ERC20 standard and will throw on any error rather then return a boolean return value to minimize user errors
227a255
>         validAmount(_value)
238c266
<         throws on any error rather then return a false flag to minimize user errors
---
>         note that the function slightly deviates from the ERC20 standard and will throw on any error rather then return a boolean return value to minimize user errors
249a278
>         validAmount(_value)
261c290
<         throws on any error rather then return a false flag to minimize user errors
---
>         note that the function slightly deviates from the ERC20 standard and will throw on any error rather then return a boolean return value to minimize user errors
284a314,316
293a326,330
353a391
>         validAmount(_amount)
371a410
>         validAmount(_amount)
384,385c423,424
<         throws on any error rather then return a false flag to minimize user errors
<         note that when transferring to the smart token's address, the coins are actually destroyed
---
>         note that the function slightly deviates from the ERC20 standard and will throw on any error rather then return a boolean return value to minimize user errors
>         also note that when transferring to the smart token's address, the coins are actually destroyed
407,408c446,447
<         throws on any error rather then return a false flag to minimize user errors
<         note that when transferring to the smart token's address, the coins are actually destroyed
---
>         note that the function slightly deviates from the ERC20 standard and will throw on any error rather then return a boolean return value to minimize user errors
>         also note that when transferring to the smart token's address, the coins are actually destroyed
427a467,471
> 
>     // fallback
>     function() {
>         assert(false);
>     }
```

### Compilation Of The Bancor Contracts With Solidity 0.4.13

**NOTE** Compiling the Bancor contracts with Solidity 0.4.13+commit.0fb4cb1a.Darwin.appleclang results in the following errors:

    $ solc SmartToken.sol 
    ERC20Token.sol:81:9: Error: Modifier already used for this function.
            validAddress(_to)
            ^---------------^
    TokenHolder.sol:49:9: Error: Modifier already used for this function.
            validAddress(_to)
            ^---------------^

For this test, the Solidity version has been downgraded to 0.4.11+commit.68ef5810.Darwin.appleclang .
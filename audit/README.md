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

I am currently merging and testing the changes for [20925fd8](https://github.com/stx-technologies/stox-token/tree/20925fd8b97746f085b95af03173d65a2ddaa504).

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
* [Testing](#testing)
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

## Testing

The following items were tested using the script [test/01_test1.sh](test/01_test1.sh) with the results saved in [test/test1results.txt](test/test1results.txt):

* [x] Deploy token contract
* [x] Deploy sale contract
* [x] Transfer ownership of the token contract to the sale contract
* [x] Distribute partner tokens
* [x] Contribute ETH to the sale contract in exchange for tokens
* [x] Finalise the sale
* [x] `transfer(...)` and `transferFrom(...)` the tokens
* [x] Transfer ownership of the token contract to a regular account
* [x] Disable token transfers and confirm `transfer(...)` and `transferFrom(...)` fails
* [x] Mint new tokens
* [x] Destroy an account's tokens
* [x] Transfer ownership of the trustee contract to a regular account
* [x] Enable token transfers
* [x] Unlock a trustee grant
* [x] Revoke a trustee grant

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

The following contracts were not reviewed Outside scope:

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
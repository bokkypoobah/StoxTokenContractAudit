#!/bin/sh

geth attach << EOF | grep "RESULT: " | sed "s/RESULT: //"

loadScript("abi.js");

var tokenAddress = "0x006BeA43Baa3f7A6f765F14f10A1a1b08334EF45";
var saleAddress = "0x40349A89114BB34d4E82e5Bf9AE6B2ac3c78b00a";

var startBlock = 4105157;

var sale = eth.contract(saleAbi).at(saleAddress);

console.log("RESULT: crowdsale.address=" + saleAddress);
console.log("RESULT: crowdsale.isFinalized=" + sale.isFinalized());
console.log("RESULT: crowdsale.isDistributed=" + sale.isDistributed());
console.log("RESULT: crowdsale.stox=" + sale.stox());
console.log("RESULT: crowdsale.trustee=" + sale.trustee());
console.log("RESULT: crowdsale.startTime=" + sale.startTime() + " " + new Date(sale.startTime() * 1000).toUTCString());
console.log("RESULT: crowdsale.endTime=" + sale.endTime() + " " + new Date(sale.endTime() * 1000).toUTCString());
console.log("RESULT: crowdsale.fundingRecipient=" + sale.fundingRecipient());
console.log("RESULT: crowdsale.tokensSold=" + sale.tokensSold().shift(-18));
console.log("RESULT: crowdsale.ETH_CAP=" + sale.ETH_CAP());
console.log("RESULT: crowdsale.EXCHANGE_RATE=" + sale.EXCHANGE_RATE());
console.log("RESULT: crowdsale.TOKEN_SALE_CAP=" + sale.TOKEN_SALE_CAP().shift(-18));
var latestBlock = eth.blockNumber;
var i;

var tokensIssuedEvents = sale.TokensIssued({}, { fromBlock: startBlock, toBlock: latestBlock });
i = 0;
tokensIssuedEvents.watch(function (error, result) {
  console.log("RESULT: TokensIssued " + i++ + " #" + result.blockNumber + ": " + JSON.stringify(result.args));
});
tokensIssuedEvents.stopWatching();

var token = eth.contract(tokenAbi).at(tokenAddress);
var decimals = token.decimals();
console.log("RESULT: token.address=" + tokenAddress);
console.log("RESULT: token.owner=" + token.owner());
console.log("RESULT: token.newOwner=" + token.newOwner());
console.log("RESULT: token.symbol=" + token.symbol());
console.log("RESULT: token.name=" + token.name());
console.log("RESULT: token.decimals=" + decimals);
console.log("RESULT: token.totalSupply=" + token.totalSupply().shift(-decimals));
console.log("RESULT: token.transfersEnabled=" + token.transfersEnabled());

var latestBlock = eth.blockNumber;
var i;

var newSmartTokenEvents = token.NewSmartToken({}, { fromBlock: startBlock, toBlock: latestBlock });
i = 0;
newSmartTokenEvents.watch(function (error, result) {
  console.log("RESULT: NewSmartToken " + i++ + " #" + result.blockNumber + ": " + JSON.stringify(result.args));
});
newSmartTokenEvents.stopWatching();

var issuanceEvents = token.Issuance({}, { fromBlock: startBlock, toBlock: latestBlock });
i = 0;
issuanceEvents.watch(function (error, result) {
  console.log("RESULT: Issuance " + i++ + " #" + result.blockNumber + ": _amount=" + result.args._amount.shift(-decimals));
});
issuanceEvents.stopWatching();

var destructionEvents = token.Destruction({}, { fromBlock: startBlock, toBlock: latestBlock });
i = 0;
destructionEvents.watch(function (error, result) {
  console.log("RESULT: Destruction " + i++ + " #" + result.blockNumber + ": _amount=" + result.args._amount.shift(-decimals));
});
destructionEvents.stopWatching();

var approvalEvents = token.Approval({}, { fromBlock: startBlock, toBlock: latestBlock });
i = 0;
approvalEvents.watch(function (error, result) {
  console.log("RESULT: Approval " + i++ + " #" + result.blockNumber + " _owner=" + result.args._owner + " _spender=" + result.args._spender + " _value=" +
result.args._value.shift(-decimals));
});
approvalEvents.stopWatching();

var transferEvents = token.Transfer({}, { fromBlock: startBlock, toBlock: latestBlock });
i = 0;
transferEvents.watch(function (error, result) {
  console.log("RESULT: Transfer " + i++ + " #" + result.blockNumber + ": _from=" + result.args._from + " _to=" + result.args._to +
" _value=" + result.args._value.shift(-decimals));
});
transferEvents.stopWatching();


EOF
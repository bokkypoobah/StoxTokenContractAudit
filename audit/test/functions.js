// Jul 14 2017
var ethPriceUSD = 205.452;

// -----------------------------------------------------------------------------
// Accounts
// -----------------------------------------------------------------------------
var accounts = [];
var accountNames = {};

addAccount(eth.accounts[0], "Account #0 - Miner");
addAccount(eth.accounts[1], "Account #1 - Contract Owner");
addAccount(eth.accounts[2], "Account #2 - Multisig");
addAccount(eth.accounts[3], "Account #3");
addAccount(eth.accounts[4], "Account #4");
addAccount(eth.accounts[5], "Account #5");
addAccount(eth.accounts[6], "Account #6");
addAccount(eth.accounts[7], "Account #7");
addAccount(eth.accounts[8], "Account #8");
addAccount(eth.accounts[9], "Account #9 - Invest.com 12.5% - Locked 1y");
addAccount("0x9065260ef6830f6372F1Bde408DeC57Fe3150530", "Strategic Partnership #1");
addAccount("0xbC14105ccDdeAadB96Ba8dCE18b40C45b6bACf58", "Strategic Partnership #2");
// addAccount("0xb54c6a870d4aD65e23d471Fb7941aD271D323f5E", "Invest.com 12.5% - Locked 1y");
addAccount("0x4eB4Cd1D125d9d281709Ff38d65b99a6927b46c1", "Stox 10% - Locked 2y");

var minerAccount = eth.accounts[0];
var contractOwnerAccount = eth.accounts[1];
var multisig = eth.accounts[2];
var account3 = eth.accounts[3];
var account4 = eth.accounts[4];
var account5 = eth.accounts[5];
var account6 = eth.accounts[6];
var account7 = eth.accounts[7];
var account8 = eth.accounts[8];
var trustee1 = eth.accounts[9];

var baseBlock = eth.blockNumber;

function unlockAccounts(password) {
  for (var i = 0; i < eth.accounts.length; i++) {
    personal.unlockAccount(eth.accounts[i], password, 100000);
  }
}

function addAccount(account, accountName) {
  accounts.push(account);
  accountNames[account] = accountName;
}


// -----------------------------------------------------------------------------
// Token Contract
// -----------------------------------------------------------------------------
var tokenContractAddress = null;
var tokenContractAbi = null;

function addTokenContractAddressAndAbi(address, tokenAbi) {
  tokenContractAddress = address;
  tokenContractAbi = tokenAbi;
}


// -----------------------------------------------------------------------------
// Account ETH and token balances
// -----------------------------------------------------------------------------
function printBalances() {
  var token = tokenContractAddress == null || tokenContractAbi == null ? null : web3.eth.contract(tokenContractAbi).at(tokenContractAddress);
  var decimals = token == null ? 18 : token.decimals();
  var i = 0;
  var totalTokenBalance = new BigNumber(0);
  console.log("RESULT:  # Account                                             EtherBalanceChange                          Token Name");
  console.log("RESULT: -- ------------------------------------------ --------------------------- ------------------------------ ---------------------------");
  accounts.forEach(function(e) {
    var etherBalanceBaseBlock = eth.getBalance(e, baseBlock);
    var etherBalance = web3.fromWei(eth.getBalance(e).minus(etherBalanceBaseBlock), "ether");
    var tokenBalance = token == null ? new BigNumber(0) : token.balanceOf(e).shift(-decimals);
    totalTokenBalance = totalTokenBalance.add(tokenBalance);
    console.log("RESULT: " + pad2(i) + " " + e  + " " + pad(etherBalance) + " " + padToken(tokenBalance, decimals) + " " + accountNames[e]);
    i++;
  });
  console.log("RESULT: -- ------------------------------------------ --------------------------- ------------------------------ ---------------------------");
  console.log("RESULT:                                                                           " + padToken(totalTokenBalance, decimals) + " Total Token Balances");
  console.log("RESULT: -- ------------------------------------------ --------------------------- ------------------------------ ---------------------------");
  console.log("RESULT: ");
}

function pad2(s) {
  var o = s.toFixed(0);
  while (o.length < 2) {
    o = " " + o;
  }
  return o;
}

function pad(s) {
  var o = s.toFixed(18);
  while (o.length < 27) {
    o = " " + o;
  }
  return o;
}

function padToken(s, decimals) {
  var o = s.toFixed(decimals);
  var l = parseInt(decimals)+12;
  while (o.length < l) {
    o = " " + o;
  }
  return o;
}


// -----------------------------------------------------------------------------
// Transaction status
// -----------------------------------------------------------------------------
function printTxData(name, txId) {
  var tx = eth.getTransaction(txId);
  var txReceipt = eth.getTransactionReceipt(txId);
  var gasPrice = tx.gasPrice;
  var gasCostETH = tx.gasPrice.mul(txReceipt.gasUsed).div(1e18);
  var gasCostUSD = gasCostETH.mul(ethPriceUSD);
  console.log("RESULT: " + name + " gas=" + tx.gas + " gasUsed=" + txReceipt.gasUsed + " costETH=" + gasCostETH +
    " costUSD=" + gasCostUSD + " @ ETH/USD=" + ethPriceUSD + " gasPrice=" + gasPrice + " block=" + 
    txReceipt.blockNumber + " txId=" + txId);
}

function assertEtherBalance(account, expectedBalance) {
  var etherBalance = web3.fromWei(eth.getBalance(account), "ether");
  if (etherBalance == expectedBalance) {
    console.log("RESULT: OK " + account + " has expected balance " + expectedBalance);
  } else {
    console.log("RESULT: FAILURE " + account + " has balance " + etherBalance + " <> expected " + expectedBalance);
  }
}

function gasEqualsGasUsed(tx) {
  var gas = eth.getTransaction(tx).gas;
  var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
  return (gas == gasUsed);
}

function failIfGasEqualsGasUsed(tx, msg) {
  var gas = eth.getTransaction(tx).gas;
  var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
  if (gas == gasUsed) {
    console.log("RESULT: FAIL " + msg);
    return 0;
  } else {
    console.log("RESULT: PASS " + msg);
    return 1;
  }
}

function passIfGasEqualsGasUsed(tx, msg) {
  var gas = eth.getTransaction(tx).gas;
  var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
  if (gas == gasUsed) {
    console.log("RESULT: PASS " + msg);
    return 1;
  } else {
    console.log("RESULT: FAIL " + msg);
    return 0;
  }
}

function failIfGasEqualsGasUsedOrContractAddressNull(contractAddress, tx, msg) {
  if (contractAddress == null) {
    console.log("RESULT: FAIL " + msg);
    return 0;
  } else {
    var gas = eth.getTransaction(tx).gas;
    var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
    if (gas == gasUsed) {
      console.log("RESULT: FAIL " + msg);
      return 0;
    } else {
      console.log("RESULT: PASS " + msg);
      return 1;
    }
  }
}


//-----------------------------------------------------------------------------
// Crowdsale Contract
//-----------------------------------------------------------------------------
var crowdsaleContractAddress = null;
var crowdsaleContractAbi = null;

function addCrowdsaleContractAddressAndAbi(address, abi) {
  crowdsaleContractAddress = address;
  crowdsaleContractAbi = abi;
}

var crowdsaleFromBlock = 0;
function printCrowdsaleContractDetails() {
  console.log("RESULT: crowdsaleContractAddress=" + crowdsaleContractAddress);
  // console.log("RESULT: crowdsaleContractAbi=" + JSON.stringify(crowdsaleContractAbi));
  if (crowdsaleContractAddress != null && crowdsaleContractAbi != null) {
    var contract = eth.contract(crowdsaleContractAbi).at(crowdsaleContractAddress);
    console.log("RESULT: crowdsale.isFinalized=" + contract.isFinalized());
    console.log("RESULT: crowdsale.isDistributed=" + contract.isDistributed());
    console.log("RESULT: crowdsale.stox=" + contract.stox());
    console.log("RESULT: crowdsale.trustee=" + contract.trustee());
    console.log("RESULT: crowdsale.startTime=" + contract.startTime() + " " + new Date(contract.startTime() * 1000).toUTCString());
    console.log("RESULT: crowdsale.endTime=" + contract.endTime() + " " + new Date(contract.endTime() * 1000).toUTCString());
    console.log("RESULT: crowdsale.fundingRecipient=" + contract.fundingRecipient());
    console.log("RESULT: crowdsale.tokensSold=" + contract.tokensSold().shift(-18));
    console.log("RESULT: crowdsale.ETH_CAP=" + contract.ETH_CAP());
    console.log("RESULT: crowdsale.EXCHANGE_RATE=" + contract.EXCHANGE_RATE());
    console.log("RESULT: crowdsale.TOKEN_SALE_CAP=" + contract.TOKEN_SALE_CAP().shift(-18));
    var latestBlock = eth.blockNumber;
    var i;

    var tokensIssuedEvents = contract.TokensIssued({}, { fromBlock: crowdsaleFromBlock, toBlock: latestBlock });
    i = 0;
    tokensIssuedEvents.watch(function (error, result) {
      console.log("RESULT: TokensIssued " + i++ + " #" + result.blockNumber + ": " + JSON.stringify(result.args));
    });
    tokensIssuedEvents.stopWatching();

//    var initializedEvents = contract.Initialized({}, { fromBlock: crowdsaleFromBlock, toBlock: latestBlock });
//    i = 0;
//    initializedEvents.watch(function (error, result) {
//      console.log("RESULT: Initialized " + i++ + " #" + result.blockNumber + ": " + JSON.stringify(result.args));
//    });
//    initializedEvents.stopWatching();
//
//    var finalizedEvents = contract.Finalized({}, { fromBlock: crowdsaleFromBlock, toBlock: latestBlock });
//    i = 0;
//    finalizedEvents.watch(function (error, result) {
//      console.log("RESULT: Finalized " + i++ + " #" + result.blockNumber + ": " + JSON.stringify(result.args));
//    });
//    finalizedEvents.stopWatching();

    crowdsaleFromBlock = parseInt(latestBlock) + 1;
  }
}


//-----------------------------------------------------------------------------
// Token Contract
//-----------------------------------------------------------------------------
var tokenFromBlock = 0;
function printTokenContractDetails() {
  console.log("RESULT: tokenContractAddress=" + tokenContractAddress);
  // console.log("RESULT: tokenContractAbi=" + JSON.stringify(tokenContractAbi));
  if (tokenContractAddress != null && tokenContractAbi != null) {
    var contract = eth.contract(tokenContractAbi).at(tokenContractAddress);
    var decimals = contract.decimals();
    console.log("RESULT: token.owner=" + contract.owner());
    console.log("RESULT: token.newOwner=" + contract.newOwner());
    console.log("RESULT: token.symbol=" + contract.symbol());
    console.log("RESULT: token.name=" + contract.name());
    console.log("RESULT: token.decimals=" + decimals);
    console.log("RESULT: token.totalSupply=" + contract.totalSupply().shift(-decimals));
    console.log("RESULT: token.transfersEnabled=" + contract.transfersEnabled());

    var latestBlock = eth.blockNumber;
    var i;

    var newSmartTokenEvents = contract.NewSmartToken({}, { fromBlock: tokenFromBlock, toBlock: latestBlock });
    i = 0;
    newSmartTokenEvents.watch(function (error, result) {
      console.log("RESULT: NewSmartToken " + i++ + " #" + result.blockNumber + ": " + JSON.stringify(result.args));
    });
    newSmartTokenEvents.stopWatching();

    var issuanceEvents = contract.Issuance({}, { fromBlock: tokenFromBlock, toBlock: latestBlock });
    i = 0;
    issuanceEvents.watch(function (error, result) {
      console.log("RESULT: Issuance " + i++ + " #" + result.blockNumber + ": _amount=" + result.args._amount.shift(-decimals));
    });
    issuanceEvents.stopWatching();

    var destructionEvents = contract.Destruction({}, { fromBlock: tokenFromBlock, toBlock: latestBlock });
    i = 0;
    destructionEvents.watch(function (error, result) {
      console.log("RESULT: Destruction " + i++ + " #" + result.blockNumber + ": _amount=" + result.args._amount.shift(-decimals));
    });
    destructionEvents.stopWatching();

    var approvalEvents = contract.Approval({}, { fromBlock: tokenFromBlock, toBlock: latestBlock });
    i = 0;
    approvalEvents.watch(function (error, result) {
      console.log("RESULT: Approval " + i++ + " #" + result.blockNumber + " _owner=" + result.args._owner + " _spender=" + result.args._spender + " _value=" +
        result.args._value.shift(-decimals));
    });
    approvalEvents.stopWatching();

    var transferEvents = contract.Transfer({}, { fromBlock: tokenFromBlock, toBlock: latestBlock });
    i = 0;
    transferEvents.watch(function (error, result) {
      console.log("RESULT: Transfer " + i++ + " #" + result.blockNumber + ": _from=" + result.args._from + " _to=" + result.args._to +
        " _value=" + result.args._value.shift(-decimals));
    });
    transferEvents.stopWatching();

    tokenFromBlock = parseInt(latestBlock) + 1;
  }
}


//-----------------------------------------------------------------------------
// Trustee Contract
//-----------------------------------------------------------------------------
var trusteeContractAddress = null;
var trusteeContractAbi = null;

function addTrusteeContractAddressAndAbi(address, abi) {
  trusteeContractAddress = address;
  trusteeContractAbi = abi;
}

var trusteeFromBlock = 0;
function printTrusteeContractDetails() {
  console.log("RESULT: trusteeContractAddress=" + trusteeContractAddress);
  // console.log("RESULT: crowdsaleContractAbi=" + JSON.stringify(crowdsaleContractAbi));
  if (trusteeContractAddress != null && trusteeContractAbi != null) {
    var contract = eth.contract(trusteeContractAbi).at(trusteeContractAddress);
    console.log("RESULT: trustee.stox=" + contract.stox());
    console.log("RESULT: trustee.owner=" + contract.owner());
    console.log("RESULT: trustee.newOwnerCandidate=" + contract.newOwnerCandidate());
    console.log("RESULT: trustee.totalVesting=" + contract.totalVesting().shift(-18));
    var latestBlock = eth.blockNumber;
    var i;

    var newGrantEvents = contract.NewGrant({}, { fromBlock: trusteeFromBlock, toBlock: latestBlock });
    i = 0;
    newGrantEvents.watch(function (error, result) {
      console.log("RESULT: NewGrant " + i++ + " #" + result.blockNumber + ": " + JSON.stringify(result.args));
    });
    newGrantEvents.stopWatching();

    var unlockGrantEvents = contract.UnlockGrant({}, { fromBlock: trusteeFromBlock, toBlock: latestBlock });
    i = 0;
    unlockGrantEvents.watch(function (error, result) {
      console.log("RESULT: UnlockGrant " + i++ + " #" + result.blockNumber + ": " + JSON.stringify(result.args));
    });
    unlockGrantEvents.stopWatching();

    var revokeGrantEvents = contract.RevokeGrant({}, { fromBlock: trusteeFromBlock, toBlock: latestBlock });
    i = 0;
    revokeGrantEvents.watch(function (error, result) {
      console.log("RESULT: RevokeGrant " + i++ + " #" + result.blockNumber + ": " + JSON.stringify(result.args));
    });
    revokeGrantEvents.stopWatching();

    trusteeFromBlock = parseInt(latestBlock) + 1;
  }
}

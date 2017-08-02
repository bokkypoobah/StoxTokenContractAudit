#!/bin/bash
# ----------------------------------------------------------------------------------------------
# Testing the smart contract
#
# Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2017. The MIT Licence.
# ----------------------------------------------------------------------------------------------

MODE=${1:-test}

GETHATTACHPOINT=`grep ^IPCFILE= settings.txt | sed "s/^.*=//"`
PASSWORD=`grep ^PASSWORD= settings.txt | sed "s/^.*=//"`

CONTRACTSDIR=`grep ^CONTRACTSDIR= settings.txt | sed "s/^.*=//"`
BANCORCONTRACTSDIR=`grep ^BANCORCONTRACTSDIR= settings.txt | sed "s/^.*=//"`

OWNABLESOL=`grep ^OWNABLESOL= settings.txt | sed "s/^.*=//"`
OWNABLETEMPSOL=`grep ^OWNABLETEMPSOL= settings.txt | sed "s/^.*=//"`

SAFERMATHSOL=`grep ^SAFERMATHSOL= settings.txt | sed "s/^.*=//"`
SAFERMATHTEMPSOL=`grep ^SAFERMATHTEMPSOL= settings.txt | sed "s/^.*=//"`

STOXSMARTTOKENSOL=`grep ^STOXSMARTTOKENSOL= settings.txt | sed "s/^.*=//"`
STOXSMARTTOKENTEMPSOL=`grep ^STOXSMARTTOKENTEMPSOL= settings.txt | sed "s/^.*=//"`
STOXSMARTTOKENJS=`grep ^STOXSMARTTOKENJS= settings.txt | sed "s/^.*=//"`

STOXSMARTTOKENSALESOL=`grep ^STOXSMARTTOKENSALESOL= settings.txt | sed "s/^.*=//"`
STOXSMARTTOKENSALETEMPSOL=`grep ^STOXSMARTTOKENSALETEMPSOL= settings.txt | sed "s/^.*=//"`
STOXSMARTTOKENSALEJS=`grep ^STOXSMARTTOKENSALEJS= settings.txt | sed "s/^.*=//"`

TRUSTEESOL=`grep ^TRUSTEESOL= settings.txt | sed "s/^.*=//"`
TRUSTEETEMPSOL=`grep ^TRUSTEETEMPSOL= settings.txt | sed "s/^.*=//"`
TRUSTEEJS=`grep ^TRUSTEEJS= settings.txt | sed "s/^.*=//"`

DEPLOYMENTDATA=`grep ^DEPLOYMENTDATA= settings.txt | sed "s/^.*=//"`

INCLUDEJS=`grep ^INCLUDEJS= settings.txt | sed "s/^.*=//"`
TEST1OUTPUT=`grep ^TEST1OUTPUT= settings.txt | sed "s/^.*=//"`
TEST1RESULTS=`grep ^TEST1RESULTS= settings.txt | sed "s/^.*=//"`

CURRENTTIME=`date +%s`
CURRENTTIMES=`date -r $CURRENTTIME -u`

# Setting time to be a block representing one day
BLOCKSINDAY=1

if [ "$MODE" == "dev" ]; then
  # Start time now
  STARTTIME=`echo "$CURRENTTIME" | bc`
else
  # Start time 1m 10s in the future
  STARTTIME=`echo "$CURRENTTIME+60" | bc`
fi
STARTTIME_S=`date -r $STARTTIME -u`
ENDTIME=`echo "$CURRENTTIME+60*4" | bc`
ENDTIME_S=`date -r $ENDTIME -u`

printf "MODE                 = '$MODE'\n" | tee $TEST1OUTPUT
printf "GETHATTACHPOINT      = '$GETHATTACHPOINT'\n" | tee -a $TEST1OUTPUT
printf "PASSWORD             = '$PASSWORD'\n" | tee -a $TEST1OUTPUT

printf "CONTRACTSDIR              = '$CONTRACTSDIR'\n" | tee -a $TEST1OUTPUT
printf "BANCORCONTRACTSDIR        = '$BANCORCONTRACTSDIR'\n" | tee -a $TEST1OUTPUT

printf "OWNABLESOL                = '$OWNABLESOL'\n" | tee -a $TEST1OUTPUT
printf "OWNABLETEMPSOL            = '$OWNABLETEMPSOL'\n" | tee -a $TEST1OUTPUT

printf "SAFERMATHSOL              = '$SAFERMATHSOL'\n" | tee -a $TEST1OUTPUT
printf "SAFERMATHTEMPSOL          = '$SAFERMATHTEMPSOL'\n" | tee -a $TEST1OUTPUT

printf "STOXSMARTTOKENSOL         = '$STOXSMARTTOKENSOL'\n" | tee -a $TEST1OUTPUT
printf "STOXSMARTTOKENTEMPSOL     = '$STOXSMARTTOKENTEMPSOL'\n" | tee -a $TEST1OUTPUT

printf "STOXSMARTTOKENSALESOL     = '$STOXSMARTTOKENSALESOL'\n" | tee -a $TEST1OUTPUT
printf "STOXSMARTTOKENSALETEMPSOL = '$STOXSMARTTOKENSALETEMPSOL'\n" | tee -a $TEST1OUTPUT
printf "STOXSMARTTOKENSALEJS      = '$STOXSMARTTOKENSALEJS'\n" | tee -a $TEST1OUTPUT

printf "TRUSTEESOL                = '$TRUSTEESOL'\n" | tee -a $TEST1OUTPUT
printf "TRUSTEETEMPSOL            = '$TRUSTEETEMPSOL'\n" | tee -a $TEST1OUTPUT

printf "DEPLOYMENTDATA            = '$DEPLOYMENTDATA'\n" | tee -a $TEST1OUTPUT
printf "INCLUDEJS                 = '$INCLUDEJS'\n" | tee -a $TEST1OUTPUT
printf "TEST1OUTPUT               = '$TEST1OUTPUT'\n" | tee -a $TEST1OUTPUT
printf "TEST1RESULTS              = '$TEST1RESULTS'\n" | tee -a $TEST1OUTPUT
printf "CURRENTTIME               = '$CURRENTTIME' '$CURRENTTIMES'\n" | tee -a $TEST1OUTPUT
printf "STARTTIME                 = '$STARTTIME' '$STARTTIME_S'\n" | tee -a $TEST1OUTPUT
printf "ENDTIME                   = '$ENDTIME' '$ENDTIME_S'\n" | tee -a $TEST1OUTPUT

# Make copy of SOL file and modify start and end times ---
`cp -rp $BANCORCONTRACTSDIR .`
`cp $CONTRACTSDIR/$OWNABLESOL $OWNABLETEMPSOL`
`cp $CONTRACTSDIR/$SAFERMATHSOL $SAFERMATHTEMPSOL`
`cp $CONTRACTSDIR/$STOXSMARTTOKENSOL $STOXSMARTTOKENTEMPSOL`
`cp $CONTRACTSDIR/$STOXSMARTTOKENSALESOL $STOXSMARTTOKENSALETEMPSOL`
`cp $CONTRACTSDIR/$TRUSTEESOL $TRUSTEETEMPSOL`

# --- Modify parameters ---
`perl -pi -e "s/bancor-contracts\/solidity\/contracts/bancor-contracts/" $STOXSMARTTOKENTEMPSOL`
`perl -pi -e "s/DURATION \= 14 days/DURATION \= 4 minutes/" $STOXSMARTTOKENTEMPSOL`
#`perl -pi -e "s/0x0010230123012010312300102301230120103122/0xabba43e7594e3b76afb157989e93c6621497fd4b/" $STOXSMARTTOKENTEMPSOL`
#`perl -pi -e "s/0x0010230123012010312300102301230120103123/0xacca534c9f62ab495bd986e002ddf0f054caae4f/" $STOXSMARTTOKENTEMPSOL`
#`perl -pi -e "s/0x0010230123012010312300102301230120103124/0xadda9b762a00ff12711113bfdc36958b73d7f915/" $STOXSMARTTOKENTEMPSOL`
#`perl -pi -e "s/0x0010230123012010312300102301230120103125/0xaeea63b5479b50f79583ec49dacdcf86ddeff392/" $STOXSMARTTOKENTEMPSOL`
#`perl -pi -e "s/0x0010230123012010312300102301230120103129/0xaffa4d3a80add8ce4018540e056dacb649589394/" $STOXSMARTTOKENTEMPSOL`
#`perl -pi -e "s/deadline \=  1499436000;.*$/deadline = $ENDTIME; \/\/ $ENDTIME_S/" $FUNFAIRSALETEMPSOL`
#`perl -pi -e "s/\/\/\/ \@return total amount of tokens.*$/function overloadedTotalSupply() constant returns (uint256) \{ return totalSupply; \}/" $DAOCASINOICOTEMPSOL`
#`perl -pi -e "s/BLOCKS_IN_DAY \= 5256;*$/BLOCKS_IN_DAY \= $BLOCKSINDAY;/" $DAOCASINOICOTEMPSOL`

DIFFS1=`diff $CONTRACTSDIR/$OWNABLESOL $OWNABLETEMPSOL`
echo "--- Differences $CONTRACTSDIR/$OWNABLESOL $OWNABLETEMPSOL ---" | tee -a $TEST1OUTPUT
echo "$DIFFS1" | tee -a $TEST1OUTPUT

DIFFS1=`diff $CONTRACTSDIR/$SAFERMATHSOL $SAFERMATHTEMPSOL`
echo "--- Differences $CONTRACTSDIR/$SAFERMATHSOL $SAFERMATHTEMPSOL ---" | tee -a $TEST1OUTPUT
echo "$DIFFS1" | tee -a $TEST1OUTPUT

DIFFS1=`diff $CONTRACTSDIR/$STOXSMARTTOKENSOL $STOXSMARTTOKENTEMPSOL`
echo "--- Differences $CONTRACTSDIR/$STOXSMARTTOKENSOL $STOXSMARTTOKENTEMPSOL ---" | tee -a $TEST1OUTPUT
echo "$DIFFS1" | tee -a $TEST1OUTPUT

DIFFS1=`diff $CONTRACTSDIR/$STOXSMARTTOKENSALESOL $STOXSMARTTOKENSALETEMPSOL`
echo "--- Differences $CONTRACTSDIR/$STOXSMARTTOKENSALESOL $STOXSMARTTOKENSALETEMPSOL ---" | tee -a $TEST1OUTPUT
echo "$DIFFS1" | tee -a $TEST1OUTPUT

DIFFS1=`diff $CONTRACTSDIR/$TRUSTEESOL $TRUSTEETEMPSOL`
echo "--- Differences $CONTRACTSDIR/$TRUSTEESOL $TRUSTEETEMPSOL ---" | tee -a $TEST1OUTPUT
echo "$DIFFS1" | tee -a $TEST1OUTPUT

echo "var saleOutput=`solc_4.1.11 --optimize --combined-json abi,bin,interface $STOXSMARTTOKENSALETEMPSOL`;" > $STOXSMARTTOKENSALEJS


geth --verbosity 3 attach $GETHATTACHPOINT << EOF | tee -a $TEST1OUTPUT
loadScript("$STOXSMARTTOKENSALEJS");
loadScript("functions.js");

var tokenAbi = JSON.parse(saleOutput.contracts["$STOXSMARTTOKENTEMPSOL:StoxSmartToken"].abi);
var tokenBin = "0x" + saleOutput.contracts["$STOXSMARTTOKENTEMPSOL:StoxSmartToken"].bin;

var saleAbi = JSON.parse(saleOutput.contracts["$STOXSMARTTOKENSALETEMPSOL:StoxSmartTokenSale"].abi);
var saleBin = "0x" + saleOutput.contracts["$STOXSMARTTOKENSALETEMPSOL:StoxSmartTokenSale"].bin;

var trusteeAbi = JSON.parse(saleOutput.contracts["$TRUSTEETEMPSOL:Trustee"].abi);
var trusteeBin = "0x" + saleOutput.contracts["$TRUSTEETEMPSOL:Trustee"].bin;

console.log("DATA: tokenAbi=" + JSON.stringify(tokenAbi));
// console.log("DATA: tokenBin=" + tokenBin);
console.log("DATA: saleAbi=" + JSON.stringify(saleAbi));
// console.log("DATA: saleBin=" + saleBin);
console.log("DATA: trusteeAbi=" + JSON.stringify(trusteeAbi));
// console.log("DATA: trusteeBin=" + trusteeBin);

unlockAccounts("$PASSWORD");
printBalances();
console.log("RESULT: ");

// -----------------------------------------------------------------------------
var tokenMessage = "Deploy StoxSmartToken";
// -----------------------------------------------------------------------------
console.log("RESULT: " + tokenMessage);
var tokenContract = web3.eth.contract(tokenAbi);
var tokenTx = null;
var tokenAddress = null;
var token = tokenContract.new({from: contractOwnerAccount, data: tokenBin, gas: 4000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        tokenTx = contract.transactionHash;
      } else {
        tokenAddress = contract.address;
        addAccount(tokenAddress, "Token '" + token.symbol() + "' '" + token.name() + "'");
        addTokenContractAddressAndAbi(tokenAddress, tokenAbi);
        printTxData("tokenAddress=" + tokenAddress, tokenTx);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfGasEqualsGasUsed(tokenTx, tokenMessage);
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var saleMessage = "Deploy StoxSmartTokenSale";
// -----------------------------------------------------------------------------
console.log("RESULT: " + saleMessage);
var saleContract = web3.eth.contract(saleAbi);
var saleTx = null;
var saleAddress = null;
var sale = saleContract.new(tokenAddress, multisig, $STARTTIME, {from: contractOwnerAccount, data: saleBin, gas: 4000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        saleTx = contract.transactionHash;
      } else {
        saleAddress = contract.address;
        addAccount(saleAddress, "StoxSmartTokenSale");
        addCrowdsaleContractAddressAndAbi(saleAddress, saleAbi);
        printTxData("saleAddress=" + saleAddress, saleTx);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfGasEqualsGasUsed(saleTx, saleMessage);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var transferOwnershipMessage = "Transfer Ownership For Token To TokenSale";
// -----------------------------------------------------------------------------
console.log("RESULT: " + transferOwnershipMessage);
var transferOwnershipTx = token.transferOwnership(saleAddress, {from: contractOwnerAccount, gas: 4000000});
while (txpool.status.pending > 0) {
}
printTxData("transferOwnershipTx", transferOwnershipTx);
printBalances();
failIfGasEqualsGasUsed(transferOwnershipTx, transferOwnershipMessage);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var acceptTransferOwnershipMessage = "Accept Transfer Ownership For Token To TokenSale";
// -----------------------------------------------------------------------------
console.log("RESULT: " + acceptTransferOwnershipMessage);
var acceptTransferOwnershipTx = sale.acceptSmartTokenOwnership({from: contractOwnerAccount, gas: 4000000});
while (txpool.status.pending > 0) {
}
printTxData("acceptTransferOwnershipTx", acceptTransferOwnershipTx);
printBalances();
failIfGasEqualsGasUsed(acceptTransferOwnershipTx, acceptTransferOwnershipMessage);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var distributeMessage = "Distribute Partner Tokens";
// -----------------------------------------------------------------------------
console.log("RESULT: " + distributeMessage);
var distributeTx = sale.distributePartnerTokens({from: contractOwnerAccount, gas: 4000000});
while (txpool.status.pending > 0) {
}
printTxData("distributeTx", distributeTx);
printBalances();
failIfGasEqualsGasUsed(distributeTx, distributeMessage);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
// Wait for crowdsale start
// -----------------------------------------------------------------------------
var startTime = sale.startTime();
var startTimeDate = new Date(startTime * 1000);
console.log("RESULT: Waiting until startTime at " + startTime + " " + startTimeDate +
  " currentDate=" + new Date());
while ((new Date()).getTime() <= startTimeDate.getTime()) {
}
console.log("RESULT: Waited until startTime at " + startTime + " " + startTimeDate +
  " currentDate=" + new Date());


// -----------------------------------------------------------------------------
var validContribution1Message = "Send Valid Contribution";
// -----------------------------------------------------------------------------
console.log("RESULT: " + validContribution1Message);
var validContribution1Tx = eth.sendTransaction({from: account3, to: saleAddress, gas: 400000, value: web3.toWei("30000.333333333333333333", "ether")});
var validContribution2Tx = eth.sendTransaction({from: account4, to: saleAddress, gas: 400000, value: web3.toWei("50000.123456789123456789", "ether")});
while (txpool.status.pending > 0) {
}
printTxData("validContribution1Tx", validContribution1Tx);
printTxData("validContribution2Tx", validContribution2Tx);
printBalances();
failIfGasEqualsGasUsed(validContribution1Tx, validContribution1Message + " ac3 30,000.333333333333333333 ETH ~ 6,000,000 STX");
failIfGasEqualsGasUsed(validContribution2Tx, validContribution1Message + " ac4 50,000.123456789123456789 ETH ~ 10,000,000 STX");
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
// Wait until startBlock 
// -----------------------------------------------------------------------------
console.log("RESULT: Waiting until endBlock #" + endBlock + " currentBlock=" + eth.blockNumber);
while (eth.blockNumber <= endBlock) {
}
console.log("RESULT: Waited until endBlock #" + endBlock + " currentBlock=" + eth.blockNumber);
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var finaliseMessage = "Finalise Crowdsale";
// -----------------------------------------------------------------------------
console.log("RESULT: " + finaliseMessage);
var finaliseTx = sale.finalize({from: contractOwnerAccount, gas: 4000000});
while (txpool.status.pending > 0) {
}
addAccount(sale.trustee(), "Trustee");
addTrusteeContractAddressAndAbi(sale.trustee(), trusteeAbi);
printTxData("finaliseTx", finaliseTx);
printBalances();
failIfGasEqualsGasUsed(finaliseTx, finaliseMessage);
printCrowdsaleContractDetails();
printTokenContractDetails();
printTrusteeContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var canTransferMessage = "Can Move Tokens";
// -----------------------------------------------------------------------------
console.log("RESULT: " + canTransferMessage);
var canTransfer1Tx = token.transfer(account5, "1000000000000000000", {from: account3, gas: 100000});
var canTransfer2Tx = token.approve(account6,  "3000000000000000000", {from: account4, gas: 100000});
while (txpool.status.pending > 0) {
}
var canTransfer3Tx = token.transferFrom(account4, account7, "3000000000000000000", {from: account6, gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("canTransfer1Tx", canTransfer1Tx);
printTxData("canTransfer2Tx", canTransfer2Tx);
printTxData("canTransfer3Tx", canTransfer3Tx);
printBalances();
failIfGasEqualsGasUsed(canTransfer1Tx, canTransferMessage + " - transfer 1 STX ac3 -> ac5. CHECK for movement");
failIfGasEqualsGasUsed(canTransfer2Tx, canTransferMessage + " - ac4 approve 3 STX ac6");
failIfGasEqualsGasUsed(canTransfer3Tx, canTransferMessage + " - ac6 transferFrom 3 STX ac4 -> ac7. CHECK for movement");
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var transferOwnership2Message = "Transfer Ownership For Token To ContractOwner";
// -----------------------------------------------------------------------------
console.log("RESULT: " + transferOwnership2Message);
var transferOwnership2Tx = sale.transferSmartTokenOwnership(contractOwnerAccount, {from: contractOwnerAccount, gas: 4000000});
while (txpool.status.pending > 0) {
}
printTxData("transferOwnership2Tx", transferOwnershipTx);
printBalances();
failIfGasEqualsGasUsed(transferOwnership2Tx, transferOwnership2Message);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var acceptTransferOwnership2Message = "Accept Transfer Ownership For Token To ContractOwner";
// -----------------------------------------------------------------------------
console.log("RESULT: " + acceptTransferOwnership2Message);
var acceptTransferOwnership2Tx = token.acceptOwnership({from: contractOwnerAccount, gas: 4000000});
while (txpool.status.pending > 0) {
}
printTxData("acceptTransferOwnership2Tx", acceptTransferOwnership2Tx);
printBalances();
failIfGasEqualsGasUsed(acceptTransferOwnership2Tx, acceptTransferOwnership2Message);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var disableTransferMessage = "Disable Token Transfers";
// -----------------------------------------------------------------------------
console.log("RESULT: " + disableTransferMessage);
var disableTransferTx = token.disableTransfers(true, {from: contractOwnerAccount, gas: 4000000});
while (txpool.status.pending > 0) {
}
printTxData("disableTransferTx", disableTransferTx);
printBalances();
failIfGasEqualsGasUsed(acceptTransferOwnership2Tx, disableTransferMessage);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var cannotTransferMessage = "Cannot Move Tokens";
// -----------------------------------------------------------------------------
console.log("RESULT: " + cannotTransferMessage);
var cannotTransfer1Tx = token.transfer(account5, "10000000000000000000", {from: account3, gas: 100000});
var cannotTransfer2Tx = token.approve(account6,  "30000000000000000000", {from: account4, gas: 100000});
while (txpool.status.pending > 0) {
}
var cannotTransfer3Tx = token.transferFrom(account4, account7, "30000000000000000000", {from: account6, gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("cannotTransfer1Tx", cannotTransfer1Tx);
printTxData("cannotTransfer2Tx", cannotTransfer2Tx);
printTxData("cannotTransfer3Tx", cannotTransfer3Tx);
printBalances();
passIfGasEqualsGasUsed(cannotTransfer1Tx, cannotTransferMessage + " - transfer 10 STX ac3 -> ac5. CHECK for NO movement");
failIfGasEqualsGasUsed(cannotTransfer2Tx, cannotTransferMessage + " - ac4 approve 30 STX ac6");
passIfGasEqualsGasUsed(cannotTransfer3Tx, cannotTransferMessage + " - ac6 transferFrom 30 STX ac4 -> ac7. CHECK for NO movement");
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var mintTokensMessage = "Mint Tokens";
// -----------------------------------------------------------------------------
console.log("RESULT: " + mintTokensMessage);
var mintTokensTx = token.issue(account8, "77700000000000000000000000000", {from: contractOwnerAccount, gas: 4000000});
while (txpool.status.pending > 0) {
}
printTxData("mintTokensTx", mintTokensTx);
printBalances();
failIfGasEqualsGasUsed(mintTokensTx, mintTokensMessage);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var burnAnyonesTokensMessage = "Burn Anyone's Tokens";
// -----------------------------------------------------------------------------
console.log("RESULT: " + burnAnyonesTokensMessage);
var burnAnyonesTokensTx = token.destroy(account8, "77010000000000000000000000000", {from: contractOwnerAccount, gas: 4000000});
while (txpool.status.pending > 0) {
}
printTxData("burnAnyonesTokensTx", burnAnyonesTokensTx);
printBalances();
failIfGasEqualsGasUsed(burnAnyonesTokensTx, burnAnyonesTokensMessage);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


EOF
grep "DATA: " $TEST1OUTPUT | sed "s/DATA: //" > $DEPLOYMENTDATA
cat $DEPLOYMENTDATA
grep "RESULT: " $TEST1OUTPUT | sed "s/RESULT: //" > $TEST1RESULTS
cat $TEST1RESULTS

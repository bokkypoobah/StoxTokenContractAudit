# IERC20Token

Source file [../bancor-contracts/IERC20Token.sol](../bancor-contracts/IERC20Token.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.11;

/*
    ERC20 Standard Token interface
*/
// BK Ok
contract IERC20Token {
    // these functions aren't abstract since the compiler emits automatically generated getter functions as external
    // BK Ok
    function name() public constant returns (string name) { name; }
    // BK Ok
    function symbol() public constant returns (string symbol) { symbol; }
    // BK Ok
    function decimals() public constant returns (uint8 decimals) { decimals; }
    // BK Ok
    function totalSupply() public constant returns (uint256 totalSupply) { totalSupply; }
    // BK Ok
    function balanceOf(address _owner) public constant returns (uint256 balance) { _owner; balance; }
    // BK Ok
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) { _owner; _spender; remaining; }

    // BK Ok
    function transfer(address _to, uint256 _value) public returns (bool success);
    // BK Ok
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    // BK Ok
    function approve(address _spender, uint256 _value) public returns (bool success);
}

```

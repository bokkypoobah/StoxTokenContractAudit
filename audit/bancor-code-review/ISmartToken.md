# ISmartToken

Source file [../bancor-contracts/ISmartToken.sol](../bancor-contracts/ISmartToken.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.11;
// BK Next 2 Ok
import './ITokenHolder.sol';
import './IERC20Token.sol';

/*
    Smart Token interface
*/
// BK Ok
contract ISmartToken is ITokenHolder, IERC20Token {
    // BK Ok
    function disableTransfers(bool _disable) public;
    // BK Ok
    function issue(address _to, uint256 _amount) public;
    // BK Ok
    function destroy(address _from, uint256 _amount) public;
}

```

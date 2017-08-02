# ITokenHolder

Source file [../bancor-contracts/ITokenHolder.sol](../bancor-contracts/ITokenHolder.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.11;
// BK Next 2 Ok
import './IOwned.sol';
import './IERC20Token.sol';

/*
    Token Holder interface
*/
// BK Ok
contract ITokenHolder is IOwned {
    // BK Ok
    function withdrawTokens(IERC20Token _token, address _to, uint256 _amount) public;
}

```

# StoxSmartToken

Source file [../../contracts/StoxSmartToken.sol](../../contracts/StoxSmartToken.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.11;

// BK Ok
import 'bancor-contracts/solidity/contracts/SmartToken.sol';

// BK Ok
import './SaferMath.sol';

/// @title Stox Smart Token
// BK Ok
contract StoxSmartToken is SmartToken {
    // BK Ok - Constructor
    function StoxSmartToken() SmartToken('Stox', 'STX', 18) {
    	// BK Ok
        disableTransfers(true);
    }
}

```

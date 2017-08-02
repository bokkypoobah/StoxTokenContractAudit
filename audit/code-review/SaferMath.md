# SaferMath

Source file [../../contracts/SaferMath.sol](../../contracts/SaferMath.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.11;

/// @title Math operations with safety checks
// BK Ok
library SaferMath {
    // BK Ok
    function mul(uint256 a, uint256 b) internal returns (uint256) {
        // BK Ok
        uint256 c = a * b;
        // BK Ok
        assert(a == 0 || c / a == b);
        // BK Ok
        return c;
    }

    // BK Ok
    function div(uint256 a, uint256 b) internal returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // BK Ok
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        // BK Ok
        return c;
    }

    // BK Ok
    function sub(uint256 a, uint256 b) internal returns (uint256) {
        // BK Ok
        assert(b <= a);
        // BK Ok
        return a - b;
    }

    // BK Ok
    function add(uint256 a, uint256 b) internal returns (uint256) {
        // BK Ok
        uint256 c = a + b;
        // BK Ok
        assert(c >= a);
        // BK Ok
        return c;
    }

    // BK Ok - Not used
    function max64(uint64 a, uint64 b) internal constant returns (uint64) {
        // BK Ok
        return a >= b ? a : b;
    }

    // BK Ok - Not used
    function min64(uint64 a, uint64 b) internal constant returns (uint64) {
        // BK Ok
        return a < b ? a : b;
    }

    // BK Ok - Not used
    function max256(uint256 a, uint256 b) internal constant returns (uint256) {
        // BK Ok
        return a >= b ? a : b;
    }

    // BK Ok
    function min256(uint256 a, uint256 b) internal constant returns (uint256) {
        // BK Ok
        return a < b ? a : b;
    }
}

```

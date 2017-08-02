# SafeMath

Source file [../bancor-contracts/SafeMath.sol](../bancor-contracts/SafeMath.sol).

<br />

<hr />

```javascript
pragma solidity ^0.4.11;

/*
    Overflow protected math functions
*/
contract SafeMath {
    /**
        constructor
    */
    // BK Ok - Constructor
    function SafeMath() {
    }

    /**
        @dev returns the sum of _x and _y, asserts if the calculation overflows

        @param _x   value 1
        @param _y   value 2

        @return sum
    */
    // BK Ok
    function safeAdd(uint256 _x, uint256 _y) internal returns (uint256) {
        // BK Ok
        uint256 z = _x + _y;
        // BK Ok
        assert(z >= _x);
        // BK Ok
        return z;
    }

    /**
        @dev returns the difference of _x minus _y, asserts if the subtraction results in a negative number

        @param _x   minuend
        @param _y   subtrahend

        @return difference
    */
    // BK Ok
    function safeSub(uint256 _x, uint256 _y) internal returns (uint256) {
    	// BK Ok
        assert(_x >= _y);
        // BK Ok
        return _x - _y;
    }

    /**
        @dev returns the product of multiplying _x by _y, asserts if the calculation overflows

        @param _x   factor 1
        @param _y   factor 2

        @return product
    */
    // BK Ok
    function safeMul(uint256 _x, uint256 _y) internal returns (uint256) {
    	// BK Ok
        uint256 z = _x * _y;
        // BK Ok
        assert(_x == 0 || z / _x == _y);
        // BK Ok
        return z;
    }
}

```

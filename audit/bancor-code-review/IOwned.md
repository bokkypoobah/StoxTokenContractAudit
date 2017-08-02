# IOwned

Source file [../bancor-contracts/IOwned.sol](../bancor-contracts/IOwned.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.11;

/*
    Owned contract interface
*/
// BK OK
contract IOwned {
    // this function isn't abstract since the compiler emits automatically generated getter functions as external
    // BK Ok - Should the `owner;` statement read `return owner`? But this is more an interface to declare the function signature
    function owner() public constant returns (address owner) { owner; }

    // BK Ok
    function transferOwnership(address _newOwner) public;
    // BK Ok
    function acceptOwnership() public;
}

```

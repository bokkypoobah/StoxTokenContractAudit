# Owned

Source file [../bancor-contracts/Owned.sol](../bancor-contracts/Owned.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.11;
import './IOwned.sol';

/*
    Provides support and utilities for contract ownership
*/
// BK Ok
contract Owned is IOwned {
    // BK Ok
    address public owner;
    // BK Ok
    address public newOwner;

    // BK Ok
    event OwnerUpdate(address _prevOwner, address _newOwner);

    /**
        @dev constructor
    */
    // BK Ok - Constructor - assign owner variable to the sending account
    function Owned() {
        // BK Ok
        owner = msg.sender;
    }

    // allows execution by the owner only
    // BK Ok
    modifier ownerOnly {
        // BK Ok
        assert(msg.sender == owner);
        // BK Ok
        _;
    }

    /**
        @dev allows transferring the contract ownership
        the new owner still need to accept the transfer
        can only be called by the contract owner

        @param _newOwner    new contract owner
    */
    // BK Ok - Can only be executed by the owner
    function transferOwnership(address _newOwner) public ownerOnly {
        // BK Ok - Check that there is a change to the owner
        require(_newOwner != owner);
        // BK Ok
        newOwner = _newOwner;
    }

    /**
        @dev used by a new owner to accept an ownership transfer
    */
    // BK Ok
    function acceptOwnership() public {
        // BK Ok - Only the new owner can execute this transaction
        require(msg.sender == newOwner);
        // BK Ok
        address prevOwner = owner;
        // BK Ok
        owner = newOwner;
        // BK Ok
        newOwner = 0x0;
        // BK Ok - Log event
        OwnerUpdate(prevOwner, owner);
    }
}

```

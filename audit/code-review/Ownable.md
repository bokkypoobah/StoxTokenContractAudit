# Ownable

Source file [../../contracts/Ownable.sol](../../contracts/Ownable.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.11;

/// @title Ownable
/// @dev The Ownable contract has an owner address, and provides basic authorization control functions, this simplifies
/// & the implementation of "user permissions".
// BK Ok
contract Ownable {
    // BK Ok
    address public owner;
    address public newOwnerCandidate;

    event OwnershipRequested(address indexed _by, address indexed _to);
    event OwnershipTransferred(address indexed _from, address indexed _to);

    /// @dev The Ownable constructor sets the original `owner` of the contract to the sender account.
    // BK Ok - Constructor setting the owner variable
    function Ownable() {
        // BK Ok
        owner = msg.sender;
    }

    /// @dev Throws if called by any account other than the owner.
    // BK Ok - Throw if not called by owner
    modifier onlyOwner() {
        // BK Ok
        if (msg.sender != owner) {
            // BK Ok
            throw;
        }

        // BK Ok
        _;
    }

    /// @dev Proposes to transfer control of the contract to a newOwnerCandidate.
    /// @param _newOwnerCandidate address The address to transfer ownership to.
    // BK Ok - Only the current owner can execute this
    function transferOwnership(address _newOwnerCandidate) onlyOwner {
        // BK Ok - Check that the proposed owner is not 0x0
        require(_newOwnerCandidate != address(0));

        // BK Ok
        newOwnerCandidate = _newOwnerCandidate;

        // BK Ok - Log event
        OwnershipRequested(msg.sender, newOwnerCandidate);
    }

    /// @dev Accept ownership transfer. This method needs to be called by the perviously proposed owner.
    // BK Ok
    function acceptOwnership() {
        // BK Ok - Only the new owner-to-be can run this
        if (msg.sender == newOwnerCandidate) {
            // BK Ok
            owner = newOwnerCandidate;
            // BK Ok
            newOwnerCandidate = address(0);

            // BK Ok - Log event
            OwnershipTransferred(owner, newOwnerCandidate);
        }
    }
}

```

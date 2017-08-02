# Trustee

Source file [../../contracts/Trustee.sol](../../contracts/Trustee.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.11;

// BK Next 3 Ok
import './SaferMath.sol';
import './Ownable.sol';
import './StoxSmartToken.sol';

/// @title Vesting trustee
contract Trustee is Ownable {
    // BK Ok
    using SaferMath for uint256;

    // The address of the STX ERC20 token.
    // BK Ok
    StoxSmartToken public stox;

    // BK Ok
    struct Grant {
        // BK Ok - Value to be vested
        uint256 value;
        // BK Ok - Start in unixtime
        uint256 start;
        // BK Ok - Cliff in unixtime
        uint256 cliff;
        // BK Ok - End in unixtime
        uint256 end;
        // BK Ok - Value already transferred
        uint256 transferred;
        // BK Ok - Can the vested amount be revoked
        bool revokable;
    }

    // Grants holder.
    // BK Ok
    mapping (address => Grant) public grants;

    // Total tokens available for vesting.
    // BK Ok
    uint256 public totalVesting;

    // BK Ok
    event NewGrant(address indexed _from, address indexed _to, uint256 _value);
    event UnlockGrant(address indexed _holder, uint256 _value);
    event RevokeGrant(address indexed _holder, uint256 _refund);

    /// @dev Constructor that initializes the address of the StoxSmartToken contract.
    /// @param _stox StoxSmartToken The address of the previously deployed StoxSmartToken smart contract.
    // BK Ok - Constructor
    function Trustee(StoxSmartToken _stox) {
        // BK Ok
        require(_stox != address(0));

        // BK Ok
        stox = _stox;
    }

    /// @dev Grant tokens to a specified address.
    /// @param _to address The address to grant tokens to.
    /// @param _value uint256 The amount of tokens to be granted.
    /// @param _start uint256 The beginning of the vesting period.
    /// @param _cliff uint256 Duration of the cliff period.
    /// @param _end uint256 The end of the vesting period.
    /// @param _revokable bool Whether the grant is revokable or not.
    // BK Ok - Only owner can call this
    function grant(address _to, uint256 _value, uint256 _start, uint256 _cliff, uint256 _end, bool _revokable)
        public onlyOwner {
        // BK Ok
        require(_to != address(0));
        // BK Ok
        require(_value > 0);

        // Make sure that a single address can be granted tokens only once.
        // BK Ok
        require(grants[_to].value == 0);

        // Check for date inconsistencies that may cause unexpected behavior.
        // BK Ok - Start - Cliff - End
        require(_start <= _cliff && _cliff <= _end);

        // Check that this grant doesn't exceed the total amount of tokens currently available for vesting.
        // BK NOTE - Have to be careful that the sum of the vested amounts don't exceed the total vested amounts
        // BK NOTE - Or the last call to assign the vested amount may fail
        // BK Ok
        require(totalVesting.add(_value) <= stox.balanceOf(address(this)));

        // Assign a new grant.
        // BK Ok - Copy data into structure that is stored in a mapping
        grants[_to] = Grant({
            value: _value,
            start: _start,
            cliff: _cliff,
            end: _end,
            transferred: 0,
            revokable: _revokable
        });

        // Tokens granted, reduce the total amount available for vesting.
        // BK Ok
        totalVesting = totalVesting.add(_value);

        // BK Ok - Log event
        NewGrant(msg.sender, _to, _value);
    }

    /// @dev Revoke the grant of tokens of a specifed address.
    /// @param _holder The address which will have its tokens revoked.
    // BK Ok - Only owner can call this
    function revoke(address _holder) public onlyOwner {
        // BK Ok
        Grant grant = grants[_holder];

        // BK Ok - Can only revoke revocable grants
        require(grant.revokable);

        // Send the remaining STX back to the owner
        // BK Ok - Calculate tokens not yet transferred out
        uint256 refund = grant.value.sub(grant.transferred);

        // Remove the grant.
        // BK Ok
        delete grants[_holder];

        // BK Ok
        totalVesting = totalVesting.sub(refund);
        // BK Ok - Send tokens to owner (msg.sender)
        stox.transfer(msg.sender, refund);

        // BK Ok - Log event
        RevokeGrant(_holder, refund);
    }

    /// @dev Calculate the total amount of vested tokens of a holder at a given time.
    /// @param _holder address The address of the holder.
    /// @param _time uint256 The specific time.
    /// @return a uint256 representing a holder's total amount of vested tokens.
    // BK Ok - Constant function
    function vestedTokens(address _holder, uint256 _time) public constant returns (uint256) {
        // BK Ok
        Grant grant = grants[_holder];
        // BK Ok
        if (grant.value == 0) {
            // BK Ok
            return 0;
        }

        // BK Ok
        return calculateVestedTokens(grant, _time);
    }

    /// @dev Calculate amount of vested tokens at a specifc time.
    /// @param _grant Grant The vesting grant.
    /// @param _time uint256 The time to be checked
    /// @return An uint256 representing the amount of vested tokens of a specific grant.
    ///   |                         _/--------   vestedTokens rect
    ///   |                       _/
    ///   |                     _/
    ///   |                   _/
    ///   |                 _/
    ///   |                /
    ///   |              .|
    ///   |            .  |
    ///   |          .    |
    ///   |        .      |
    ///   |      .        |
    ///   |    .          |
    ///   +===+===========+---------+----------> time
    ///     Start       Cliff      End
    // BK Ok - Constant function
    function calculateVestedTokens(Grant _grant, uint256 _time) private constant returns (uint256) {
        // If we're before the cliff, then nothing is vested.
        // BK Ok
        if (_time < _grant.cliff) {
            // BK Ok
            return 0;
        }

        // If we're after the end of the vesting period - everything is vested;
        // BK Ok
        if (_time >= _grant.end) {
            // BK Ok
            return _grant.value;
        }

        // Interpolate all vested tokens: vestedTokens = tokens/// (time - start) / (end - start)
        // BK NOTE - vestedTokens = amount x (time - start) / (end - start)
        // BK Ok
         return _grant.value.mul(_time.sub(_grant.start)).div(_grant.end.sub(_grant.start));
    }

    /// @dev Unlock vested tokens and transfer them to their holder.
    /// @return a uint256 representing the amount of vested tokens transferred to their holder.
    // BK Ok - Anyone can call this, but only accounts with vesting tokens will be able to transfer out their vested portions
    function unlockVestedTokens() public {
        // BK Ok
        Grant grant = grants[msg.sender];
        // BK Ok
        require(grant.value != 0);

        // Get the total amount of vested tokens, acccording to grant.
        // BK Ok
        uint256 vested = calculateVestedTokens(grant, now);
        // BK Ok - Nothing available, return
        if (vested == 0) {
            // BK Ok
            return;
        }

        // Make sure the holder doesn't transfer more than what he already has.
        // BK Ok - Amount that can be transferred = vested - amount transferred
        uint256 transferable = vested.sub(grant.transferred);
        // BK Ok - Nothing that can be transferred, return
        if (transferable == 0) {
            // BK Ok
            return;
        }

        // BK Ok - Keep track of the amount already transferred
        grant.transferred = grant.transferred.add(transferable);
        // BK Ok - Reduce the total vested tokens by the amount being transferred
        totalVesting = totalVesting.sub(transferable);
        // BK Ok - Transfer transferable amount to the caller
        stox.transfer(msg.sender, transferable);

        // BK Ok - Log event
        UnlockGrant(msg.sender, transferable);
    }
}

```

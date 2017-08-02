# SmartToken

Source file [../bancor-contracts/SmartToken.sol](../bancor-contracts/SmartToken.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.11;
// BK Next 4 Ok
import './ISmartToken.sol';
import './ERC20Token.sol';
import './TokenHolder.sol';
import './Owned.sol';

/*
    Smart Token v0.2

    'Owned' is specified here for readability reasons
*/
// BK Ok
contract SmartToken is ISmartToken, ERC20Token, Owned, TokenHolder {
    // BK Ok
    string public version = '0.2';

    // BK Ok
    bool public transfersEnabled = true;    // true if transfer/transferFrom are enabled, false if not

    // triggered when a smart token is deployed - the _token address is defined for forward compatibility, in case we want to trigger the event from a factory
    // BK Ok
    event NewSmartToken(address _token);
    // triggered when the total supply is increased
    // BK Ok
    event Issuance(uint256 _amount);
    // triggered when the total supply is decreased
    // BK Ok
    event Destruction(uint256 _amount);

    /**
        @dev constructor

        @param _name       token name
        @param _symbol     token short symbol, 1-6 characters
        @param _decimals   for display purposes only
    */
    // BK Ok - Constructor
    function SmartToken(string _name, string _symbol, uint8 _decimals)
        // BK Ok
        ERC20Token(_name, _symbol, _decimals)
    {
        // BK Ok
        require(bytes(_symbol).length <= 6); // validate input
        // BK Ok - Log event
        NewSmartToken(address(this));
    }

    // allows execution only when transfers aren't disabled
    // BK Ok
    modifier transfersAllowed {
        // BK Ok
        assert(transfersEnabled);
        _;
    }

    /**
        @dev disables/enables transfers
        can only be called by the contract owner

        @param _disable    true to disable transfers, false to enable them
    */
    // BK Ok - Only owner can execute
    function disableTransfers(bool _disable) public ownerOnly {
        // BK Ok
        transfersEnabled = !_disable;
    }

    /**
        @dev increases the token supply and sends the new tokens to an account
        can only be called by the contract owner

        @param _to         account to receive the new amount
        @param _amount     amount to increase the supply by
    */
    // BK Ok - Only owner can call at any time to mint new tokens for any account
    function issue(address _to, uint256 _amount)
        // BK Ok
        public
        // BK Ok
        ownerOnly
        // BK Ok
        validAddress(_to)
        // BK Ok
        notThis(_to)
        // BK Ok
        validAmount(_amount)
    {
        // BK Ok
        totalSupply = safeAdd(totalSupply, _amount);
        // BK Ok
        balanceOf[_to] = safeAdd(balanceOf[_to], _amount);

        // BK Ok
        Issuance(_amount);
        // BK Ok
        Transfer(this, _to, _amount);
    }

    /**
        @dev removes tokens from an account and decreases the token supply
        can only be called by the contract owner

        @param _from       account to remove the amount from
        @param _amount     amount to decrease the supply by
    */
    // BK Ok - Owner can call at any time to destroy tokens belonging to any account
    function destroy(address _from, uint256 _amount)
        // BK Ok
        public
        // BK Ok
        ownerOnly
        // BK Ok
        validAmount(_amount)
    {
        // BK Ok
        balanceOf[_from] = safeSub(balanceOf[_from], _amount);
        // BK Ok
        totalSupply = safeSub(totalSupply, _amount);

        // BK Ok
        Transfer(_from, this, _amount);
        // BK Ok
        Destruction(_amount);
    }

    // ERC20 standard method overrides with some extra functionality

    /**
        @dev send coins
        note that the function slightly deviates from the ERC20 standard and will throw on any error rather then return a boolean return value to minimize user errors
        also note that when transferring to the smart token's address, the coins are actually destroyed

        @param _to      target address
        @param _value   transfer amount

        @return true if the transfer was successful, false if it wasn't
    */
    // BK Ok
    function transfer(address _to, uint256 _value) public transfersAllowed returns (bool success) {
        // BK Ok
        assert(super.transfer(_to, _value));

        // transferring to the contract address destroys tokens
        // BK Ok
        if (_to == address(this)) {
            // BK Ok
            balanceOf[_to] -= _value;
            // BK Ok
            totalSupply -= _value;
            // BK Ok
            Destruction(_value);
        }

        // BK Ok
        return true;
    }

    /**
        @dev an account/contract attempts to get the coins
        note that the function slightly deviates from the ERC20 standard and will throw on any error rather then return a boolean return value to minimize user errors
        also note that when transferring to the smart token's address, the coins are actually destroyed

        @param _from    source address
        @param _to      target address
        @param _value   transfer amount

        @return true if the transfer was successful, false if it wasn't
    */
    // BK Ok
    function transferFrom(address _from, address _to, uint256 _value) public transfersAllowed returns (bool success) {
        // BK Ok
        assert(super.transferFrom(_from, _to, _value));

        // transferring to the contract address destroys tokens
        // BK Ok
        if (_to == address(this)) {
            // BK Ok
            balanceOf[_to] -= _value;
            // BK Ok
            totalSupply -= _value;
            // BK Ok
            Destruction(_value);
        }

        // BK Ok
        return true;
    }

    // fallback
    // BK Ok
    function() {
        // BK Ok
        assert(false);
    }
}

```
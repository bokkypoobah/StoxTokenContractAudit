# TokenHolder

Source file [../bancor-contracts/TokenHolder.sol](../bancor-contracts/TokenHolder.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.11;
// BK Next 2 Ok
import './Owned.sol';
import './IERC20Token.sol';

/*
    We consider every contract to be a 'token holder' since it's currently not possible
    for a contract to deny receiving tokens.

    The TokenHolder's contract sole purpose is to provide a safety mechanism that allows
    the owner to send tokens that were sent to the contract by mistake back to their sender.
*/
// BK Ok
contract TokenHolder is Owned {
    /**
        @dev constructor
    */
    // BK Ok
    function TokenHolder() {
    }

    // validates an address - currently only checks that it isn't null
    // BK Ok
    modifier validAddress(address _address) {
        // BK Ok
        require(_address != 0x0);
        // BK Ok
        _;
    }

    // verifies that an amount is greater than zero
    // BK Ok
    modifier validAmount(uint256 _amount) {
        // BK Ok
        require(_amount > 0);
        // BK Ok
        _;
    }

    // verifies that the address is different than this contract address
    // BK Ok
    modifier notThis(address _address) {
        // BK Ok
        require(_address != address(this));
        // BK Ok
        _;
    }

    /**
        @dev withdraws tokens held by the contract and sends them to an account
        can only be called by the owner

        @param _token   ERC20 token contract address
        @param _to      account to receive the new amount
        @param _amount  amount to withdraw
    */
    // BK Ok - Only owner can execute this function
    function withdrawTokens(IERC20Token _token, address _to, uint256 _amount)
        // BK Ok
        public
        // BK Ok
        ownerOnly
        // BK Ok
        validAddress(_token)
        // BK Ok
        validAddress(_to)
        // BK Ok
        notThis(_to)
        // BK Ok
        validAmount(_amount)
    {
        // BK Ok
        assert(_token.transfer(_to, _amount));
    }
}

```

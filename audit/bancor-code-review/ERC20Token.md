# ERC20Token

Source file [../bancor-contracts/ERC20Token.sol](../bancor-contracts/ERC20Token.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.11;
// BK Next 2 Ok
import './IERC20Token.sol';
import './SafeMath.sol';

/**
    ERC20 Standard Token implementation
*/
// BK Ok
contract ERC20Token is IERC20Token, SafeMath {
    // BK Ok
    string public standard = 'Token 0.1';
    // BK Ok
    string public name = '';
    // BK Ok
    string public symbol = '';
    // BK Ok - uint8 instead of uin256
    uint8 public decimals = 0;
    // BK Ok
    uint256 public totalSupply = 0;
    // BK Ok
    mapping (address => uint256) public balanceOf;
    // BK Ok
    mapping (address => mapping (address => uint256)) public allowance;

    // BK Ok
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    // BK Ok
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    /**
        @dev constructor

        @param _name        token name
        @param _symbol      token symbol
        @param _decimals    decimal points, for display purposes
    */
    // BK Ok - Constructor
    function ERC20Token(string _name, string _symbol, uint8 _decimals) {
        // BK Ok
        require(bytes(_name).length > 0 && bytes(_symbol).length > 0); // validate input

        // BK Ok
        name = _name;
        // BK Ok
        symbol = _symbol;
        // BK Ok
        decimals = _decimals;
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

    /**
        @dev send coins
        note that the function slightly deviates from the ERC20 standard and will throw on any error rather then return a boolean return value to minimize user errors

        @param _to      target address
        @param _value   transfer amount

        @return true if the transfer was successful, false if it wasn't
    */
    // BK Ok - This function will throw when there are errors instead of returning a false
    function transfer(address _to, uint256 _value)
        // BK Ok
        public
        // BK Ok
        validAddress(_to)
        // BK Ok
        validAmount(_value)
        // BK Ok
        returns (bool success)
    {
        // BK Ok
        balanceOf[msg.sender] = safeSub(balanceOf[msg.sender], _value);
        // BK Ok
        balanceOf[_to] = safeAdd(balanceOf[_to], _value);
        // BK Ok
        Transfer(msg.sender, _to, _value);
        // BK Ok
        return true;
    }

    /**
        @dev an account/contract attempts to get the coins
        note that the function slightly deviates from the ERC20 standard and will throw on any error rather then return a boolean return value to minimize user errors

        @param _from    source address
        @param _to      target address
        @param _value   transfer amount

        @return true if the transfer was successful, false if it wasn't
    */
    // BK Ok - This function will throw when there are errors instead of returning false
    function transferFrom(address _from, address _to, uint256 _value)
        // BK Ok
        public
        // BK Ok
        validAddress(_from)
        // BK Ok
        validAddress(_to)
        // BK Ok
        validAmount(_value)
        // BK Ok
        returns (bool success)
    {
        // BK Ok
        allowance[_from][msg.sender] = safeSub(allowance[_from][msg.sender], _value);
        // BK Ok
        balanceOf[_from] = safeSub(balanceOf[_from], _value);
        // BK Ok
        balanceOf[_to] = safeAdd(balanceOf[_to], _value);
        // BK Ok
        Transfer(_from, _to, _value);
        // BK Ok
        return true;
    }

    /**
        @dev allow another account/contract to spend some tokens on your behalf
        note that the function slightly deviates from the ERC20 standard and will throw on any error rather then return a boolean return value to minimize user errors

        also, to minimize the risk of the approve/transferFrom attack vector
        (see https://docs.google.com/document/d/1YLPtQxZu1UAvO9cZ1O2RPXBbT0mooh4DYKjA_jp-RLM/), approve has to be called twice
        in 2 separate transactions - once to change the allowance to 0 and secondly to change it to the new allowance value

        @param _spender approved address
        @param _value   allowance amount

        @return true if the approval was successful, false if it wasn't
    */
    // BK Ok
    function approve(address _spender, uint256 _value)
        // BK Ok
        public
        // BK Ok
        validAddress(_spender)
        // BK Ok
        returns (bool success)
    {
        // if the allowance isn't 0, it can only be updated to 0 to prevent an allowance change immediately after withdrawal
        // BK Ok
        require(_value == 0 || allowance[msg.sender][_spender] == 0);

        // BK Ok
        allowance[msg.sender][_spender] = _value;
        // BK Ok
        Approval(msg.sender, _spender, _value);
        // BK Ok
        return true;
    }
}

```

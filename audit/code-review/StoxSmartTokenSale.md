# StoxSmartTokenSale

Source file [../../contracts/StoxSmartTokenSale.sol](../../contracts/StoxSmartTokenSale.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.11;

// BK Next 4 Ok
import './SaferMath.sol';
import './Ownable.sol';
import './StoxSmartToken.sol';
import './Trustee.sol';

/// @title Stox Smart Token sale
// BK Ok
contract StoxSmartTokenSale is Ownable {
    // BK Ok
    using SaferMath for uint256;

	// BK Ok
    uint256 public constant DURATION = 14 days;

    // BK Ok
    bool public isFinalized = false;
    // BK Ok
    bool public isDistributed = false;

    // The address of the STX ERC20 token.
    // BK Ok
    StoxSmartToken public stox;

    // The address of the token allocation trustee;
    // BK Ok
    Trustee public trustee;

    // BK Next 3 Ok
    uint256 public startTime = 0;
    uint256 public endTime = 0;
    address public fundingRecipient;

    // BK Ok
    uint256 public tokensSold = 0;

    // TODO: update to the correct values.
    // BK Ok
    uint256 public constant ETH_CAP = 148000;
    // BK Ok
    uint256 public constant EXCHANGE_RATE = 200; // 200 STX for ETH
    uint256 public constant TOKEN_SALE_CAP = ETH_CAP * EXCHANGE_RATE * 10 ** 18;

    // BK Ok
    event TokensIssued(address indexed _to, uint256 _tokens);

    /// @dev Throws if called when not during sale.
    // BK Ok
    modifier onlyDuringSale() {
        if (tokensSold >= TOKEN_SALE_CAP || now < startTime || now >= endTime) {
            // BK Ok
            throw;
        }

        // BK Ok
        _;
    }

    /// @dev Throws if called before sale ends.
    // BK Ok
    modifier onlyAfterSale() {
        if (!(tokensSold >= TOKEN_SALE_CAP || now >= endTime)) {
            // BK Ok
            throw;
        }

        // BK Ok
        _;
    }

    /// @dev Constructor that initializes the sale conditions.
    /// @param _fundingRecipient address The address of the funding recipient.
    /// @param _startTime uint256 The start time of the token sale.
    // BK Ok - Constructor
    function StoxSmartTokenSale(address _stox, address _fundingRecipient, uint256 _startTime) {
        // BK Ok - Check token contract address is non-zero
        require(_stox != address(0));
        // BK Ok - Check wallet address is non-zero
        require(_fundingRecipient != address(0));
        // BK Ok - Check starting in the future
        require(_startTime > now);

        // BK Ok - Link token contract
        stox = StoxSmartToken(_stox);

        // BK Next 3 Ok
        fundingRecipient = _fundingRecipient;
        startTime = _startTime;
        endTime = startTime + DURATION;
    }

    /// @dev Distributed tokens to the partners who have participated during the pre-sale.
    // BK Ok - Only owner and external
    function distributePartnerTokens() external onlyOwner {
    	// BK Ok - Run once
        require(!isDistributed);

		// BK Next 2 Ok
        assert(tokensSold == 0);
        assert(stox.totalSupply() == 0);

        // Distribute strategic tokens to partners. Please note, that this address doesn't represent a single entity or
        // person and will be only used to distribute tokens to 30~ partners.
        //
        // Please expect to see token transfers from this address in the first 24 hours after the token sale ends.
        issueTokens(0x9065260ef6830f6372F1Bde408DeC57Fe3150530, 14800000 * 10 ** 18);

		// BK Ok
        isDistributed = true;
    }

    /// @dev Finalizes the token sale event.
    // BK Ok - Anyone can execute this function when the cap is reached or the crowdsale end date is reached
    function finalize() external onlyAfterSale {
        // BK Ok - Can only run this once
        if (isFinalized) {
            // BK Ok
            throw;
        }

        // Grant vesting grants.
        //
        // TODO: use real addresses.
        // BK Ok
        trustee = new Trustee(stox);

        // Since only 50% of the tokens will be sold, we will automatically issue the same amount of sold STX to the
        // trustee.
        // BK Ok
        uint256 unsoldTokens = tokensSold;

        // Issue 55% of the remaining tokens (== 27.5%) go to strategic parternships.
        // BK NOTE - strategicPartnershipTokens = unsoldTokens x 55%
        // BK Ok
        uint256 strategicPartnershipTokens = unsoldTokens.mul(55).div(100);

        // Note: we will substract the bonus tokens from this grant, since they were already issued for the pre-sale
        // strategic partners and should've been taken from this allocation.
        // BK NOTE - tokens(0x...3129) = strategicPartnershipTokens - PARTNER_BONUS
        // BK Ok
        stox.issue(0xbC14105ccDdeAadB96Ba8dCE18b40C45b6bACf58, strategicPartnershipTokens);

        // Issue the remaining tokens as vesting grants:
        // BK NOTE - tokens(trustee) = unsoldTokens - strategicPartnershipTokens
        // BK NOTE - tokens(trustee) = unsoldTokens - unsoldTokens x 55%
        // BK NOTE - tokens(trustee) = unsoldTokens x 45%
        stox.issue(trustee, unsoldTokens.sub(strategicPartnershipTokens));

        // 25% of the remaining tokens (== 12.5%) go to Invest.com, at uniform 12 months vesting schedule.
        // BK NOTE - tokens(0x...3121) = unsoldTokens x 25%
        // BK NOTE - There is no cliff, linear vesting from now to 1y
        // BK NOTE - The vested amount is revokable
        // BK Ok
        trustee.grant(0xb54c6a870d4aD65e23d471Fb7941aD271D323f5E, unsoldTokens.mul(25).div(100), now, now,
            now.add(1 years), true);

        // 20% of the remaining tokens (== 10%) go to Stox team, at uniform 24 months vesting schedule.
        // BK NOTE - tokens(0x...3122) = unsoldTokens x 20%
        // BK NOTE - There is no cliff, linear vesting from now to 2y
        // BK NOTE - The vested amount is revokable
        // BK OK
        trustee.grant(0x4eB4Cd1D125d9d281709Ff38d65b99a6927b46c1, unsoldTokens.mul(20).div(100), now, now,
            now.add(2 years), true);

        // Re-enable transfers after the token sale.
        // BK Ok - Enable transfers
        stox.disableTransfers(false);

        // BK Ok
        isFinalized = true;
    }

    /// @dev Create and sell tokens to the caller.
    /// @param _recipient address The address of the recipient.
    // BK Ok - Anyone can call this during the crowdsale to contribute funds and receive tokens
    function create(address _recipient) public payable onlyDuringSale {
        // BK Ok - Check address is not 0x0
        require(_recipient != address(0));
        // BK Ok - Check that some ETH has been sent
        require(msg.value > 0);

        // BK Ok - Check initial distribution has been executed
        assert(isDistributed);

        // BK NOTE - tokens = min(ethValue x EXCHANGE_RATE, TOKEN_SALE_CAP - tokensSold)
        // BK Ok
        uint256 tokens = SaferMath.min256(msg.value.mul(EXCHANGE_RATE), TOKEN_SALE_CAP.sub(tokensSold));
        // BK NOTE - contribution = tokens / EXCHANGE_RATE
        // BK Ok
        uint256 contribution = tokens.div(EXCHANGE_RATE);

        // BK Ok - Create tokens
        issueTokens(_recipient, tokens);

        // Transfer the funds to the funding recipient.
        // BK Ok - Transfer funds to beneficiary multisig
        fundingRecipient.transfer(contribution);

        // Refund the msg.sender, in the case that not all of its ETH was used. This can happen only when selling the
        // last chunk of STX.
        // BK Ok - Refund = ethValue - contribution
        uint256 refund = msg.value.sub(contribution);
        // BK Ok
        if (refund > 0) {
            // BK Ok
            msg.sender.transfer(refund);
        }
    }

    /// @dev Issues tokens for the recipient.
    /// @param _recipient address The address of the recipient.
    /// @param _tokens uint256 The amount of tokens to issue.
    // BK Ok - Private, can only be called by other public functions
    function issueTokens(address _recipient, uint256 _tokens) private {
        // Update total sold tokens.
        // BK Ok
        tokensSold = tokensSold.add(_tokens);

        // BK Ok - Mint tokens
        stox.issue(_recipient, _tokens);

        // BK Ok - Log event
        TokensIssued(_recipient, _tokens);
    }

    /// @dev Fallback function that will delegate the request to create.
    // BK Ok - Default function when ETH sent. Payable, only active during the sale period. Anyone can call this to send ETH and receive tokens
    function () external payable onlyDuringSale {
        // BK Ok
        create(msg.sender);
    }

    /// @dev Proposes to transfer control of the StoxSmartToken contract to a new owner.
    /// @param _newOwnerCandidate address The address to transfer ownership to.
    ///
    /// Note that:
    ///   1. The new owner will need to call StoxSmartToken's acceptOwnership directly in order to accept the ownership.
    ///   2. Calling this method during the token sale will prevent the token sale to continue, since only the owner of
    ///      the StoxSmartToken contract can issue new tokens.
    // BK Ok - Only owner
    function transferSmartTokenOwnership(address _newOwnerCandidate) external onlyOwner {
        // BK Ok
        stox.transferOwnership(_newOwnerCandidate);
    }

    /// @dev Accepts new ownership on behalf of the StoxSmartToken contract. This can be used, by the token sale
    /// contract itself to claim back ownership of the StoxSmartToken contract.
    // BK Ok - Only owner, although the new owner can directly call the stox.acceptOwnership()
    function acceptSmartTokenOwnership() external onlyOwner {
        // BK Ok
        stox.acceptOwnership();
    }

    /// @dev Proposes to transfer control of the Trustee contract to a new owner.
    /// @param _newOwnerCandidate address The address to transfer ownership to.
    ///
    /// Note that:
    ///   1. The new owner will need to call Trustee's acceptOwnership directly in order to accept the ownership.
    ///   2. Calling this method during the token sale won't be possible, as the Trustee is only created after its
    ///      finalization.
    // BK Ok - Only owner
    function transferTrusteeOwnership(address _newOwnerCandidate) external onlyOwner {
        // BK Ok
        trustee.transferOwnership(_newOwnerCandidate);
    }

    /// @dev Accepts new ownership on behalf of the Trustee contract. This can be used, by the token sale
    /// contract itself to claim back ownership of the Trustee contract.
    // BK Ok - Only owner, although the new owner can directly call trustee.acceptOwnership()
    function acceptTrusteeOwnership() external onlyOwner {
        // BK Ok
        trustee.acceptOwnership();
    }
}

```

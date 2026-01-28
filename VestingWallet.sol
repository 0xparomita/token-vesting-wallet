// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract VestingWallet is Ownable {
    event TokensReleased(address token, uint256 amount);

    // The token being vested
    IERC20 public immutable token;
    
    // Address receiving the tokens
    address public immutable beneficiary;

    // Unix timestamp when vesting starts
    uint256 public immutable start;

    // Duration in seconds of the cliff (no tokens released before start + cliff)
    uint256 public immutable cliff;

    // Total duration of the vesting in seconds
    uint256 public immutable duration;

    // Amount of tokens already released
    uint256 public released;

    constructor(
        address _token,
        address _beneficiary,
        uint256 _start,
        uint256 _cliffDuration,
        uint256 _duration
    ) Ownable(msg.sender) {
        require(_beneficiary != address(0), "Invalid beneficiary");
        require(_cliffDuration <= _duration, "Cliff > Duration");
        require(_duration > 0, "Duration is 0");

        token = IERC20(_token);
        beneficiary = _beneficiary;
        start = _start;
        cliff = _start + _cliffDuration;
        duration = _duration;
    }

    /**
     * @notice Transfers available vested tokens to the beneficiary.
     */
    function release() public {
        uint256 unreleased = releasableAmount();
        require(unreleased > 0, "No tokens due");

        released += unreleased;
        token.transfer(beneficiary, unreleased);

        emit TokensReleased(address(token), unreleased);
    }

    /**
     * @notice Calculates the amount of tokens that can be claimed now.
     */
    function releasableAmount() public view returns (uint256) {
        return vestedAmount() - released;
    }

    /**
     * @notice Calculates total vested tokens based on time.
     */
    function vestedAmount() public view returns (uint256) {
        uint256 currentBalance = token.balanceOf(address(this));
        uint256 totalBalance = currentBalance + released;

        if (block.timestamp < cliff) {
            return 0;
        } else if (block.timestamp >= start + duration) {
            return totalBalance;
        } else {
            return (totalBalance * (block.timestamp - start)) / duration;
        }
    }
}

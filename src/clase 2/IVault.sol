// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title Vault Interface for Solidity 101 Class 2
 * @dev This contract is a vault for ETH, but also distributes rewards evenly to all users in the vault
 */
interface IVault {
    /**
     * Check the current ETH balance of a user
     * @param _user address of the user to check balance
     */
    function balanceOf(address _user) external returns (uint);

    /**
     * Deposit ETH into the vault
     * @dev This function should be payable
     */
    function deposit() external payable;

    /**
     * Withdraw all ETH from the vault
     * @dev remember to also send rewards to users
     */
    function withdraw() external;

    /**
     * Send ETH to reward all users in the vault
     */
    function rewardUsers() external payable;

    /**
     * Return ETH to a specific user
     * @param _user address of the user to return ETH to
     */
    function returnETHToUser(address _user) external;

    // modifier onlyOwner

    event Deposit(address indexed _depositor, uint _depositAmount);
    event Withdraw(address indexed _user, uint _amountWithdrawn);
    event Rewarded(uint _amountRewarded);
}

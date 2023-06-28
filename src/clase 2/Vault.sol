// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import "./IVault.sol";
//----------------------
// Errors
//----------------------
error Vault__InsufficientETH();
error Vault__ErrorOnETHTransfer();
error Vault__NotOwner();
error Vault__InsufficientUsers();

/**
 * @title Vault for Solidity 101 Class 2
 * @author Semi Invader
 */
contract Vault is IVault {
    //---------------------------------------------------------
    // State Variables
    //---------------------------------------------------------

    // mapping( address _user => uint _balance) public balanceOf;
    mapping(address _user => uint _balance) private balances;
    uint public totalRewardedETH;
    uint public usersInVault;
    address public owner;

    //---------------------------------------------------------
    // Modifiers
    //---------------------------------------------------------
    modifier onlyOwner() {
        if (msg.sender != owner) revert Vault__NotOwner();
        _;
    }

    //---------------------------------------------------------
    // Constructor
    //---------------------------------------------------------

    constructor() {
        owner = msg.sender;
    }

    //---------------------------------------------------------
    // External Functions
    //---------------------------------------------------------

    function balanceOf(address _user) external view returns (uint) {
        return balances[_user];
    }

    function deposit() external payable {
        // require(msg.value > 0, "Insufficient ETH");
        if (msg.value == 0) revert Vault__InsufficientETH();

        if (balances[msg.sender] == 0) usersInVault++;
        // msg.sender contains user Address
        // msg.value amount of eth to receive
        balances[msg.sender] += msg.value;

        emit Deposit(msg.sender, msg.value);
    }

    function withdraw() external {
        _removeUser(msg.sender);
    }

    function returnETHToUser(address _user) external onlyOwner {
        _removeUser(_user);
    }

    function rewardUsers() external payable {
        if (msg.value == 0) revert Vault__InsufficientETH();
        if (usersInVault == 0) revert Vault__InsufficientUsers();
        totalRewardedETH += msg.value;
        emit Rewarded(msg.value);
    }

    //---------------------------------------------------------
    // Internal Functions
    //---------------------------------------------------------
    /**
     * the core behind returning ETH to a user and giving them rewards.
     * @param _user address of the user to remove
     */
    function _removeUser(address _user) internal {
        uint userBalance = balances[_user];
        if (userBalance == 0 || usersInVault == 0)
            revert Vault__InsufficientETH();
        uint rewardBalance = totalRewardedETH / usersInVault;
        balances[_user] = 0;
        totalRewardedETH -= rewardBalance;
        usersInVault--;
        (bool success, ) = payable(_user).call{value: userBalance}("");
        if (!success) revert Vault__ErrorOnETHTransfer();
        emit Withdraw(_user, userBalance);
    }
}

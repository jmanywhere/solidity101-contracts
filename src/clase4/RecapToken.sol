// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "openzeppelin/token/ERC20/ERC20.sol";
import "openzeppelin/access/Ownable.sol";

contract RecapToken is ERC20, Ownable {
    struct ExclusionStatus {
        bool taxExcluded;
        bool stakingExcluded;
    }

    mapping(address => ExclusionStatus) public exclusionStatus;

    uint public txTax = 5;
    uint public constant BASE_PERCENTAGE = 100;
    address public stakingAddress;

    event ExclusionStatusChanged(
        address indexed account,
        bool taxExcluded,
        bool stakingExcluded
    );
    event StakingAddressChanged(
        address indexed newAddress,
        address indexed prevAddress
    );

    constructor(address _stakingAddress) ERC20("RecapToken", "RCT") {
        _mint(msg.sender, 20_000_000 ether);
        require(_stakingAddress != address(0), "Zero address");
        stakingAddress = _stakingAddress;
    }

    function _transfer(
        address _from,
        address _to,
        uint amount
    ) internal override {
        if (exclusionStatus[_from].taxExcluded) {
            super._transfer(_from, _to, amount);
            return;
        }

        uint taxAmount = (amount * txTax) / BASE_PERCENTAGE;
        amount -= taxAmount;
        if (exclusionStatus[_to].stakingExcluded) {
            super._transfer(_from, stakingAddress, taxAmount);
        } else _burn(_from, taxAmount);

        super._transfer(_from, _to, amount);
    }

    function burn(uint amount) external {
        _burn(msg.sender, amount);
    }

    function burnFrom(address account, uint amount) external {
        uint currentAllowance = allowance(account, msg.sender);
        require(
            currentAllowance >= amount,
            "ERC20: burn amount exceeds allowance"
        );
        _approve(account, msg.sender, currentAllowance - amount);
        _burn(account, amount);
    }

    function setExcludedFromTax(
        address account,
        bool status
    ) external onlyOwner {
        ExclusionStatus storage currentStatus = exclusionStatus[account];
        require(
            !currentStatus.stakingExcluded,
            "Already excluded from staking"
        );
        exclusionStatus[account].taxExcluded = status;
        emit ExclusionStatusChanged(
            account,
            currentStatus.taxExcluded,
            currentStatus.stakingExcluded
        );
    }

    function setExcludedFromStaking(
        address account,
        bool status
    ) external onlyOwner {
        ExclusionStatus storage currentStatus = exclusionStatus[account];
        require(!currentStatus.taxExcluded, "Already excluded from tax");
        exclusionStatus[account].stakingExcluded = status;
        emit ExclusionStatusChanged(
            account,
            currentStatus.taxExcluded,
            currentStatus.stakingExcluded
        );
    }

    function setStakingAddress(address _stakingAddress) external onlyOwner {
        require(_stakingAddress != address(0), "Zero address");
        emit StakingAddressChanged(_stakingAddress, stakingAddress);
        stakingAddress = _stakingAddress;
    }
}

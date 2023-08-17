// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {ERC20} from "openzeppelin/token/ERC20/ERC20.sol";

error CLM__AlreadyClaimed();

contract ClaimableToken is ERC20 {
    mapping(address => bool) public claimable;

    event ClaimTokens(address indexed account);

    constructor() ERC20("ClaimableToken", "CLM") {}

    function claim() external {
        if (claimable[msg.sender]) revert CLM__AlreadyClaimed();
        claimable[msg.sender] = true;
        _mint(msg.sender, 1_000 ether);
        emit ClaimTokens(msg.sender);
    }

    function burn(uint amount) external {
        _burn(msg.sender, amount);
    }
}

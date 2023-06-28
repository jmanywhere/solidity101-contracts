// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import "openzeppelin/token/ERC20/ERC20.sol";

contract MyFirstToken is ERC20 {
    constructor() ERC20("TeacherToken", "TTK") {
        _mint(msg.sender, 100 ether);

        transfer(0xC7a763255ec8fF6115996DBD0C81757B1b0B3B40, 10 ether);
    }
}

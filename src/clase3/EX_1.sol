// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import "openzeppelin/token/ERC20/ERC20.sol";
import "openzeppelin/token/ERC20/extensions/ERC20Burnable.sol";
import "openzeppelin/access/Ownable.sol";

error AM__ExceedMaxSupply(uint256 maxSupply);

contract AutoMinterToken is ERC20, ERC20Burnable, Ownable {
    uint public constant MAX_SUPPLY = 10_000 ether;
    uint private tokensPerETH = 10_000;

    modifier validAmount(uint amount) {
        require(amount > 0, "Invalid amount");
        _;
    }

    constructor() ERC20("AutoMinterToken", "AMT") {}

    receive() external payable validAmount(msg.value) {
        _mintTokens(msg.value, msg.sender);
    }

    function mint(uint256 amount) external payable validAmount(amount) {
        require(amount != msg.value, "Invalid amount");
        _mintTokens(amount, msg.sender);
    }

    function retrieveTokens() external onlyOwner {
        uint balance = address(this).balance;
        require(balance > 0, "No funds to retrieve");
        (bool succ, ) = payable(owner()).call{value: balance}("");
        require(succ, "Transfer failed");
    }

    function _mintTokens(uint256 amount, address _user) internal {
        uint tokensToMint = amount * tokensPerETH;
        if (tokensToMint + totalSupply() > MAX_SUPPLY) {
            revert AM__ExceedMaxSupply(MAX_SUPPLY - totalSupply());
        }
        _mint(_user, tokensToMint);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

contract PrimerContrato {
    uint256 public favorite;
    string public name;

    function setData(string memory _newName, uint256 _favoriteNumber) external {
        name = _newName;
        favorite = _favoriteNumber;
    }
}

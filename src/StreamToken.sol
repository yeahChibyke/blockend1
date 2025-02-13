// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

// The logic of this contract is not final
contract StreamToken is ERC20, Ownable {
    uint256 claimSupply = 1_000_000e18;

    constructor() ERC20("Stream Token", "STRK") Ownable(msg.sender) {
        _mint(msg.sender, claimSupply);
    }
}

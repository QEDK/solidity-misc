//SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC20Swap is Ownable {
	IERC20 public token;
	uint256 public amount;
	uint256 public dripAmt;

	error TransferFailed();

	constructor(IERC20 newToken, uint256 newAmount, uint256 newDripAmt) {
		token = newToken;
		amount = newAmount;
		dripAmt = newDripAmt;
		newToken.transferFrom(msg.sender, address(this), amount);
	}

	function withdraw(IERC20 newToken, uint256 newAmount) external onlyOwner {
		if(!newToken.transfer(msg.sender, newAmount)) {
			revert TransferFailed();
		}
	}

	function drip(IERC20 userToken, uint256 userAmount) external {
		require(userAmount >= dripAmt, "NOT_ENOUGH_TOKENS");
		if(!userToken.transferFrom(msg.sender, owner(), userAmount)) {
			revert TransferFailed();
		}
		if(!token.transfer(msg.sender, dripAmt)) {
			revert TransferFailed();
		}
	}
}

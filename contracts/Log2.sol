// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

/**
 * @title Log2
 * @author QEDK (https://github.com/QEDK/solidity-misc/blob/master/contracts/Log2.sol)
 * @notice Gas optimized calculation of the log2 function
 */
library Log2 {
    function log2floor(uint256 num) external pure returns (uint256 res) {
        assembly("memory-safe") {
            // this is a hard concept to visualize but let's try:
            // we shift num to the right by 128 bits, so essentially dividing by 2^128
            // this gives us a number between [0 - 2^128 - 1), if number is 0, then we found the log2
            if gt(shr(128, num), 0) {
                num := shr(128, num)
                res := add(res, 128)
            }
            if gt(shr(64, num), 0) {
                num := shr(64, num)
                res := add(res, 64)
            }
            if gt(shr(32, num), 0) {
                num := shr(32, num)
                res := add(res, 32)
            }
            if gt(shr(16, num), 0) {
                num := shr(16, num)
                res := add(res, 16)
            }
            if gt(shr(8, num), 0) {
                num := shr(8, num)
                res := add(res, 8)
            }
            if gt(shr(4, num), 0) {
                num := shr(4, num)
                res := add(res, 4)
            }
            if gt(shr(2, num), 0) {
                num := shr(2, num)
                res := add(res, 2)
            }
            if gt(shr(1, num), 0) {
                res := add(res, 1)
            }
        }
    }

    function log2ceil(uint256 num) external pure returns (uint256 res) {
        assembly("memory-safe") {
            let input := num
            if gt(shr(128, num), 0) {
                num := shr(128, num)
                res := add(res, 128)
            }
            if gt(shr(64, num), 0) {
                num := shr(64, num)
                res := add(res, 64)
            }
            if gt(shr(32, num), 0) {
                num := shr(32, num)
                res := add(res, 32)
            }
            if gt(shr(16, num), 0) {
                num := shr(16, num)
                res := add(res, 16)
            }
            if gt(shr(8, num), 0) {
                num := shr(8, num)
                res := add(res, 8)
            }
            if gt(shr(4, num), 0) {
                num := shr(4, num)
                res := add(res, 4)
            }
            if gt(shr(2, num), 0) {
                num := shr(2, num)
                res := add(res, 2)
            }
            if gt(shr(1, num), 0) {
                res := add(res, 1)
            }
            if lt(shl(res, 1), input) {
                res := add(res, 1)
            }
        }
    }
}

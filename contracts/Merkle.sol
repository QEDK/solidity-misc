// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.20;

/**
 * @title Merkle
 * @author QEDK (https://github.com/QEDK/solidity-misc/blob/master/contracts/Merkle.sol)
 * @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/MerkleProofLib.sol)
 * @notice Gas optimized verification of proof of inclusion for a leaf in an ordered Merkle tree
 */
library Merkle {
    /**
     * @notice checks membership of a leaf in a merkle tree
     * @param leaf keccak256 hash to check the membership of
     * @param index position of the hash in the tree
     * @param rootHash root hash of the merkle tree
     * @param proof an array of hashes needed to prove the membership of the leaf
     * @return isMember boolean value indicating if the leaf is in the tree or not
     */
    function checkMembership(
        bytes32 leaf,
        uint256 index,
        bytes32 rootHash,
        bytes32[] calldata proof
    ) internal pure returns (bool isMember) {
        // solhint-disable-next-line no-inline-assembly
        assembly ("memory-safe") {
            // if proof is empty, check if the leaf is the root
            if proof.length {
                // set end to be the end of the proof array, shl(5, proof.length) is equivalent to proof.length * 32
                let end := add(proof.offset, shl(5, proof.length))
                // set iterator to the start of the proof array
                let i := proof.offset
                // prettier-ignore
                // solhint-disable-next-line no-empty-blocks
                for {} 1 {} {
                    // if index is odd, leaf slot is at 0x20, else 0x0
                    let leafSlot := shl(5, and(0x1, index))
                    mstore(leafSlot, leaf)
                    // store proof element in whichever slot is not occupied by the leaf
                    mstore(xor(leafSlot, 32), calldataload(i))
                    leaf := keccak256(0, 64)
                    index := shr(1, index)
                    i := add(i, 32)
                    if iszero(lt(i, end)) {
                        break
                    }
                }
            }
            isMember := eq(leaf, rootHash)
        }
    }

    /**
     * @notice checks membership of a leaf in a merkle tree
     * @param leaf keccak256 hash to check the membership of
     * @param index position of the hash in the tree
     * @param rootHash root hash of the merkle tree
     * @param proof an array of hashes needed to prove the membership of the leaf (in memory)
     * @return isMember boolean value indicating if the leaf is in the tree or not
     */
    function checkMembershipMemory(
        bytes32 leaf,
        uint256 index,
        bytes32 rootHash,
        bytes32[] memory proof
    ) internal pure returns (bool isMember) {
        // solhint-disable-next-line no-inline-assembly
        assembly ("memory-safe") {
            // if proof is empty, check if the leaf is the root
            if mload(proof) {
                // set iterator to the start of the proof array
                let i := add(proof, 0x20)
                // set end to be the end of the proof array, shl(5...) is equivalent to proof.length * 32
                let end := add(i, shl(5, mload(proof)))
                // prettier-ignore
                // solhint-disable-next-line no-empty-blocks
                for {} 1 {} {
                    // if index is odd, leaf slot is at 0x20, else 0x0
                    let leafSlot := shl(5, and(0x1, index))
                    mstore(leafSlot, leaf)
                    // store proof element in whichever slot is not occupied by the leaf
                    mstore(xor(leafSlot, 32), mload(i))
                    leaf := keccak256(0, 64)
                    index := shr(1, index)
                    i := add(i, 32)
                    if iszero(lt(i, end)) {
                        break
                    }
                }
            }
            isMember := eq(leaf, rootHash)
        }
    }
}

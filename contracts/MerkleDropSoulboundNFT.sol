//SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Merkle Drop Souldbound NFT
/// @author QEDK (https://github.com/QEDK)
/// @notice This contract takes an existing merkle root and allows them to claim from the tranche of NFTs.
/// @custom:experimental This is an experimental contract.
contract MerkleDropSoulboundNFT is ERC721URIStorage, Ownable {
    uint256 public trancheId;
    uint256 public tokenId;
    mapping(uint256 => bytes32) public trancheMerkles;
    mapping(uint256 => string) public trancheUris;
    mapping(uint256 => mapping(address => bool)) public trancheClaims;

    // solhint-disable-next-line
    constructor() ERC721("MerkleSoulboundNFT", "MSN") {
    }

    function addTranche(bytes32 _merkleRoot, string calldata _uri) external onlyOwner {
        trancheUris[trancheId] = _uri;
        trancheMerkles[trancheId] = _merkleRoot;
        trancheId++;
    }

    function modifyTranche(bytes32 _newMerkleRoot, string calldata _newUri, uint256 _id) external onlyOwner {
        trancheUris[_id] = _newUri;
        trancheMerkles[_id] = _newMerkleRoot;
    }

    function deleteTranche(uint256 _id) external onlyOwner {
        delete trancheMerkles[_id];
        delete trancheUris[_id];
    }

    function expireTranche(uint256 _id) external onlyOwner {
        delete trancheMerkles[_id];
    }

    function claimFromTranche(uint256 _id, bytes32[] calldata merkleProof) external {
        require(trancheClaims[_id][msg.sender] == false, "ALREADY_CLAIMED");
        trancheClaims[_id][msg.sender] = true;
        require(MerkleProof.verify(merkleProof, trancheMerkles[_id], keccak256(abi.encodePacked(msg.sender))), "INVALID_MERKLE_PROOF");
        _mint(msg.sender, tokenId); // _mint instead of _safeMint so contract wallets are able to receive
        _setTokenURI(tokenId, trancheUris[_id]);
        tokenId++;
    }

    function _transfer(
        address /* from */,
        address /* to */,
        uint256 /* tokenId */
    ) internal pure override {
        revert("SOULBOUND_TRANSFER_DISALLOWED");
    }
}

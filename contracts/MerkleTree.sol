//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract MerkleTree {
    bytes32[] public hashes;
    string[4] transactions = [
        "Tx1: Sherlock -> John", // 0x90468595c91ed4200be8b123bbbe77b1fb5b30eadae281a4f5080d2bc1991b3b
        "Tx2: John -> Sherlock", // 0x0e43ce31529c0636853f9279d28101a2e1827641a7fb0dc10d4f0a35cfe9328c
        "Tx3: John -> Mary",     // 0xbd38068ba9ae7b93f04d731eea79bde24ed281775355581ad179afee4e310e49
        "Tx4: Mary -> Sherlock"  // 0x9f952de64c66104d2e1f24801cfd115637e74247011e0a48b3990b70122e7a05
    ];

    constructor() {
        for (uint i = 0; i < transactions.length; i++) {
            hashes.push(keccak256(abi.encodePacked(transactions[i])));
        }

        uint count = transactions.length;
        uint offset = 0;

        while (count > 0) {
            for (uint i = 0; i < count - 1; i += 2) {
                hashes.push(
                    keccak256(
                        abi.encodePacked(
                        hashes[offset + i], hashes[offset + i + 1]
                        )
                    )
                );
            }
            offset += count;
            count /= 2;
        }
    }

    function verify(
        string memory transactoin, 
        uint index, 
        bytes32 root, 
        bytes32[] memory proof
        )
        public pure returns(bool)
    {
        bytes32 hash = keccak256(abi.encodePacked(transactoin));
        for (uint i = 0; i < proof.length; i++) {
            bytes32 element = proof[i];
            if (index % 2 == 0) {
                hash = keccak256(abi.encodePacked(hash, element));
            } else {
                hash = keccak256(abi.encodePacked(element, hash));
            }
            index /= 2;
        }
        return hash == root;
    }

    function verify2(string memory transaction, uint index)
        public view returns(bool)
    {
        bytes32 root = hashes[hashes.length - 1];
        uint levelLength = transactions.length;
        uint totalOffset = 0;
        uint indexInLevel = index;

        bytes32 hash = keccak256(abi.encodePacked(transaction));
        while (index != (hashes.length - 1)) {
            if (index % 2 == 0) {
                hash = keccak256(abi.encodePacked(hash, hashes[index + 1]));
            } else {
                hash = keccak256(abi.encodePacked(hashes[index - 1], hash));
            }
            totalOffset += levelLength;
            indexInLevel /= 2;
            index = totalOffset + indexInLevel;
            levelLength /= 2;
        }
        return hash == root;
    }
}

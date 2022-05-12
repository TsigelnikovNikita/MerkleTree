//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract MerkleTree {
    bytes32[] public hashes;
    string[4] transactions = [
        "Tx1: Sherlock -> John",
        "Tx1: John -> Sherlock",
        "Tx1: John -> Mary",
        "Tx1: Mary -> Sherlock"
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
                        transactions[offset + i], transactions[offset + i + 1]
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

    function findHashIndex(bytes32 hash) public view returns(uint) {
        for (uint i = 0; i < transactions.length; i++) {
            if (hashes[i] == hash) {
                return i;
            }
        }
        revert();
    }

    function verify2(string memory transaction)
        public view returns(bool)
    {
        bytes32 root = hashes[hashes.length - 1];
        uint levelLength = transactions.length;
        uint totalOffset = levelLength;

        bytes32 hash = keccak256(abi.encodePacked(transaction));
        uint index = findHashIndex(hash);
        uint indexInLevel = index;
        while (index != hashes.length) {
            if (index % 2 == 0) {
                hash = keccak256(abi.encodePacked(hash, hashes[index + 1]));
            } else {
                hash = keccak256(abi.encodePacked(hashes[index - 1], hash));
            }
            indexInLevel /= 2;
            index = totalOffset + indexInLevel;
            levelLength /= 2;
            totalOffset += levelLength;
        }
        return hash == root;
    }
}

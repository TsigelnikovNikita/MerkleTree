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
        return hash == proof;
    }
}

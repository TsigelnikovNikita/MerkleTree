//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract MerkleTree {
    bytes32[] public hashes;
    uint public immutable transactionsCount;

    constructor(string[] memory _transactions) {
        for (uint i = 0; i < _transactions.length; i++) {
            hashes.push(keccak256(abi.encodePacked(_transactions[i])));
        }

        transactionsCount = _transactions.length;
        uint count = _transactions.length;
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
        uint levelLength = transactionsCount;
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

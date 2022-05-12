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
            hashes.push(makeHash(transactions[i]));
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

    function encode(string memory input) public pure returns(bytes memory) {
        return abi.encodePacked(input);
    }

    function makeHash(string memory input) public pure returns (bytes32) {
        return keccak256(encode(input));
    }

}

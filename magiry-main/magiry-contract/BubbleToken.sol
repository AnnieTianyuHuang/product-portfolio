// SPDX-License-Identifier: MIT
// Author: Blink Chen
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract ForgeERC20 is ERC20 {
    using Counters for Counters.Counter;

    mapping(address => bool) private _owners;
    Counters.Counter private _transactionIdCounter;
    uint8 private _numConfirmationsRequired;

    struct Transaction {
        address to;
        uint256 amount;
        uint8 confirmations;
        bool executed;
        bool denied;
    }

    mapping(uint256 => Transaction) private _transactions;

    constructor(address[] memory owners_, uint256 initialSupply, uint8 numConfirmationsRequired_) ERC20("BubbleToken", "BBLE") {
        for (uint i = 0; i < owners_.length; i++) {
            _owners[owners_[i]] = true;
        }
        _numConfirmationsRequired = numConfirmationsRequired_;
        _mint(msg.sender, initialSupply);
    }

    modifier onlyOwners() {
        require(_owners[msg.sender], "Not an owner");
        _;
    }

    function multisig_mint(address to, uint256 amount) public onlyOwners returns (uint256) {
        uint256 txID = addTransaction(to, amount);
        confirmTransaction(txID);
        return txID;
    }

    function addTransaction(address to, uint256 amount) internal returns (uint256) {
        _transactionIdCounter.increment();
        uint256 newTxID = _transactionIdCounter.current();
        _transactions[newTxID] = Transaction({
            to: to,
            amount: amount,
            confirmations: 0,
            executed: false,
            denied: false
        });

        return newTxID;
    }

    function confirmTransaction(uint256 txID) public onlyOwners {
        require(_transactions[txID].to != address(0), "Transaction doesn't exist");
        require(!_transactions[txID].executed, "Transaction already executed");
        require(!_transactions[txID].denied, "Transaction has been denied");

        _transactions[txID].confirmations += 1;

        if (_transactions[txID].confirmations == _numConfirmationsRequired) {
            _mint(_transactions[txID].to, _transactions[txID].amount);
            _transactions[txID].executed = true;
        }
    }

    function denyTransaction(uint256 txID) public onlyOwners {
        require(_transactions[txID].to != address(0), "Transaction doesn't exist");
        require(!_transactions[txID].executed, "Transaction already executed");

        _transactions[txID].denied = true;
    }

    function isOwner(address account) public view returns (bool) {
        return _owners[account];
    }

    function getNumConfirmationsRequired() public view returns (uint8) {
        return _numConfirmationsRequired;
    }
}


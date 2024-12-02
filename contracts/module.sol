// SPDX-License-Identifier: GPL-3.0

import "@openzeppelin/contracts/access/Ownable.sol";

pragma solidity >=0.8.2 <0.9.0;

/// @dev The `Enum` library defines an enumeration to specify the type of operation for a transaction.
library Enum {
    enum Operation {
        Call,         // Represents a standard contract call (transfer or function execution).
        DelegateCall  // Represents a delegate call (used to execute code in the context of another contract).
    }
}

/// @dev Interface for interacting with the Safe contract. It includes only the function needed for the module.
interface ISafe {
    /**
     * @dev Executes a transaction from a module (like this contract). 
     * This function enables the module to send Ether or execute functions on behalf of the Safe.
     * 
     * @param to The address to which the transaction is directed.
     * @param value The amount of Ether (in wei) to be sent.
     * @param data The calldata for the transaction (could be empty if only sending Ether).
     * @param operation Defines whether the transaction is a Call or DelegateCall.
     * 
     * @return success Indicates if the transaction was successful or not.
     */
    function execTransactionFromModule(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation
    ) external returns (bool success);
}

/// @dev This contract represents a module that can be added to a Safe wallet. 
/// It allows the owner to send Ether from the Safe to another address.
contract TestModule is Ownable {
    
    // Constructor to initialize the module. 
    // The `Ownable` contract's constructor is called, setting the sender as the owner.
    constructor() Ownable(msg.sender) {}

    /**
     * @dev Transfers Ether from the Safe to a specified address.
     * This function can only be called by the owner of the module (as inherited from the Ownable contract).
     *
     * @param from The address of the Safe. This module must be enabled on the Safe for this function to work.
     * @param to The address that will receive the Ether.
     * @param amount The amount of Ether (in wei) to be sent.
     */
    function transferEth(
        address from,
        address to,
        uint256 amount
    ) public onlyOwner {
        // Calls the Safe's execTransactionFromModule function to execute the transaction.
        // It transfers `amount` of Ether from the Safe (`from`) to the recipient (`to`).
        ISafe(from).execTransactionFromModule(
            to,                // Recipient address.
            amount,            // Amount of Ether to send.
            hex"00",           // Empty calldata (no function call, just a plain Ether transfer).
            Enum.Operation.Call // Indicates this is a regular call (not a delegate call).
        );
    }
}
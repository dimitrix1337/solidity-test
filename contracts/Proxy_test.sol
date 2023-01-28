// SPDX-License-Identifier: NONE
// DON'T USE IT!!!

pragma solidity ^0.8.0;

/*
    @title Testing proxy
    @author octaviusp
    @notice Don't use it in real world, this is only for development purposes.
    @dev Upgrading contract and upgrading storage.
    @ABSTRACT IT WORKS PERFECTLY, BUT IS ONLY A PERSONAL TEST.
*/

contract Storage {
    /*
    @notice Creating three variables only for storage contract.
    @dev 
    - MEMORY SLOT -
    ---------------
    0x00 - 0 - TYPE: UINT - VALUE: 0 - POINTER NAME: AGE
    0x10 - 1 - TYPE: UINT - VALUE: 0 - POINTER NAME: MONEY
    0x20 - 2 - TYPE: UINT - VALUE: 0 - POINTER NAME: NAME
    */
    uint public age;
    uint money;
    string name;
}

contract Storage_extended is Storage {
    /*
    @notice Inheriting from Storage contract
    @dev 
    - MEMORY SLOT -
    ---------------
    0x00 - 0 - TYPE: UINT - VALUE: 0 - POINTER NAME: AGE
    0x10 - 1 - TYPE: UINT - VALUE: 0 - POINTER NAME: MONEY
    0x20 - 2 - TYPE: UINT - VALUE: 0 - POINTER NAME: NAME
    0x30 - 3 - TYPE: STRING - VALUE: "" - POINTER NAME: LAST_NAME
    0x40 - 4 - TYPE: STRING - VALUE: "" - POINTER NAME: DNI
    */
    string last_name;
    string dni;
}



contract Proxy is Storage_extended {
    /*
    @title PROXY CONTRACT IT CALLS THE LOGIC CONTRACT.
    @notice Inheriting from Storage_extended contract
    @dev 
    - MEMORY SLOT -
    ---------------
    0x00 - 0 - TYPE: UINT - VALUE: 0 - POINTER NAME: AGE
    0x10 - 1 - TYPE: UINT - VALUE: 0 - POINTER NAME: MONEY
    0x20 - 2 - TYPE: UINT - VALUE: 0 - POINTER NAME: NAME
    0x30 - 3 - TYPE: STRING - VALUE: "" - POINTER NAME: LAST_NAME
    0x40 - 4 - TYPE: STRING - VALUE: "" - POINTER NAME: DNI
    0x50 - 5 - TYPE: ADDRESS - VALUE: ADDRESS(0) - POINTER NAME: _IMPL
    */

    /*
    @dev it is the address of the contract which contains all logic, once it is called, it
    returns all data to proxy contract storage.
    */
    address _impl;


    /*
    @dev Setting first contract implementation v1
    */
    constructor (address implementation) {
        _impl = implementation;
    }

    /*
    @dev Function to change implementation, to upgrade contract
    @notice IT'S FREE TO MODIFY, IT MEANS WHATEVER ADDRESS CAN MODIFY IT, DON'T USE IT!
    @notice ONLY FOR TEST PURPOSES
    */
    function change_implementation(address new_impl) public {
        _impl = new_impl;
    }

    /*
    The caller of the proxy will send a function signature call which in proxy contrat doesn't exists
    so, the EVM will search every function signature of the PROXY contract and determines it doesn't
    have any function signature equal to the call function signature, so it falls in the fallback function
    then the fallback functions load logic and send it to implementation contract which it needs to
    have the function and execute, once is executed, the implementation returns data, this data is
    stored in PROXY contract
    ****************
    IMPORTANT: MAKE SURE THE IMPL CONTRACT INHERIT THE STORAGE_EXTENDED STORAGE, FOR DON'T MAKE
    STORAGE COLLISIONS
    ****************
    */
    fallback () external payable {
        assembly {
            // (0) creating a variable call ptr(pointer) which points to the memory location 0x40
            let ptr := mload(0x40)

            /* (1) copy incoming call data 
            from 0 index, to calldatasize, it means, all calldata.
            if we change the 0 to another > 0 number, is like grabbing from another index
            *****************
            EXAMPLE:
            name: tony
            calldata from 0 to max = tony
            calldata from 1 to max = ony
            *****************
            */
            calldatacopy(ptr, 0, calldatasize())

            /* (2) forward call to logic contract 
            creating new variable called result, it is the return value of the delegatecall, its a boolean
            then, we delegatecall to the implement contract, with the gas sent via transaction
            with ptr data in bytes, to max lenght of calldatasize,
            idk which means the last zero's.

            the variable size store the data max length returned via delegatecall.

            ***********
            IMPORTANT: 
            SLOAD(X) CHARGE THE PARAMETER WITH THE STORAGE MEMORY ALLOCATION X
            (ONLY IN THIS CASE THE SLOAD(5) BELONG TO _IMPL ADDRESS CONTRACT, TAKE CARE OF THIS)
            ***********
            ***********
            DISCLAIMER:
            i need to set () parentheses to all evm functions like gas(), calldatasize(), etc...
            ***********
            */
            let result := delegatecall(gas(), sload(5), ptr, calldatasize(), 0, 0)
            let size := returndatasize()

            /* (3) retrieve return data 
            then, we return the data of the delegatecall returned to the ptr variabble and set it
            from index 0 to the max length which is saved in size variable.
            */
            returndatacopy(ptr, 0, size)

            /* (4) forward return data back to caller
            once all is ready, we create a switch to determinate how the call is going
            
            CASES -

            if the case of result is 0 it means FALSE, then revert operation

            if the case if default it means 1 Of course, the call was finished succesfully,
            then return all data to be stored here, in the contract proxy.
            */
            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }

}

contract ImplementationV1 is Storage_extended {
    /*
    IMPLEMENTATION V1 
    */
    // THIS ADDRESS MEMORY DOESN'T CONTAIN ANYTHING ONLY FOR AVOID STORAGE COLLISIONS
    address AddingAddressMemorySlotToAvoidCollisionWithProxyStorage;

    function modify_slot_0(uint number) public {
        age = number;
    }
}

contract ImplementationV2 is ImplementationV1 {
    /*
    IMPLEMENTATION V2 
    */
    // WE DON'T NEED TO SET ADDRESS MEMORY NEW TO AVOID STORAGE BECAUSE WE INHERIT IT FROM
    // IMPLEMENTATIONV1, THIS IS A STORAGE PATTERN, INHERIT ALL BEFORE VARIABLES FROM LAST IMPLEMENTATION.
    function modify_slot_0_with_multiply(uint number) public {
        age = number*5;
    }
}

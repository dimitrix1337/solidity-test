// SPDX-License-Identifier: UNLICENSED

pragma solidity = 0.8.7;

contract shipInternally {

    uint arrivehour;
    uint price;
    uint totalseats;
    uint reservedseats;
    bool buy;
    mapping(address => uint) clientSeats;
    address owner;
    address payable[] clients;

    // OF COURSE IN A PRODUCTION I WILL USE OPENZEPPELIN OWNABLE..
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor () {
        owner = msg.sender;
    }

    function ticketSell(uint arrivehour_minutes, uint _price, uint _totalseats) public onlyOwner {
        arrivehour = block.timestamp + arrivehour_minutes;
        price = _price;
        totalseats = _totalseats;
        reservedseats = 0;
        buy = true;
    }

    function closebuy() public onlyOwner {
        buy = false;
    }

    function buySeats(uint quantity) public payable {
        require(price * quantity == msg.value, "Please set correct funds");
        require(totalseats >= reservedseats + quantity);
        reservedseats += quantity;
        clients.push(payable(msg.sender));
        clientSeats[msg.sender] = quantity;
    }

    /*
            WITHDRAW PATTERN AND OPTIMIZING SOME FEATURES

            @DEV ABSTRACT:
            without optimization = TX.COST = 42981
            with optimization and preventing lock funds = TX.COST = 35125
            (conclusion: don't avoid use for loops

            optimized function without reentrant module
            35125-35147
            with it 
            36944
            (conclusion: set own reentrancy guard)
    */

    // InSECURE AND NO GAS OPTIMIZATION
    function paySecure() public {
        require(!buy && block.timestamp > arrivehour);
        uint i = 0;
        // THE LOOP IS TOO EXPENSIVE AND COULD LOCK FUNDS IF THERE ARE SO MUCH CLIENTS
        for (i; i < clients.length; i++) {
            uint reservedSeatsPerClient = clientSeats[clients[i]];
            uint toPay = price * reservedSeatsPerClient;
            clientSeats[clients[i]] = 0;
            clients[i].transfer(toPay);
        }
    }
    // SECURE AND GAS OPTIMIZATION
    function WithDrawClientSecure() public {
        // IN THIS METHOD, THE OWN CLIENT COULD WITHDRAW HIS FUNDS
        // AND IT CANNOT BE LOCKED FOREVER BECAUSE IT IS CHEAPER TRANSACTION THAN BEFORE
        // AND IT CONTAINS REENTRANCY SECURE

        // FIRST WE CHECK IF BUY IS OPEN OR NOT, PROBABLY IT WILL BE MORE CERTAINLY THAN ARRIVEHOUR
        // AND FAST WE CAN REVERT AND APPLI EARLY REVERT PATTERN
        require(!buy && block.timestamp > arrivehour);
        // PREVENTING REENTRANCY
        uint reservedSeatsPerClient = clientSeats[msg.sender];
        clientSeats[msg.sender] = 0;
        payable(msg.sender).transfer(price * reservedSeatsPerClient);
    }

}


//SPDX-License-Identifier:UNLICENSED
pragma solidity ^ 0.8.7;

contract VanityNameRegistering {

    // the listing price of buy a name
    uint fee;
    // the time cost of each 
    uint time_expand_ratio;
    constructor (uint TaxRate, uint TimeExpandRatio) {
        fee = TaxRate; // taxrate in wei
        time_expand_ratio = TimeExpandRatio; // suggest: in seconds
    }

    // struct name for each registered name
    struct Name {
        // to see owner
        address owner;
        // the time where name bought
        uint bought;
        // time to expiration , it depends on uint time algorithm which is based in msg.value amount, higher amount, higher time ownership.
        uint expiration;
        // amount was locked for the user, once the expiration is ready , the user can unlock his founds.
        uint amount_locked;
    }
    
    event NewNamedRegistered(string name, uint time); // events to emit
    event NameExpired(string name);

    // a mapping to set every name to his Name Struct
    mapping(string => Name) VanityNames;

    // register a name that wasn't already registered.
    function RegisterName(string memory name) public payable {
        // if the name.bought == 0 it means that nobody bought this
        // a logical conjunction, if owner is equal to default initial address value it means the name is available
        // or the name.owner should be different to msg.sender
        require((VanityNames[name].bought == 0 && VanityNames[name].owner == address(0)) || VanityNames[name].owner != msg.sender, "Error: name already in use.");
        // listingFee according to the size of name, well this is a simple algorithm
        // for every character in the name it is multiply by a tax rate 
        // of course this tax rate is customizable.
        uint listingFee = calculateCostOfName(bytes(name));
        // the time of the name is in ownership according the money amount that the sender sent.
        // again, a simple algorithm => for every 1 wei sent the ownership of the name extends X second (customizable)
        uint time = calculateTimeOwnership(msg.value);
        // well, the msg.value needs to be greater than listingFee , the rest of wei sent would go to the time of ownership.
        require(msg.value > listingFee, "Error: insufficient founds.");
        // set the data
        VanityNames[name].owner = msg.sender;
        VanityNames[name].bought = block.timestamp;
        VanityNames[name].expiration = time;
        // msg.value - listingFee because the listingFee isn't added to the amount locked by the user.
        VanityNames[name].amount_locked = msg.value - listingFee;

        emit NewNamedRegistered(name, block.timestamp);
    }

    // function to see if the name is expired or not, it returns a bool to frontend interaction.
    function isExpired(string memory name) public returns(bool expired) {
        // setting a pointer storage to the mapping name
        Name storage nameRegistered = VanityNames[name];
        // if the time what was name bought + now is greater or equal to the expiration it means the name ownerships is down.
        if ((nameRegistered.bought + block.timestamp) >= nameRegistered.expiration) {
            // prevent reentrancy attacks set the amount to a uint variable recently created and after set amount to 0
            uint amount = nameRegistered.amount_locked;
            nameRegistered.amount_locked = 0;
            // unlocking founds for the owner of the name
            payable(nameRegistered.owner).transfer(amount);
            // set all data to default values, because the previous owner was deleted.
            nameRegistered.owner = address(0);
            nameRegistered.bought = 0;
            nameRegistered.expiration = 0;
            // returning true, is expired.
            emit NameExpired(name);
            return true;    
        } else { return false; } // returning false, isn't expired yet

    }
    
    // a simple function which returns a Name struct in memory to get name info (owner, etc...)
    function getNameInfo(string memory name) public view returns (Name memory) {

        Name memory gettingNameInfo = Name(VanityNames[name].owner, VanityNames[name].bought, VanityNames[name].expiration, VanityNames[name].amount_locked);
        return gettingNameInfo;
    }  

    // a simple algorithm to determinate the cost of the name based in it's length
    function calculateCostOfName(bytes memory name) private view returns (uint) {
        return (fee * name.length);
    }

    // a simple algorithm to determinate the time of ownership
    function calculateTimeOwnership(uint msg_value) private view returns(uint) {
        return msg_value * time_expand_ratio;
    }

    // ---------- OPTIONAL FEATURES -> EXTEND THE TIME OF OWNERSHIP
    function ExtendTime(string memory name) public payable OnlyOwner(name) {
        VanityNames[name].expiration += calculateTimeOwnership(msg.value);
        VanityNames[name].amount_locked += msg.value;
    }

    modifier OnlyOwner(string memory name) {
        require(VanityNames[name].owner == msg.sender, "Error: you aren't the name owner.");
        _;
    }

}
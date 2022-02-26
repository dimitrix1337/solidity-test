const test = artifacts.require('VanityNameRegistering')

contract("Testing the fiver test", (accounts) => {

        it("\n It should register a name for first time", async () => {
            // a poiinter to the contract deployed in the blockchain
            const contrac = await test.deployed()
            //  awaiting the function execution giving their truffle parametes, from which account and how many value in the msg.value
            await contrac.RegisterName("octavio", {from: accounts[0], value:99999});
    
    
        })
        console.log("------------------------------------------------------------------")
        
        console.log("------------------------------------------------------------------")

        it("\n It should get info of already registered name", async () => {
            // a poiinter to the contract deployed in the blockchain
            const contrac = await test.deployed()
            // getting info of registered name
            const getInfo = async () =>  { return await contrac.getNameInfo("octavio") }
            getInfo().then(response => 
                {
                    if (response.length > 0) {
                        console.log(response)
                    } else {
                        revert("No registered name")
                    }
                }
                )
        })
        console.log("------------------------------------------------------------------")

        it("\n It should trigger an error because the name is already registered.", async () => {
            // a poiinter to the contract deployed in the blockchain
            const contrac = await test.deployed()
            
            // creating a name already registered, of course it throws and error if the smart contract was fine developed.
            await contrac.RegisterName("octavio", {from: accounts[0], value:1});
        })
    

})
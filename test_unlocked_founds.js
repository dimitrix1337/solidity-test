const test = artifacts.require('VanityNameRegistering')

contract("Test number 2", (accounts) => {
    it("It should unlocked the founds", async () => {
        // a poiinter to the contract deployed in the blockchain
        const contrac = await test.deployed()
        // variable with beforemoney to test if after registering name it is less than it.
        const beforeMoney = await web3.eth.getBalance(accounts[2])
        console.log("BEFORE MONEY: ", web3.utils.fromWei(beforeMoney, "ether"))
        // registering name with account[2], i can access accounts array because i give it in parameters to the contract initial functions
        // it was injected by truffle.
        await contrac.RegisterName("asd", {from: accounts[2], value:web3.utils.toWei("90", "ether"), gas:300000})
    
        const afterRegisternameMoney = await web3.eth.getBalance(accounts[2])
        console.log("AFTER REGISTER NAME MONEY: ", web3.utils.fromWei(afterRegisternameMoney, "ether"))
    
        // verifying if the name is expired
        await contrac.isExpired("asd")

        // if is expired the afterExpiredMoney must be more than afterRegisternameMoney, because the user unlocked his money.
        const afterExpiredMoney = await web3.eth.getBalance(accounts[2])
    
        console.log("AFTER RETURNING MONEY: ", web3.utils.fromWei(afterExpiredMoney, "ether"))
        let it_should = afterRegisternameMoney < afterExpiredMoney
        assert(it_should, "ERROR")
        console.log("Founds returned succesfully: ", it_should)
    })
})


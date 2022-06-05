const ethers = require('ethers')

const addresses = {
  WETH: '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2',
  factory: '0x8C6Be0F021a162EcB2cc7aEFC579A719EC15e00F', 
  router: '0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D',
  wallet: '0x0b9A658E9145C052486975BF02B082AeA6d1929F'

}

// ELIMINAR ANTES DE SUBIR A GITHUB XD
const mnemonic = "pluck park shed donkey crunch purity essence excite all erupt clog oblige" // 12 words string

// creating a pointer to the provider of infura (websocket)
const provider = new ethers.providers.WebSocketProvider("wss://ropsten.infura.io/ws/v3/7c663bdab8f34a28ba78eb5d9b0f35d1")

// creating a wallet from mnemonic before created
const wallet = ethers.Wallet.fromMnemonic(mnemonic)

// this script is ready to sign transactions
// we connect the wallet to the provider
const account = wallet.connect(provider)

const factory = new ethers.Contract(
	addresses.factory,
	['event emiting(uint256 price, string name)'],
  	account
)

// CREATING A EVENT LISTENER LOGIC WITH .ON
// all contract instances has .on method to listen to events emitted
factory.on('emiting', async (price: number, name: string) => {
	console.log(`
		----------------
		EVENT LOGED
		----------------
		${price} -> ${name} 
		-----------------
		`)
})

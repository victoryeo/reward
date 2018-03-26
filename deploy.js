const HDWalletProvider = require('truffle-hdwallet-provider');
const Web3 = require('web3');
const {interface, bytecode} = require('./compile');

const provider = new HDWalletProvider(
  //'pride auto solar tomorrow trim dismiss myth alert scrap gap clean rotate',
  //'https://rinkeby.infura.io/JNRJAgUOOxgEuieFsYyY'
  'group glue sphere combine same raise snap tool lumber castle strike spot',
  'https://rinkeby.infura.io/pZug2gOrwO40eUGbLzxd'
);

const web3 = new Web3(provider);

const deploy = async () => {
  const accounts =  await web3.eth.getAccounts();

  console.log('Attempt to deploy from account', accounts[0]);

  const result = await new web3.eth.Contract(JSON.parse(interface))
    .deploy({ data: bytecode })
    .send({gas: '2000000', from: accounts[0] });

  console.log('Contract deployed to ', result.options.address);
};

deploy();

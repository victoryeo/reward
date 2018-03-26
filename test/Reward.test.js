const assert = require('assert');
const ganache  = require('ganache-cli');
const Web3 = require('web3');

const web3 = new Web3(ganache.provider());

const { interface, bytecode } = require('../compile');

let accounts;
let reward;
let balance;

beforeEach(async () => {
    accounts = await web3.eth.getAccounts();

    balance = web3.eth.getBalance(accounts[0]);

    reward = await new web3.eth.Contract(JSON.parse(interface))
      .deploy({data: bytecode})
      .send({from: accounts[0], gas: '2000000'});
});

describe('Reward',()=>{
  it('deploys a contract', ()=> {
    assert.ok(reward.options.address);
        console.log(balance);
  });

  it('allows order_start', async()=> {
    await reward.methods.order_start(accounts[0], "aa", "bb", 123, 1234).call ({
      from: accounts[0]
    });
    const id = await reward.methods.referrals(0).call();
    console.log(id);

    assert.equal(accounts[0], id.employeeID);
  });

  //it('check employeeID', async() => {
  //  const employee = await reward.methods.employee().call();
  //  assert.equal(accounts[0], employee);
  //});
});

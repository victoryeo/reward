const path = require('path');
const fs = require('fs');
//const fs = require('fs-extra');
const solc = require('solc');

//const bPath = path.resolve(__dirname, 'contracts', 'erc20.sol');
const bPath = path.resolve(__dirname, 'contracts', 'Reward.sol');
const source = fs.readFileSync(bPath,'utf8');

aa = solc.compile(source, 1);
//module.exports = aa.contracts[':erc20'];
module.exports = aa.contracts[':Reward'];

//console.log(aa);
console.log(aa.contracts[':Reward'].interface);

const Factory = artifacts.require("UniswapV2Factory.sol");
const Token1 = artifacts.require("Token1.sol");
const Token2 = artifacts.require("Token2.sol");

//choose the address use by the deployment
//array of addresses available to us, by default the fisrt one is gonna
//be used by default as a deployment
module.exports = async function (deployer, network, addresses) {
//first address
//add async to be able to use await keyword
  //transaction senc to the deployement
  await deployer.deploy(Factory, addresses[0]);
  //to have the reference to the factory, to the smart contract
  //wait for this transaction to be mined
  const factory = await Factory.deployed();

  let token1Address, token2Address;
  if(network === 'mainnet'){
      token1Address = '';
      token2Address = '';
  } else {
      //testnet deployment 
      await deployer.deploy(Token1);
      await deployer.deploy(Token2);
      //give reference to these tokens
      const token1 = await Token1.deployed();
      const token2 = await Token2.deployed();
      //save the addresses
      token1Address = token1.address;
      token2Address = token2.address;
  }

  //now we can execute function to the smart contract
  //get 2 token addresses of the smart contract
  await factory.createPair(token1Address, token2Address);
};

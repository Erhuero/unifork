const Router = artifacts.require("UniswapV2Router02.sol");
const WETH = artifacts.require("WETH.sol");

module.exports = async function (deployer, network) {
    //pointer of the wrapped ether
    let weth;
    //address found in ganache terminal 
    const FACTORY_ADDRESS = '0xb0A516F89958f73926af3e353b2Fcd301305F705';
    //depliy on mainnet we don't need to deploy the wrapped ether because it is already exist
    //gonna be connected to a deployed version
    //test if we deply on the mainnet or testnet
    if(network === 'mainnet') {
        //found on etherscan
        weth = await WETH.at('0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2');
    } else {
        await deployer.deploy(WETH);
        weth = await WETH.deployed();
    }
    await deployer.deploy(Router, FACTORY_ADDRESS, weth.address);
};

const BonusToken = artifacts.require("BonusToken.sol");
const LiquidityMigrator = artifacts.require("LiquidityMigrator.sol");

module.exports = async function (deployer) {
  await deployer.deploy(BonusToken);
  //get reference to the token
  const bonusToken = await BonusToken.deployed();
  //define a different address router
  const routerAddress = '';
  const pairAddress = '';
  const routerForkAddress = '';
  const pairForkAddress = '';

  //deploy the migrator
  await deployer.deploy(
    LiquidityMigrator,
    //pass all the addresses
    routerAddress,
    pairAddress,
    routerForkAddress,
    pairForkAddress,
    bonusToken.address
  );

  const liquidityMigrator = await LiquidityMigrator.deployed();
  //to allow the liquidity migrator to mint token on bonus token
  await bonusToken.setLiquidator(liquidityMigrator.address);

};

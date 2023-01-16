const {network} =require("hardhat");

module.exports = async function ({ getNamedAccounts, deployments }) {
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();
  const lottery = await deploy("lottery.sol"),{
    from : deployer,
    args : [],
    log : true ,
    waitConfirmations: network.config.blockConfirmations || 1,

  }
};

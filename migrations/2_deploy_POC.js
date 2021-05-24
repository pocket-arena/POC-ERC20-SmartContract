const POC = artifacts.require("MyToken");

module.exports = function(deployer) {
  deployer.deploy(POC);
};

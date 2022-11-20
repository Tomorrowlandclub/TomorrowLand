const BingoToken = artifacts.require("BingoToken");

module.exports = function(deployer) {
    deployer.deploy(BingoToken);
};

const test = artifacts.require("VanityNameRegistering");

module.exports = function (deployer) {
    // set the time_expand_ratio and fee to 0 to don't wait much time in expiring the ownership to assert the funds were returned to the user.
  deployer.deploy(test, 0, 0);
};

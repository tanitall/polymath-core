const SafeMath = artifacts.require('./SafeMath.sol');
const Ownable = artifacts.require('./Ownable.sol');
const PolyToken = artifacts.require('./PolyToken.sol');
const SecurityToken = artifacts.require('./SecurityToken.sol');
const Compliance = artifacts.require('./Compliance.sol');
const Customers = artifacts.require('./Customers.sol');
const SecurityTokenRegistrar = artifacts.require('./SecurityTokenRegistrar.sol');

module.exports = async (deployer, network) => {
  console.log(`Deploying Polymath Network Smart contracts to ${network}...`);
  await deployer.deploy(PolyToken);
  await deployer.deploy(Customers, PolyToken.address);
  await deployer.deploy(Compliance, Customers.address);
  await deployer.deploy(SecurityToken);
  await deployer.deploy(SecurityTokenRegistrar, PolyToken.address);
  console.log(`\nPolymath Network Smart Contracts Deployed:\n
    PolyToken: ${PolyToken.address}\n
    Compliance: ${Compliance.address}\n
    Customers: ${Customers.address}\n
    SecurityToken: ${SecurityToken.address}\n
    SecurityTokenRegistrar: ${SecurityTokenRegistrar.address}\n
  `);
};

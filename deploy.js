const hre = require("hardhat");

async function main() {
  const [deployer, beneficiary] = await hre.ethers.getSigners();
  
  // 1. Deploy the Token
  const MockToken = await hre.ethers.getContractFactory("MockToken");
  const token = await MockToken.deploy();
  await token.waitForDeployment();
  console.log(`Token deployed to: ${token.target}`);

  // 2. Deploy Vesting Contract
  // Config: Start now, 60s cliff, 3600s total duration
  const start = Math.floor(Date.now() / 1000);
  const cliff = 60; 
  const duration = 3600;

  const Vesting = await hre.ethers.getContractFactory("VestingWallet");
  const vesting = await Vesting.deploy(
      token.target,
      beneficiary.address,
      start,
      cliff,
      duration
  );
  await vesting.waitForDeployment();
  console.log(`Vesting Wallet deployed to: ${vesting.target}`);

  // 3. Fund the vesting wallet
  await token.transfer(vesting.target, hre.ethers.parseEther("1000"));
  console.log("Transferred 1000 tokens to vesting wallet");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

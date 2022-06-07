// We import Chai to use its asserting functions here.
const { expect } = require("chai");
const { ethers, waffle } = require("hardhat");

// `describe` is a Mocha function that allows you to organize your tests. It's
// not actually needed, but having your tests organized makes debugging them
// easier. All Mocha functions are available in the global scope.

// `describe` receives the name of a section of your test suite, and a callback.
// The callback must define the tests of that section. This callback can't be
// an async function.
describe("Taxless Arbitrage contract", function () {
  // Mocha has four functions that let you hook into the test runner's
  // lifecyle. These are: `before`, `beforeEach`, `after`, `afterEach`.

  // They're very useful to setup the environment for tests, and to clean it
  // up after they run.

  // A common pattern is to declare some variables, and assign them in the
  // `before` and `beforeEach` callbacks.

  const oneMillionPawth = '1000000000000000';
  const oneHundredMillionPawth = '100000000000000000';
  const tenEth = '10000000000000000000';

  let TaxlessArbitrageContract;
  let taxlessArb;
  let PawthereumContract;
  let pawthereum;
  let PancakeFactoryContract;
  let pancakeFactory;
  let PancakeRouterContract;
  let pancakeRouter;
  let WethContract;
  let weth;
  let owner;
  let approvedSwapper;
  let notApprovedSwapper;
  let addrs;

  // `beforeEach` will run before each test, re-deploying the contract every
  // time. It receives a callback, which can be async.
  beforeEach(async function () {
    // Get the ContractFactory and Signers here.
    TaxlessArbitrageContract = await ethers.getContractFactory("contracts/TaxlessArbitrage.sol:TaxlessArbitrage");
    WethContract = await ethers.getContractFactory("contracts/test_contracts/WBNB.sol:WBNB");
    PawthereumContract = await ethers.getContractFactory("contracts/test_contracts/Pawthereum.sol:Pawthereum");
    PancakeFactoryContract = await ethers.getContractFactory("contracts/test_contracts/PancakeFactory.sol:PancakeFactory");
    PancakeRouterContract = await ethers.getContractFactory("contracts/test_contracts/PancakeRouter.sol:PancakeRouter");
  
    // addresses
    [owner, approvedSwapper, notApprovedSwapper, ...addrs] = await ethers.getSigners();

    // deploy contracts
    weth = await WethContract.deploy();
    pancakeFactory = await PancakeFactoryContract.deploy(owner.address);
    pancakeRouter = await PancakeRouterContract.deploy(pancakeFactory.address, weth.address);
    pawthereum = await PawthereumContract.deploy(owner.address, pancakeRouter.address);
    taxlessArb = await TaxlessArbitrageContract.deploy(weth.address);

    // set arb contract to taxless
    await pawthereum.setTaxless(taxlessArb.address, true);

    // allow the approved account to swap
    await taxlessArb.setApprovedSwapper(approvedSwapper.address, true);

    // create an LP with pawth's init function
    await pawthereum.approve(pancakeRouter.address, oneHundredMillionPawth);
    await pancakeRouter.addLiquidityETH(
      pawthereum.address,
      oneHundredMillionPawth,
      '0',
      '0',
      owner.address,
      parseInt(new Date().getTime() / 1000 + 50000),
      { value: tenEth, from: owner.address }
    );
    await pawthereum.setTaxActive(true);

    // send some eth to the accounts that will test
    await pawthereum.transfer(approvedSwapper.address, oneHundredMillionPawth);
    await pawthereum.transfer(notApprovedSwapper.address, oneHundredMillionPawth);
  });

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      expect(await taxlessArb.owner()).to.equal(owner.address);
    });
    it("Should be set to taxless by Pawthereum", async function () {
      expect(await pawthereum.isTaxlessAccount(taxlessArb.address)).to.equal(true);
    });
  })

  describe("Permissions", function () {
    it("Should deny unauthorized accounts", async function () {
      await pawthereum.connect(notApprovedSwapper).approve(taxlessArb.address, oneMillionPawth);
      await expect(taxlessArb.connect(notApprovedSwapper)
      .taxlessSell(
        pancakeRouter.address,
        pawthereum.address,
        oneMillionPawth,
        0,
        notApprovedSwapper.address
      ))
      .to.be.revertedWith("Access denied");
    });

    it("Should allow authorized accounts", async function () {
      await pawthereum.connect(approvedSwapper).approve(taxlessArb.address, oneMillionPawth);
      await expect(taxlessArb.connect(approvedSwapper)
      .taxlessSell(
        pancakeRouter.address,
        pawthereum.address,
        oneMillionPawth,
        0,
        approvedSwapper.address
      ))
      .to.not.be.reverted
    });
  });

  describe("Taxless swaps", function () {
    it("Should allow authorized accounts to swap taxlessly", async function () {
      // owner receives taxes when a taxed tx occurs so check balance before and after
      // to make sure it doesnt receive taxes on taxless swaps
      const ownerPawthBalanceBefore = await pawthereum.balanceOf(owner.address);
      
      // perform swap
      await pawthereum.connect(approvedSwapper).approve(taxlessArb.address, oneMillionPawth);
      await taxlessArb.connect(approvedSwapper)
      .taxlessSell(
        pancakeRouter.address,
        pawthereum.address,
        oneMillionPawth,
        0,
        approvedSwapper.address
      );

      // make sure owner balance did not increase
      const ownerPawthBalanceAfter = await pawthereum.balanceOf(owner.address);
      expect(
        Number(ownerPawthBalanceAfter)
      ).to.not.be.greaterThan(
        Number(ownerPawthBalanceBefore)
      );
    });
  })

  describe("Taxed swaps", function () {
    it("Should tax swaps if the taxless feature was removed", async function () {
      await pawthereum.setTaxless(taxlessArb.address, false);

      // owner receives taxes when a taxed tx occurs so check balance before and after
      // to make sure it receives taxes on taxless swaps
      const ownerPawthBalanceBefore = await pawthereum.balanceOf(owner.address);
      
      // perform swap
      await pawthereum.connect(approvedSwapper).approve(taxlessArb.address, oneMillionPawth);
      await taxlessArb.connect(approvedSwapper)
      .taxlessSell(
        pancakeRouter.address,
        pawthereum.address,
        oneMillionPawth,
        0,
        approvedSwapper.address
      );

      // make sure owner did increased
      const ownerPawthBalanceAfter = await pawthereum.balanceOf(owner.address);
      expect(
        Number(ownerPawthBalanceAfter)
      ).to.be.greaterThan(
        Number(ownerPawthBalanceBefore)
      );
    });
  })

  describe("Sells tokens and receives eth", function () {
    it("Should allow authorized accounts to swap taxlessly", async function () {
      // make sure the swapper sells tokens after the swap
      const approvedSwapperBalanceBefore = await pawthereum.balanceOf(approvedSwapper.address);
      // make sure the swapper receives eth after the swap
      const approvedSwapperEthBalanceBefore = await waffle.provider.getBalance(approvedSwapper.address);

      // perform swap
      await pawthereum.connect(approvedSwapper).approve(taxlessArb.address, oneMillionPawth);

      await taxlessArb.connect(approvedSwapper)
      .taxlessSell(
        pancakeRouter.address,
        pawthereum.address,
        oneMillionPawth,
        0,
        approvedSwapper.address
      );

      // make sure the swapper sold tokens
      const approvedSwapperBalanceAfter = await pawthereum.balanceOf(approvedSwapper.address);
      expect(
        Number(approvedSwapperBalanceAfter)
      ).to.be.lessThan(
        Number(approvedSwapperBalanceBefore)
      );
      // make sure the swapper receives eth
      const approvedSwappEthBalanceAfter = await waffle.provider.getBalance(approvedSwapper.address);
      expect(
        Number(approvedSwappEthBalanceAfter)
      ).to.be.greaterThan(
        Number(approvedSwapperEthBalanceBefore)
      );
    });
  })
});

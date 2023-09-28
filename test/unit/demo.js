// const { assert } = require("chai")
// const { deployments, ethers, getNamedAccounts } = require("hardhat")
// describe("FundMe", async function () {
//     let fundMe
//     let deployer
//     let mockV3Aggregator
//     beforeEach(async () => {
//         //deploy our fundme contract
//         // using hardhat-deploy

//         // const accounts = await getNamedAccounts()
//         // const accountZero = accounts[0]
//         //const { deployer } = await getNamedAccounts()
//         deployer = (await getNamedAccounts()).deployer
//         deployments.fixture(["all"])
//         // ethers.ge
//         fundMe = await ethers.getContract("FundMe", deployer)
//         mockV3Aggregator = await ethers.getContract(
//             "MockV3Aggregator",
//             deployer
//         )
//     })
//     describe("constructor", async function () {
//         it("sets the aggregator addresses correctly", async () => {
//             const response = await fundMe.priceFeed()
//             assert.equal(response, mockV3Aggregator.address)
//         })
//     })
// })

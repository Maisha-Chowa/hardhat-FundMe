const { run } = require("hardhat")

const verify = async (contractAddress, args) => {
    console.log("Verifying contract...", contractAddress)
    try {
        await run("verify:verify", {
            address: contractAddress,
            constructorArguments: args,
        })
        console.log(contractAddress)
    } catch (e) {
        if (e.message.toLowerCase().includes("already verified")) {
            console.log("Already Verified!")
        } else {
            console.log(e)
        }
    }
}

module.exports ={verify}
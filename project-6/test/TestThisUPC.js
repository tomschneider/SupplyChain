// This script is designed to test the solidity smart contract - SuppyChain.sol -- and the various functions within
// Declare a variable and assign the compiled smart contract artifact
var SupplyChain = artifacts.require('SupplyChain')

contract('SupplyChain', function(accounts) {

    var upc = 2

/**    it("TEST dumpItemBufferOne()", async() => {
        {
            const supplyChain = await SupplyChain.deployed()
            const resultBufferOne = await supplyChain.fetchItemBufferOne.call(upc)
            const resultBufferTwo = await supplyChain.fetchItemBufferTwo.call(upc)
            console.log("UPC " + resultBufferOne[1])
            console.log("SKU " + resultBufferOne[0]);
            console.log("STATE " + resultBufferTwo[5])
            console.log("----------------------------------------")
            console.log("ProductID " + resultBufferTwo[2])
            console.log("ProductNotes " + resultBufferTwo[3])
            console.log("ProductPrice " + resultBufferTwo[4])
            console.log("----------------------------------------")
            console.log("OwnerID " + resultBufferOne[2])
            console.log("DistributorID " + resultBufferTwo[6])
            console.log("RetailerID " + resultBufferTwo[7])
            console.log("ConsumerID " + resultBufferTwo[8])
            console.log("----------------------------------------")
            console.log("OriginFarmerID " + resultBufferOne[3])
            console.log("OriginFarmName " + resultBufferOne[4])
            console.log("OriginFarmInformation " + resultBufferOne[5])
            console.log("OriginFarmLatitude " + resultBufferOne[6])
            console.log("OriginFarmLongitude " + resultBufferOne[7])
        }
    })
 */
});


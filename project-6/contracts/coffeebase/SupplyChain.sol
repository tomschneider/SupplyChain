// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "../coffeeaccesscontrol/ConsumerRole.sol";
import "../coffeeaccesscontrol/DistributorRole.sol";
import "../coffeeaccesscontrol/FarmerRole.sol";
import "../coffeeaccesscontrol/RetailerRole.sol";
import "../coffeecore/Ownable.sol";

// Define a contract 'Supplychain'
contract SupplyChain is Ownable, FarmerRole, DistributorRole, RetailerRole, ConsumerRole {

  // Define 8 events with the same 8 state values and accept 'upc' as input argument
  event ItemHarvested(uint upc);
  event ItemProcessed(uint upc);
  event ItemPacked(uint upc);
  event ItemForSale(uint upc);
  event ItemSold(uint upc);
  event ItemShipped(uint upc);
  event ItemReceived(uint upc);
  event ItemPurchased(uint upc);

  // my own
  event RefundSent(address purchaser);
  event PaymentSent(address seller);

  // Define a variable called 'upc' for Universal Product Code (UPC)
  uint  upc;

  // Define a variable called 'sku' for Stock Keeping Unit (SKU)
  uint  sku;


  // Define a public mapping 'itemsHistory' that maps the UPC to an array of TxHash, 
  // that track its journey through the supply chain -- to be sent from DApp.
  mapping (uint => string[]) itemsHistoryByUPC;
  
  // Define enum 'State' with the following values:
  enum State
  { 
    Harvested,  // 0
    Processed,  // 1
    Packed,     // 2
    ForSale,    // 3
    Sold,       // 4
    Shipped,    // 5
    Received,   // 6
    Purchased   // 7
    }

  State constant defaultState = State.Harvested;

  // Define a struct 'Item' with the following fields:
  struct Item {
    uint    sku;  // Stock Keeping Unit (SKU)
    uint    upc; // Universal Product Code (UPC), generated by the Farmer, goes on the package, can be verified by the Consumer
    address ownerID;  // Metamask-Ethereum address of the current owner as the product moves through 8 stages
    address originFarmerID; // Metamask-Ethereum address of the Farmer
    string  originFarmName; // Farmer Name
    string  originFarmInformation;  // Farmer Information
    string  originFarmLatitude; // Farm Latitude
    string  originFarmLongitude;  // Farm Longitude
    uint    productID;  // Product ID potentially a combination of upc + sku
    string  productNotes; // Product Notes
    uint    productPrice; // Product Price
    State   itemState;  // Product State as represented in the enum above
    address distributorID;  // Metamask-Ethereum address of the Distributor
    address retailerID; // Metamask-Ethereum address of the Retailer
    address consumerID; // Metamask-Ethereum address of the Consumer
  }

  // Define a modifier that checks if the paid amount is sufficient to cover the price
  modifier ensurePurchaserPaidEnough(uint _price) {
    require(msg.value >= _price); 
    _;
  }
  
  // Define a modifier that checks the price and refunds the remaining balance
  // TRW: I refactored this to self-document because 'checkValue' carries little meaning
  modifier checkForRefund(uint _upc) {
    _;
    uint _price = itemsByUPC[_upc].productPrice;
    uint amountToReturn = msg.value - _price;
    address consumer = msg.sender;
    payable(consumer).transfer(amountToReturn);
    emit RefundSent(consumer);
  }

  // Define a modifier that checks if an item.state of a upc is Harvested
  modifier stateIsHarvested(uint _upc) {
    require(itemsByUPC[_upc].itemState == State.Harvested);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Processed
  // DONE
  modifier stateIsProcessed(uint _upc) {
    require(itemsByUPC[_upc].itemState == State.Processed);
    _;
  }
  
  // Define a modifier that checks if an item.state of a upc is Packed
  // DONE
  modifier stateIsPacked(uint _upc) {
    require(itemsByUPC[_upc].itemState == State.Packed);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is ForSale
  // DONE
  modifier stateIsForSale(uint _upc) {
    require(itemsByUPC[_upc].itemState == State.ForSale);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Sold
  // DONE
  modifier stateIsSold(uint _upc) {
    require(itemsByUPC[_upc].itemState == State.Sold);
    _;
  }
  
  // Define a modifier that checks if an item.state of a upc is Shipped
  // DONE
  modifier stateIsShipped(uint _upc) {
    require(itemsByUPC[_upc].itemState == State.Shipped);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Received
  // DONE
  modifier stateIsReceived(uint _upc) {
    require(itemsByUPC[_upc].itemState == State.Received);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Purchased
  // DONE
  modifier stateIsPurchased(uint _upc) {
    require(itemsByUPC[_upc].itemState == State.Purchased);
    _;
  }

  // In the constructor set 'owner' to the address that instantiated the contract
  // and set 'sku' to 1
  // and set 'upc' to 1
  constructor() payable {
    sku = 1;
    upc = 1;
  }

  // Define a function 'kill' if required
  function kill() public {
    if (msg.sender == owner()) {
      selfdestruct(payable(owner()));
    }
  }

  // Define a public mapping 'items' that maps the UPC to an Item.
  mapping (uint => Item) itemsByUPC;

  // Define a function 'harvestItem' that allows a farmer to mark an item 'Harvested'
  function harvestItem(uint           _upc,
                        address       _originFarmerID,
                        string memory _originFarmName,
                        string memory _originFarmInformation,
                        string memory _originFarmLatitude,
                        string memory _originFarmLongitude,
                        string memory _productNotes) public
  {
    // Add the new item as part of Harvest
    itemsByUPC[_upc].ownerID = _originFarmerID;
    itemsByUPC[_upc].sku = sku;

    itemsByUPC[_upc].upc = _upc;
    itemsByUPC[_upc].originFarmerID = _originFarmerID;
    itemsByUPC[_upc].originFarmName = _originFarmName;
    itemsByUPC[_upc].originFarmInformation = _originFarmInformation;
    itemsByUPC[_upc].originFarmLatitude = _originFarmLatitude;
    itemsByUPC[_upc].originFarmLongitude = _originFarmLongitude;
    itemsByUPC[_upc].productNotes = _productNotes;
    itemsByUPC[_upc].itemState = State.Harvested;
    itemsByUPC[_upc].productID = sku + upc;

    // Increment sku
    sku = sku + 1;
    // Emit the appropriate event
    emit ItemHarvested(itemsByUPC[_upc].upc);
  }

  function processItem(uint _upc) public
    // Call modifier to check if upc has passed previous supply chain stage
    stateIsHarvested(_upc)
    // Call modifier to verify caller of this function
    onlyFarmer()
  {
    // Update the appropriate fields
    itemsByUPC[_upc].itemState = State.Processed;

    // Emit the appropriate event
    emit ItemProcessed(_upc);
  }


  // Define a function 'packItem' that allows a farmer to mark an item 'Packed'
  // DONE
  function packItem(uint _upc) public 
  // Call modifier to check if upc has passed previous supply chain stage
  stateIsProcessed(_upc)
  // Call modifier to verify caller of this function
  onlyFarmer()
  {
    // Update the appropriate fields
    itemsByUPC[_upc].itemState = State.Packed;
    // Emit the appropriate event
    emit ItemPacked(_upc);
  }

  // Define a function 'sellItem' that allows a farmer to mark an item 'ForSale'
  function sellItem(uint _upc, uint _price) public 
  // Call modifier to check if upc has passed previous supply chain stage
  stateIsPacked(_upc)
  // Call modifier to verify caller of this function
  onlyFarmer()
  {
    // Update the appropriate fields
    itemsByUPC[_upc].itemState = State.ForSale;
    itemsByUPC[_upc].productPrice = _price;
    // Emit the appropriate event
  emit ItemForSale(_upc);
    
  }

  // Define a function 'buyItem' that allows the disributor to mark an item 'Sold'
  // Use the above defined modifiers to check if the item is available for sale,
  // if the buyer has paid enough,
  // and any excess ether sent is refunded back to the buyer
  // DONE
  function buyItem(uint _upc) public payable 
    // Call modifier to check if upc has passed previous supply chain stage
    stateIsForSale(_upc)
    // Call modifer to check if buyer has paid enough
    ensurePurchaserPaidEnough(_upc)
    // Call modifer to send any excess ether back to buyer
    checkForRefund(_upc)
    {
      // Update the appropriate fields - ownerID, distributorID, itemState
     address farmersAddress = itemsByUPC[_upc].ownerID;

        // I'm unsure difference between ownerID and distributorID
      // i've decide ownerID is the current owner
      itemsByUPC[_upc].ownerID = msg.sender;
      itemsByUPC[_upc].distributorID = msg.sender;
      itemsByUPC[_upc].itemState = State.Sold;
      // Transfer money to farmer
      payable(farmersAddress).transfer(itemsByUPC[_upc].productPrice);
      // emit the appropriate event

      emit ItemSold(_upc);
      emit PaymentSent(farmersAddress);
  }

  // Define a function 'shipItem' that allows the distributor to mark an item 'Shipped'
  // Use the above modifers to check if the item is sold
  // DONE
  // Strange, shipped, but to whom???
  function shipItem(uint _upc) public 
    // Call modifier to check if upc has passed previous supply chain stage
    stateIsSold(_upc)
    // Call modifier to verify caller of this function
    onlyDistributor()
    {
    // Update the appropriate fields
    itemsByUPC[_upc].itemState = State.Shipped;
    // Emit the appropriate event
    emit ItemShipped(_upc);
  }

  // Define a function 'receiveItem' that allows the retailer to mark an item 'Received'
  // Use the above modifiers to check if the item is shipped
  function receiveItem(uint _upc) public 
    // Call modifier to check if upc has passed previous supply chain stage
    stateIsShipped(_upc)
    // Access Control List enforced by calling Smart Contract / DApp
    onlyRetailer()
    {
    // Update the appropriate fields - ownerID, retailerID, itemState
    itemsByUPC[_upc].ownerID = msg.sender;
      itemsByUPC[_upc].retailerID = msg.sender;
      itemsByUPC[_upc].itemState = State.Received;
    // Emit the appropriate event
      emit ItemReceived(_upc);
    
  }

  // Define a function 'purchaseItem' that allows the consumer to mark an item 'Purchased'
  // Use the above modifiers to check if the item is received
  function purchaseItem(uint _upc) public 
    // Call modifier to check if upc has passed previous supply chain stage
    stateIsReceived(_upc)
    // Access Control List enforced by calling Smart Contract / DApp
    onlyConsumer()
    {
    // Update the appropriate fields - ownerID, consumerID, itemState
      itemsByUPC[_upc].ownerID = msg.sender;
      itemsByUPC[_upc].consumerID = msg.sender;
      itemsByUPC[_upc].itemState = State.Purchased;
      // Emit the appropriate event
      emit ItemPurchased(_upc);
    }

  // Define a function 'fetchItemBufferOne' that fetches the data
  function fetchItemBufferOne(uint _upc) public view returns
  (
    uint    itemSKU,
    uint    itemUPC,
    address ownerID,
    address originFarmerID,
    string  memory originFarmName,
    string  memory originFarmInformation,
    string  memory originFarmLatitude,
    string  memory originFarmLongitude)
  {
    Item memory item = itemsByUPC[_upc];
    return (
      item.sku,
      item.upc,
      item.ownerID,
      item.originFarmerID,
      item.originFarmName,
      item.originFarmInformation,
      item.originFarmLatitude,
      item.originFarmLongitude
    );
  }


  // Define a function 'fetchItemBufferTwo' that fetches the data
  function fetchItemBufferTwo(uint _upc) public view returns
  (
    uint    itemSKU,
    uint    itemUPC,
    uint    productID,
    string  memory productNotes,
    uint    productPrice,
    uint    itemState,
    address distributorID,
    address retailerID,
    address consumerID
  )
  {
    Item memory item = itemsByUPC[_upc];
    return (
        item.sku,
        item.upc,
        item.productID,
        item.productNotes,
        item.productPrice,
        uint256(item.itemState),
        item.distributorID,
        item.retailerID,
        item.consumerID

    );
  }

}

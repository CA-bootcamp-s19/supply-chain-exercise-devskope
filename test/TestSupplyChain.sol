pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/SupplyChain.sol";
import "./SupplyChainProxy.sol";

contract TestSupplyChain {
    SupplyChain private supplyChain;
    SupplyChainProxy private seller;
    SupplyChainProxy private buyer;

    uint256 public initialBalance = 6 ether;

    string private name = "book";
    uint256 private price = 50000;
    uint256 private sku = 0;

    /* perform setup before each test case */
    function beforeEach() public {
        // Contract to test
        supplyChain = new SupplyChain();

        // proxy buyer
        buyer = new SupplyChainProxy(supplyChain);

        // proxy seller
        seller = new SupplyChainProxy(supplyChain);

        // add an item for sale
        seller.addItem(name, price);
        // pre fund buyer
        address(buyer).transfer(1 ether);
    }

    // buyItem
    // test for purchasing an item that is not for Sale
    function testFailBuyingItemNotForSale() public {
        // item with such a ridiculos sku is definitely not for sale 😊
        bool result = buyer.buyItem(100000000, price);
        Assert.isFalse(result, "Bleep! Purchased an item not marked for sale");
    }

    // test for failure if user does not send enough funds
    function testFailBuyingBelowPrice() public {
        bool result = buyer.buyItem(sku, price / 2);
        Assert.isFalse(result, "Buyer sent enough or more funds");
    }

    // shipItem
    // test for trying to ship an item that is not marked Sold
    function testFailUnsoldItem() public {
        bool result = seller.shipItem(sku);
        Assert.isFalse(
            result,
            "seller can not ship an item that has not been sold"
        );
    }

    // test for calls that are made by not the seller
    function testFailBuyerInitiateShipping() public {
        buyer.buyItem(sku, price);
        bool result = buyer.shipItem(sku);
        Assert.isFalse(result, "Buyer shipped item - buyers must not do this");
    }

    // receiveItem
    // test calling the function on an item not marked Shipped
    function testFailReceiveNotShippedItem() public {
        buyer.buyItem(sku, price);
        bool result = buyer.receiveItem(sku);
        Assert.isFalse(result, "Recieved - Should not receive unshipped item");
    }

    // test calling the function from an address that is not the buyer
    function testFailSellerRecievingBuyerItem() public {
        buyer.buyItem(sku, price);
        seller.shipItem(sku);
        bool result = seller.receiveItem(sku);
        Assert.isFalse(result, "Item must only be received by buyer");
    }
}

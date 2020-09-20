pragma solidity ^0.5.0;
import "../contracts/SupplyChain.sol";

contract SupplyChainProxy {
    SupplyChain public targetChain;

    constructor(SupplyChain _target) public {
        targetChain = _target;
    }

    /*
     *          ====== Proxy functions ======
     * The following functions invoke respective targetChain functions
     * with msg.sender set to this proxy's address and return
     * a success flag to the proxy invoker
     */
    function addItem(string memory itemName, uint256 itemPrice) public {
        targetChain.addItem(itemName, itemPrice);
    }

    function buyItem(uint256 sku, uint256 price) public returns (bool res) {
        (res, ) = address(targetChain).call.value(price)(
            abi.encodeWithSignature("buyItem(uint256)", sku)
        );
    }

    function shipItem(uint256 sku) public returns (bool res) {
        (res, ) = address(targetChain).call(
            abi.encodeWithSignature("shipItem(uint256)", sku)
        );
    }

    function receiveItem(uint256 sku) public returns (bool res) {
        (res, ) = address(targetChain).call(
            abi.encodeWithSignature("receiveItem(uint256)", sku)
        );
    }

    /*          ====== End Proxy functions ======        */

    function() external payable {} // permit receiving ether transfers
}

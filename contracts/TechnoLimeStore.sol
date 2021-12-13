// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
pragma abicoder v2;

import './Ownable.sol';

contract Store is Ownable {
    struct BoughtProduct {
        string productType;
        bool isBought;
        uint blockNum;
    }

    // Storing products and their quantity in a mapping
    mapping(string => uint) products;
    mapping(string => bool) existingProducts;
    string[] productTypes;

    // Storing the bought products by clients in a nested mapping
    mapping(address => mapping(string => BoughtProduct)) boughtProducts;
    mapping(string => address[]) productBuyers;

    // Add a product to the store (owner only)
    function addProduct(string memory productType, uint quantity) external onlyOwner {
        products[productType] += quantity;

        if (!existingProducts[productType]) {
            existingProducts[productType] = true;
            productTypes.push(productType);
        }
    }

    modifier onlyExisting (string memory productType) {
        require(existingProducts[productType], "Product doesn't exist");
        _;
    }

    // Buy a product
    function buyProduct(string memory productType) external onlyExisting(productType) {
        require(products[productType] > 0, "Insufficient Quantity");

        address buyer = msg.sender;
        uint blockNum = block.number;

        require(!boughtProducts[buyer][productType].isBought, "Customer already has this product");

        boughtProducts[buyer][productType] = BoughtProduct(productType, true, blockNum);
        productBuyers[productType].push(buyer);
        products[productType] -= 1;
    }

    // Return a product
    function returnProduct(string memory productType) external onlyExisting(productType) {
        address buyer = msg.sender;
        uint blockNum = block.number;

        require(boughtProducts[buyer][productType].isBought, "Customer doesn't own this product");
        require(blockNum - boughtProducts[buyer][productType].blockNum < 100, "Too late to return product");

        delete boughtProducts[buyer][productType];
        products[productType]++;
    }

    // View the addresses of clients that have bought a certain product
    function getProductBuyers(string memory productType) external view onlyExisting(productType) returns (address[] memory) {
        return productBuyers[productType];
    }

    // View products in store
    function getProductTypes() external view returns (string[] memory) {
        return productTypes;
    }
}
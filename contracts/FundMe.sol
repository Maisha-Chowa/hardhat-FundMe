// // SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";

error NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;
    address public i_owner;
    uint256 public constant MINIMUM_USD = 50 * 10 ** 18;

    AggregatorV3Interface public priceFeed;

    event Funded(address funder, uint256 amount); // Event for tracking funding
    event Withdrawn(address withdrawer, uint256 amount); // Event for tracking withdrawals
    event Transferred(address from, address to, uint256 amount); // Event for tracking transfers

    constructor(address priceFeedAddress) {
        priceFeed = AggregatorV3Interface(priceFeedAddress);
        i_owner = msg.sender;
    }

    function fund() public payable {
        require(
            msg.value.getConversionRate(priceFeed) >= MINIMUM_USD,
            "You need to spend more ETH!"
        );
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
        emit Funded(msg.sender, msg.value); // Emit Funded event
    }

    modifier onlyOwner() {
        // require(msg.sender == owner);
        if (msg.sender != i_owner) revert NotOwner();
        _;
    }

    function withdraw(
        uint256 amount
    ) public payable onlyOwner returns (uint256) {
        uint256 camount = amount.getConversionRate(priceFeed);
        require(camount >= MINIMUM_USD, "You need to withdraw more ETH!");
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");

        addressToAmountFunded[msg.sender] -= amount;
        emit Withdrawn(msg.sender, amount); // Emit Withdrawn event

        return addressToAmountFunded[msg.sender];
    }

    function getFunders() public view returns (address[] memory) {
        return funders;
    }

    function transferEther(
        address payable recipient,
        uint256 amount
    ) public payable {
        require(
            amount <= addressToAmountFunded[msg.sender],
            "Insufficient funds"
        );
        recipient.transfer(amount); // Use transfer() for safer transfers

        addressToAmountFunded[msg.sender] -= amount;
        addressToAmountFunded[recipient] += amount;

        (bool success, ) = payable(recipient).call{value: amount}("");
        require(success, "Transfer failed");

        emit Transferred(msg.sender, recipient, amount);
    }
}

//     function transfer(
//         address recipient,
//         uint256 amount
//     ) public payable onlyOwner {
//         uint256 camount = amount.getConversionRate(priceFeed);
//         require(camount >= MINIMUM_USD, "You need to withdraw more ETH!");
//         require(
//             amount <= addressToAmountFunded[msg.sender],
//             "Insufficient funds"
//         );
//         // require(recipient != address(0), "Invalid recipient address");

//         addressToAmountFunded[msg.sender] -= amount;
//         addressToAmountFunded[recipient] += amount;

//         (bool success, ) = payable(recipient).call{value: amount}("");
//         require(success, "Transfer failed");

//         emit Transferred(msg.sender, recipient, amount); // Emit Transferred event
//     }
// }

// pragma solidity ^0.8.8;

// import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
// import "./PriceConverter.sol";

// error NotOwner();

// contract FundMe {
//     using PriceConverter for uint256;

//     mapping(address => uint256) public addressToAmountFunded;
//     address[] public funders;

//     address public i_owner;
//     uint256 public constant MINIMUM_USD = 50 * 10 ** 18;

//     AggregatorV3Interface public priceFeed;

//     constructor(address priceFeedAddress) {
//         priceFeed = AggregatorV3Interface(priceFeedAddress);
//         i_owner = msg.sender;
//     }

//     function fund() public payable{
//         require(
//             msg.value.getConversionRate(priceFeed) >= MINIMUM_USD,
//             "You need to spend more ETH!"
//         );
//         addressToAmountFunded[msg.sender] += msg.value;
//         funders.push(msg.sender);
//     }

//     modifier onlyOwner() {
//         // require(msg.sender == owner);
//         if (msg.sender != i_owner) revert NotOwner();
//         _;
//     }

//     function withdraw(uint256 amount) public payable returns (uint256) {
//         uint256 camount = amount.getConversionRate(priceFeed);
//         require(camount >= MINIMUM_USD, "You need to withdraw more ETH!");
//         (bool success, ) = payable(msg.sender).call{value: amount}("");
//         require(success, "Transfer failed");

//         addressToAmountFunded[msg.sender] -= amount;

//         return addressToAmountFunded[msg.sender];
//     }

//     function getFunders() public view returns (address[] memory) {
//     return funders;
//   }

//     // function withdraw() public onlyOwner {
//     //     // here need to change to implement withdraw
//     //     for (
//     //         uint256 funderIndex = 0;
//     //         funderIndex < funders.length;
//     //         funderIndex++
//     //     ) {
//     //         address funder = funders[funderIndex];
//     //         addressToAmountFunded[funder] = 0;
//     //     }
//     //     funders = new address[](0);
//     //     // // transfer
//     //     // payable(msg.sender).transfer(address(this).balance);
//     //     // // send
//     //     // bool sendSuccess = payable(msg.sender).send(address(this).balance);
//     //     // require(sendSuccess, "Send failed");
//     //     // call
//     //     (bool callSuccess, ) = payable(msg.sender).call{
//     //         value: address(this).balance
//     //     }("");
//     //     require(callSuccess, "Call failed");
//     // }

//     // Explainer from: https://solidity-by-example.org/fallback/
//     // Ether is sent to contract
//     //      is msg.data empty?
//     //          /   \
//     //         yes  no
//     //         /     \
//     //    receive()?  fallback()
//     //     /   \
//     //   yes   no
//     //  /        \
//     //receive()  fallback()

//     // fallback() external payable {
//     //     fund();
//     // }

//     // receive() external payable
//     //     fund();
//     // }
// }

// Concepts we didn't cover yet (will cover in later sections)
// 1. Enum
// 2. Events
// 3. Try / Catch
// 4. Function Selector
// 5. abi.encode / decode
// 6. Hash with keccak256
// 7. Yul / Assembly

// Here's a breakdown of the code:

// 1. Contract Structure:

// FundMe: The main contract, managing fundraising and withdrawals.
// PriceConverter: A library (imported) for price conversions.
// 2. State Variables:

// addressToAmountFunded: A mapping to track each funder's contribution.
// funders: An array to store funder addresses.
// i_owner: The contract owner's address.
// MINIMUM_USD: The minimum funding amount in USD.
// priceFeed: An interface to fetch price data (Chainlink).
// 3. Constructor:

// Initializes priceFeed with a provided address.
// Sets the contract owner to the deployer.
// 4. fund() Function:

// Receives funds: Accepts ETH payments using payable.
// Enforces minimum: Ensures the ETH value in USD meets MINIMUM_USD.
// Records contribution: Adds the amount to addressToAmountFunded.
// Adds funder: Appends the funder's address to the funders array.
// 5. onlyOwner Modifier:

// Restricts function access to the contract owner.
// 6. withdraw() Function:

// Owner-only: Only the owner can call this function.
// Resets contributions: Sets all addressToAmountFunded values to 0.
// Clears funders list: Empties the funders array.
// Withdraws funds: Sends the entire contract balance to the owner.
// Uses a low-level call with value transfer for flexibility.
// Checks for success and reverts if failed.
// Key Points:

// Implements a basic crowdfunding mechanism with a minimum funding requirement.
// Leverages Chainlink for price data to ensure minimum funding in USD.
// Enforces ownership restrictions for withdrawals.
// Demonstrates different methods of sending ETH within a contract.

// what is msg.sender and msg.value in solidity

// In Solidity, msg.sender and msg.value are two special variables available within every function of a contract:

// msg.sender:

// Represents the address of the entity that initiated the current transaction. This could be another contract calling your function, an externally owned account (EOA), or even another function within the same contract.
// It's a public address type variable, meaning you can directly access it within your function code.
// Knowing the msg.sender is crucial for implementing access control, managing interactions with users, and identifying callers of your functions.
// msg.value:

// Represents the amount of Ether (in wei) sent along with the current transaction. This is only relevant for functions marked as payable.
// It's a uint256 type variable, providing the amount in wei directly.
// msg.value is commonly used for functions handling payments, deposits, or any interaction with Ether within the contract.
// Here are some additional points to remember:

// Both msg.sender and msg.value are pre-determined by the network and cannot be influenced by your contract code.
// You can rely on these variables to track who is interacting with your contract and how much they are sending, but you should always validate and perform necessary checks before using them.
// Modifiers like payable and nonpayable can control whether msg.value is available and whether the function can receive Ether at all.
// I hope this explanation clarifies the meaning and significance of msg.sender and msg.value in Solidity. Feel free to ask further questions if you need more details!

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract AnimalRandomNumberGenerator is VRFConsumerBaseV2 {
    uint256 private constant ROLL_IN_PROGRESS = 42;

    VRFCoordinatorV2Interface COORDINATOR;

    // Your subscription ID.
    uint64 s_subscriptionId;

    address vrfCoordinator = 0x2eD832Ba664535e5886b75D64C46EB9a228C2610;

    bytes32 s_keyHash =
        0x354d2f95da55398f44b7cff77da56283d9c6c829a4bdf1bbcaf2ad6a4d081f61;

    uint32 callbackGasLimit = 40000;

    // The default is 3, but you can set this higher.
    uint16 requestConfirmations = 3;

    // For this example, retrieve 1 random value in one request.
    // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
    uint32 numWords = 1;
    address s_owner;
    mapping(address => uint256) public s_result;
    mapping(uint256 => address) public s_requestIdToAddress;

    constructor(uint64 subscriptionId) VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        s_owner = msg.sender;
        s_subscriptionId = subscriptionId;
    }

    function SendRandomNoRequest() public returns (uint256 requestId) {
        // Will revert if subscription is not set and funded.
        requestId = COORDINATOR.requestRandomWords(
            s_keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );

        s_requestIdToAddress[requestId] = msg.sender;
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomNumber
    ) internal override {
        uint256 d20Value = (randomNumber[0] % 10) + 1;
        s_result[s_requestIdToAddress[requestId]] = d20Value;
    }

    function GetRandomNo(address player) public view returns (uint256) {
        return (s_result[player]);
    }

    modifier onlyOwner() {
        require(msg.sender == s_owner);
        _;
    }
}

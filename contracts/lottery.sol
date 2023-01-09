//Lottery

// Ui
// Enter the lottery /Add some eth /pay up
// pick a random winner // Verifiable
// automate the process
// Chainlink Oracle generate randomness

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

error lottery__NotEnoughFee();

contract lottery is VRFConsumerBaseV2 {
  // State Var
  uint256 private immutable i_entranceFee;
  address payable[] private s_players;
  VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
  bytes32 private immutable i_keyHash;
  uint64 private immutable i_subscriptionId;
  uint16 private constant REQUEST_CONFIRMATIONS;
  uint32 private constant i_callbackGasLimit;
  uint32 private constant NUM_WORDS=1;

  event lotteryenter(address indexed player);
  event RequestedLotteryWinner(uint256 indexed requestId);

  constructor(
    address vrfCoordinatorV2,
    uint256 entranceFee,
    bytes32 keyHash,
    uint64 subscriptionId,
    uint32 callbackGasLimit
  ) VRFConsumerBaseV2(vrfCoordinatorV2) {
    i_entranceFee = entranceFee;
    i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
    i_keyHash = keyHash;
    i_subscriptionId=subscriptionId;
    i_callbackGasLimit=callbackGasLimit;
  }

  function enterlottery() public payable {
    if (msg.value < i_entranceFee) {
      revert lottery__NotEnoughFee();
    }
    s_players.push(payable(msg.sender));
    emit lotteryenter(msg.sender);
  }

  function requestRandomWinner() external {
    //Request
    //use it
    uint256 requestId = i_vrfCoordinator.requestRandomWords(
      i_keyHash,
      s_subscriptionId,
      REQUEST_CONFIRMATIONS,
      callbackGasLimit,
      NUM_WORDS,
    );
  }

  function fulfillRandomWords(
    uint256 requestId,
    uint256[] memory randomWords
  ) internal override {}

  function getEntranceFee() public view returns (uint256) {
    return i_entranceFee;
  }

  function getPlayer(uint256 index) public view returns (address) {
    return s_players[index];
  }
}

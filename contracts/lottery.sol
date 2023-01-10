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
import "@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol";

error lottery__NotEnoughFee();
error lottery_TransferFailed();

contract lottery is VRFConsumerBaseV2, KeeperCompatibleInterface {
  enum lotteryState {
    OPEN,
    CALCULATING
  }

  // State Var
  uint256 private immutable i_entranceFee;
  address payable[] private s_players;
  VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
  bytes32 private immutable i_keyHash;
  uint64 private immutable i_subscriptionId;
  uint16 private constant REQUEST_CONFIRMATIONS = 3;
  uint32 private immutable i_callbackGasLimit;
  uint32 private constant NUM_WORDS = 1;

  //Lottery Variables
  address private s_recentWinner;
  lotteryState private s_lotteryState;

  event lotteryenter(address indexed player);
  event RequestedLotteryWinner(uint256 indexed requestId);
  event WinnerPicked(address indexed winner);

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
    i_subscriptionId = subscriptionId;
    i_callbackGasLimit = callbackGasLimit;
    s_lotteryState = lotteryState.OPEN;
  }

  function enterlottery() public payable {
    if (msg.value < i_entranceFee) {
      revert lottery__NotEnoughFee();
    }
    s_players.push(payable(msg.sender));
    emit lotteryenter(msg.sender);
  }

  // checkup keep from chainlink
  /**
   * @dev  Function that Chainlink Keeper node calls
   * It shoule be treue inorder to return true
   */

  function checkUpkeep(bytes calldata /*checkData*/) external override {}

  function requestRandomWinner() external {
    //Request
    //use it
    uint256 requestId = i_vrfCoordinator.requestRandomWords(
      i_keyHash,
      i_subscriptionId,
      REQUEST_CONFIRMATIONS,
      i_callbackGasLimit,
      NUM_WORDS
    );
    emit RequestedLotteryWinner(requestId);
  }

  function fulfillRandomWords(
    uint256 /*requestId*/,
    uint256[] memory randomWords
  ) internal override {
    uint256 indexOfWinner = randomWords[0] % s_players.length;
    address payable recentWinner = s_players[indexOfWinner];
    s_recentWinner = recentWinner;
    (bool success, ) = recentWinner.call{ value: address(this).balance }("");
    // require success
    if (!success) {
      revert lottery_TransferFailed();
    }
    emit WinnerPicked(recentWinner);
  }

  function getEntranceFee() public view returns (uint256) {
    return i_entranceFee;
  }

  function getPlayer(uint256 index) public view returns (address) {
    return s_players[index];
  }

  function fetchRecentWinner() public view returns (address) {
    return s_recentWinner;
  }
}

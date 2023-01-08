//Lottery

// Ui
// Enter the lottery /Add some eth /pay up
// pick a random winner // Verifiable
// automate the process
// Chainlink Oracle generate randomness

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

error lottery__NotEnoughFee();

contract lottery {
  // State Var
  uint256 private immutable i_entranceFee;
  address payable[] private s_players;

  constructor(uint256 entranceFee) {
    i_entranceFee = entranceFee;
  }

  function enterlottery() public payable {
    if (msg.value < i_entranceFee) {
      revert lottery__NotEnoughFee();
    }
    s_players.push(payable(msg.sender);
  }

  function getEntranceFee() public view returns (uint256) {
    return i_entranceFee;
  }

  function getPlayer(uint256 index) public view returns (address) {
    return s_players[index];
  }
}

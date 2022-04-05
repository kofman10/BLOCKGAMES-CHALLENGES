// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;

uint256 public constant threshold = 1 wei;

uint public deadline = block.timestamp + 72 hours;

  mapping ( address => uint256 ) public balances;

  event Stake(address indexed sender, uint256 amount); 


  constructor(address exampleExternalContractAddress) public {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

 function stake() public payable{
          
     balances[msg.sender] += msg.value;
     
     emit Stake(msg.sender, msg.value);
 }
  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )

   

  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value
 
  function execute() public {
         
     require(timeLeft() == 0, "deadline has not yet been reached");
     uint256 contractBalance = address(this).balance;

     require(contractBalance >= threshold, "Threshold is not reached");

     (bool sent,) = address(exampleExternalContract).call{value: contractBalance}(abi.encodeWithSignature("complete()"));
      require(sent, "exampleExternalContract.complete failed :(");
  }

  // if the `threshold` was not met, allow everyone to call a `withdraw()` function
   function withdraw(address payable depositor) public {
           
          uint256 userBalance = balances[depositor];

          require(timeLeft() == 0, "deadline not yet expired");

          require(userBalance > 0, "No balance to withdraw");

          balances[depositor] = 0;

          (bool sent,) = depositor.call {value: userBalance}("");

          require(sent, "Failed to send user balance back to the user");

   }

  // Add a `withdraw()` function to let users withdraw their balance


  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
    function timeLeft() public view returns(uint256 timeleft) {
           
        return deadline >= block.timestamp ? deadline - block.timestamp : 0;


        
    }
 
    receive() external payable {
     stake();
   }
        
  // Add the `receive()` special function that receives eth and calls stake()

}

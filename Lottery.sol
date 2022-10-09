// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

//require
//modifier
//constructor
//function
//event
//mapping
//array

contract Lottery{
    address private owner;
    address payable lastWinner;
    address payable[] private participants; 
    mapping (uint256 => address payable) public lotteryWinnerHistory;
    uint256 private lotteryId;

    constructor(){
        lotteryId=1; //lotteries indexed 
        owner=msg.sender; //setting the owner
    }

    // allows the owner to transfer ownership of the contract
    function transferOwnership(address _newOwner) external onlyOwner {
        owner = _newOwner;
    }

    //each participant have to pay 0.2 ether to join lottery
    function enterLottery() payable external checkEtherValue{  
        participants.push(payable(msg.sender)); //has to mark with "payable" keyword.
    }

    //generates a random number with using bunch of data & keccak algorithm
    function getRandomNumber() public view onlyOwner returns (uint256) {
        return uint256(
            keccak256( //keccak256 algorithm
                abi.encodePacked(
                    owner,  
                    block.timestamp,  
                    block.difficulty,  
                    address(this).balance)));  
    }

    //ends a lottery
    function pickRandomWinner() public payable onlyOwner { //only owner can pick a random winner
        uint256 winnerIndex=getRandomNumber() % participants.length; //gets a random number with keccak algorithm
        lastWinner=participants[winnerIndex]; //setting the winner
        emit Winner(lastWinner,lotteryId,address(this).balance); //emit the event
        lastWinner.transfer(address(this).balance); //transfer eth
        lotteryWinnerHistory[lotteryId]=lastWinner; //stores last winner in array
        participants= new address payable[](0); //reset the game
        lotteryId++;  //starts a new lottery
    }

    //gets contract balance
    function getBalance() public onlyOwner view returns(uint256){
        return address(this).balance; //returns total eth
    }

    //gets participants list
    function getParticipants() public onlyOwner view returns(address payable[] memory){
        return participants; //returns participants
    }

    function getWinnerByLotteryId(uint256 _lotteryId) public view returns(address payable) {
        return lotteryWinnerHistory[_lotteryId]; //returns a winner with given lottery id
    }

    //modifiers
    modifier onlyOwner(){
        require(msg.sender==owner,"Caller is not the owner!"); //checks owner
        _;
    }
     modifier checkEtherValue(){
        require(msg.value == .2 ether,"You have to pay exactly 0.2 ether"); //checks ether value
        _;
    }

     //if someone tries to pay ether to contract instead of enterLottery method 
    receive() external payable checkEtherValue{
         participants.push(payable(msg.sender));
         emit Received(payable(msg.sender));
    } 

    //events
    event Received(address payable indexed _sender);
    event Winner(address payable indexed _winner , uint256 _lotteryId, uint256 _value);    
}
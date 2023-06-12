// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Lottery // 0xc1dC97a8242626538A569Cad41bb2a3a6881Ce59
{

    address payable[] public players;
    address manager;
    address payable  winner;
    uint counter;
    bool isOver;
    bool claimed;
    uint win_amt;
    



    constructor(){
        manager = msg.sender;
        counter = 0;
        isOver = false;
        claimed = false;
    }

    modifier isManager{
        require(msg.sender == manager);
        _;
    }
    function getBalance() public view returns(uint){
        return address(this).balance;    
    }

    function getPlayers() public view returns(address payable[] memory){
        return players;
    }

    function enter() payable public{
        require(msg.value >= 0.01 ether);
        players.push(payable(msg.sender));
    }
    
    function random() private returns(uint){
        counter ++;
        return uint (keccak256(abi.encodePacked(manager, block.timestamp,block.difficulty,counter)));   
    }

    function pickWinner() public payable isManager{
        require(players.length > 0);
        require(!isOver);
        winner = players[random() % players.length];
        isOver = true;
        win_amt = (address(this).balance / 10) + 0.008 ether;
        
        //reset
        players = new address payable [](0);
    }

    function claimPrize() public payable {
        require(isOver);
        require(!claimed);
        
        if(msg.sender == winner)
            winner.transfer(win_amt);
        else 
            payable(msg.sender).transfer(0.008 ether);

    }
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Lottery // 0xb9b74787EDb18884f24FED17dF4184612036dE75
{

    address payable[] public players;
    address payable manager;
    address payable  winner;
    uint counter;
    bool isOver;
    // bool claimed;
    uint win_amt;
    // mapping(address => bool) public isClaimed;
    



    constructor(){
        manager = payable(msg.sender);
        counter = 0;
        isOver = false;
        // claimed = false;
    }

    modifier isManager{
        require(msg.sender == manager);
        _;
    }

    modifier isinPlayer{
        require(isPlayer(msg.sender));
        _;
    }

    function isPlayer(address account) public view returns (bool) {
        for (uint i = 0; i < players.length; i++) {
            if (players[i] == account) {
                return true; // Account found in the array
            }
        }
        return false; // Account not found in the array
    }

    // function getClaimed() public view returns(bool){
    //     return isClaimed[msg.sender];    
    // }

    function getWinner() public view returns (address){
        return winner;
    }

    function getManager() public view returns(address){
        return manager;
    }
    function getOver() public view returns(bool){
        return isOver;    
    }
    function getBalance() public view returns(uint){
        return address(this).balance;    
    }

    function getPlayers() public view returns(address payable[] memory){
        return players;
    }

    function enter() payable public{
        require(msg.value >= 0.01 ether);
        require(!isOver);
        players.push(payable(msg.sender));
    }
    
    function random() public returns(uint){
        counter ++;
        return uint (keccak256(abi.encodePacked(manager, block.timestamp,block.difficulty,counter)));   
    }

    function pickWinner() public payable isManager{
        require(players.length > 0);
        require(!isOver);
        winner = players[random() % players.length];
        isOver = true;
        win_amt = (address(this).balance / 10) + 0.008 ether;
        manager.transfer(address(this).balance / 10);
        
        
    }

    function removeAddress(address addr) public {
        for (uint i = 0; i < players.length; i++) {
            if (players[i] == addr) {
                // Move the last element to the position being removed
                players[i] = players[players.length - 1];
                break;
            }
        }
        // Remove the last element
        players.pop();
    }

    function claimPrize() public payable isinPlayer{
        require(isOver, "not over");

        if(msg.sender == winner)
            winner.transfer(win_amt);
        else 
            payable(msg.sender).transfer(0.008 ether);

        removeAddress(msg.sender);

        if(address(this).balance == 0){
            isOver = false;
        }
        
    }
}

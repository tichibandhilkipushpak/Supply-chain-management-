pragma solidity ^0.8.0;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

//This is known as inheritance is keywork extends the ownable contract to shared wallet.
contract SharedWallet is Ownable{

    mapping(address=>uint) public allowance;
    event change(address fromwhom,address to,uint oldvalue,uint newvalue);
    
    function addallowance(address who,uint amount)public onlyOwner{
        emit change(msg.sender,who,allowance[who],amount);
        allowance[who]+=amount;
    }
    modifier ownerorallowed(uint _amount){
        require(isowner() || allowance[msg.sender]>=_amount,"You are not alowed");
        _;
    }
    //Here owner can withdraw as much as he want
    function withdrawMoney(address payable _to, uint _amount) public ownerorallowed(_amount){
        require(_amount<=address(this).balance,"Not Enough funds");
        if(!isowner())
        allowance[msg.sender]-=_amount;
        _to.transfer(_amount);
        
    }

    receive () external payable{

    }
}

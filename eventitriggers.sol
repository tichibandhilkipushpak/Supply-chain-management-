// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

//this allows us to restrict the specific activities that has to be done bu the owner only.
contract ownable{
    address public owner;
    constructor() internal{
        owner=msg.sender;
    }
    modifier onlyowner(){
        require(isowner(),"you are not the owner");
        _;
    }
    function isowner()public view returns (bool){
        return (msg.sender==owner);
    }
}

contract Item{
    uint public price;
    uint public itemindex;
    uint public pricepaid;
    itemmanager parentcontract;
    constructor(itemmanager _parentcontract,uint _price,uint _index)public{
        parentcontract=_parentcontract;
        price=_price;
        itemindex=_index;
        
        
    }
    
    //This payable function ensures us that anyone can make the payment and the payement will be succesful according
    //To the given appropriate conditions.
    receive() external payable{
        require(pricepaid==0,"Already paid");
        require(price==msg.value,"Not accept Partial Payment");
        pricepaid+=msg.value;
        //After all the verification process we can find that the 
        (bool success, ) = address(parentcontract).call{value:msg.value}(abi.encodeWithSignature("triggerpayment(uint256)", itemindex));
        require(success,"Transaction was not succesful");
    }
    
    fallback () external{
    }
}

contract itemmanager is ownable{
    
    enum supplychainstate{created,paid,delivered}
    struct item{
        Item _item;
        string identifier;
        uint price;
        itemmanager.supplychainstate state;
    }
    mapping(uint => item)public items;
    uint index;
    
    event supplychainstep(uint _index,uint step,address _item);
    
    function CreateItem(string memory identifier,uint price)public onlyowner{
        
        Item newitem=new Item(this,price,index);
        items[index]._item=newitem;
        items[index].identifier=identifier;
        items[index].price=price;
        items[index].state=supplychainstate.created;
        emit supplychainstep(index,uint(items[index].state),address(newitem));
        index++;
    
    }
    
    function triggerpayment(uint _index)public payable {
        require(items[_index].price==msg.value,"Only Full payments are accepted");
        require(items[_index].state==supplychainstate.created,"Item is in the supply chain");
        items[_index].state=supplychainstate.paid;
        emit supplychainstep(_index,uint(items[_index].state),address(items[_index]._item));
        
    }
    function triggerdelivery(uint _index)public onlyowner{
       
        require(items[_index].state==supplychainstate.paid,"Payment has to be made");
        items[_index].state=supplychainstate.delivered;
        emit supplychainstep(_index,uint(items[_index].state),address(items[_index]._item));
    }
}

pragma solidity ^0.4.17;


contract CampaignFactory{
    address[] public deployedCampaigns;

    function createCampaign(uint minimum) public{ //minimum is the minimumContribution that a contract expects
        address newCampaign=new Campaign(minimum,msg.sender);
        deployedCampaigns.push(newCampaign);
    }

    function getDeployedCampaign() public view returns(address[]){
        return deployedCampaigns;
    }




}

contract Campaign{

    struct Request{
        string description;
        uint value;
        address recipient;
        bool complete;

        uint approvalCount; //number of people who call yes
        mapping(address=>bool) approvals;
    }

    address public manager;
    uint public minimumContribution;
    //address[] public approvers;
    Request[] public requests;
    mapping(address=>bool) public approvers;
    uint public approversCount;

    modifier restricted(){
        require(msg.sender==manager);
        _;
    }

    function Campaign(uint minimum, address creator) public{
        manager=creator;
        minimumContribution=minimum;    //this is to set the minimum contribution a user has to give to be an approver
    }


    function Contribute() public payable{

        require(msg.value>minimumContribution);

        approvers[msg.sender] = true;
        //approvers.push(msg.sender);
        approversCount++;
    }

    function createRequest(string description1, uint value1, address recipient1 ) public restricted {
        Request memory newRequest= Request({
           description: description1,
           value: value1,
           recipient: recipient1,
           complete: false,
           approvalCount:0
           /*when we inititalize properties of a struct, we donot have to inititalize reference types i.e, mapping*/
        });
        requests.push(newRequest);
    }




    /*Voting sys requirement
    1. single approver cannot vote multiple times
    2. it should be resilient for huge number of Contributors
    */

    function approveRequest(uint index)public{ //index is the index of request in the array
        Request storage request1=requests[index]; //we use storage keyword as we want to stick to the changes done in this function
        require(approvers[msg.sender]); //to check if the address who called the func is an approver
        require(!request1.approvals[msg.sender]); //to check if the person has already voted on this contract

        request1.approvals[msg.sender]=true;
        request1.approvalCount++;
    }

    function finalizeRequest(uint index) public restricted{
        Request storage req1=requests[index];

        require(req1.approvalCount>(approversCount/2));
        require(!req1.complete);

        req1.recipient.transfer(req1.value);
        req1.complete=true;




    }








}

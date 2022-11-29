//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IERC721 
{
    function transferFrom(
        address _from,
        address _to,
        uint256 _id
    ) external;
}


contract Escrow 
{
    address public         nftAddress;
    address payable public seller;
    address public         inspector;
    address public         lender;

    //MAPPINGS
   
    mapping(uint256 => bool)                     public isListed;   //Mapping to know if a token was listed or not 
    mapping(uint256 => uint256)                  public purchasePrice; //Mapping for set the purchase price 
    mapping(uint256 => uint256)                  public escrowAmount; //Mapping tokenID to escrow amount 
    mapping(uint256 => address)                  public buyer; //Mapping to set the buyers of each token 
    mapping(uint256 => bool)                     public inspectionPassed; // To check if the inspection passed 
    mapping(uint256 => mapping(address => bool)) public approval; // To approve the sale of a nft  

    // MODIFIERS
    
    // Modifier: only the seller can transfer the token to the escrow contract   
    modifier onlySeller()
    {
        require(msg.sender == seller, "Only seller can call this method");
        _;
    }

    // Modifier: only the seller can transfer the token to the escrow contract   
    modifier onlyBuyer(uint256 _nftID)
    {
        require(msg.sender == buyer[_nftID], "Only buyer can call this method");
        _;
    }

    // Modifier: only the inspector can change the passed status of a NFT (real state)   
    modifier onlyInspector()
    {
        require(msg.sender == inspector, "Only seller can call this method");
        _;
    }

    //CONSTRUCTOR

    constructor (address _nftAddress, address payable _seller, address _inspector, address _lender)
    {
        nftAddress  = _nftAddress;
        seller      = _seller;
        inspector   = _inspector;
        lender      = _lender;
    }

    //FUNCTIONS

    //Send a token from seller to this contract (only seller)
    function list(uint256 _nftID, address _buyer, uint256 _purchasePrice, uint256 _escrowAmount) public payable onlySeller
    {
        IERC721(nftAddress).transferFrom(msg.sender, address(this), _nftID); //transfer token
        isListed[_nftID]      = true; // set true on the mapping isListed for this token
        purchasePrice[_nftID] = _purchasePrice; // set the price of the token on the mapping
        escrowAmount[_nftID]  = _escrowAmount; // set the escrow amount of the token on the mapping
        buyer[_nftID]         = _buyer; // set the buyer of the each token on the mapping
    }

    //Buyer deposit earnest (only buyer)
    function depositEarnest(uint256 _nftID)public payable onlyBuyer(_nftID)
    {
        //Account deposit should be equal or bigger than token cost 
        require(msg.value >= escrowAmount[_nftID]);
    }

    //Function to change the inspection status of a nft (only inspector)
    function updateInspectionStatus(uint _nftID, bool _passed) public onlyInspector
    {
        inspectionPassed[_nftID] = _passed; 
    }

    //Function to approve a sale 
    function approveSale(uint256 _nftID) public view
    {
        approval[_nftID][msg.sender] == true;
    }

    //Finalize Sale
    // -> Require inspection status (add more items here, like appraisal)
    // -> Require sale to be authorized
    // -> Require founds to be correct amount
    // -> Transfer NFT to buyer
    // -> Transfer founds to Seller
    function finalizeSale(uint256 _nftID) public
    {
        require(inspectionPassed[_nftID]);
        require(approval[_nftID][buyer[_nftID]]);
        require(approval[_nftID][seller]);
        require(approval[_nftID][lender]);
        require(address(this).balance >= purchasePrice[_nftID]);

        isListed[_nftID] = false;

        //transfer ether from this smart contract to the seller
        (bool success, ) = payable(seller).call{value: address(this).balance}("");
        require(success);
         //transfer token to buyer 
        IERC721(nftAddress).transferFrom(address(this), buyer[_nftID], _nftID);

    }

    //If the inspection == false refound, otherwise send ether to seller
    function cancelSale(uint256 _nftID) public 
    {
        if (inspectionPassed[_nftID] == false) 
        {
            payable(buyer[_nftID]).transfer(address(this).balance);
        } 
        else 
        {
            payable(seller).transfer(address(this).balance);
        }
    }

    //Receive function (without data) to enable the sending of ethers to this contract 
    receive() external payable
    {

    }

    //Get the this smart contract balance
    function getBalance() public view returns(uint256)
    {
        return address(this).balance;
    }



}

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
   
    mapping(uint256 => bool)    public isListed;   //Mapping to know if a token was listed or not 
    mapping(uint256 => uint256) public purchasePrice; //Mapping for set the purchase price 
    mapping(uint256 => uint256) public escrowAmount; //Mapping tokenID to escrow amount 
    mapping(uint256 => address) public buyer; //Mapping to set the buyers of each token 

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

    //CONSTRUCTOR

    constructor (address _nftAddress, address payable _seller, address _inspector, address _lender)
    {
        nftAddress  = _nftAddress;
        seller      = _seller;
        inspector   = _inspector;
        lender      = _lender;
    }

    //FUNCTIONS

    //Send a token from seller to this contract (payable function)
    function list(uint256 _nftID, address _buyer, uint256 _purchasePrice, uint256 _escrowAmount) public payable onlySeller
    {
        IERC721(nftAddress).transferFrom(msg.sender, address(this), _nftID); //transfer token
        isListed[_nftID]      = true; // set true on the mapping isListed for this token
        purchasePrice[_nftID] = _purchasePrice; // set the price of the token on the mapping
        escrowAmount[_nftID]  = _escrowAmount; // set the escrow amount of the token on the mapping
        buyer[_nftID]         = _buyer; // set the buyer of the each token on the mapping
    }

    //Buyer deposit earnest
    function depositEarnest(uint256 _nftID)public payable onlyBuyer(_nftID)
    {
        //Account deposit should be equal or bigger than token cost 
        require(msg.value >= escrowAmount[_nftID]);
    }

}

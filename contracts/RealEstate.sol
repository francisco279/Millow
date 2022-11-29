//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

//
contract RealEstate is ERC721URIStorage
{
    //Declare us the counter 
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    //Construct of the token 
    constructor() ERC721("Real Estate", "REAL") 
    {
    
    }

    //Mint function:Set the token to an address
    function mint(string memory tokenURI) public returns (uint256)
    {
        _tokenIds.increment(); // Increment the token id
        uint256 newItemId = _tokenIds.current(); // Set the id to newItemId variable 
        _mint(msg.sender, newItemId); // Set the token to address 
        _setTokenURI(newItemId, tokenURI);
        return newItemId; 
    }

    //Function to get the total supply of tokens
    function totalSupply() public view returns (uint256)
    {
        return _tokenIds.current();
    }
}
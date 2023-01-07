// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./INFT_sale.sol";

contract NFT_sale is INFT_sale{

    // admin address
    address payable immutable public admin;

    //Mapping from bytes32 to nft details
    mapping(bytes32 => NFT) public nft;

    //restricted to admin 
    modifier onlyAdmin {
      require(msg.sender == admin);
      _;
    }
    // NFT validation
    modifier nftsExist(address _nft , uint _tokenId) {
        require(_nft!= address(0),"nft doesn't exist");
        require(nft[getKeccak(_nft,_tokenId)].sold==false,"nft was already sold");
        _;
    }

    constructor()  {
        admin = payable (msg.sender);
    }
    
    struct NFT{
        address nft;
        uint tokenId;
        address owner;
        uint recieved;
        uint price;
        bool sold;
    }
    // getting bytes32 for matching NFT details
    function getKeccak(address _nft , uint _tokenId) public virtual override pure returns(bytes32){
        return keccak256(abi.encodePacked(_nft, _tokenId));
    }
    function owner(address _nft , uint _tokenId) public view returns(address){
     bytes32 key = keccak256(abi.encodePacked(_nft, _tokenId));
     return nft[key].owner;
    }

    // Listing the nft to smart contract
    function nft_list (address _nft, uint _price, uint _tokenId) external virtual override nftsExist(_nft,_tokenId){
        bytes32 key = keccak256(abi.encodePacked(_nft, _tokenId));
        //nft should not be listed already
        require(nft[key].tokenId!=_tokenId,"nft already exist");

        nft[key].nft = _nft;
        nft[key].tokenId = _tokenId;
        nft[key].price = _price;
        nft[key].owner = msg.sender;

        emit nft_logs(_nft,_tokenId,msg.sender,_price);
    }
     // NFT claming function for the winner of the game
    function claim_reward(address winnerAddress, address _nft, uint _tokenId) external virtual override {
        bytes32 key = keccak256(abi.encodePacked(_nft, _tokenId));
        
        require(winnerAddress != address(0),"No such winner exist") ;
        require(nft[key].recieved >= nft[key].price,"Complete contribution isn't made yet");

        ERC721 nftContract = ERC721(nft[key].nft);
        nftContract.transferFrom(nft[key].owner,winnerAddress, _tokenId);
        
        nft[key].owner=winnerAddress;
        emit nft_logs(_nft,_tokenId,winnerAddress,nft[key].price);
    }
    // Buying the nft from the contract
    function buy( address _nft, uint _tokenId) payable external virtual override nftsExist(_nft,_tokenId) {

       bytes32 key = keccak256(abi.encodePacked(_nft, _tokenId));

        require(msg.sender != address(0),"this buyer doesn't exist");
        require(msg.value >= nft[key].price,"Amount should equal to NFT price");


        ERC721 nftContract = ERC721(nft[key].nft);
        nftContract.transferFrom(nft[key].owner, msg.sender, _tokenId);

        nft[key].owner = msg.sender;
        nft[key].sold=true;

        emit nft_logs(_nft,_tokenId,msg.sender,nft[key].price);
        admin.transfer(msg.value);
        
    }
    // Starting the game by contributing the nft price
     function start(address _nft, uint _tokenId) payable  external virtual override nftsExist(_nft,_tokenId) {
        bytes32 key = keccak256(abi.encodePacked(_nft, _tokenId));
        uint req = (nft[key].price*51)/100;

        require(msg.value >= req); 

         nft[key].recieved+= msg.value;
         
        if(nft[key].recieved>nft[key].price){
            nft[key].sold=true;
        }   
    }
      // admin withdraw function
    function admin_withdraw() external override onlyAdmin{
        admin.transfer(address(this).balance);
    }
}
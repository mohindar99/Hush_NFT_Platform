// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
  * importing IERC721 as we use ERC721 in the main contract of bidding
*/

interface Ibidding {
    /*
    * Emmitted when the owner of the NFT is listed and changed.
    */
     event nft_logs(address nft,uint tokenId,address owner,uint price);
    
    /*
    * Returns a unique keccak value by taking nft address and tokenid from the user for listing the NFT
    */
    function getKeccak(address _nft , uint _tokenId) external pure returns(bytes32) ;
    /*
    * Require a unique tokenID instead of repeated
    * Token is registered in the contract for further usage
    * nft address cannot be a zero address
    * NFT cannot a sold one
    */

    function nft_list (address _nft, uint _price, uint _tokenId) external  ;
      
    /*
    * Winner address cannot be zero address
    * Total contribution of the nft should be greter than nft price
    *  Winner could claim the NFT after winning the game from the contract which can be done when the token 'owner' approves the contract.
    *  Emits a {nft_logs} event.
    */

    function claim_reward(address winnerAddress, address _nft, uint _tokenId) external ;
    
    /*
    * NFT address cannot be a zero address
    * NFT cannot a sold one
    * Buyer cannot be zero address
    * Amount sent by the buyer should be equal to the price of NFT
    * Buying the NFT directly with the mentioned price which can be done when the token 'owner' approves the contract
    *  Emits a {nft_logs} event.
    */
    function buy(address _nft, uint _tokenId) external payable  ;
        
    
    /*
    * NFT address cannot be a zero address
    * NFT cannot a sold one
    * Bidder cannot be zero address
    * Staring the game by sending 51% of the amount of the NFT
    *  Emits a {nft_logs} event.
    */
    function start(address _nft, uint _tokenId) payable external;  
   
    
    /*
    * Only admin should withdraw the funds
    * Admin can withdraw the funds from the contract which is 2% in each bidding transaction
    */
    function admin_withdraw() external  ;

}

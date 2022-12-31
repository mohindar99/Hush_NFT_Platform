// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NFT_sale {
    address payable public immutable admin;
    mapping(bytes32 => NFT) public nft;

    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }

    modifier nftsExist(address _nft, uint256 _tokenId) {
        require(_nft != address(0), "nft doesn't exist");
        require(
            nft[getKeccak(_nft, _tokenId)].sold == false,
            "nft was already sold"
        );
        _;
    }

    event nft_logs(address nft, uint256 tokenId, address owner, uint256 price);

    constructor() {
        admin = payable(msg.sender);
    }

    struct NFT {
        address nft;
        uint256 tokenId;
        address owner;
        uint256 recieved;
        uint256 price;
        bool sold;
    }

    function getKeccak(address _nft, uint256 _tokenId)
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(_nft, _tokenId));
    }

    function nft_list(
        address _nft,
        uint256 _price,
        uint256 _tokenId
    ) public nftsExist(_nft, _tokenId) {
        bytes32 key = keccak256(abi.encodePacked(_nft, _tokenId));
        //nft should not be listed already
        require(nft[key].tokenId != _tokenId, "nft already exist");

        nft[key].nft = _nft;
        nft[key].tokenId = _tokenId;
        nft[key].price = _price;
        nft[key].owner = msg.sender;

        emit nft_logs(_nft, _tokenId, msg.sender, _price);
    }

    function clam_reward(
        address winnerAddress,
        address _nft,
        uint256 _tokenId
    ) public {
        bytes32 key = keccak256(abi.encodePacked(_nft, _tokenId));

        require(winnerAddress != address(0), "No such winner exist");
        require(
            nft[key].recieved >= nft[key].price,
            "Complete contribution isn't made yet"
        );

        ERC721 nftContract = ERC721(nft[key].nft);
        nftContract.transferFrom(nft[key].owner, winnerAddress, _tokenId);

        emit nft_logs(_nft, _tokenId, winnerAddress, nft[key].price);
    }

    function buy(
        address buyer,
        address _nft,
        uint256 _tokenId
    ) public payable nftsExist(_nft, _tokenId) {
        bytes32 key = keccak256(abi.encodePacked(_nft, _tokenId));

        require(buyer != address(0), "this buyer doesn't exist");
        require(
            msg.value >= nft[key].price,
            "Amount should equal to NFT price"
        );

        ERC721 nftContract = ERC721(nft[key].nft);
        nftContract.transferFrom(nft[key].owner, buyer, _tokenId);

        nft[key].owner = msg.sender;
        nft[key].sold = true;

        emit nft_logs(_nft, _tokenId, msg.sender, nft[key].price);
        admin.transfer(msg.value);
    }

    function start(address _nft, uint256 _tokenId)
        public
        payable
        nftsExist(_nft, _tokenId)
    {
        bytes32 key = keccak256(abi.encodePacked(_nft, _tokenId));
        uint256 req = (nft[key].price * 51) / 100;

        require(msg.value >= req);

        nft[key].recieved += msg.value;

        if (nft[key].recieved > nft[key].price) {
            nft[key].sold = true;
        }
    }

    function admin_withdraw() public onlyAdmin {
        admin.transfer(address(this).balance);
    }
}

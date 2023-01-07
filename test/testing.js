const {expect}=require("chai");
const { ethers }= require("hardhat");

describe("NFT bid test", function () { 
    let nft_sale;
    let nft_bid;
    let owner;
    let addr1;
    let addr2;
    let addrs;
    let basic_nft;
    let demonft;

    beforeEach("deployment", async function () { 
        nft_sale = await ethers.getContractFactory("NFT_sale");
        [owner, addr1, addr2,...addrs] = await ethers.getSigners();
        //aurguments are passed through the deploy
        nft_bid = await nft_sale.deploy();
        //deploying the nft contract
        basic_nft = await ethers.getContractFactory("demo");
        demonft = await basic_nft.deploy();
    })

    describe("Listing NFT", function () { 
        it("Checking the listing of NFT", async function () { 
            await nft_bid.nft_list(demonft.address, 2, 1);
            await expect(nft_bid.nft_list(demonft.address,2,1)).to.be.revertedWith("nft already exist");
        })
   
        it("Checking the owner of the listed nft", async function () { 
            await nft_bid.nft_list(demonft.address, 2, 1);
            let owner1 = await nft_bid.connect(addr1).owner(demonft.address, 1);
            expect(owner1).to.equal(owner.address);
        })
    })
  
    describe("buying the nft", function () { 
        it("trying to buy the nft", async function () {
            await demonft.safeMint(owner.address,1);
            await demonft.setApprovalForAll(nft_bid.address,true);
            await nft_bid.nft_list(demonft.address,2, 1);
            const val = { value: ethers.utils.parseEther('0.000000000000000002') };
            await nft_bid.connect(addr1).buy(demonft.address, 1, val);
            let owner1 = await nft_bid.owner(demonft.address, 1);
            expect(owner1).to.equal(addr1.address);
        })     
    })
   
    describe("bidding the nft", function () { 
 // The winner is decided from the front-end and we just assumed as addr1 as winner
        it(" Deciding the winner ", async function () {
            await demonft.safeMint(owner.address,1);
            await demonft.setApprovalForAll(nft_bid.address,true);
            await nft_bid.nft_list(demonft.address, 6, 1);
            let val = {value:ethers.utils.parseEther('0.000000000000000004')}
            await nft_bid.connect(addr1).start(demonft.address, 1, val);
            await nft_bid.connect(addr2).start(demonft.address, 1, val);
        //self declared winner as addr1
            await nft_bid.claim_reward(addr1.address, demonft.address, 1); 
            let winneraddress = await nft_bid.owner(demonft.address, 1);
            expect(winneraddress).to.equal(addr1.address);         
         })
        it(" checking the price send for nft", async function(){ 
            await nft_bid.nft_list(demonft.address, 6, 1);
            let val = { value: ethers.utils.parseEther('0.000000000000000002') };
            await expect(nft_bid.start(demonft.address, 1, val)).to.be.revertedWith("");
        })
    })
})

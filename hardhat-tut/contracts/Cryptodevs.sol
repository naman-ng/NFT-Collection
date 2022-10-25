// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IWhitelist.sol";

contract CryptoDev is ERC721Enumerable, Ownable {
    string _baseTokenURI;
    uint256 public _price = 0.1 ether;
    uint256 public maxTokenIds = 20;
    uint256 public tokenIds;
    bool public _paused;
    IWhitelist whitelist;
    bool public presaleStarted;
    uint256 public presaleEnded;

    modifier onlyWhenNotPaused() {
        require(!_paused, "Currently paused");
        _;
    }

    constructor(string memory baseURI, address whitelistContract)
        ERC721("Naman pro", "NP")
    {
        _baseTokenURI = baseURI;
        whitelist = IWhitelist(whitelistContract);
    }

    function startPresale() public payable onlyWhenNotPaused {
        require(
            presaleStarted && block.timestamp < presaleEnded,
            "Presale is not running"
        );
        require(
            whitelist.whitelistedAddresses(msg.sender),
            "You are note whitelisted"
        );
        require(tokenIds < maxTokenIds, "Exceeded max supply");
        require(msg.value >= _price, "Ether is not sufficient");
        tokenIds += 1;
        _safeMint(msg.sender, tokenIds);
    }

    function mint() public payable onlyWhenNotPaused {
        require(
            presaleStarted && block.timestamp >= presaleEnded,
            "Presale is running"
        );
        require(tokenIds < maxTokenIds, "Exceeded max supply");
        require(msg.value >= _price, "Ether is not sufficient");

        tokenIds += 1;
        _safeMint(msg.sender, tokenIds);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function setPaused(bool val) public onlyOwner {
        _paused = val;
    }

    function withdraw() public onlyOwner {
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) = _owner.call{value: amount}("");
        require(sent, "Failed to send");
    }

    receive() external payable {}

    fallback() external payable {}
}

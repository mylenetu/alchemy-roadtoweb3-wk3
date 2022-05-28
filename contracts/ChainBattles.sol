// SPDX-License-Identifier: MIT

// original smart contract (pre-challenges) 0x99BB1C1AD6E73dB8dA27242436fF8072f1f87CAC
// contract post challenges 0x14810D97514dfc3cE0BfAbAC4d3FbD649807AEEB

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract ChainBattles is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

// challenge portion
struct Trait {
  uint level;
  uint grit;
  uint empathy;
  uint courage;
}

    mapping (uint256 => Trait) public tokenIdtoTrait;
    // mapping(uint256 => uint256) public tokenIdtoLevels;

    constructor() ERC721 ("Chain Battles", "CBTLS"){

    }

    function generateCharacter(uint256 tokenId) public view returns(string memory){

    bytes memory svg = abi.encodePacked(
        '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
        '<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>',
        '<rect width="100%" height="100%" fill="black" />',
        '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',"Warrior",'</text>',
        '<text x="50%" y="60%" class="base" dominant-baseline="middle" text-anchor="middle">', "Level: ",getLevel(tokenId),'</text>',
        '<text x="50%" y="70%" class="base" dominant-baseline="middle" text-anchor="middle">', "Grit: ",getGrit(tokenId),'</text>',
        '<text x="50%" y="80%" class="base" dominant-baseline="middle" text-anchor="middle">', "Empathy: ",getEmpathy(tokenId),'</text>',
        '<text x="50%" y="90%" class="base" dominant-baseline="middle" text-anchor="middle">', "Courage: ",getCourage(tokenId),'</text>',
        '</svg>'
    );
    return string(
        abi.encodePacked(
            "data:image/svg+xml;base64,",
            Base64.encode(svg)
        )    
    );
}

    function getLevel(uint256 tokenId) public view returns (string memory) {
        Trait memory _trait = tokenIdtoTrait[tokenId];
        return _trait.level.toString();
    }

    function getGrit(uint256 tokenId) public view returns (string memory) {
        Trait memory _trait = tokenIdtoTrait[tokenId];
        return _trait.grit.toString();
    }

    function getEmpathy(uint256 tokenId) public view returns (string memory) {
        Trait memory _trait = tokenIdtoTrait[tokenId];
        return _trait.empathy.toString();
    }

    function getCourage(uint256 tokenId) public view returns (string memory) {
        Trait memory _trait = tokenIdtoTrait[tokenId];
        return _trait.courage.toString();
    }

    // Get the image
    function getTokenURI(uint256 tokenId) public view returns (string memory){
    bytes memory dataURI = abi.encodePacked(
        '{',
            '"name": "Chain Battles #', tokenId.toString(), '",',
            '"description": "Battles on chain",',
            '"image": "', generateCharacter(tokenId), '"',
        '}'
    );
    return string(
        abi.encodePacked(
            "data:application/json;base64,",
            Base64.encode(dataURI)
            )
        );
    }

    function mint() public {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        Trait storage _trait = tokenIdtoTrait[newItemId];
        _trait.level = 1;
        _trait.grit = 7;
        _trait.empathy = 9;
        _trait.courage = 5;
        _setTokenURI(newItemId, getTokenURI(newItemId));
    }

   function train(uint256 tokenId) public {
        require(_exists(tokenId), "You must use an existing token!");
        require(
            ownerOf(tokenId) == msg.sender,
            "You can only train a token you own!"
        );

        Trait storage _trait = tokenIdtoTrait[tokenId];

        uint256 currentLevel = _trait.level;
        _trait.level = currentLevel + 1;

        uint256 currentGrit = _trait.grit;
        _trait.grit = currentGrit + getRandomNumber(currentGrit);

        uint256 currentEmpathy = _trait.empathy;
        _trait.empathy = currentEmpathy + getRandomNumber(currentEmpathy);

        uint256 currentCourage = _trait.courage;
        _trait.courage = currentCourage + getRandomNumber(currentCourage);

        _setTokenURI(tokenId, getTokenURI(tokenId));
    } 

    function getRandomNumber(uint256 max) public view returns (uint256) {
        bytes memory seed = abi.encodePacked(block.timestamp,block.difficulty,msg.sender);
        uint256 rand = random(seed,max);
        return rand;
    }

    function random(bytes memory _seed, uint256 max) private pure returns (uint256) {
        return uint256(keccak256(_seed)) % max;        
    }
    
}

// adapted from 0xF5bA2a53Ea0b92C7B1d10a65eb0677cAb1BdB758
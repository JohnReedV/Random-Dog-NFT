// SPDX-License-Identifier: MIT
pragma solidity 0.8.8;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

abstract contract CoolDogs is ERC721URIStorage, VRFConsumerBase {
    uint256 public tokenCounter;
    bytes32 public keyhash;
    uint256 public fee;
    mapping(uint256 => Breed) public tokenIdToBreed;
    mapping(bytes32 => address) public requestIdToSender;
    event requestedCollectible(bytes32 indexed requestId, address requester);
    event breedAssigned(uint256 indexed tokenId, Breed breed);
    enum Breed {
        PUG,
        SHIBA_INU,
        ST_BERNARD
    }

    constructor(
        address _vrfCoordinator,
        address _linkToken,
        bytes32 _keyhash,
        uint256 _fee
    ) VRFConsumerBase(_vrfCoordinator, _linkToken) ERC721("Cake", "CAKE") {
        tokenCounter = 0;
        keyhash = _keyhash;
        fee = _fee;
    }

    function createCollectible() public returns (bytes32) {
        bytes32 requestId = requestRandomness(keyhash, fee);
        requestIdToSender[requestId] = msg.sender;
        emit requestedCollectible(requestId, msg.sender);
    }

    function fullfillRandomness(bytes32 requestId, uint256 randomNumber)
        internal
    {
        Breed breed = Breed(randomNumber % 3);
        uint256 newTokenId = tokenCounter;
        tokenIdToBreed[newTokenId] = breed;
        emit breedAssigned(newTokenId, breed);
        address owner = requestIdToSender[requestId];
        _safeMint(owner, newTokenId);
        tokenCounter++;
    }

    function setTokenURI(uint256 tokenId, string memory _tokenURI) public {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: caller is required to be either owner or approved"
        );
        _setTokenURI(tokenId, _tokenURI);
    }
}

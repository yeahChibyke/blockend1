// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title UserRegistry
 * @dev This contract manages user registration within a protocol. Only an admin can remove users or change the admin.
 *      Users can register (become a user) and leave the protocol themselves.
 * @notice anywhere you see this tag @ofca (in commented out functions). It stands for off-chain activity, and it means the frontend or something else should handle that activity.
 */
contract UserRegistry is ERC721, Ownable {
    // --->>> ERRORS
    error UR__NotAdmin(); // thrown when the caller is not the admin
    error UR__CantBeZeroAddress(); // thrown when zero address is provided
    error UR__CannotTransferNFT();
    error ERC721Metadata__URI_QueryFor_NonExistentToken();

    // --->>> VARIABLES
    struct User {
        address wallet;
        string name;
        string email;
        string image; // ipfs or other hosted image
    }

    uint256 private _nextUserId;
    address private s_admin; // address of the protocol admin responsible for user management
    uint256 public userCount; // count of users in the protocol
    mapping(address => uint256) public userToNftId; // maps user to their profile NfT
    mapping(uint256 => User) private s_users; // stores user metadata

    mapping(string => bool) private s_nameExists;
    mapping(string => bool) private s_emailExists;

    // --->>> EVENTS
    event BecameUser(address indexed user, uint256 indexed userId, string name, string email, string image);
    event UserLeft(address indexed user, uint256 indexed userId);
    event AdminSet(address indexed oldAdmin, address indexed newAdmin);

    // --->>> MODIFIERS
    // @dev restricts function acces to the admin
    modifier onlyAdmin() {
        if (msg.sender != s_admin) {
            revert UR__NotAdmin();
        }
        _;
    }

    /// @dev prevents zero address from being used
    modifier cantbeZeroAddress(address _zeroAddress) {
        if (_zeroAddress == address(0)) {
            revert UR__CantBeZeroAddress();
        }
        _;
    }

    // --->>> CONSTRUCTOR
    constructor() ERC721("UStreamDApp", "USDA") Ownable(msg.sender) {
        s_admin = msg.sender;
    }

    // --->>> EXTERNAL FUNCTIONS
    // @notice Registers the caller of the function as a user in the protocol and mints them a USDA user NFT in the process
    function becomeUser(string memory _name, string memory _email, string memory _image) external {
        require(userToNftId[msg.sender] == 0, "User profile already exists!");
        require(!s_nameExists[_name], "Username has already been taken!");
        require(!s_emailExists[_email], "Email has already been used!!");

        uint256 userId = ++_nextUserId;
        _safeMint(msg.sender, userId);
        ++userCount;

        // store metadata on-chain
        s_users[userId] = User({wallet: msg.sender, name: _name, email: _email, image: _image});
        userToNftId[msg.sender] = userId;

        s_nameExists[_name] = true; // Mark username as used
        s_emailExists[_email] = true; // Mark email has used

        emit BecameUser(msg.sender, userId, _name, _email, _image);
    }

    // @notice Allows users to leave the protocol; delete their profile (burn the NFT)
    function leave() external {
        uint256 userId = userToNftId[msg.sender];
        require(userId != 0, "User does not exist!");
        require(ownerOf(userId) == msg.sender, "Not profile owner!");

        _burn(userId);
        delete userToNftId[msg.sender];
        delete s_users[userId];
        userCount--;

        emit UserLeft(msg.sender, userId);
    }

    // @notice Admin can remove users
    function removeUser(address _userToBeRemoved) external onlyAdmin cantbeZeroAddress(_userToBeRemoved) {
        uint256 userId = userToNftId[_userToBeRemoved];
        require(userId != 0, "User does not exist!");

        _burn(userId);
        delete userToNftId[_userToBeRemoved];
        delete s_users[userId];
        userCount--;

        emit UserLeft(msg.sender, userId);

        // P.S. Should add a blacklist mapping to prevent removedUsers from joining the protocol again. Dependent on team decision.
    }

    // --->>> PURE AND PUBLIC FUNCTIONS
    function tokenURI(uint256 userId) public view virtual override returns (string memory) {
        if (ownerOf(userId) == address(0)) {
            revert ERC721Metadata__URI_QueryFor_NonExistentToken();
        }

        address userAddress = s_users[userId].wallet;
        string memory userName = s_users[userId].name;
        string memory userEmail = s_users[userId].email;
        string memory userImageURI = s_users[userId].image;

        return string(
            abi.encodePacked(
                _baseURI(),
                Base64.encode(
                    abi.encodePacked(
                        '{"address":"',
                        userAddress,
                        '"name":"',
                        userName,
                        '"email":"',
                        userEmail,
                        '"image":"',
                        userImageURI,
                        '"}'
                    )
                )
            )
        );
    }

    // --->>> OVER-RIDE FUNCTIONS
    function transferFrom(address, address, uint256) public pure override {
        revert UR__CannotTransferNFT();
    }

    function safeTransferFrom(address, address, uint256, bytes memory) public pure override {
        revert UR__CannotTransferNFT();
    }

    // --->>> SETTER FUNCTIONS
    // @notice Allows current admin to set a new admin
    function setAdmin(address newAdmin) external onlyAdmin cantbeZeroAddress(newAdmin) {
        address oldAdmin = s_admin;
        s_admin = newAdmin;

        emit AdminSet(oldAdmin, newAdmin);
    }

    // --->>> GETTER FUNCTIONS
    // @notice Returns address of current admin
    function getAdmin() external view returns (address) {
        return s_admin;
    }
}

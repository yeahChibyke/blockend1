// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title UserRegistry
 * @dev This contract manages user registration within a protocol. Only an admin can remove users or change the admin.
 *      Users can register (become a user) and leave the protocol themselves.
 * @notice anywhere you see this tag @ofca (in commented out functions). It stands for off-chain activity, and it means the frontend or something else should handle that activity.
 */
contract UserRegistry is Ownable {
    // errors
    /// @dev thrown when the caller is not the admin
    error UR__NotAdmin();
    /// @dev thrown when trying to interact with a user that doesn't exist
    error UR__UserDoesntExist();
    /// @dev thrown when attempting to add a user that already exists
    error UR__UserExist();
    /// @dev thrown when the zero address is provided
    error UR__CantBeZeroAddress();

    // variables
    /// @dev address of the protocol admin responsible for user management
    address private s_admin;
    /// @dev count of registered users in the protocol
    uint256 private s_userCount;
    /// @dev array storing the list of registered user addresses
    address[] private s_userList;
    /// @dev mapping to check if a user is currently registered (true) or not (false)
    mapping(address user => bool status) private s_userStatus;

    // events
    event BecameUser(address indexed user);
    event LeftProtocol(address indexed user);
    event UserRemoved(address indexed user);
    event AdminSet(address indexed oldAdmin, address indexed newAdmin);

    // modifiers
    /// @dev restricts function acces to the admin
    modifier onlyAdmin() {
        if (msg.sender != s_admin) {
            revert UR__NotAdmin();
        }
        _;
    }

    /// @dev ensures inputted address is not a user
    modifier notAUser(address _nonUser) {
        if (s_userStatus[_nonUser]) {
            revert UR__UserExist();
        }
        _;
    }

    /// @dev ensures inputted address is a user
    modifier aUser(address _aUser) {
        if (!s_userStatus[_aUser]) {
            revert UR__UserDoesntExist();
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

    // constructor
    constructor() Ownable(msg.sender) {
        s_userCount = 0;
        s_admin = msg.sender;
    }

    // external functions
    /**
     * @notice registers the caller of the function as a user in the protocol
     * @dev reverts if user is already registered
     * emits a BecameUser event upon successful registration
     */
    function becomeUser() external notAUser(msg.sender) {
        s_userList.push(msg.sender);
        s_userStatus[msg.sender] = true;
        s_userCount++;

        emit BecameUser(msg.sender);
    }

    /**
     * @notice allows a regsitered to leave the protocol of their own accord
     * @dev reverts if the user is not registered
     * emits a LeftProtocol event upon successful exit
     */
    function leaveProtocol() external aUser(msg.sender) {
        s_userStatus[msg.sender] = false;
        _removeFromList(msg.sender);
        s_userCount--;

        emit LeftProtocol(msg.sender);
    }

    /**
     * @notice allows admin to remove a registered user from the protocol
     * @dev reverts if the provided address is either the zero address or not a registered user
     * @param _user address of user to be removed
     * emits a RemovedUser event upon successful removal
     */
    function removeUser(address _user) external onlyAdmin cantbeZeroAddress(_user) aUser(_user) {
        s_userStatus[_user] = false;
        _removeFromList(_user);
        s_userCount--;

        emit UserRemoved(_user);
    }

    // function suspendUser() external onlyAdmin @ofca {}

    // internal function
    /**
     * @dev internal function to remove a user from the user list
     * @dev swaps the user to be removed with the last user in the list, then pops the array
     * @param _user address of user to be removed from the list
     */
    function _removeFromList(address _user) internal {
        uint256 length = s_userList.length;

        for (uint256 a; a < length; a++) {
            if (s_userList[a] == _user) {
                s_userList[a] = s_userList[length - 1];
                s_userList.pop();
                break;
            }
        }
    }

    // setter function
    /**
     * @notice allows current admin to set a new admin
     * @dev reverts if inputted address is zero address
     * @param newAdmin address of the new admin
     * emits a AdminSet event upon successful admin change
     */
    function setAdmin(address newAdmin) external onlyAdmin cantbeZeroAddress(newAdmin) {
        address oldAdmin = s_admin;
        s_admin = newAdmin;

        emit AdminSet(oldAdmin, newAdmin);
    }

    // getter functions
    /// @dev returns address of current admin
    function getAdmin() external view returns (address) {
        return s_admin;
    }

    /// @dev returns total count of registered users
    function getUserCount() external view returns (uint256) {
        return s_userCount;
    }

    /// @dev returns list of registered users
    function getUserList() external view returns (address[] memory) {
        return s_userList;
    }

    /// @dev checks status of inputted address, and reverts if inputted address is zero address
    function getUserStatus(address _user) external view cantbeZeroAddress(_user) returns (bool) {
        return s_userStatus[_user];
    }
}

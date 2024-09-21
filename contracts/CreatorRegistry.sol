// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title CreatorRegistry
 * @dev This contract manages creator registration within a protocol. Only an admin can add or remove users as well as change the admin.
 * @notice anywhere you see this tag @ofca (in commented out functions). It stands for off-chain activity, and it means the frontend or something else should handle that activity.
 */
contract CreatorRegistry is Ownable {
    // errors
    /// @dev thrown when the caller is not the admin
    error CR__NotAdmin();
    /// @dev thrown when trying to interact with a creator that already exists
    error CR__CreatorExist();
    /// @dev thrown when trying to interact with a creator that doesn't exist
    error CR__CreatorDoesntExist();
    /// @dev thrown when the sero address is provided
    error CR__CantBeZeroAddress();

    // variables
    /// @dev address of the protocol admin responsible for creator management
    address private s_admin;
    /// @dev count of registered creators in the protocol
    uint256 private s_creatorCount;
    /// @dev array storing the list of registered creator addresses
    address[] private s_creatorList;
    /// @dev mapping to check if a creator is currently registered (true) or not (false)
    mapping(address creator => bool status) private s_creatorStatus;

    // events
    event CreatorAdded(address indexed creator, address indexed adminWhoAddedCreator);
    event CreatorRemoved(address indexed creator, address indexed adminWhoRemovedCreator);
    event AdminSet(address indexed oldAdmin, address indexed newAdmin);

    // modifiers
    /// @dev restricts acces to the admin
    modifier onlyAdmin() {
        if (msg.sender != s_admin) {
            revert CR__NotAdmin();
        }
        _;
    }

    /// @dev ensures inputted address is not a creator
    modifier notACreator(address nonCreator) {
        if (s_creatorStatus[nonCreator]) {
            revert CR__CreatorExist();
        }
        _;
    }

    /// @dev ensures inputted address is a creator
    modifier aCreator(address creator) {
        if (!s_creatorStatus[creator]) {
            revert CR__CreatorDoesntExist();
        }
        _;
    }

    /// @dev prevents zero address from being used
    modifier cantbeZeroAddress(address _zeroAddress) {
        if (_zeroAddress == address(0)) {
            revert CR__CantBeZeroAddress();
        }
        _;
    }

    // constructor
    constructor() Ownable(msg.sender) {
        s_admin = msg.sender;
        s_creatorCount = 0;
    }

    // external functions
    /**
     * @notice registers the applicant as a creator in the protocol
     * @param applicant the address to be added as a creator
     * @dev reverts if either a nonAdmin calls it, the applicant is already a creator, or the applicant is zero address
     * emits a CreatorAdded event upon suucessful addition
     */
    function addCreator(address applicant) external onlyAdmin notACreator(applicant) cantbeZeroAddress(applicant) {
        s_creatorStatus[applicant] = true;
        s_creatorList.push(applicant);
        s_creatorCount++;

        emit CreatorAdded(applicant, msg.sender);
    }

    /**
     * @notice removes the creator from the protocol
     * @param creator the address of the creator to be removed from the protocol
     * @dev reverts if either a nonAdmin calls it, the inputted address is not a creator, or the inputted address is zero address
     * emits a CreatorRemoved event upon successful removal
     */
    function removeCreator(address creator) external onlyAdmin aCreator(creator) cantbeZeroAddress(creator) {
        s_creatorStatus[creator] = false;
        _removeFromList(creator);
        s_creatorCount--;

        emit CreatorRemoved(creator, msg.sender);
    }

    // internal function
    /**
     * @dev internal function to remove the creator from the creator list
     * @dev swaps the creator to be removed with the last creator in the list, then pops the array
     * @param _creator address of creator to be removed from the list
     */
    function _removeFromList(address _creator) internal {
        uint256 length = s_creatorList.length;

        for (uint256 a; a < length; a++) {
            if (s_creatorList[a] == _creator) {
                s_creatorList[a] = s_creatorList[length - 1];
                s_creatorList.pop();
                break;
            }
        }
    }

    // setter function
    /**
     * @notice allows current admin to set new admin
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

    /// @dev returns total count of registered creators
    function getCreatorCount() external view returns (uint256) {
        return s_creatorCount;
    }

    /// @dev returns list of registered creators
    function getCreatorList() external view returns (address[] memory) {
        return s_creatorList;
    }

    /// @dev checks status of inputted address, and reverts if inputted address is zero address
    function getCreatorStatus(address _creator) external view cantbeZeroAddress(_creator) returns (bool) {
        return s_creatorStatus[_creator];
    }
}

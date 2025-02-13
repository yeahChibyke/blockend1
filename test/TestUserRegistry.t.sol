// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console2} from "forge-std/Test.sol";
import {UserRegistry} from "../src/UserRegistry.sol";

contract TestUserRegistry is Test {
    UserRegistry usda;
    address chibyke = address(0x123);
    address proper = address(0x456);
    address admin = address(0x789);

    function setUp() public {
        usda = new UserRegistry();

        vm.prank(usda.owner());
        usda.setAdmin(admin);
    }

    function testBecomeUser() public {
        vm.prank(chibyke);
        usda.becomeUser("yc", "yc@ustream.com", "ipfs://profileImage");

        uint256 chibykeId = usda.userToNftId(chibyke);
        assert(chibykeId == 1);
        assert(usda.userCount() == 1);
    }

    function testCannotDuplicateUser() public {
        // chibykes becomes user
        vm.prank(chibyke);
        usda.becomeUser("yc", "yc@ustream.com", "ipfs://profileImage");
        assert(usda.userCount() == 1);

        // proper tries to duplicate his profile
        vm.startPrank(proper);
        vm.expectRevert();
        usda.becomeUser("yc", "proper@ustream.com", "ipfs://profileImage"); // tries with same name
        vm.expectRevert();
        usda.becomeUser("proper", "yc@ustream.com", "ipfs://profileImage"); // tries with same email
        vm.stopPrank();

        // chibyke tries to register again.. even with different details
        vm.prank(chibyke);
        vm.expectRevert();
        usda.becomeUser("chibyke", "chibyke@ustream.com", "ipfs://profileImage");

        assert(usda.userCount() == 1); // user count is unchanged
    }

    function testLeave() public {
        // chibyke and proper join the rpotocol
        vm.prank(chibyke);
        usda.becomeUser("yc", "yc@ustream.com", "ipfs://profileImage");
        vm.prank(proper);
        usda.becomeUser("proper", "proper@ustream.com", "ipfs://profileImage");

        uint256 chibykeId = usda.userToNftId(chibyke);
        uint256 properId = usda.userToNftId(proper);
        assert(chibykeId == 1);
        assert(properId == 2);
        assert(usda.userCount() == 2);

        // chibyke leaves
        vm.prank(chibyke);
        usda.leave();

        assert(usda.userCount() == 1);
        uint256 newChibykeId = usda.userToNftId(chibyke);
        assert(newChibykeId == 0);
    }

    function testRemoveUser() public {
        // chibykes becomes user
        vm.prank(chibyke);
        usda.becomeUser("yc", "yc@ustream.com", "ipfs://profileImage");
        uint256 chibykeId = usda.userToNftId(chibyke);
        assert(chibykeId == 1);
        assert(usda.userCount() == 1);

        // admin removes chibyke
        vm.prank(admin);
        usda.removeUser(chibyke);

        uint256 newChibykeId = usda.userToNftId(chibyke);
        assert(newChibykeId == 0);
        assert(usda.userCount() == 0);
    }

    function testTransferRevert() public {
        // chibykes becomes user
        vm.prank(chibyke);
        usda.becomeUser("yc", "yc@ustream.com", "ipfs://profileImage");

        uint256 chibykeId = usda.userToNftId(chibyke);

        vm.startPrank(chibyke);
        vm.expectRevert();
        usda.transferFrom(chibyke, proper, chibykeId);
        vm.expectRevert();
        usda.safeTransferFrom(chibyke, proper, chibykeId);
        vm.stopPrank();
    }

    function testOnlyAdminCanSetAdmin() public {
        vm.prank(chibyke);
        vm.expectRevert();
        usda.setAdmin(chibyke);

        vm.prank(admin);
        usda.setAdmin(proper);

        assert(usda.getAdmin() == proper);
    }

    function testTokenURI() public {
        vm.prank(chibyke);
        usda.becomeUser("yc", "yc@ustream.com", "ipfs://profileImage");

        uint256 chibykeId = usda.userToNftId(chibyke);
        string memory chibykeURI = usda.tokenURI(chibykeId);

        console2.log(chibykeURI); // Metadata should be encoded in Base64
    }
}

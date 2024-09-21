// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";


const UserRegistryModule = buildModule("UserRegistryModule", (m) => {

    const userRegistryModule = m.contract("UserRegistry");

    return { userRegistryModule };
});

export default UserRegistryModule;
// 0x6EaE18Fab50930333185769cC8f44980BCA0987A
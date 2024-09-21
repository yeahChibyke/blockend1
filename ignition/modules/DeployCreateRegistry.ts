// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";


const CreateRegistryModule = buildModule("CreateRegistryModule", (m) => {

  const createRegistryModule = m.contract("CreatorRegistry");

  return { createRegistryModule };
});

export default CreateRegistryModule;

// 0xD322bfaEf271b93e22371A1652D8e921DD1A7586

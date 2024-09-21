// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";


const StreamTokenModule = buildModule("StreamTokenModule", (m) => {

  const streamTokenModule = m.contract("StreamToken");

  return { streamTokenModule };
});

export default StreamTokenModule;
// 0x938cbDBbCd0e50E3ee01c913B53BD73FF2E4c610

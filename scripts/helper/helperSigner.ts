import { ethers } from "ethers";
require("dotenv").config();

export function getWallet(networkName: string): ethers.Wallet {
  return generateWallet(networkName);
}

function generateWallet(networkName: string): ethers.Wallet {
  const providerRPC = {
    network: {
      name: networkName,
      rpc: getRPC(networkName),
      chainId: getChainId(networkName),
    },
  };

  const provider = new ethers.providers.StaticJsonRpcProvider(
    providerRPC.network.rpc,
    {
      chainId: providerRPC.network.chainId,
      name: providerRPC.network.name,
    }
  );

  const accountFrom = {
    privateKey: process.env.PRIVATE_KEY_OWNER || "",
  };

  const wallet = new ethers.Wallet(accountFrom.privateKey, provider);

  return wallet;
}

function getRPC(networkName: string) {
  switch (networkName) {
    case "l1":
      return process.env.GETH_L1_URL;
    case "storknet":
      return process.env.STORKNET_URL;
    case "l1-test":
      return process.env.GETH_L1_TEST_URL;
    default:
      return process.env.GETH_L1_URL;
  }
}

function getChainId(networkName: string): number {
  switch (networkName) {
    case "l1":
      return Number(process.env.GETH_L1_CHAINID);
    case "storknet":
      return Number(process.env.STORKNET_CHAINID);
    case "l1-test":
      return Number(process.env.GETH_L1_TEST_CHAINID);
    default:
      return Number(process.env.GETH_L1_CHAINID);
  }
}
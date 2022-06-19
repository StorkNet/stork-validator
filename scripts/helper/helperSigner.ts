import { ethers } from "ethers";
require("dotenv").config();

export function getSignerHardhat(
  signerId: string
): ethers.providers.JsonRpcSigner {
  const provider = new ethers.providers.JsonRpcProvider(
    "http://localhost:8545"
  );
  switch (signerId) {
    case "owner":
      return provider.getSigner(0);
    case "client":
      return provider.getSigner(1);
    case "1":
      return provider.getSigner(2);
    case "2":
      return provider.getSigner(3);
    case "3":
      return provider.getSigner(4);
    case "4":
      return provider.getSigner(5);
    case "5":
      return provider.getSigner(6);
  }

  return provider.getSigner(0);
}

export function getSigner(signerId: string): string[] {
  switch (signerId) {
    case "rinkeby":
      return [process.env.PUBLIC_KEY || "", process.env.PRIVATE_KEY || ""];

    case "owner":
      return [
        process.env.PUBLIC_KEY_OWNER || "",
        process.env.PRIVATE_KEY_OWNER || "",
      ];
    case "client":
      return [
        process.env.PUBLIC_KEY_CLIENT || "",
        process.env.PRIVATE_KEY_CLIENT || "",
      ];
    case "1":
      return [process.env.PUBLIC_KEY_1 || "", process.env.PRIVATE_KEY_1 || ""];
    case "2":
      return [process.env.PUBLIC_KEY_2 || "", process.env.PRIVATE_KEY_2 || ""];
    case "3":
      return [process.env.PUBLIC_KEY_3 || "", process.env.PRIVATE_KEY_3 || ""];
    case "4":
      return [process.env.PUBLIC_KEY_4 || "", process.env.PRIVATE_KEY_4 || ""];
    case "5":
      return [process.env.PUBLIC_KEY_5 || "", process.env.PRIVATE_KEY_5 || ""];
  }

  return [
    process.env.PUBLIC_KEY_CLIENT || "",
    process.env.PRIVATE_KEY_CLIENT || "",
  ];
}

export function getWallet() {
  const providerRPC = {
    storknet: {
      name: "storknet" || "",
      rpc: process.env.STORKNET_URL || "",
      chainId: 1337,
    },
  };

  const provider = new ethers.providers.StaticJsonRpcProvider(
    providerRPC.storknet.rpc,
    {
      chainId: providerRPC.storknet.chainId,
      name: providerRPC.storknet.name,
    }
  );

  const accountFrom = {
    privateKey: process.env.PRIVATE_KEY_OWNER || "",
  };

  const wallet = new ethers.Wallet(accountFrom.privateKey, provider);

  return wallet;
}

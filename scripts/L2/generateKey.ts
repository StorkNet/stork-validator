/* eslint-disable node/no-missing-import */
// npx hardhat run scripts/miner/addMiner.ts --network localhost
import { Contract, ethers, Wallet } from "ethers";

import { getContract } from "../helper/helperContractAddress";
import { getStorknetWallet } from "../helper/helperSigner";
import { eventListenerKeyExposed } from "./listenKeyExposed";


export async function GenerateKey(
  reqId: number,
  client: string,
  fallbackFunction: string,
  data: string,
  ids: number,
  zkChallenge: string
) {
  const wallet: Wallet = getStorknetWallet();

  const CONTRACT_ADDRESS: string = getContract("StorkRequestHandler");

  const contract: Contract = new ethers.Contract(
    CONTRACT_ADDRESS,
    [
      "function exposeKeyToElectedMiner(uint256 _reqId) external",
    ],
    wallet
  );

  contract
    .exposeKeyToElectedMiner(
      reqId
    )
    .then((tx: any) => {
      console.log("Transaction hash:", tx.hash);
      eventListenerKeyExposed(
        reqId,
        client,
        fallbackFunction,
        data,
        ids,
        zkChallenge
      );
    })
    .catch((error: any) => {
      console.log("Error:", error);
    });
}

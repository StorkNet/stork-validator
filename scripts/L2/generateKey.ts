/* eslint-disable node/no-missing-import */
// npx hardhat run scripts/miner/addMiner.ts --network localhost
import { Contract, ethers, Wallet } from "ethers";

import { getContract } from "../helper/helperContractAddress";
import { getWallet } from "../helper/helperSigner";


export function GenerateKey(
  reqId: number,
) {
  const wallet: Wallet = getWallet();

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
      //push tx to l1
    })
    .catch((error: any) => {
      console.log("Error:", error);
    });
}

/* eslint-disable node/no-missing-import */
// npx hardhat run scripts/miner/addMiner.ts --network localhost
import { Contract, ethers, Wallet } from "ethers";

import { getContract } from "../helper/helperContractAddress";
import { getL1Wallet } from "../helper/helperSigner";

export function HandleRequest(
  reqId: number,
  clientAddress: string,
  fallbackFunction: string,
  data: string,
  ids: number,
  zkProof: string,
  key: number,
) {
  const L1wallet: Wallet = getL1Wallet();

  const CONTRACT_ADDRESS: string = getContract("MultiSigVerification");

  console.log(reqId + " " + clientAddress + " " + fallbackFunction + " " + data + " " + zkProof + " " + key);
  const contract: Contract = new ethers.Contract(
    CONTRACT_ADDRESS,
    [
      "function supplyRequestData(uint256 _reqId, address _addr, string calldata _fallback, bytes calldata _data, uint8 _storkId ,bytes32 zkProof, uint256 _key) external",
    ],
    L1wallet
  );

  contract
    .supplyRequestData(
      reqId,
      clientAddress,
      fallbackFunction,
      data,
      ids,
      zkProof,
      key,
    )
    .then((tx: any) => {
      console.log("Transaction hash:", tx.hash);
    })
    .catch((error: any) => {
      console.log("Error:", error);
    });
}
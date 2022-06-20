/* eslint-disable node/no-missing-import */
// npx hardhat run scripts/miner/addMiner.ts --network localhost
import { Contract, ethers, Wallet } from "ethers";

import { getContract } from "../helper/helperContractAddress";
import { getStorknetWallet } from "../helper/helperSigner";

export function ResolveRequest(
  reqId: number,
  clientAddress: string,
  phalanxName: string,
  key: number,
  fallbackFunction: string,
  arrayOfIds: any
) {
  const wallet: Wallet = getStorknetWallet();

  const CONTRACT_ADDRESS: string = getContract("StorkRequestHandler");

  const contract: Contract = new ethers.Contract(
    CONTRACT_ADDRESS,
    [
      "function startPoStForRequest(uint256 _reqId, address _client, bytes32 _phalanxName, uint256 _key, string calldata _fallbackFunction, uint8[] calldata _ids) external",
    ],
    wallet
  );

  contract
    .startPoStForRequest(
      reqId,
      clientAddress,
      ethers.utils.keccak256(ethers.utils.toUtf8Bytes(phalanxName)),
      key,
      fallbackFunction,
      arrayOfIds,
    )
    .then((tx: any) => {
      console.log("Transaction hash:", tx.hash);
    })
    .catch((error: any) => {
      console.log("Error:", error);
    });
}

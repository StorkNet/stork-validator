/* eslint-disable node/no-missing-import */
// npx hardhat run scripts/miner/addMiner.ts --network localhost
import { Contract, ethers, Wallet } from "ethers";

import { getContract } from "../helper/helperContractAddress";
import { getStorknetWallet } from "../helper/helperSigner";

export function ProposeTx(
  clientAddr: string,
  queryName: string,
  phalanxName: string,
  storkId: number,
  txStork: string,
  txStorkParameter: string,
  fallbackFunction: string,
  key: number
) {
  const wallet: Wallet = getStorknetWallet();

  const CONTRACT_ADDRESS: string = getContract("StorkBlockGenerator");

  const contract: Contract = new ethers.Contract(
    CONTRACT_ADDRESS,
    [
      "function proposeTxForBlock(address _clientAddr, string calldata _queryName, bytes32 _phalanxName, uint8 _storkId, bytes calldata _txStork, bytes calldata _txStorkParameter, string calldata _fallbackFunction, uint256 _key) external",
    ],
    wallet
  );

  contract
    .proposeTxForBlock(
      clientAddr,
      queryName,
      ethers.utils.keccak256(ethers.utils.toUtf8Bytes(phalanxName)),
      storkId,
      txStork,
      txStorkParameter,
      fallbackFunction,
      key
    )
    .then((tx: any) => {
      console.log("Transaction hash:", tx.hash);
    })
    .catch((error: any) => {
      console.log("Error:", error);
    });
}

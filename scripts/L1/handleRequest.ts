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
  zkProof: string,
  key: number,
) {
  const L1wallet: Wallet = getL1Wallet();

  const CONTRACT_ADDRESS: string = getContract("MultiSigVerification");

  console.log(reqId + " " + clientAddress + " " + fallbackFunction + " " + data + " " + zkProof + " " + key);
  const contract: Contract = new ethers.Contract(
    CONTRACT_ADDRESS,
    [
      "function supplyRequestData(uint256 _reqId, address _addr, string calldata _fallback, bytes calldata _data, bytes32 zkProof, uint256 _key) external",
    ],
    L1wallet
  );

  contract
    .supplyRequestData(
      reqId,
      clientAddress,
      fallbackFunction,
      data,
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

HandleRequest(0, "0xF26200BEF0E10501B89AF5210eCA8cD4b2a170fF", "receiveData(bytes)", "0xdccbe5d665358dad8beba1e47ef92e35643e58fa96c6b1c61b2f0c710fe0dc6d", "0x1fd35d2f29adf658eaff86211e4cb063769c61757af01ef6bd7a9c650723d3dd", 126);

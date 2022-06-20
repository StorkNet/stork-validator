require("dotenv").config();

export function getContract(contractName: string): string {
  switch (contractName) {
    case "StorkQuery":
      return process.env.CONTRACT_ADDRESS_STORKQUERY || "";
    case "StorkBlockGenerator":
      return process.env.CONTRACT_ADDRESS_STORKBLOCKGENERATOR || "";
    case "StorkRequestHandler":
      return process.env.CONTRACT_ADDRESS_STORKREQUESTHANDLER || "";
    case "MultiSigVerification" :
      return process.env.CONTRACT_ADDRESS_MULTISIGVERIFICATION || "";
    default:
      return "";
  }
}

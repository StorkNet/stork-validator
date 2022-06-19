require("dotenv").config();

export function getContract(contractName: string): string {
  switch (contractName) {
    case "StorkQueries":
      return process.env.CONTRACT_ADDRESS_STORKQUERIES || "";
    case "StorkBlockGenerator":
      return process.env.CONTRACT_ADDRESS_STORKBLOCKGENERATOR || "";
    case "StorkRequestHandler":
      return process.env.CONTRACT_ADDRESS_STORKREQUESTHANDLER || "";
    default:
      return "";
  }
}

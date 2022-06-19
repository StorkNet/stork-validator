/* eslint-disable node/no-missing-import */
import { getContract } from "../helper/helperContractAddress";
import { ProposeTx } from "../L2/proposeTx";

// eslint-disable-next-line node/no-extraneous-require
const Web3 = require("web3");

const API_URL = process.env.GETH_L1_URL;
const web3 = new Web3(API_URL);

const CONTRACT_ADDRESS = getContract("StorkQueries");

const contract = require("../../artifacts/contracts/StorkQuery.sol/StorkQueries.json");
const StorkQuery = new web3.eth.Contract(contract.abi, CONTRACT_ADDRESS);

let _fromBlock: number = 0;
const listenEvent: string = "EventStorkCreate";

function eventListener() {
  StorkQuery.getPastEvents(
    listenEvent,
    {
      fromBlock: "latest",
    },
    function (_error: any, events: any) {
      if (events[0] !== undefined) {
        if (events[0].blockNumber >= _fromBlock) {
          for (let i = 0; i < events.length; i++) {
            console.log(
              `\n[+]New Block with transaction ${events[i].transactionHash} at block number ${events[i].blockNumber}\n${events[i].returnValues._clientAddress} - ${events[i].returnValues._phalanxName} - ${events[i].returnValues._storkId} \n${events[i].returnValues._stork}`
            );
            console.log("\n[+]Proposing transaction...");
            ProposeTx(
              events[i].returnValues._clientAddress,
              "createStork",
              events[i].returnValues._phalanxName,
              events[i].returnValues._storkId,
              events[i].returnValues._stork,
              "0x0000000000000000000000000000000000000000000000000000000000000000",
              "null",
              Math.floor(Math.random() * 100)
            );
            console.log(
              events[i].returnValues._clientAddress,
              " createStork ",
              events[i].returnValues._phalanxName,
              " ",
              events[i].returnValues._storkId,
              " ",
              events[i].returnValues._stork,
              " 0x0000000000000000000000000000000000000000000000000000000000000000 ",
              " null ",
              Math.floor(Math.random() * 100)
            );
          }
          _fromBlock = events[events.length - 1].blockNumber + 1;
        }
      }
    }
  );
  setTimeout(eventListener, 10 * 1000);
}

console.log("start listening for " + listenEvent);
eventListener();

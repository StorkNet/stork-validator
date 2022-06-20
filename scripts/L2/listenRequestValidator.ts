/* eslint-disable node/no-missing-import */
import { getContract } from "../helper/helperContractAddress";

import { GenerateKey } from "./generateKey";

// eslint-disable-next-line node/no-extraneous-require
const Web3 = require("web3");

const API_URL = process.env.STORKNET_URL;
const web3 = new Web3(API_URL);

const CONTRACT_ADDRESS: string = getContract("StorkRequestHandler");

const contract = require("../../artifacts/contracts/StorkRequestHandler.sol/StorkRequestHandler.json");
const StorkRequestHandler = new web3.eth.Contract(contract.abi, CONTRACT_ADDRESS);

let _fromBlock: number = 0;
const listenEvent: string = "RequestValidator";

function eventListener() {
  StorkRequestHandler.getPastEvents(
    listenEvent,
    {
      fromBlock: "latest",
    },
    async function (_error: any, events: any) {
      if (events[0] !== undefined) {
        if (events[0].blockNumber >= _fromBlock) {
          for (let i = 0; i < events.length; i++) {
            console.log(
              `\n[+]New Block with transaction ${events[i].transactionHash} at block number ${events[i].blockNumber}\n${events[i].returnValues._reqId} - ${events[i].returnValues._miner} - ${events[i].returnValues._fallbackFunction} \n${events[i].returnValues._zkChallenge} \n${events[i].returnValues._data}`
            );
            if (events[i].returnValues._miner == process.env.PUBLIC_KEY_OWNER) {
              await GenerateKey(events[i].returnValues._reqId,
                events[i].returnValues._client,
                events[i].returnValues._fallbackFunction,
                events[i].returnValues._data,
                events[i].returnValues._ids,
                events[i].returnValues._zkChallenge);
            }
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

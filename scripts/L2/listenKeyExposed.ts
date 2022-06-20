/* eslint-disable node/no-missing-import */
import { getContract } from "../helper/helperContractAddress";
import { HandleRequest } from "../L1/handleRequest";

// eslint-disable-next-line node/no-extraneous-require
const Web3 = require("web3");

const API_URL = process.env.STORKNET_URL;
const web3 = new Web3(API_URL);

const CONTRACT_ADDRESS: string = getContract("StorkRequestHandler");

const contract = require("../../artifacts/contracts/StorkRequestHandler.sol/StorkRequestHandler.json");
const StorkRequestHandler = new web3.eth.Contract(contract.abi, CONTRACT_ADDRESS);

let _fromBlock: number = 0;

const listenEvent: string = "KeyExposed";

export function eventListenerKeyExposed(
    // blockNumber: number,
    reqId: number,
    client: string,
    fallbackFunction: string,
    data: string,
    zkChallenge: string
): void {
    let key: number = 0;
    StorkRequestHandler.getPastEvents(
        listenEvent,
        {
            fromBlock: "latest"//blockNumber-1,
        },
        function (_error: any, events: any) {
            if (events[0] !== undefined) {
                if (events[0].blockNumber > _fromBlock) {
                    for (let i = 0; i < events.length; i++) {
                        if (reqId == events[i].returnValues._reqId) {
                            console.log(
                                `\n[+]New Block with transaction ${events[i].transactionHash} at block number ${events[i].blockNumber}\n with reqid ${events[i].returnValues._reqId} - has key ${events[i].returnValues.key}`
                            );
                            key = events[i].returnValues.key;
                            console.log(events);

                            HandleRequest(reqId,
                                client,
                                fallbackFunction,
                                data,
                                zkChallenge,
                                key);
                        }
                        _fromBlock = events[events.length - 1].blockNumber + 1;
                    }
                }
            }
        }
    );
}

console.log("start listening for " + listenEvent);

The client portion of the protocol. Here one of the clients interacts with a mainnet and another interacts with the StorkNet. 

Helper functions are used to provide contract addresses, rpc urls, accounts, from the env.

L1 has the event CRUD listeners that then trigger the L2 trigger of proposeTx which deposits the Tx onto the StorkChain

L2 has event listeners for block creation, key creations, and the trigger for a REQUEST query handle where it listens to data from the StorkNet and deposits that on the network that generated the request

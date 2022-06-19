// File: contracts/StorkTypes.sol

pragma solidity ^0.8.0;

/// @custom: Data Control Contract is called DCC

/// @title Stork Handler Contract
/// @author Shankar "theblushirtdude" Subramanian
/// @notice Used to connect a StorkContract to StorkNet
/// @dev
contract StorkTypes {
    /// @notice Storks are the smallest data unit of the StorkNet
    /// @dev It contains the data stored in the request along with a unique id wrt the collection
    /// @custom: Unique id for each data stored of Flock _typeId
    /// @custom: Id of the Phalanx type interacted with
    /// @custom: Bytes data of the Stork type _typeId (name, age, isMale, etc)
    struct Stork {
        uint8 _id;
        uint8 _typeId;
        bytes _data;
    }

    /// @notice Custom StorkNet datatype for storing data
    /// @dev StorkDataType is the custom data type so that StorkNodes can process data off-chain for lookups
    /// @custom: Solidity data type (string, uint256, bool, etc) of the variable
    /// @custom: Variable name of the data type (name, age, isMale, etc)
    /// @custom: The index of the variable for arrays or mappings
    struct PhalanxType {
        string varType;
        string varName;
        string varIndex;
    }

    /// @notice A collection of Storks
    /// @dev Contains info on a particular group of storks
    /// @custom: The Phalanx type id for lookups
    /// @custom: The size of the Phalanx (the collection of storks)
    /// @custom: Name proposed by Srinidhi
    struct Phalanx {
        uint8 phalanxTypeId;
        uint8 phalanxLastId;
    }

    /// @notice The different types of operations for data processing
    /// @dev The different operations for delete, update, and create
    enum CONDITION {
        eq, // equals to
        gt, // greater than
        lt, // less than
        gte, // greater than or equal to
        lte, // less than or equal to
        neq // not equal to
    }

    /// @notice The request parameters for a parameter request
    /// @dev varName is the variable, operation is how compare,varValue is the value
    /// @custom: Id of the Phalanx type interacted with
    /// @custom: Operation being performed on the variable
    /// @custom: The value of the variable being replaced after the operation is performed
    struct StorkParameter {
        uint8 typeVarId;
        CONDITION operation;
        string varValue;
    }
}

// File: contracts/StorkBlock.sol

pragma solidity ^0.8.0;

contract StorkBlock is StorkTypes {
    struct Block {
        uint32 blockNumber;
        bytes32 validatorProof;
        address blockMiner;
        bytes32[] txHash;
        address[] contracts;
        address[] validators;
        uint8[] contractsTxCounts;
        uint8[] validatorsTxCounts;
        uint8 minConfirmations;
        uint256 blockLockTime;
        bool isSealed;
    }

    struct QueryInfo {
        uint8 cost;
        bytes32 queryHash;
        bool hasStork;
        bool hasParameter;
        bool hasFallback;
    }

    struct AddressInfo {
        uint8 txCount;
        bool isAdded;
    }

    modifier blockInOperation() {
        if (blockHasStarted == false) {
            blockHasStarted = true;
            setNextBlockLockTime();
        }
        _;
    }

    modifier isNotSealed() {
        require(blocks[blockCount].isSealed == false, "block sealed");
        if (nextBlockLockTime < block.timestamp) {
            createNullBlock();
            blockCount++;
        }
        _;
    }

    mapping(uint32 => Block) public blocks;
    mapping(uint32 => bytes32) public blockHashes;

    uint32 public blockCount;

    mapping(string => QueryInfo) internal queryInfo;

    uint256 internal blockLockDuration;
    uint256 internal blockTxAddDuration;
    uint256 internal blockCreateTime = 40 seconds;
    uint256 internal nextBlockLockTime = block.timestamp;
    uint256 internal percentageToPass;
    bool internal blockHasStarted;
    uint256 internal currentTime;

    bytes32[] internal txHashes;
    address[] public validators;
    address[] internal clients;

    uint256 public txCount;
    uint256 internal key;

    mapping(address => AddressInfo) internal clientCounter;
    mapping(address => AddressInfo) internal validatorInfo;
    mapping(address => bool) internal isClientAddedToBlock;

    function setNextBlockLockTime() internal {
        nextBlockLockTime += blockLockDuration;
        blockTxAddDuration = nextBlockLockTime - blockCreateTime;
    }

    function setNewBlockLockDuration(uint256 _blockLockDuration) internal {
        blockLockDuration = _blockLockDuration * 1 seconds;
        setNextBlockLockTime();
    }

    function setPercentageToPass(uint256 _percentageToPass) internal {
        percentageToPass = _percentageToPass;
    }

    function setOperationData() internal {
        queryInfo["createPhalanxType"] = QueryInfo(
            1,
            keccak256(abi.encode("createPhalanxType")),
            false,
            false,
            false
        );

        queryInfo["createStork"] = QueryInfo(
            1,
            keccak256(abi.encode("createStork")),
            true,
            false,
            false
        );

        queryInfo["updateStorkById"] = QueryInfo(
            1,
            keccak256(abi.encode("updateStorkById")),
            true,
            true,
            false
        );

        queryInfo["deleteStorkById"] = QueryInfo(
            1,
            keccak256(abi.encode("deleteStorkById")),
            false,
            false,
            false
        );

        queryInfo["requestStorkById"] = QueryInfo(
            3,
            keccak256(abi.encode("requestStorkById")),
            false,
            false,
            true
        );
    }

    function addOperationData(
        string calldata _queryName,
        uint8 _cost,
        bool _hasStork,
        bool _hasParameter,
        bool _hasFallback
    ) public {
        queryInfo[_queryName] = QueryInfo(
            _cost,
            keccak256(abi.encode(_queryName)),
            _hasStork,
            _hasParameter,
            _hasFallback
        );
    }

    function createNullBlock() internal {
        resetVariables();
        blocks[blockCount] = Block({
            blockNumber: uint32(blockCount),
            validatorProof: bytes32(0),
            blockMiner: address(0),
            txHash: new bytes32[](0),
            contracts: new address[](0),
            validators: new address[](0),
            contractsTxCounts: new uint8[](0),
            validatorsTxCounts: new uint8[](0),
            minConfirmations: 0,
            blockLockTime: block.timestamp + blockLockDuration,
            isSealed: false
        });
    }

    function resetVariables() internal {
        blockHasStarted = false;

        for (uint256 i; i < clients.length; i++) {
            clientCounter[clients[i]] = AddressInfo(0, false);
            isClientAddedToBlock[clients[i]] = false;
        }

        for (uint256 i; i < validators.length; i++) {
            validatorInfo[validators[i]] = AddressInfo(0, false);
        }

        for (uint256 i = txHashes.length; i > 0; i--) {
            txHashes.pop();
        }

        for (uint256 i = validators.length; i > 0; i--) {
            validators.pop();
        }

        for (uint256 i = clients.length; i > 0; i--) {
            clients.pop();
        }

        txCount = 0;
    }

    function announceNewBlock(uint32 _blockNumber) public {
        emit NewBlock(
            _blockNumber,
            blockHashes[_blockNumber],
            blocks[_blockNumber].blockMiner,
            blocks[_blockNumber].validators,
            abi.encode(blocks[_blockNumber])
        );
    }

    event NewBlock(
        uint256 indexed _blockNumber,
        bytes32 indexed _blockHash,
        address _blockMiner,
        address[] _validators,
        bytes _blockData
    );
}

// File: contracts/StorkBlockGenerator.sol

pragma solidity ^0.8.0;

contract OraclePoSt {
    function startPoSt(
        uint256 _key,
        uint8 _validatorsRequired,
        address[] calldata validators
    ) external {}

    function getBlockValidators() public view returns (address[] memory) {}

    function getBlockValidatorChallenge() public view returns (bytes32) {}
}

contract ZKTransaction {
    function startPoSt(
        uint256 _key,
        uint8 _validatorsRequired,
        address[] calldata validators
    ) external {}

    function generateZKTxs(bytes32[] memory txs) external {}

    function getZkTxs() external returns (bytes32[] memory) {}
}

contract StorkDataStore is StorkTypes {
    function setStorkBlockGeneratorAddress(address _storkBlockGeneratorAddress)
        external
    {}

    function createNewPhalanx(
        address _addr,
        bytes32 _phalanxName,
        bytes calldata _phalanxData
    ) public {}

    function createNewData(
        address _addr,
        bytes32 _phalanxName,
        uint8 _storkId,
        bytes calldata _storkData
    ) public {}

    function deleteData(
        address _addr,
        bytes32 _phalanxName,
        uint8 _storkId
    ) public {}
}

contract StorkBlockGenerator is StorkBlock {
    struct TxData {
        address client;
        address[] validators;
        mapping(address => bool) validatorIsAdded;
        bytes32 queryName;
        bytes32 phalanxName;
        uint8 storkId;
        bytes stork;
        bytes storkParameter;
        string _fallbackFunction;
        bool isProposed;
    }

    mapping(bytes32 => TxData) internal txData;

    OraclePoSt internal immutable PoSt;
    ZKTransaction internal immutable zkTx;
    StorkDataStore internal immutable dataStore;

    constructor(
        uint256 _blockLockDuration,
        uint256 _percentageToPass,
        address _PoStAddr,
        address _zkTxAddr,
        address _dataStoreAddr
    ) {
        blockCount = 0;
        nextBlockLockTime = block.timestamp;
        percentageToPass = _percentageToPass;
        setNewBlockLockDuration(_blockLockDuration);
        PoSt = OraclePoSt(_PoStAddr);
        zkTx = ZKTransaction(_zkTxAddr);
        dataStore = StorkDataStore(_dataStoreAddr);
        createNullBlock();
        setOperationData();
    }

    function proposeTxForBlock(
        address _clientAddr,
        string calldata _queryName,
        bytes32 _phalanxName,
        uint8 _storkId,
        bytes calldata _txStork,
        bytes calldata _txStorkParameter,
        string calldata _fallbackFunction,
        uint256 _key
    ) external isNotSealed blockInOperation {
        if (blockTxAddDuration <= block.timestamp) {
            addTxToBlock();
        } else {
            key = _key;
            bytes32 txHashed = keccak256(
                abi.encode(
                    _clientAddr,
                    _queryName,
                    _storkId,
                    _txStork,
                    _txStorkParameter
                )
            );

            // if the txHash doesn't exist, add it to the TxList and increase the txCount of the client
            if (!txData[txHashed].isProposed) {
                if (!clientCounter[_clientAddr].isAdded) {
                    clientCounter[_clientAddr].isAdded = true;
                    clients.push(_clientAddr);
                }
                clientCounter[_clientAddr].txCount += queryInfo[_queryName]
                    .cost;
                txData[txHashed].isProposed = true;
                txData[txHashed].client = _clientAddr;
                txHashes.push(txHashed);
                txCount++;
            }

            txData[txHashed].queryName = keccak256(abi.encode(_queryName));
            txData[txHashed].phalanxName = _phalanxName;
            txData[txHashed].stork = _txStork;
            txData[txHashed].storkId = _storkId;
            txData[txHashed].storkParameter = _txStorkParameter;
            txData[txHashed]._fallbackFunction = _fallbackFunction;

            //add msg.sender to the list of proposers for the tx
            if (!txData[txHashed].validatorIsAdded[msg.sender]) {
                txData[txHashed].validators.push(msg.sender);
                validatorInfo[msg.sender].txCount += queryInfo[_queryName].cost;
            }

            // this creates the list of unique validators
            if (!validatorInfo[msg.sender].isAdded) {
                validators.push(msg.sender);
                validatorInfo[msg.sender].isAdded = true;
            }
        }
    }

    function addTxToBlock() public isNotSealed {
        blocks[blockCount].isSealed = true;
        uint8 validationsRequired = uint8(
            (validators.length * percentageToPass) / 100
        );
        for (uint8 i = 0; i < txCount; ++i) {
            if (txData[txHashes[i]].validators.length >= validationsRequired) {
                blocks[blockCount].txHash.push(txHashes[i]);
                if (isClientAddedToBlock[txData[txHashes[i]].client] == false) {
                    blocks[blockCount].contracts.push(
                        txData[txHashes[i]].client
                    );
                    blocks[blockCount].contractsTxCounts.push(
                        clientCounter[txData[txHashes[i]].client].txCount
                    );
                    isClientAddedToBlock[txData[txHashes[i]].client] = true;
                }
                blocks[blockCount].minConfirmations = validationsRequired;

                if (
                    txData[txHashes[i]].queryName ==
                    queryInfo["createPhalanxType"].queryHash
                ) {
                    dataStore.createNewPhalanx(
                        txData[txHashes[i]].client,
                        txData[txHashes[i]].phalanxName,
                        txData[txHashes[i]].stork
                    );
                } else if (
                    txData[txHashes[i]].queryName ==
                    queryInfo["createStork"].queryHash ||
                    txData[txHashes[i]].queryName ==
                    queryInfo["updateStorkById"].queryHash
                ) {
                    dataStore.createNewData(
                        txData[txHashes[i]].client,
                        txData[txHashes[i]].phalanxName,
                        txData[txHashes[i]].storkId,
                        txData[txHashes[i]].stork
                    );
                } else if (
                    txData[txHashes[i]].queryName ==
                    queryInfo["deleteStorkById"].queryHash
                ) {
                    dataStore.deleteData(
                        txData[txHashes[i]].client,
                        txData[txHashes[i]].phalanxName,
                        txData[txHashes[i]].storkId
                    );
                }
            }
        }

        for (uint8 i; i < validators.length; ++i) {
            blocks[blockCount].validators.push(validators[i]);
            blocks[blockCount].validatorsTxCounts.push(
                validatorInfo[validators[i]].txCount
            );
        }

        PoSt.startPoSt(key, validationsRequired, validators);
        blocks[blockCount].validatorProof = PoSt.getBlockValidatorChallenge();
        PoSt.startPoSt(key, 1, validators);
        blocks[blockCount].blockMiner = PoSt.getBlockValidators()[0];

        zkTx.startPoSt(
            key,
            uint8(blocks[blockCount].txHash.length),
            validators
        );
        zkTx.generateZKTxs(blocks[blockCount].txHash);
        blocks[blockCount].txHash = zkTx.getZkTxs();

        blockHashes[blockCount] = keccak256(
            abi.encode(
                blocks[blockCount].blockMiner,
                abi.encode(blocks[blockCount])
            )
        );

        announceNewBlock(blockCount);
        blockCount++;
        setNextBlockLockTime();
        createNullBlock();
    }
}

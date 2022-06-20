// SPDX-License-Identifier: MIT
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

    /// @notice Associates a id number with your custom Phalanx type
    /// @dev Maps the data type name to a Phalanx type object
    mapping(string => Phalanx) public phalanxInfo;

    /// @notice Counts the number of Phalanx types
    /// @dev Used to keep track of the number of Phalanx types
    uint8 public storkTypeCount;

    /// @notice Checks if a Phalanx type exists
    /// @dev Used to check if a Phalanx type exists
    mapping(string => bool) public phalanxExists;
}
// File: contracts/StorkQuery.sol

pragma solidity ^0.8.0;

/// @title Stork Handler Contract
/// @author Shankar "theblushirtdude" Subramanian
/// @notice Used to connect a StorkContract to StorkNet
/// @dev
contract StorkQuery is StorkTypes {
    modifier isStorkClient() {
        // (bool succ, bytes memory val) = storkFundAddr.staticcall(
        //     abi.encodeWithSignature("isStorkClient(address)", msg.sender)
        // );

        // require(abi.decode(val, (bool)), "SQ- Not a validator");
        _;
    }

    address public immutable storkFundAddr;
    uint256 internal reqId;

    constructor(address _storkFundAddr) {
        storkFundAddr = _storkFundAddr;
    }

    /// @notice Stores new data in the StorkNet
    /// @dev Increments the phalanx's storkLastId, makes a stork with the new id and data, then emits a event
    /// @param _phalanxName The StorkDataType
    /// @param _abiEncodeData The value of the data being stored
    function createStork(
        string memory _phalanxName,
        uint8 _storkId,
        bytes memory _abiEncodeData
    ) external isStorkClient {
        emit EventStorkCreate(
            msg.sender,
            _phalanxName,
            _storkId,
            abi.encode(
                Stork({
                    _id: _storkId,
                    _typeId: phalanxInfo[_phalanxName].phalanxTypeId,
                    _data: _abiEncodeData
                })
            )
        );
    }

    /// @notice Lets StorkNet know that this contract has a new Store request
    /// @param _phalanxName The address of the contract that created the new StorkDataType
    /// @param _storkId The data type name keccak256-ed because that's how events work
    /// @param _stork The data being stored
    event EventStorkCreate(
        address indexed _clientAddress,
        string _phalanxName,
        uint8 _storkId,
        bytes _stork
    );

    //-------------------------------------------------------------------------------------

    /// @notice Stores the StorkDataType in the StorkNet
    /// @dev The event emitted tells StorkNet about the data being stored, it's type, and the contract associated
    /// @param _phalanxName The StorkDataType
    /// @param _storkId The value of the data being stored
    /// @param _abiEncodeData The value of the data being stored
    function updateStorkById(
        string memory _phalanxName,
        uint32 _storkId,
        bytes memory _abiEncodeData
    ) external isStorkClient {
        emit EventStorkUpdateById(
            msg.sender,
            _phalanxName,
            _storkId,
            abi.encode(
                Stork({
                    _id: phalanxInfo[_phalanxName].phalanxTypeId,
                    _typeId: phalanxInfo[_phalanxName].phalanxTypeId,
                    _data: _abiEncodeData
                })
            )
        );
    }

    /// @notice Stores the StorkDataType in the StorkNet
    /// @dev The event emitted tells StorkNet about the data being stored, it's type, and the contract associated
    /// @param _phalanxName The StorkDataType
    /// @param _storkParam The parameters of the data being stored
    /// @param _abiEncodeData The value of the data being stored
    function updateStorkByParam(
        string memory _phalanxName,
        StorkParameter[] memory _storkParam,
        bytes memory _abiEncodeData
    ) external isStorkClient {
        emit EventStorkUpdateByParams(
            msg.sender,
            _phalanxName,
            _storkParam,
            abi.encode(
                Stork({
                    _id: phalanxInfo[_phalanxName].phalanxTypeId,
                    _typeId: phalanxInfo[_phalanxName].phalanxTypeId,
                    _data: _abiEncodeData
                })
            )
        );
    }

    /// @notice Lets StorkNet know that this contract has a new Store request
    /// @param _phalanxName The address of the contract that created the new StorkDataType
    /// @param _storkId The data type name keccak256-ed because that's how events work
    /// @param _stork The data being stored
    event EventStorkUpdateById(
        address indexed _clientAddress,
        string _phalanxName,
        uint32 _storkId,
        bytes _stork
    );

    /// @notice Lets StorkNet know that this contract has a new Store request
    /// @param _phalanxName The address of the contract that created the new StorkDataType
    /// @param _storkParam The parameters being searched for in the update
    /// @param _stork The data being stored
    event EventStorkUpdateByParams(
        address indexed _clientAddress,
        string _phalanxName,
        StorkParameter[] _storkParam,
        bytes _stork
    );

    //-------------------------------------------------------------------------------------

    /// @notice Stores the StorkDataType in the StorkNet
    /// @dev The event emitted tells StorkNet about the data being stored, it's type, and the contract associated
    /// @param _phalanxName The StorkDataType
    /// @param _storkId The index to delete
    function deleteStorkById(string memory _phalanxName, uint32[] memory _storkId)
        external
        isStorkClient
    {
        emit EventStorkDeleteById(msg.sender, _phalanxName, _storkId);
    }

    /// @notice Stores the StorkDataType in the StorkNet
    /// @dev The event emitted tells StorkNet about the data being stored, it's type, and the contract associated
    /// @param _phalanxName The StorkDataType
    /// @param _storkParam The index to delete
    function deleteStorkByParam(string memory _phalanxName, StorkParameter[] memory _storkParam)
        external
        isStorkClient
    {
        emit EventStorkDeleteByParams(msg.sender, _phalanxName, abi.encode(_storkParam));
    }

    /// @notice Lets StorkNet know that this contract has a new Store request
    /// @param _storkName The data type name keccak256-ed because that's how events work
    /// @param _storkId The index to delete
    event EventStorkDeleteById(
        address indexed _clientAddress,
        string _storkName,
        uint32[] _storkId
    );

    /// @notice Lets StorkNet know that this contract has a new Store request
    /// @param _storkName The data type name keccak256-ed because that's how events work
    /// @param _storkParam The index to delete
    event EventStorkDeleteByParams(
        address indexed _clientAddress,
        string _storkName,
        bytes _storkParam
    );

    //-------------------------------------------------------------------------------------

    /// @notice Stores the StorkDataType in the StorkNet
    /// @notice Stores the StorkDataType in the StorkNet
    /// @dev The event emitted tells StorkNet about the data being stored, it's type, and the contract associated
    /// @param _phalanxName The StorkDataType
    /// @param _arrayOfIds The value of the data being stored
    /// @param _fallbackFunction The value of the data being stored
    function requestStorkById(
        string memory _phalanxName,
        uint32[] memory _arrayOfIds,
        string memory _fallbackFunction
    ) external isStorkClient {
        emit EventStorkRequestId(msg.sender, _phalanxName, _arrayOfIds, _fallbackFunction, reqId++);
    }

    /// @notice Stores the StorkDataType in the StorkNet
    /// @dev The event emitted tells StorkNet about the data being stored, it's type, and the contract associated
    /// @param _phalanxName The StorkDataType
    /// @param _storkRequestParameters The value of the data being stored
    /// @param _fallbackFunction The value of the data being stored
    function requestStorkByParams(
        string memory _phalanxName,
        StorkParameter[] memory _storkRequestParameters,
        string memory _fallbackFunction
    ) external isStorkClient {
        emit EventStorkRequestByParams(
            msg.sender,
            _phalanxName,
            abi.encode(_storkRequestParameters),
            _fallbackFunction
        );
    }

    /// @dev The event emitted tells StorkNet about the data being stored, it's type, and the contract associated
    /// @param _phalanxName The StorkDataType
    /// @param _storkIdRange The value of the data being stored
    /// @param _fallbackFunction The value of the data being stored
    function requestStorkByRange(
        string memory _phalanxName,
        uint32[] memory _storkIdRange,
        string memory _fallbackFunction
    ) external isStorkClient {
        emit EventStorkRequestByRange(msg.sender, _phalanxName, _storkIdRange, _fallbackFunction);
    }

    /// @notice Lets StorkNet know that this contract has a new Store request
    /// @param _phalanxName The address of the contract that created the new StorkDataType
    /// @param _arrayOfIds The data type name keccak256-ed because that's how events work
    /// @param _fallbackFunction The data being stored
    event EventStorkRequestId(
        address indexed _clientAddress,
        string _phalanxName,
        uint32[] _arrayOfIds,
        string _fallbackFunction,
        uint256 _reqId
    );

    /// @notice Lets StorkNet know that this contract has a new Store request
    /// @param _phalanxName The address of the contract that created the new StorkDataType
    /// @param _storkRequestParameters The data type name keccak256-ed because that's how events work
    /// @param _fallbackFunction The data being stored
    event EventStorkRequestByParams(
        address indexed _clientAddress,
        string _phalanxName,
        bytes _storkRequestParameters,
        string _fallbackFunction
    );

    /// @notice Lets StorkNet know that this contract has a new Store request
    /// @param _phalanxName The address of the contract that created the new StorkDataType
    /// @param _storkIdRange The data type name keccak256-ed because that's how events work
    /// @param _fallbackFunction The data being stored
    event EventStorkRequestByRange(
        address indexed _clientAddress,
        string _phalanxName,
        uint32[] _storkIdRange,
        string _fallbackFunction
    );
}

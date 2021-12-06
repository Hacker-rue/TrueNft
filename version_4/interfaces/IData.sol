pragma ton-solidity >= 0.43.0;

interface IData {
    struct bet {
        address owner;
        uint128 cost;
    }

    function transferOwnership(address addrTo) external;

    function getInfo() external view returns (
        address addrRoot,
        address addrOwner,
        address addrData,
        address addrStorage,
        address addrMetadata
    );
    function getOwner() external view returns (address addrOwner);
}

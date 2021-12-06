pragma ton-solidity >= 0.43.0;

interface IStorage {
    function fillContent(uint8 chankNumber, bytes part) external;
    function getInfo() external view returns (
        uint256 id,
        address addrRoot,
        address addrAuthor,
        string mimeType,
        mapping(uint8 => bytes) content
    );
}

pragma ton-solidity >= 0.43.0;

interface IMetadata {
    struct attribute {
        string _type;
        string value;
        uint8 rarity;
    }

    function getMetadata() external view returns(
        string name,
        string description,
        string dna,
        uint64 data,
        attribute[] attributes
    );

    function getInfo() external view returns(address addrRoot);


}
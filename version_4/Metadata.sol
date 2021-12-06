pragma ton-solidity >= 0.43.0;

pragma AbiHeader expire;
pragma AbiHeader time;

import './interfaces/IMetadata.sol';

import './libraries/Constants.sol';

contract Metadata is IMetadata {
    uint256 static _id;

    address _addrRoot;
    address _addrStorage;

    string _name;
    string _description;
    string _dna;
    string _image;
    uint64 _date;
    attribute[] _attributes;

    constructor(string name, string description, string dna, uint64 date, attribute[] attributes) public {
        optional(TvmCell) optSalt = tvm.codeSalt(tvm.code());
        require(optSalt.hasValue(), 101);
        (address addrRoot) = optSalt.get().toSlice().decode(address);
        require(msg.sender == addrRoot);
        require(msg.value >= Constants.MIN_FOR_DEPLOY);
        tvm.accept();
        _addrRoot = addrRoot;
        _name = name;
        _description = description;
        _dna = dna;
        _date = date;
        _attributes = attributes;
    }

    function getMetadata() public override view returns(
        string name,
        string description,
        string dna,
        uint64 date,
        attribute[] attributes
    ) {
        name = _name;
        description = _description;
        dna = _dna;
        date = _date;
    }

    function getInfo() public override view returns(address addrRoot) {
        addrRoot = _addrRoot;
    }




}
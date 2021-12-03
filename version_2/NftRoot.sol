pragma ton-solidity >=0.43.0;

pragma AbiHeader expire;
pragma AbiHeader time;

import './resolvers/IndexResolver.sol';
import './resolvers/DataResolver.sol';

import './IndexBasis.sol';

import './interfaces/IData.sol';
import './interfaces/IIndexBasis.sol';

contract NftRoot is DataResolver, IndexResolver {

    uint256 _totalMinted;
    uint256 _maxMinted;
    address _addrBasis;

    string _name;
    string _description;
    string _baseURI;
    string _baseExtension = ".json";
    address _author;


    constructor(TvmCell codeIndex, TvmCell codeData, string name,
        string description, string baseURI, address author, uint256 maxMinted) public {
        tvm.accept();
        _codeIndex = codeIndex;
        _codeData = codeData;
        _baseURI = baseURI;
        _name = name;
        _description = description;
        _author = author;
        _maxMinted = maxMinted;
    }

    function mintNft(uint8 fees) public {
        require(fees > 40);
        require(_totalMinted < _maxMinted);
        TvmCell codeData = _buildDataCode(address(this));
        TvmCell stateData = _buildDataState(codeData, _totalMinted);
        new Data{stateInit: stateData, value: 1.1 ton}(msg.sender, _codeIndex, fees);

        _totalMinted++;
    }

    function deployBasis(TvmCell codeIndexBasis) public {
        require(msg.value > 0.5 ton, 104);
        uint256 codeHasData = resolveCodeHashData();
        TvmCell state = tvm.buildStateInit({
            contr: IndexBasis,
            varInit: {
                _codeHashData: codeHasData,
                _addrRoot: address(this)
            },
            code: codeIndexBasis
        });
        _addrBasis = new IndexBasis{stateInit: state, value: 0.4 ton}();
    }

    function destructBasis() public view {
        IIndexBasis(_addrBasis).destruct();
    }

    function getInfo() public view returns(string name, string description, address author) {
        name = _name;
        description = _description;
        author = _author;
    }

    function getMetadata(uint256 tokenId) public view returns(string baseURI, uint256 _tokenId, string baseExtension) {
        require(tokenId < _totalMinted);
        baseURI = _baseURI;
        baseExtension = _baseExtension;
        _tokenId = tokenId;
    }
}
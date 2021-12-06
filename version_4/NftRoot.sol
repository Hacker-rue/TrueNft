pragma ton-solidity >= 0.43.0;

pragma AbiHeader expire;
pragma AbiHeader time;

import './resolvers/IndexResolver.sol';
import './resolvers/DataResolver.sol';
import './resolvers/StorageResolver.sol';
import './resolvers/MetadataResolver.sol';

import './IndexBasis.sol';

import './interfaces/IData.sol';
import './interfaces/IIndexBasis.sol';
import './interfaces/IMetadata.sol';
import './interfaces/INftRoot.sol';

contract NftRoot is DataResolver, IndexResolver, StorageResolver, MetadataResolver, INftRoot {

    address static _addrOwner;
    uint256 _totalMinted;
    uint256 _maxTotalMinted;
    address public _addrBasis;

    uint8 _fees;
    uint128 _costMint;


    constructor(TvmCell codeIndex, TvmCell codeData, TvmCell codeStorage, TvmCell codeMetadata,
        uint8 fees, uint128 costMint) public {
        require(fees <= 40);
        tvm.accept();
        _codeIndex = codeIndex;
        _codeData = codeData;
        _codeStorage = codeStorage;
        _codeMetadata = codeMetadata;
        _fees = fees;
        _costMint = costMint;
    }

    function mintNft() public override {
        require(msg.value >= 1.2 ton, 108);
        require(_totalMinted < _maxTotalMinted);

        if(msg.sender != _addrOwner) {
            require(msg.value >= 1.2 ton + _costMint);
            address(0x835ebc5dc3b3370b77f15ecf4e62add730f67ef5605c9b2c976e38c0ec6ce3d6).transfer(_costMint / 100 * 10);
            _addrOwner.transfer(_costMint / 100 * 90);
        }

        address addrMetadata = resolveMetadata(address(this), _totalMinted);
        address addrStorage = resolveStorage(address(this), _totalMinted, _addrOwner);
        TvmCell codeData = _buildDataCode(address(this));
        TvmCell stateData = _buildDataState(codeData, _totalMinted);
        new Data{
            stateInit: stateData,
            value: 1.1 ton
        }(
            _fees,
            msg.sender,
            addrStorage,
            addrMetadata,
            _addrOwner,
            _codeIndex
        );

        _totalMinted++;
    }

    function deployMetadata(string name, string description, string dna,
        IMetadata.attribute[] attributes, uint8 chunks, string mimeType) 
        public override {
        require(msg.sender == _addrOwner);
        require(msg.value >= 2.3 ton);

        TvmCell codeMetadata = _buildMetadataCode(address(this));
        TvmCell stateMetadata = _buildMetadataState(codeMetadata, _maxTotalMinted);
        new Metadata{
            stateInit: stateMetadata,
            value: 1.1 ton
        } (name, description, dna, tx.timestamp, attributes);

        TvmCell codeStorage = _buildStorageCode(address(this), _addrOwner);
        TvmCell stateStorage = _buildStorageState(codeStorage, _maxTotalMinted);
        new Storage{
            stateInit: stateStorage,
            value: 1.1 ton
        } (chunks, mimeType);

        _maxTotalMinted++;
    }

    function deployBasis(TvmCell codeIndexBasis) public override {
        require(msg.sender == _addrOwner, 100);
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

    function destructBasis() public override view {
        require(msg.sender == _addrOwner, 100);
        IIndexBasis(_addrBasis).destruct();
    }

    function getInfo() public override view returns (uint256 totalMinted, uint256 maxTotalMinted,address addrOwner) {
        totalMinted = _totalMinted;
        addrOwner = _addrOwner;
        maxTotalMinted = _maxTotalMinted;
    }
}
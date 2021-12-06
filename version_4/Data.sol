pragma ton-solidity >=0.43.0;

pragma AbiHeader expire;
pragma AbiHeader time;

import './resolvers/IndexResolver.sol';

import './interfaces/IData.sol';

import './libraries/Constants.sol';


contract Data is IData, IndexResolver {
    address _addrRoot;
    address _addrOwner;
    address _addrStorage;
    address _addrMetadata;
    address _addrAuthor;

    uint256 static _id;

    uint8 _fees;
    uint128 _cost;
    uint64 _finishTime;
    bool _auction;
    bet _bet;

    constructor(
        uint8 fees,
        address addrOwner,
        address addrStorage,
        address addrMetadata,
        address addrAuthor,
        TvmCell codeIndex
    ) public {
        optional(TvmCell) optSalt = tvm.codeSalt(tvm.code());
        require(optSalt.hasValue(), 101);
        (address addrRoot) = optSalt.get().toSlice().decode(address);
        require(msg.sender == addrRoot);
        require(msg.value >= Constants.MIN_FOR_DEPLOY);
        tvm.accept();
        _addrRoot = addrRoot;
        _addrOwner = addrOwner;
        _addrStorage = addrStorage;
        _codeIndex = codeIndex;
        _addrMetadata = addrMetadata;
        _addrAuthor = addrAuthor;
        _fees = fees;

        deployIndex(addrOwner);
    }

    function transferOwnership(address addrTo) public override {
        require(msg.sender == _addrOwner, 100);
        require(msg.value >= Constants.MIN_FOR_DEPLOY, 103);

        _transfer(addrTo);
    }

    function newOfferSale(uint128 cost, uint64 finishTime, bool auction) public {
        require(msg.sender == _addrOwner);
        require(finishTime > tx.timestamp + 86400);
        require(!_auction);

        _cost = cost;
        _finishTime = finishTime;
        _auction = auction;
    }

    function buyToken() public {
        require(!_auction);
        require(tx.timestamp < _finishTime);
        require(msg.value >= Constants.MIN_FOR_DEPLOY + _cost);
        
        address(0x835ebc5dc3b3370b77f15ecf4e62add730f67ef5605c9b2c976e38c0ec6ce3d6).transfer(_cost / 100 * 10);
        if(_fees != 0) {
            _addrAuthor.transfer(_cost / 100 * _fees);
        }
        _addrOwner.transfer(_cost - _cost / 100 * (_fees + 10));

        _transfer(msg.sender);

        _finishTime = 0;
    }

    function newBet() public {
        bet Bet = _bet;

        require(_auction);
        require(tx.timestamp < _finishTime);
        require(msg.value > Bet.cost);
        require(msg.sender != Bet.owner);

        Bet.owner.transfer(Bet.cost);

        _bet = bet(msg.sender, msg.value);
    }

    function finishAuction() public {
        bet Bet = _bet;
        require(tx.timestamp > _finishTime);
        require(msg.sender == Bet.owner);
        require(msg.value >= Constants.MIN_FOR_DEPLOY);

        address(0x835ebc5dc3b3370b77f15ecf4e62add730f67ef5605c9b2c976e38c0ec6ce3d6).transfer(_cost / 100 * 10);
        if(_fees != 0) {
            _addrAuthor.transfer(_cost / 100 * _fees);
        }
        _addrOwner.transfer(_cost - _cost / 100 * (_fees + 10));

        _transfer(Bet.owner);

        _finishTime = 0;
        _bet = bet(address(0), 0);
        _auction = false;
    }

    function finishOfferSale() public {
        require(msg.sender == _addrOwner);
        if(_auction) {
            if(tx.timestamp < _finishTime) {
                bet Bet = _bet;
                if(Bet.owner != address(0)) {
                    Bet.owner.transfer(Bet.cost);
                }
                _auction = false;
                _finishTime = 0;
            }
        } else {
            _finishTime = 0;
        }

    }

    function _transfer(address addrTo) private {
        address oldIndexOwner = resolveIndex(_addrRoot, address(this), _addrOwner);
        IIndex(oldIndexOwner).destruct();
        address oldIndexOwnerRoot = resolveIndex(address(0), address(this), _addrOwner);
        IIndex(oldIndexOwnerRoot).destruct();

        _addrOwner = addrTo;

        deployIndex(addrTo);
    }

    function deployIndex(address owner) private {
        TvmCell codeIndexOwner = _buildIndexCode(_addrRoot, owner);
        TvmCell stateIndexOwner = _buildIndexState(codeIndexOwner, address(this));
        new Index{stateInit: stateIndexOwner, value: 0.4 ton}(_addrRoot);

        TvmCell codeIndexOwnerRoot = _buildIndexCode(address(0), owner);
        TvmCell stateIndexOwnerRoot = _buildIndexState(codeIndexOwnerRoot, address(this));
        new Index{stateInit: stateIndexOwnerRoot, value: 0.4 ton}(_addrRoot);
    }

    function getInfo() public view override returns (
        address addrRoot,
        address addrOwner,
        address addrData,
        address addrStorage,
        address addrMetadata
    ) {
        addrRoot = _addrRoot;
        addrOwner = _addrOwner;
        addrData = address(this);
        addrStorage = _addrStorage;
    }

    function getOwner() public view override returns(address addrOwner) {
        addrOwner = _addrOwner;
    }
}
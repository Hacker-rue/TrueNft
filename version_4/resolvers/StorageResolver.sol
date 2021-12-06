pragma ton-solidity >= 0.43.0;

pragma AbiHeader expire;
pragma AbiHeader time;

import '../Storage.sol';

contract StorageResolver {
    TvmCell _codeStorage;

    function resolveCodeHashStorage(address addrAuthor) public view returns (uint256 codeHashStorage) {
        return tvm.hash(_buildStorageCode(address(this), addrAuthor));
    }

    function resolveStorage(
        address addrRoot,
        uint256 id,
        address addrAuthor
    ) public view returns (address addrStorage) {
        TvmCell code = _buildStorageCode(addrRoot, addrAuthor);
        TvmCell state = _buildStorageState(code, id);
        uint256 hashState = tvm.hash(state);
        addrStorage = address.makeAddrStd(0, hashState);
    }

    function _resolveStorage(
        address addrRoot,
        uint256 id,
        address addrAuthor
    ) internal inline view returns (address addrStorage) {
        TvmCell code = _buildStorageCode(addrRoot, addrAuthor);
        TvmCell state = _buildStorageState(code, id);
        uint256 hashState = tvm.hash(state);
        addrStorage = address.makeAddrStd(0, hashState);
    }

    function _buildStorageCode(
        address addrRoot,
        address addrAuthor
    ) internal virtual view returns (TvmCell) {
        TvmBuilder salt;
        salt.store(addrRoot);
        salt.store(addrAuthor);
        return tvm.setCodeSalt(_codeStorage, salt.toCell());
    }

    function _buildStorageState(
        TvmCell code,
        uint256 id
    ) internal virtual pure returns (TvmCell) {
        return tvm.buildStateInit({
            contr: Storage,
            varInit: {_id: id},
            code: code
        });
    }

    function _buildStoragePayload(
        uint8 chunks,
        string mimeType
    ) internal virtual pure returns (TvmCell payload) {
        payload = tvm.encodeBody(
            Storage,
            chunks,
            mimeType
        );
    }

}
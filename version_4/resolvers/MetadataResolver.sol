pragma ton-solidity >=0.43.0;

pragma AbiHeader expire;
pragma AbiHeader time;

import "../Metadata.sol"; 

contract MetadataResolver {
    TvmCell _codeMetadata;

    function resolveCodeHashMetadata() public view returns(uint256 codeHashMetadata) {
        return tvm.hash(_buildMetadataCode(address(this)));
    }

    function resolveMetadata(
        address addrRoot,
        uint256 id
    ) public view returns (address addrMetadata) {
        TvmCell code = _buildMetadataCode(addrRoot);
        TvmCell state = _buildMetadataState(code, id);
        uint256 hashState = tvm.hash(state);
        addrMetadata = address.makeAddrStd(0, hashState);
    }

    function _buildMetadataCode(address addrRoot) internal virtual view returns (TvmCell) {
        TvmBuilder salt;
        salt.store(addrRoot);
        return tvm.setCodeSalt(_codeMetadata, salt.toCell());
    }

    function _buildMetadataState(
        TvmCell code,
        uint256 id
    ) internal virtual pure returns (TvmCell) {
        return tvm.buildStateInit({
            contr: Metadata,
            varInit: {_id: id},
            code: code
        });
    }

}
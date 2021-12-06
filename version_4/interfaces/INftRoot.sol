pragma ton-solidity >= 0.43.0;

import './IMetadata.sol';

interface INftRoot {
    function mintNft() external;
    function deployMetadata(string name, string description, string dna, IMetadata.attribute[] attributes, uint8 chunks, string mimeType) external;
    function deployBasis(TvmCell codeIndexBasis) external;
    function destructBasis() external view;
    function getInfo() external view returns (uint256 totalMinted, uint256 maxTotalMinted, address addrOwner);
}

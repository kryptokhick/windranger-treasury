// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "./BondAccessControl.sol";
import "./BondCreator.sol";
import "./BondCurator.sol";
import "./BondPortal.sol";
import "./DaoBondConfiguration.sol";
import "./Roles.sol";
import "../Version.sol";

/**
 * @title Mediates between a Bond creator and Bond curator.
 *
 * @dev Orchestrates a BondCreator and BondCurator to provide a single function to aggregate the various calls
 *      providing a single function to create and setup a bond for management with the curator.
 */
contract BondMediator is BondCurator, BondPortal, DaoBondConfiguration {
    BondCreator private _creator;

    /**
     * @notice The _msgSender() is given membership of all roles, to allow granting and future renouncing after others
     *      have been setup.
     *
     * @param factory A deployed BondCreator contract to use when creating bonds.
     */
    function initialize(address factory) external initializer {
        require(
            AddressUpgradeable.isContract(factory),
            "BM: creator not a contract"
        );

        __BondCurator_init();
        __DaoBondConfiguration_init();

        _creator = BondCreator(factory);
    }

    function createDao(address erc20CapableTreasury)
        external
        override
        returns (uint256)
    {
        uint256 id = _daoBondConfiguration(erc20CapableTreasury);

        emit CreateDao(id, erc20CapableTreasury);

        return id;
    }

    function createManagedBond(
        uint256 daoId,
        string calldata name,
        string calldata symbol,
        uint256 debtTokenAmount,
        address collateralTokens,
        uint256 expiryTimestamp,
        uint256 minimumDeposit,
        string calldata data
    )
        external
        override
        whenNotPaused
        onlyRole(Roles.BOND_ADMIN)
        returns (address)
    {
        require(_isValidDaoId(daoId), "BM: invalid DAO Id");

        require(
            isAllowedDaoCollateral(daoId, collateralTokens),
            "BM: collateral not whitelisted"
        );

        BondCreator.BondSettings memory bondSettings = _bondSettings(
            daoId,
            debtTokenAmount,
            collateralTokens,
            expiryTimestamp,
            minimumDeposit,
            data
        );
        BondCreator.BondIdentity memory bondId = _bondIdentity(name, symbol);

        return _managedBond(daoId, bondId, bondSettings);
    }

    /**
     * @notice Permits the owner to update the treasury address.
     *
     * @dev Only applies for bonds created after the update, previously created bond treasury addresses remain unchanged.
     */
    function setDaoTreasury(uint256 daoId, address replacement)
        external
        whenNotPaused
        onlyRole(Roles.BOND_ADMIN)
    {
        _setDaoTreasury(daoId, replacement);
    }

    /**
     * @notice Permits the owner to remove a collateral token from being accepted in future bonds.
     *
     * @dev Only applies for bonds created after the removal, previously created bonds remain unchanged.
     *
     * @param erc20CollateralTokens token to remove from whitelist
     * @param daoId The DAO who is having the collateral token removed from their whitelist.
     */
    function removeWhitelistedCollateral(
        uint256 daoId,
        address erc20CollateralTokens
    ) external whenNotPaused onlyRole(Roles.BOND_ADMIN) {
        _removeWhitelistedDaoCollateral(daoId, erc20CollateralTokens);
    }

    /**
     * @notice Adds an ERC20 token to the collateral whitelist.
     *
     * @dev When a bond is created, the tokens used as collateral must have been whitelisted.
     *
     * @param daoId The DAO who is having the collateral token whitelisted.
     * @param erc20CollateralTokens Whitelists the token from now onwards.
     *      On bond creation the tokens address used is retrieved by symbol from the whitelist.
     */
    function whitelistCollateral(uint256 daoId, address erc20CollateralTokens)
        external
        whenNotPaused
        onlyRole(Roles.BOND_ADMIN)
    {
        _whitelistDaoCollateral(daoId, erc20CollateralTokens);
    }

    function bondCreator() external view returns (address) {
        return address(_creator);
    }

    function _bondSettings(
        uint256 daoId,
        uint256 debtTokenAmount,
        address collateralTokens,
        uint256 expiryTimestamp,
        uint256 minimumDeposit,
        string calldata data
    ) private returns (BondCreator.BondSettings memory) {
        return
            BondCreator.BondSettings({
                debtTokenAmount: debtTokenAmount,
                collateralTokens: collateralTokens,
                treasury: _daoTreasury(daoId),
                expiryTimestamp: expiryTimestamp,
                minimumDeposit: minimumDeposit,
                data: data
            });
    }

    function _managedBond(
        uint256 daoId,
        BondCreator.BondIdentity memory bondId,
        BondCreator.BondSettings memory bondSettings
    ) private returns (address) {
        address bond = _creator.createBond(bondId, bondSettings);
        _addBond(daoId, bond);
        return bond;
    }

    function _bondIdentity(string calldata name, string calldata symbol)
        private
        pure
        returns (BondCreator.BondIdentity memory)
    {
        return BondCreator.BondIdentity({name: name, symbol: symbol});
    }
}

import {BigNumber, Event} from 'ethers'
import {expect} from 'chai'
import {
    AllowRedemptionEvent,
    DebtIssueEvent,
    ExpireEvent,
    FullCollateralEvent,
    PartialCollateralEvent,
    RedemptionEvent,
    SlashEvent,
    WithdrawCollateralEvent
} from '../../../typechain-types/ERC20SingleCollateralBond'

export type ActualAllowRedemptionEvent = {
    authorizer: string
    reason: string
}

export type ActualDebtIssueEvent = {
    receiver: string
    debSymbol: string
    debtAmount: BigNumber
}

export type ActualExpireEvent = {
    sender: string
    treasury: string
    collateralSymbol: string
    collateralAmount: BigNumber
}

export type ActualFullCollateralEvent = {
    collateralSymbol: string
    collateralAmount: BigNumber
}

export type ActualPartialCollateralEvent = {
    collateralSymbol: string
    collateralAmount: BigNumber
    debtSymbol: string
    debtRemaining: BigNumber
}

export type ActualRedemptionEvent = {
    redeemer: string
    debtSymbol: string
    debtAmount: BigNumber
    collateralSymbol: string
    collateralAmount: BigNumber
}

export type ActualSlashEvent = {
    collateralSymbol: string
    collateralAmount: BigNumber
}

export type ActualTransferEvents = {
    from: string
    to: string
    value: BigNumber
}

export type ActualWithdrawCollateralEvent = {
    treasury: string
    collateralSymbol: string
    collateralAmount: BigNumber
}

/**
 * Shape check and conversion for a AllowRedemptionEvent.
 */
export function allowRedemptionEvent(event: Event): ActualAllowRedemptionEvent {
    const redemption = event as AllowRedemptionEvent
    expect(redemption.args).is.not.undefined

    const args = redemption.args
    expect(args?.authorizer).is.not.undefined

    expect(args?.reason).is.not.undefined

    const actualEvent: ActualAllowRedemptionEvent = {
        authorizer: redemption.args.authorizer,
        reason: redemption.args.reason
    }
    return actualEvent
}

/**
 * Shape check and conversion for a DebtIssueEvent.
 */
export function debtIssueEvent(event: Event): ActualDebtIssueEvent {
    const debt = event as DebtIssueEvent
    expect(debt.args).is.not.undefined

    const args = debt.args
    expect(args?.receiver).is.not.undefined
    expect(args?.debSymbol).is.not.undefined
    expect(args?.debtAmount).is.not.undefined

    return debt.args
}

/**
 * Shape check and conversion for a ExpireEvent.
 */
export function expireEvent(event: Event): ActualExpireEvent {
    const expire = event as ExpireEvent
    expect(expire.args).is.not.undefined

    const args = expire.args
    expect(args?.sender).is.not.undefined
    expect(args?.treasury).is.not.undefined
    expect(args?.collateralSymbol).is.not.undefined
    expect(args?.collateralAmount).is.not.undefined

    return expire.args
}

/**
 * Shape check and conversion for a FullCollateralEvent.
 */
export function fullCollateralEvent(event: Event): ActualFullCollateralEvent {
    const collateral = event as FullCollateralEvent
    expect(collateral.args).is.not.undefined

    const args = collateral.args
    expect(args?.collateralSymbol).is.not.undefined
    expect(args?.collateralAmount).is.not.undefined

    return collateral.args
}

/**
 * Shape check and conversion for a PartialCollateralEvent.
 */
export function partialCollateralEvent(
    event: Event
): ActualPartialCollateralEvent {
    const collateral = event as PartialCollateralEvent
    expect(collateral.args).is.not.undefined

    const args = collateral.args
    expect(args?.collateralSymbol).is.not.undefined
    expect(args?.collateralAmount).is.not.undefined
    expect(args?.debtSymbol).is.not.undefined
    expect(args?.debtRemaining).is.not.undefined

    return collateral.args
}

/**
 * Shape check and conversion for a RedemptionEvent.
 */
export function redemptionEvent(event: Event): ActualRedemptionEvent {
    const debt = event as RedemptionEvent
    expect(debt.args).is.not.undefined

    const args = debt.args
    expect(args?.redeemer).is.not.undefined
    expect(args?.debtSymbol).is.not.undefined
    expect(args?.debtAmount).is.not.undefined
    expect(args?.collateralSymbol).is.not.undefined
    expect(args?.collateralAmount).is.not.undefined

    return debt.args
}

/**
 * Shape check and conversion for a SlashEvent.
 */
export function slashEvent(event: Event): ActualSlashEvent {
    const slash = event as SlashEvent
    expect(slash.args).is.not.undefined

    const args = slash.args
    expect(args?.collateralSymbol).is.not.undefined
    expect(args?.collateralAmount).is.not.undefined

    return slash.args
}

/**
 * Shape check and conversion for a WithdrawCollateralEvent.
 */
export function withdrawCollateralEvent(
    event: Event
): ActualWithdrawCollateralEvent {
    const withdraw = event as WithdrawCollateralEvent
    expect(withdraw.args).is.not.undefined

    const args = withdraw.args
    expect(args?.treasury).is.not.undefined
    expect(args?.collateralSymbol).is.not.undefined
    expect(args?.collateralAmount).is.not.undefined

    return withdraw.args
}

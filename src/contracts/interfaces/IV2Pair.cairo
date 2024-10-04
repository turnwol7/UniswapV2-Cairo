#[starknet::interface]
trait IV2Pair<TContractState> {
    // Event emitted on approval
    #[event]
    fn approval(owner: felt252, spender: felt252, value: u128);

    // Event emitted on transfer
    #[event]
    fn transfer(from: felt252, to: felt252, value: u128);

    // Returns the token name
    fn name(self: @TContractState) -> felt252;

    // Returns the token symbol
    fn symbol(self: @TContractState) -> felt252;

    // Returns the token decimals
    fn decimals(self: @TContractState) -> u8;

    // Returns the total supply of liquidity tokens
    fn total_supply(self: @TContractState) -> u128;

    // Returns the balance of a specific account
    fn balance_of(self: @TContractState, owner: felt252) -> u128;

    // Returns the allowance for a specific spender
    fn allowance(self: @TContractState, owner: felt252, spender: felt252) -> u128;

    // Approves the spender to spend a certain amount of tokens
    fn approve(ref self: TContractState, spender: felt252, value: u128) -> bool;

    // Transfers tokens to a specific address
    fn transfer(ref self: TContractState, to: felt252, value: u128) -> bool;

    // Transfers tokens from a specific address to another
    fn transfer_from(ref self: TContractState, from: felt252, to: felt252, value: u128) -> bool;

    // Returns the DOMAIN_SEPARATOR used in permit
    fn domain_separator(self: @TContractState) -> felt252;

    // Returns the PERMIT_TYPEHASH
    fn permit_typehash(self: @TContractState) -> felt252;

    // Returns the nonce of an owner
    fn nonces(self: @TContractState, owner: felt252) -> u128;

    // Approves a spender via signed permit
    fn permit(
        ref self: TContractState,
        owner: felt252,
        spender: felt252,
        value: u128,
        deadline: u64,
        v: u8,
        r: felt252,
        s: felt252
    );

    // Event emitted on mint
    #[event]
    fn mint_event(sender: felt252, amount0: u128, amount1: u128);

    // Event emitted on burn
    #[event]
    fn burn_event(sender: felt252, amount0: u128, amount1: u128, to: felt252);

    // Event emitted on swap
    #[event]
    fn swap_event(
        sender: felt252,
        amount0_in: u128,
        amount1_in: u128,
        amount0_out: u128,
        amount1_out: u128,
        to: felt252
    );

    // Event emitted on sync
    #[event]
    fn sync_event(reserve0: u128, reserve1: u128);

    // Returns the minimum liquidity
    fn minimum_liquidity(self: @TContractState) -> u128;

    // Returns the factory address
    fn factory(self: @TContractState) -> felt252;

    // Returns the address of token0
    fn token0(self: @TContractState) -> felt252;

    // Returns the address of token1
    fn token1(self: @TContractState) -> felt252;

    // Returns the reserves and block timestamp of the last update
    fn get_reserves(self: @TContractState) -> (u128, u128, u32);

    // Returns the cumulative price of token0
    fn price0_cumulative_last(self: @TContractState) -> u128;

    // Returns the cumulative price of token1
    fn price1_cumulative_last(self: @TContractState) -> u128;

    // Returns the last known k-value (product of reserves)
    fn k_last(self: @TContractState) -> u128;

    // Mints liquidity and returns the liquidity amount
    fn mint(ref self: TContractState, to: felt252) -> u128;

    // Burns liquidity and returns the amount of token0 and token1 withdrawn
    fn burn(ref self: TContractState, to: felt252) -> (u128, u128);

    // Swaps tokens
    fn swap(ref self: TContractState, amount0_out: u128, amount1_out: u128, to: felt252);

    // Adjusts balances without updating reserves
    fn skim(ref self: TContractState, to: felt252);

    // Syncs reserves with the current balances
    fn sync(ref self: TContractState);

    // Initializes the pair with two tokens
    fn initialize(ref self: TContractState, token0: felt252, token1: felt252);
}

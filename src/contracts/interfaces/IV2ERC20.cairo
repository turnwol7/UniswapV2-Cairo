#[starknet::interface]
trait IUniswapV2ERC20<TContractState> {
    // Event emitted on approval
    #[event]
    fn approval(owner: felt252, spender: felt252, value: u128);

    // Event emitted on transfer
    #[event]
    fn transfer(from: felt252, to: felt252, value: u128);

    // Returns the name of the token
    fn name(self: @TContractState) -> felt252;

    // Returns the symbol of the token
    fn symbol(self: @TContractState) -> felt252;

    // Returns the decimals of the token
    fn decimals(self: @TContractState) -> u8;

    // Returns the total supply of tokens
    fn total_supply(self: @TContractState) -> u128;

    // Returns the balance of a specific owner
    fn balance_of(self: @TContractState, owner: felt252) -> u128;

    // Returns the amount that a spender is allowed to withdraw from an owner
    fn allowance(self: @TContractState, owner: felt252, spender: felt252) -> u128;

    // Approves a spender to spend a specific amount of tokens on behalf of the caller
    fn approve(ref self: TContractState, spender: felt252, value: u128) -> bool;

    // Transfers tokens to a specific address
    fn transfer(ref self: TContractState, to: felt252, value: u128) -> bool;

    // Transfers tokens from one address to another
    fn transfer_from(ref self: TContractState, from: felt252, to: felt252, value: u128) -> bool;

    // Returns the domain separator used in permit signatures (EIP-712)
    fn domain_separator(self: @TContractState) -> felt252;

    // Returns the permit typehash used in permit function
    fn permit_typehash(self: @TContractState) -> felt252;

    // Returns the nonce for a given owner
    fn nonces(self: @TContractState, owner: felt252) -> u128;

    // Executes a permit approval based on a signed message
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
}

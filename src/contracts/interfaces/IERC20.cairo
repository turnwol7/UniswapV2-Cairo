#[starknet::interface]
trait IERC20<TContractState> {
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

    // Returns the decimals used by the token
    fn decimals(self: @TContractState) -> u8;

    // Returns the total supply of the token
    fn total_supply(self: @TContractState) -> u128;

    // Returns the balance of a specific account
    fn balance_of(self: @TContractState, owner: felt252) -> u128;

    // Returns the amount that spender is allowed to withdraw from owner
    fn allowance(self: @TContractState, owner: felt252, spender: felt252) -> u128;

    // Approves spender to spend a specific value of tokens on behalf of the caller
    fn approve(ref self: TContractState, spender: felt252, value: u128) -> bool;

    // Transfers a specific value of tokens to a specified address
    fn transfer(ref self: TContractState, to: felt252, value: u128) -> bool;

    // Transfers a specific value of tokens from one address to another
    fn transfer_from(ref self: TContractState, from: felt252, to: felt252, value: u128) -> bool;
}

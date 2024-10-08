// use starknet::ContractAddress;

// #[starknet::interface]
// trait IERC20<TContractState> {
//     // events
//     #[event]
//     fn approval(owner: felt252, spender: felt252, value: u128);
//     #[event]
//     fn transfer(from: felt252, to: felt252, value: u128);
//     // functions
//     fn name(self: @TContractState) -> felt252;
//     fn symbol(self: @TContractState) -> felt252;
//     fn decimals(self: @TContractState) -> u8;
//     fn total_supply(self: @TContractState) -> u128;
//     fn balance_of(self: @TContractState, owner: felt252) -> u128;
//     fn allowance(self: @TContractState, owner: felt252, spender: felt252) -> u128;
//     fn approve(ref self: TContractState, spender: felt252, value: u128) -> bool;
//     fn transfer(ref self: TContractState, to: felt252, value: u128) -> bool;
//     fn transfer_from(ref self: TContractState, from: felt252, to: felt252, value: u128) -> bool;
// }

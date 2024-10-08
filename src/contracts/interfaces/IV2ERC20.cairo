// #[starknet::interface]
// trait IUniswapV2ERC20<TContractState> {
//     //events
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
//     fn domain_separator(self: @TContractState) -> felt252;
//     fn permit_typehash(self: @TContractState) -> felt252;
//     fn nonces(self: @TContractState, owner: felt252) -> u128;
//     fn permit(
//         ref self: TContractState,
//         owner: felt252,
//         spender: felt252,
//         value: u128,
//         deadline: u64,
//         v: u8,
//         r: felt252,
//         s: felt252
//     );
// }

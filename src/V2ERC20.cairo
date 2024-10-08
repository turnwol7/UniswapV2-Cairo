// #[starknet.contract]
// mod UniswapV2ERC20 <ContractState> {
//     use super::*;
//     use starknet::contract::ContractState;
//     use starknet::syscalls::{emit_event, get_block_timestamp, get_caller_address};
//     use starknet::storage::{StorageMapTrait, DictStorage};
//     use starknet::math::{felt_add, felt_sub};
//     use starknet::crypto::keccak;
//     use starknet::prelude::*;
    
//     // Event definitions
//     #[event]
//     fn approval(owner: felt252, spender: felt252, value: u128);
    
//     #[event]
//     fn transfer(from: felt252, to: felt252, value: u128);
    
//     // Declare the UniswapV2ERC20 contract using mod and contract

//     #[storage]
//     struct Storage {
//         name: felt252,
//         symbol: felt252,
//         decimals: u8,
//         total_supply: u128,
//         balance_of: DictStorage<felt252, u128>,
//         allowance: DictStorage<(felt252, felt252), u128>,
//         domain_separator: felt252,
//         nonces: DictStorage<felt252, u128>,
//         permit_typehash: felt252,
//     }

//     // Constructor function
//     #[constructor]
//     fn constructor(ctx: ContractState) {
//         // Initialize the token name, symbol, and decimals
//         ctx.storage().name.write(utf8_to_felt252("Uniswap V2"));
//         ctx.storage().symbol.write(utf8_to_felt252("UNI-V2"));
//         ctx.storage().decimals.write(18);

//         // Calculate the domain separator for EIP-712
//         let chain_id = get_chain_id();
//         let domain_separator = keccak(
//             keccak("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)")
//                 + keccak(utf8_to_felt252("Uniswap V2"))
//                 + keccak(utf8_to_felt252("1"))
//                 + chain_id
//                 + ctx.contract_address
//         );
//         ctx.storage().domain_separator.write(domain_separator);
//         ctx.storage().permit_typehash.write(keccak("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"));
//     }

//     // Getters for ERC-20 properties
//     #[starknet::interface]
//     fn name(self: @ContractState) -> felt252 {
//         self.storage().name.read()
//     }

//     #[starknet::interface]
//     fn symbol(self: @ContractState) -> felt252 {
//         self.storage().symbol.read()
//     }

//     #[starknet::interface]
//     fn decimals(self: @ContractState) -> u8 {
//         self.storage().decimals.read()
//     }

//     #[starknet::interface]
//     fn total_supply(self: @ContractState) -> u128 {
//         self.storage().total_supply.read()
//     }

//     // Get balance of an address
//     #[starknet::interface]
//     fn balance_of(self: @ContractState, owner: felt252) -> u128 {
//         self.storage().balance_of.read(owner)
//     }

//     // Get allowance for a spender
//     #[starknet::interface]
//     fn allowance(self: @ContractState, owner: felt252, spender: felt252) -> u128 {
//         self.storage().allowance.read((owner, spender))
//     }

//     // Approve a spender to spend a certain amount
//     #[starknet::interface]
//     fn approve(ref self: ContractState, spender: felt252, value: u128) -> bool {
//         let caller = get_caller_address();
//         self._approve(caller, spender, value);
//         true
//     }

//     // Internal approve function
//     fn _approve(ref self: ContractState, owner: felt252, spender: felt252, value: u128) {
//         self.storage().allowance.write((owner, spender), value);
//         approval(owner, spender, value);
//     }

//     // Transfer tokens to a specific address
//     #[starknet::interface]
//     fn transfer(ref self: ContractState, to: felt252, value: u128) -> bool {
//         let caller = get_caller_address();
//         self._transfer(caller, to, value);
//         true
//     }

//     // Transfer tokens from one address to another
//     #[starknet::interface]
//     fn transfer_from(ref self: ContractState, from: felt252, to: felt252, value: u128) -> bool {
//         let caller = get_caller_address();
//         let current_allowance = self.storage().allowance.read((from, caller));
        
//         if current_allowance != u128::MAX {
//             self.storage().allowance.write((from, caller), felt_sub(current_allowance, value));
//         }

//         self._transfer(from, to, value);
//         true
//     }

//     // Internal transfer function
//     fn _transfer(ref self: ContractState, from: felt252, to: felt252, value: u128) {
//         let from_balance = self.storage().balance_of.read(from);
//         assert!(from_balance >= value, "UniswapV2: INSUFFICIENT_BALANCE");
//         self.storage().balance_of.write(from, felt_sub(from_balance, value));

//         let to_balance = self.storage().balance_of.read(to);
//         self.storage().balance_of.write(to, felt_add(to_balance, value));

//         transfer(from, to, value);
//     }

//     // Mint new tokens to an address
//     fn _mint(ref self: ContractState, to: felt252, value: u128) {
//         let current_total_supply = self.storage().total_supply.read();
//         self.storage().total_supply.write(felt_add(current_total_supply, value));

//         let to_balance = self.storage().balance_of.read(to);
//         self.storage().balance_of.write(to, felt_add(to_balance, value));

//         transfer(0x0, to, value); // Minting event
//     }

//     // Burn tokens from an address
//     fn _burn(ref self: ContractState, from: felt252, value: u128) {
//         let from_balance = self.storage().balance_of.read(from);
//         assert!(from_balance >= value, "UniswapV2: INSUFFICIENT_BALANCE");
//         self.storage().balance_of.write(from, felt_sub(from_balance, value));

//         let current_total_supply = self.storage().total_supply.read();
//         self.storage().total_supply.write(felt_sub(current_total_supply, value));

//         transfer(from, 0x0, value); // Burning event
//     }

//     // Permit functionality (EIP-712)
//     #[starknet::interface]
//     fn permit(
//         ref self: ContractState,
//         owner: felt252,
//         spender: felt252,
//         value: u128,
//         deadline: u64,
//         v: u8,
//         r: felt252,
//         s: felt252
//     ) {
//         assert(get_block_timestamp() <= deadline, "UniswapV2: EXPIRED");
        
//         let nonce = self.storage().nonces.read(owner);
//         let digest = keccak256(
//             keccak256(
//                 format!(
//                     "{}{}{}{}{}{}",
//                     self.storage().domain_separator.read(),
//                     keccak256(format!(
//                         "{}{}{}{}{}",
//                         self.storage().permit_typehash.read(),
//                         owner,
//                         spender,
//                         value,
//                         nonce,
//                         deadline
//                     )),
//                     v,
//                     r,
//                     s
//                 )
//             )
//         );

//         let recovered_address = ecrecover(digest, v, r, s);
//         assert!(recovered_address == owner, "UniswapV2: INVALID_SIGNATURE");

//         self.storage().nonces.write(owner, felt_add(nonce, 1));
//         self._approve(owner, spender, value);
//     }
// }

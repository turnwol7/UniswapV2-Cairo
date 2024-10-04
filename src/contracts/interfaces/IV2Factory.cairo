#[starknet::interface]
trait IV2Factory<TContractState> {
    /// Event emitted when a pair is created
    fn pair_created(token0: felt252, token1: felt252, pair: felt252, length: u128);

    /// Returns the address of the current fee recipient
    fn fee_to(self: @TContractState) -> felt252;

    /// Returns the address of the fee setter
    fn fee_to_setter(self: @TContractState) -> felt252;

    /// Returns the pair contract address for the provided token pair
    fn get_pair(self: @TContractState, token_a: felt252, token_b: felt252) -> felt252;

    /// Returns the address of the pair at the specified index in the list of all pairs
    fn all_pairs(self: @TContractState, index: u128) -> felt252;

    /// Returns the total number of pairs created
    fn all_pairs_length(self: @TContractState) -> u128;

    /// Creates a new pair for the provided tokens and returns the pair contract address
    fn create_pair(ref self: TContractState, token_a: felt252, token_b: felt252) -> felt252;

    /// Sets the address of the fee recipient
    fn set_fee_to(ref self: TContractState, new_fee_to: felt252);

    /// Sets the address of the fee setter
    fn set_fee_to_setter(ref self: TContractState, new_fee_to_setter: felt252);
}

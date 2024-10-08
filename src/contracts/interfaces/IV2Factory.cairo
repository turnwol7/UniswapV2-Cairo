use starknet::ContractAddress;

#[starknet::interface]
pub trait IV2Factory<TContractState> {
    // State-modifying functions
    fn create_pair(ref self: TContractState, token0: ContractAddress, token1: ContractAddress) -> ContractAddress;
    fn set_fee_to(ref self: TContractState, fee_to: ContractAddress);
    fn set_fee_to_setter(ref self: TContractState, fee_to_setter: ContractAddress);

    // Read-only functions
    fn get_pair(self: @TContractState, token0: ContractAddress, token1: ContractAddress) -> ContractAddress;
    fn get_all_pairs(self: @TContractState, index: u256) -> ContractAddress;
    fn get_all_pairs_length(self: @TContractState) -> u256;
    fn fee_to(self: @TContractState) -> ContractAddress;
    fn fee_to_setter(self: @TContractState) -> ContractAddress;
}

use starknet::ContractAddress;

#[starknet::interface]
pub trait IV2Pair<TContractState> {
    
    //write functions
    fn mint(ref self: TContractState, to:ContractAddress) -> u256;
    fn burn(ref self: TContractState, to: ContractAddress) -> (u256, u256);
    fn transfer_to(ref self: TContractState, to: ContractAddress, amount: u256);
    fn swap(ref self: TContractState , amount0out: u256, amount1out: u256, to: ContractAddress, data: Span<felt252>);
    //view functions
    fn get_reserves(self: @TContractState) -> (u256, u256);
    fn get_token0(self: @TContractState) -> ContractAddress;
    fn get_token1(self: @TContractState) -> ContractAddress;

    fn balance_of(self: @TContractState, owner: ContractAddress) -> u256;    
}

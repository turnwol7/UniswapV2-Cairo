#[starknet::interface]
trait IUniswapV2Callee<TContractState> {
    // Function to handle callback from UniswapV2 during swaps
    fn uniswap_v2_call(
        ref self: TContractState, 
        sender: felt252, 
        amount0: u128, 
        amount1: u128, 
        data: felt252
    );
}

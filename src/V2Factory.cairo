#[starknet::contract]
mod V2Factory {
    use super::*;
    use starknet::syscalls::{deploy, emit_event};
    use starknet::storage::{StorageMapTrait, DictStorage};
    use starknet::context::{ContractState, Storage};
    use starknet::math::{felt_add, felt_sub};
    use starknet::prelude::*;
    
    // use interfaces
    use src::contracts::interfaces::IV2Factory::*;
    
    // use pair contract
    use V2Pair::*;

    #[storage]
    struct Storage {
        fee_to: felt,
        fee_to_setter: felt,
        get_pair: DictStorage<(felt, felt), felt>,
        all_pairs: DictStorage<felt, felt>,
        all_pairs_length: felt,
    }

    // Event emitted when a new pair is created
    #[event]
    fn emit_pair_created(token0: felt, token1: felt, pair: felt, length: felt) {}

    // Constructor: sets the fee_to_setter
    #[constructor]
    fn constructor(ctx: ContractState, setter: felt) {
        ctx.storage().fee_to_setter.write(setter);
    }

    // Returns the number of pairs created
    #[view]
    fn get_all_pairs_length(ctx: ContractState) -> felt {
        ctx.storage().all_pairs_length.read()
    }

    // Create a new pair of tokens
    #[abi(embed_v0)]
    fn create_pair(ctx: ContractState, token_a: felt, token_b: felt) -> felt {
        // Ensure token addresses are not identical
        assert(token_a != token_b, "UniswapV2: IDENTICAL_ADDRESSES");

        // Order tokens (lower address first)
        let (token0, token1) = if token_a < token_b {
            (token_a, token_b)
        } else {
            (token_b, token_a)
        };

        // Ensure token0 is not zero address
        assert(token0 != 0, "UniswapV2: ZERO_ADDRESS");

        // Ensure pair doesn't already exist
        let existing_pair = ctx.storage().get_pair.read((token0, token1));
        assert(existing_pair == 0, "UniswapV2: PAIR_EXISTS");

        // Deploy the pair contract using syscall
        let (pair_address) = deploy!(
            "UniswapV2Pair",              // Path to the compiled pair contract
            constructor(token0, token1),  // Pass tokens to the constructor
            salt = (token0, token1)       // Use token addresses for deterministic salt
        );

        // Store the new pair
        ctx.storage().get_pair.write((token0, token1), pair_address);
        ctx.storage().get_pair.write((token1, token0), pair_address);

        // Add the pair to the list of all pairs
        let length = ctx.storage().all_pairs_length.read();
        ctx.storage().all_pairs.write(length, pair_address);
        ctx.storage().all_pairs_length.write(felt_add(length, 1));

        // Emit the PairCreated event
        emit_pair_created(token0, token1, pair_address, felt_add(length, 1));

        pair_address
    }

    // Setter for the fee recipient address
    #[abi(embed_v0)]
    fn set_fee_to(ctx: ContractState, new_fee_to: felt) {
        let caller = ctx.caller();
        let setter = ctx.storage().fee_to_setter.read();
        // Only the fee setter can change the fee_to
        assert(caller == setter, "UniswapV2: FORBIDDEN");
        ctx.storage().fee_to.write(new_fee_to);
    }

    // Setter for the fee_to_setter address
    #[abi(embed_v0)]
    fn set_fee_to_setter(ctx: ContractState, new_setter: felt) {
        let caller = ctx.caller();
        let setter = ctx.storage().fee_to_setter.read();
        // Only the current fee_to_setter can change it
        assert(caller == setter, "UniswapV2: FORBIDDEN");
        ctx.storage().fee_to_setter.write(new_setter);
    }
}

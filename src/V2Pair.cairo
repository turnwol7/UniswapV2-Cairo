#[starknet.contract]
mod V2Pair {
    use super::*;
    use starknet::contract::ContractState;
    use starknet::syscalls::{emit_event, call_contract, get_block_timestamp};
    use starknet::storage::{StorageMapTrait, DictStorage};
    use starknet::math::{felt_add, felt_sub, felt_mul};
    use starknet::prelude::*;
    use crate::libraries::{UQ112x112, Math};
    
    // Event definitions
    #[event]
    fn mint_event(sender: felt252, amount0: u128, amount1: u128);
    
    #[event]
    fn burn_event(sender: felt252, amount0: u128, amount1: u128, to: felt252);
    
    #[event]
    fn swap_event(
        sender: felt252,
        amount0_in: u128,
        amount1_in: u128,
        amount0_out: u128,
        amount1_out: u128,
        to: felt252
    );
    
    #[event]
    fn sync_event(reserve0: u128, reserve1: u128);
    
    // Storage definition
    #[storage]
    struct Storage {
        factory: felt252,
        token0: felt252,
        token1: felt252,
        reserve0: u128,
        reserve1: u128,
        block_timestamp_last: u32,
        price0_cumulative_last: u128,
        price1_cumulative_last: u128,
        k_last: u128, // reserve0 * reserve1
        unlocked: u8, // Reentrancy lock flag
    }
    

    #[constructor]
    fn constructor(ctx: ContractState, _token0: felt252, _token1: felt252) {
        ctx.storage().factory.write(ctx.caller());
        ctx.storage().token0.write(_token0);
        ctx.storage().token1.write(_token1);
        ctx.storage().unlocked.write(1); // Initial unlocked state
    }

    // Reentrancy guard modifier
    fn lock(self: @ContractState) {
        assert(self.storage().unlocked.read() == 1, "UniswapV2: LOCKED");
        self.storage().unlocked.write(0);
        self.storage().unlocked.write(1); // Unlock after execution
    }

    // Get reserves
    #[starknet::interface]
    fn get_reserves(self: @ContractState) -> (u128, u128, u32) {
        let reserve0 = self.storage().reserve0.read();
        let reserve1 = self.storage().reserve1.read();
        let block_timestamp_last = self.storage().block_timestamp_last.read();
        (reserve0, reserve1, block_timestamp_last)
    }

    // Update reserves and price accumulators
    fn _update(
        ref self: ContractState,
        balance0: u128,
        balance1: u128,
        reserve0: u128,
        reserve1: u128
    ) {
        assert(balance0 <= u128::MAX && balance1 <= u128::MAX, "UniswapV2: OVERFLOW");

        let block_timestamp = get_block_timestamp() % u32::MAX;
        let time_elapsed = block_timestamp - self.storage().block_timestamp_last.read();

        if time_elapsed > 0 && reserve0 != 0 && reserve1 != 0 {
            let price0 = UQ112x112::encode(reserve1).uqdiv(reserve0);
            let price1 = UQ112x112::encode(reserve0).uqdiv(reserve1);

            self.storage().price0_cumulative_last.write(
                self.storage().price0_cumulative_last.read() + price0 * time_elapsed
            );
            self.storage().price1_cumulative_last.write(
                self.storage().price1_cumulative_last.read() + price1 * time_elapsed
            );
        }

        self.storage().reserve0.write(balance0);
        self.storage().reserve1.write(balance1);
        self.storage().block_timestamp_last.write(block_timestamp);

        sync_event(balance0, balance1);
    }

    // Mint liquidity tokens
    #[starknet::interface]
    fn mint(ref self: ContractState, to: felt252) -> u128 {
        let (reserve0, reserve1, _) = self.get_reserves();
        let balance0 = call_contract!(self.storage().token0.read(), "balanceOf", address=self.contract_address);
        let balance1 = call_contract!(self.storage().token1.read(), "balanceOf", address=self.contract_address);
        let amount0 = felt_sub(balance0, reserve0);
        let amount1 = felt_sub(balance1, reserve1);

        let fee_on = self._mint_fee(reserve0, reserve1);
        let total_supply = self.get_total_supply();
        let liquidity = if total_supply == 0 {
            let liquidity = Math::sqrt(amount0 * amount1) - 1000; // MINIMUM_LIQUIDITY
            self._mint(0x0, 1000); // Lock the first 1000 liquidity tokens
            liquidity
        } else {
            Math::min(
                felt_mul(amount0, total_supply) / reserve0,
                felt_mul(amount1, total_supply) / reserve1
            )
        };

        assert(liquidity > 0, "UniswapV2: INSUFFICIENT_LIQUIDITY_MINTED");
        self._mint(to, liquidity);

        self._update(balance0, balance1, reserve0, reserve1);
        if fee_on {
            self.storage().k_last.write(felt_mul(reserve0, reserve1));
        }
        mint_event(self.caller(), amount0, amount1);

        liquidity
    }

    // Burn liquidity tokens
    #[starknet::interface]
    fn burn(ref self: ContractState, to: felt252) -> (u128, u128) {
        let (reserve0, reserve1, _) = self.get_reserves();
        let balance0 = call_contract!(self.storage().token0.read(), "balanceOf", address=self.contract_address);
        let balance1 = call_contract!(self.storage().token1.read(), "balanceOf", address=self.contract_address);
        let liquidity = self.get_balance(self.contract_address);

        let total_supply = self.get_total_supply();
        let amount0 = felt_mul(liquidity, balance0) / total_supply;
        let amount1 = felt_mul(liquidity, balance1) / total_supply;

        assert(amount0 > 0 && amount1 > 0, "UniswapV2: INSUFFICIENT_LIQUIDITY_BURNED");
        self._burn(self.contract_address, liquidity);
        self._safe_transfer(self.storage().token0.read(), to, amount0);
        self._safe_transfer(self.storage().token1.read(), to, amount1);

        self._update(balance0, balance1, reserve0, reserve1);
        burn_event(self.caller(), amount0, amount1, to);

        (amount0, amount1)
    }

    // Swap tokens between token0 and token1
    #[starknet::interface]
    fn swap(
        ref self: ContractState,
        amount0_out: u128,
        amount1_out: u128,
        to: felt252
    ) {
        assert(amount0_out > 0 || amount1_out > 0, "UniswapV2: INSUFFICIENT_OUTPUT_AMOUNT");
        let (reserve0, reserve1, _) = self.get_reserves();

        let token0 = self.storage().token0.read();
        let token1 = self.storage().token1.read();
        assert(to != token0 && to != token1, "UniswapV2: INVALID_TO");

        if amount0_out > 0 {
            self._safe_transfer(token0, to, amount0_out);
        }
        if amount1_out > 0 {
            self._safe_transfer(token1, to, amount1_out);
        }

        let balance0 = call_contract!(token0, "balanceOf", address=self.contract_address);
        let balance1 = call_contract!(token1, "balanceOf", address=self.contract_address);

        let amount0_in = felt_sub(balance0, felt_sub(reserve0, amount0_out));
        let amount1_in = felt_sub(balance1, felt_sub(reserve1, amount1_out));

        assert(amount0_in > 0 || amount1_in > 0, "UniswapV2: INSUFFICIENT_INPUT_AMOUNT");

        let balance0_adjusted = felt_mul(balance0, 1000) - felt_mul(amount0_in, 3);
        let balance1_adjusted = felt_mul(balance1, 1000) - felt_mul(amount1_in, 3);
        assert(
            felt_mul(balance0_adjusted, balance1_adjusted) >= felt_mul(reserve0, reserve1) * 1000**2,
            "UniswapV2: K"
        );

        self._update(balance0, balance1, reserve0, reserve1);
        swap_event(self.caller(), amount0_in, amount1_in, amount0_out, amount1_out, to);
    }

    // Internal safe transfer function
    fn _safe_transfer(token: felt252, to: felt252, value: u128) {
        let success = call_contract!(token, "transfer", to, value);
        assert(success, "UniswapV2: TRANSFER_FAILED");
    }

    // Mint fee logic
    fn _mint_fee(self: @ContractState, reserve0: u128, reserve1: u128) -> bool {
        let fee_to = self.storage().factory.read();  // Assume feeTo is stored in factory
        let k_last = self.storage().k_last.read();
        let fee_on = fee_to != 0;
        if fee_on && k_last != 0 {
            let root_k = Math::sqrt(reserve0 * reserve1);
            let root_k_last = Math::sqrt(k_last);
            if root_k > root_k_last {
                let total_supply = self.get_total_supply();
                let liquidity = (root_k - root_k_last) * total_supply / (root_k * 5 + root_k_last);
                if liquidity > 0 {
                    self._mint(fee_to, liquidity);
                }
            }
        }
        fee_on
    }
}

use starknet::ContractAddress;
use super::contracts::interfaces::IV2Pair::IV2Pair;

#[starknet::contract]
mod V2Pair {
    use super::{ContractAddress, IV2Pair};
    use openzeppelin_token::erc20::interface::{IERC20CamelDispatcher, IERC20CamelDispatcherTrait};

    use starknet::{get_caller_address, get_contract_address};
    use starknet::syscalls::{call_contract_syscall};
  //  use core::num::traits::Sqrt;   
    use core::num::traits::Zero;
    use starknet::storage::Map;
    
    
    const PAIR_FLASH_SWAP_CALLBACK: felt252 = 0x234; // change to real callback function name
    const MINIMUM_LIQUIDITY: u256 = 1_000;

    #[storage]
    struct Storage {
        token0: ContractAddress,
        token1: ContractAddress,
        reserves0: u256,
        reserves1: u256,
        k_last: u256,

        //erc20 helpers
        balance_of: Map<ContractAddress, u256>,
        total_supply: u256,
    }

    #[constructor]
    fn constructor(ref self: ContractState, token0: ContractAddress, token1: ContractAddress) {
        self.token0.write(token0);
        self.token1.write(token1);
    }

    #[abi(embed_v0)]
    impl V2PairImpl of IV2Pair<ContractState> {

        fn swap( ref self: ContractState, amount0out: u256, amount1out: u256, to: ContractAddress, data: Span<felt252>) {
            assert!(amount0out > 0 || amount1out > 0, "PAIR: INSUFFICIENT_OUTPUT_AMOUNT");
            let (_reserves0, _reserves1) = self.get_reserves();
            assert!(amount0out < _reserves0 && amount1out < _reserves1, "PAIR: INSUFFICIENT_LIQUIDITY" );

            let _token0 =  self.token0.read();
            let _token1 = self.token1.read();

            assert!(to != _token0 && to != _token1, "PAIR: INVALID_TO");

            if amount0out > 0 {
                IERC20CamelDispatcher{contract_address : _token0}.transfer(to, amount0out);
            }
            if amount1out > 0 {
                IERC20CamelDispatcher{contract_address : _token1}.transfer(to, amount1out);
            }
            // if data.len() > 0 {
            //     self.flash_swap(to, data)
            // }

            let _balance0 = IERC20CamelDispatcher{contract_address : _token0}.balanceOf(get_contract_address());
            let __constructorbalance1 = IERC20CamelDispatcher{contract_address : _token1}.balanceOf(get_contract_address());

        }

        fn burn(ref self: ContractState, to: ContractAddress) -> (u256, u256) {
            let (_reserves0, _reserves1) = self.get_reserves();
            let _token0 = self.token0.read();
            let _token1 = self.token1.read();

            let balance0 = IERC20CamelDispatcher{contract_address : _token0}.balanceOf(get_contract_address());
            let balance1 = IERC20CamelDispatcher{contract_address : _token1}.balanceOf(get_contract_address());

            let liquidity = self.balance_of.read(to);
            let _total_supply = self.total_supply.read();

            let amount0 = balance0 * liquidity / _total_supply;
            let amount1 = balance1 * liquidity / _total_supply;

            assert!(amount0 > 0 &&amount1 > 0, "Pair: INSUFICIENT_LIQUIDITY_BURNED");

            self._burn(to, liquidity);
            
            
            //transfer tokens to the caller "to"
            IERC20CamelDispatcher{contract_address : _token0}.transfer(to, amount0);
            IERC20CamelDispatcher{contract_address : _token1}.transfer(to, amount1);
            
            self._update(balance0, balance1);
            (amount0, amount1)

        }

        fn mint (ref self: ContractState, to: ContractAddress) -> u256 {
            let (_reserves0, _reserves1) = self.get_reserves();
            let balance0 = IERC20CamelDispatcher{contract_address : self.get_token0()}.balanceOf(get_contract_address());
            let balance1 = IERC20CamelDispatcher{contract_address : self.get_token1()}.balanceOf(get_contract_address());     
            
            let amount0 = balance0 - _reserves0;
            let amount1 = balance1 - _reserves1;

            let _total_supply = self.total_supply.read();

            let mut liquidity: u256 = 0;

            if _total_supply == 0 {
                // burn 1000
                let sqrt_result = (amount0 + amount1).into();
                liquidity = sqrt_result - MINIMUM_LIQUIDITY;
                self._mint(Zero::zero(), MINIMUM_LIQUIDITY); 
            } else {
                let left_hand = amount0 * _total_supply / _reserves0;
                let right_hand = amount1 * _total_supply / _reserves1;
                liquidity = self._min(left_hand, right_hand);
            }

            assert!(liquidity > 0, "Pair: INSUFFICIENT_LIQUIDITY_MINTER");

            self._mint(to, liquidity);
            self. _update(balance0, balance1);

            liquidity

        }

        //view functions
        fn get_reserves(self: @ContractState) -> (u256, u256) {
            (self.reserves0.read(), self.reserves1.read())
        }

        fn get_token0(self: @ContractState) -> ContractAddress {
            self.token0.read()
        }

        fn get_token1(self: @ContractState) -> ContractAddress {
            self.token1.read()
        }

        fn transfer_to (ref self: ContractState, to: ContractAddress, amount: u256) {
            let caller = get_caller_address();
            let balance = self.balance_of.read(caller);
            assert!(balance == amount, "Pair: INSUFFICIENT_BALANCE");

            self.balance_of.write(caller, balance - amount);
            self.balance_of.write(to, self.balance_of.read(to) + amount);
        }

        fn balance_of(self: @ContractState, owner: ContractAddress) -> u256 {
            self.balance_of.read(owner)
        }

    }


    //internal trait implementation
    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn _min(self: @ContractState, a: u256, b: u256) -> u256 {
            if a < b {
                a
            } else {
                b
            }
        }
        fn _mint(ref self: ContractState, to: ContractAddress, amount: u256) {
            let _total_supply = self.total_supply.read();
            let curr_balance = self.balance_of.read(to);

            self.balance_of.write(to, curr_balance + amount);
            self.total_supply.write(_total_supply + amount);
        }

        fn _burn(ref self: ContractState, to: ContractAddress, amount: u256) {
            let _total_supply = self.total_supply.read();
            let curr_balance = self.balance_of.read(to);

            self.balance_of.write(to, curr_balance - amount);
            self.total_supply.write(_total_supply - amount);
        }
        fn _update(ref self: ContractState, balance0: u256, balance1: u256) {
            self.reserves0.write(balance0);
            self.reserves1.write(balance1);
        }

        fn flash_swap(ref self: ContractState, to: ContractAddress, data: Span<felt252>) {
           let _= call_contract_syscall(to, PAIR_FLASH_SWAP_CALLBACK, data);
        }
        
    }
}

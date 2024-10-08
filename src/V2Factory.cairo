
use starknet::{ContractAddress};

// Import the interface
use super::contracts::interfaces::IV2Factory::IV2Factory;


#[starknet::contract]
mod V2Factory {
    
    use starknet::storage::{
        Map
    };
    use super::ContractAddress;

    use starknet::get_caller_address;
    use starknet::contract_address_const;
    use super::IV2Factory;

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        PairCreated: PairCreated,
    }

    #[derive(Drop, starknet::Event)]
    struct PairCreated {
        token0: ContractAddress,
        token1: ContractAddress,
        pair: ContractAddress,
        pair_count: u256,
    }

    #[storage]
    struct Storage {
        fee_to: ContractAddress,
        fee_to_setter: ContractAddress,
        pairs: Map<(ContractAddress, ContractAddress), ContractAddress>,
        all_pairs: Map<u32, ContractAddress>,
        all_pairs_length: u32,
    }

    #[constructor]
    fn constructor(ref self: ContractState, fee_setter: ContractAddress) {
        self.fee_to_setter.write(fee_setter);
    }

    #[abi(embed_v0)]
    impl V2FactoryImpl of IV2Factory<ContractState> {
        fn create_pair(
            ref self: ContractState,
            token0: ContractAddress,
            token1: ContractAddress
        ) -> ContractAddress {
            assert(token0 != token1, 'V2: IDENTICAL_ADDRESSES');
            let (token0, token1) = if token0 < token1 {
                (token0, token1)
            } else {
                (token1, token0)
            };
            assert(token0.into() != 0, 'V2: ZERO_ADDRESS');
            assert(self.pairs.read((token0, token1)) == 0.try_into().unwrap(), 'V2: PAIR_EXISTS');

            // Here you would deploy a new pair contract
            // For this example, we'll use a dummy address
            let pair = contract_address_const::<0x1>();

            self.pairs.write((token0, token1), pair);
            
            let length = self.all_pairs_length.read();
            self.all_pairs.write(length, pair);
            self.all_pairs_length.write(length + 1);

            // Emit the PairCreated event
            self.emit(Event::PairCreated(PairCreated {
                token0, token1, pair,
                pair_count: (length + 1).into()
            }));

            pair
        }

        fn get_pair(
            self: @ContractState,
            token0: ContractAddress,
            token1: ContractAddress
        ) -> ContractAddress {
            self.pairs.read((token0, token1))
        }

        fn get_all_pairs(self: @ContractState, index: u256) -> ContractAddress {
            self.all_pairs.read(index.try_into().unwrap())
        }

        fn get_all_pairs_length(self: @ContractState) -> u256 {
            self.all_pairs_length.read().into()
        }

        fn fee_to(self: @ContractState) -> ContractAddress {
            self.fee_to.read()
        }

        fn fee_to_setter(self: @ContractState) -> ContractAddress {
            self.fee_to_setter.read()
        }

        fn set_fee_to(ref self: ContractState, fee_to: ContractAddress) {
            assert(get_caller_address() == self.fee_to_setter.read(), 'V2: FORBIDDEN');
            self.fee_to.write(fee_to);
        }

        fn set_fee_to_setter(ref self: ContractState, fee_to_setter: ContractAddress) {
            assert(get_caller_address() == self.fee_to_setter.read(), 'V2: FORBIDDEN');
            self.fee_to_setter.write(fee_to_setter);
        }
    }
}

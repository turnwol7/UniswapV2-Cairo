#[starknet::contract]
mod UQ112x112 {
    // Define the constant Q112, which is 2^112
    const Q112: u128 = 2_u128.pow(112);

    // Encode a u112 number as UQ112x112
    #[view]
    fn encode(y: u128) -> u128 {
        let z = felt_mul(y, Q112); // Multiply y by 2^112
        z
    }

    // Divide a UQ112x112 by a u112, returning a UQ112x112
    #[view]
    fn uqdiv(x: u128, y: u128) -> u128 {
        assert!(y != 0, "Division by zero");
        let z = felt_div(x, y); // Perform the division
        z
    }
}

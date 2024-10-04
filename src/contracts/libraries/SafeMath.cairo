#[starknet::contract]
mod SafeMath {
    // Function to safely add two unsigned 128-bit integers, ensuring no overflow
    #[view]
    fn add(x: u128, y: u128) -> u128 {
        let z = felt_add(x, y);
        assert!(z >= x, "SafeMath: addition overflow");
        z
    }

    // Function to safely subtract two unsigned 128-bit integers, ensuring no underflow
    #[view]
    fn sub(x: u128, y: u128) -> u128 {
        assert!(x >= y, "SafeMath: subtraction underflow");
        let z = felt_sub(x, y);
        z
    }

    // Function to safely multiply two unsigned 128-bit integers, ensuring no overflow
    #[view]
    fn mul(x: u128, y: u128) -> u128 {
        if y == 0 {
            return 0;
        }
        let z = felt_mul(x, y);
        assert!(z / y == x, "SafeMath: multiplication overflow");
        z
    }
}

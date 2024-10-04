#[starknet::contract]
mod Math {

    // Function to return the minimum of two values
    #[view]
    fn min(x: u128, y: u128) -> u128 {
        if x < y {
            x
        } else {
            y
        }
    }

    // Function to calculate the square root of a number using the Babylonian method
    #[view]
    fn sqrt(y: u128) -> u128 {
        if y > 3 {
            let mut z = y;
            let mut x = felt_add(y / 2, 1);

            while x < z {
                z = x;
                x = (felt_add(y / x, x)) / 2;
            }

            z
        } else if y != 0 {
            1
        } else {
            0
        }
    }
}

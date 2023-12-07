//static AMEANID: &str = "AmId";
const AMEANID: &str = "AmId";

struct VectorOfContinuous {}

impl VectorOfContinuous {

    const ARITHMETIC_MEAN_ID: &str = "ArithmeticMean";

}

fn main() {
    println!("trace 1:  {}",AMEANID);
    println!("trace 2:  {}",VectorOfContinuous::ARITHMETIC_MEAN_ID);
}

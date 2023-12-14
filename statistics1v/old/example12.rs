enum Blek {
    Yuck,
    Ewe,
}

const YUCK: Blek  = Blek::Yuck;
const EWE:  Blek  = Blek::Ewe;

fn print_tit(icky: Blek) {
    match icky {
        Blek::Yuck    => println!("YUCK!!!"),
        Blek::Ewe     => println!("Ewe!!!"),
    }
}
fn main() {
    let mut s = "".to_string();
    
    for i in 0..1 {
        println!("trace {i},{s}");
        s = format!("{s},{i}");
    }
    print_tit(YUCK);
    print_tit(EWE);
}

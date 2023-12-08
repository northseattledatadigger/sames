use std::collections::*;
fn main() {
    let mut hm: HashMap<i128,f64> = HashMap::new();
    hm.insert(123,122.567);
    let floatything = hm.get(&123).unwrap();
    println!("trace hm:  {}",floatything);
    let mut btm: BTreeMap<i128,f64> = BTreeMap::new();
    btm.insert(456,455.567);
    let floatything = btm.get(&456).unwrap();
    println!("trace btm:  {}",floatything);
}

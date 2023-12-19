// example17.rs
#![ allow(unused)]

use csv::StringRecord;

fn main() {
    let record = StringRecord::new();
    let example: Vec<String> = record
        .iter()
        .map(|v| v.iter().collect::<String>())
        .collect();
}

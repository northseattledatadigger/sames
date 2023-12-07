#![allow(unused)]

use std::collections::HashSet;

pub fn try_tuple<'a>() -> Option<(u32,HashSet<&'a str>)> {
    let mut candidates = HashSet::new();
    candidates.insert("one");
    return Some((1,candidates));
}

fn main() {

    let result = try_tuple().unwrap();
    println!("trace count: {}",result.0);
    for x in result.1.iter() {
        println!("trace mode value:  {x}");
    }
}

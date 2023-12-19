#![ allow(unused)]
use std::fmt::Display;
use regex::Regex;

trait X {}

#[derive(Debug)]
struct S1 {}

impl X for S1 {}

#[derive(Debug)]
struct S2 {}
impl X for S2 {}

fn main() {
    let mut v: Vec<Box<dyn X>> = Vec::new();
    let re = Regex::new(r"\b\w{13}\b").unwrap();
    
    v.push(Box::new(S1 {}));
    v.push(Box::new(S2 {}));
    //v.push(S1);
    //v.push(S2);
    //println!("{:?}",<dyn X>::v[0]);
    //println!("{}",*v[0]);
    //println!("{:?}",*v[0]);
    if v.len() > 0 {
        println!("trace 9:  {:?}",v.len());
    }
}

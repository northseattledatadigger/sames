// example14.rs
#![ allow(unused)]

pub trait X {
    fn new() -> Self;
    fn see_all(&self);
}

#[derive(Debug)]
struct S1 {
    content: String,
    list:   Vec<f64>,
    happy:  bool,
}

impl X for S1 {
    fn new() -> Self {
        let buffer = S1::new();
        buffer.content  = "Generic S1 stuff.".to_string();
        buffer.list     = Vec::new();
        buffer.happy    = false;
        return buffer;
    }
    fn see_all(&self) {
        println!("From an object of struct S1.");
    }
}

impl S1 {
    fn see_one(&self) {
        println!("You see one.");
    }
}

#[derive(Debug)]
struct S2 {
    content: String,
    list:   Vec<i32>,
}
impl X for S2 {
    fn new() -> Self {
        let buffer = S2::new();
        buffer.content  = "Generic S2 stuff.".to_string();
        buffer.list     = Vec::new();
        return buffer;
    }
    fn see_all(&self) {
        println!("From an object of struct S2.");
    }
}

impl S2 {
    fn see_two(&self) {
        println!("You see two.");
    }
}

fn main() {
    let mut v: Vec<Box<dyn X>> = Vec::new();
    
    v.push(Box::new(S1 {}));
    v.push(Box::new(S2 {}));
    if v.len() > 0 {
        println!("trace 9:  {:?}",v.len());
    }
    v[0].see_one();
}

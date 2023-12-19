// example15.rs
#![ allow(unused)]

//use any::Any;
use std::convert::Into;

trait X {
    fn get_content(&self) -> String;
    fn get_vr(&self) -> &Vec;
    fn see_all(&self);
}
trait X1: X {
    fn see_one(&self);
}

struct S1 {
    content: String,
    list:   Vec<f64>,
    happy:  bool,
}
impl X for S1 {
    fn get_content(&self) -> String {
        let b = self.content.to_string();
        return b;
    }
    fn see_all(&self) {
        println!("See this one??");
    }
}
impl X1 for S1 {
/*
    fn new_from_ick() -> S1 {
        let buffer = S1 {
            content:    "Y".to_string(),
            list:       vec![1.1,2.2,3.3],
            happy:      true,
        };
        return buffer;
    }
 */
    fn see_one(&self) {
        println!("See just this one?");
    }
}

struct S2 {
    content: String,
    list:   Vec<i32>,
}
impl X for S2 {
    fn get_content(&self) -> String {
        let b = self.content.to_string();
        return b;
    }
    fn see_all(&self) {
        println!("See this two too??");
    }
}

enum XE {
    S1(S1),
    S2(S2),
}

fn main() {
    let mut v: Vec<Box<dyn X>> = Vec::new();
    v.push(Box::new(S1 { content: "X".to_string(), list: vec![1.1,2.0,3.9], happy: false, }));
    v.push(Box::new(S2 { content: "X".to_string(), list: vec![4,5,6], }));
//    v.push(Box::new(S2 { content: "Y".to_string(), list: Vec::new(), }));
    //v.push(Box::new(S2 {}));
    if v.len() > 0 {
        println!("trace 9:  {:?}",v.len());
    }
    v[0].see_all();
    v[1].see_all();
    let rv = &v;
    let vv  = vec![rv];
    let b = &vv[0];
    let b2 = &vv[0][0];
    //println!("trace 10 {}",*b2.content);
//    println!("trace 10 {}",*v[0].content);
    //let cvb: Vec<Box<dyn X1>> = v.into();
    //let cvb: Box<dyn X1> as From<&Box<dyn X>> = v[0];
    //let cvb: Box<dyn X1> = v[0];
    //cvb.see_one();
    //let cvb: Vec<dyn X1> = v.iter().map(|item| &**item as &dyn X1).collect();
    //let cvb: Vec<dyn X1>    =  
}

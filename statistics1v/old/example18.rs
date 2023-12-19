#![ allow(unused)]
use regex::Regex;
fn _xc_parse_csv(data_string: String) -> Option<Vec<String>> {
    if data_string.len() == 0 {
        return None;
    }
    let result: Vec<String> = data_string.split(",").map(|s| s.to_string()).collect();
    Some(result)
}

fn main() {
    let csvstr  = "1,2,3,4,5,\"6\"";
    if let Some(xa) = _xc_parse_csv(csvstr.to_string()) {
        println!("trace xa[0]: {}",xa[0]);
        println!("trace xa[1]: {}",xa[1]);
        println!("trace xa[2]: {}",xa[2]);
        println!("trace xa[3]: {}",xa[3]);
        println!("trace xa[4]: {}",xa[4]);
        println!("trace xa[5]: {}",xa[5]);
    }
}

//use std::collections::*;
fn main() {
    let firstnameid = "First Name";
    let firstname = "Xeno";
    let thingstring = "{{    \"Here\":{{
    \"{{}}\":  \"{{}}\",
    }}
}}
";
    println!("trace btm:  {}",thingstring);
    println!("{{    \"Here\":{{\n\"{}\":  \"{}\",\n}}\n}}\n",firstnameid,firstname);
    println!("{{
    \"Here\":
    {{
        \"{}\": \"{}\",
    }}
}}
",firstnameid,firstname);
}

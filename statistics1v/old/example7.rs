macro_rules! collection_csv_line_fmt_str {
    () => {
        "{},{}\n{},{}\n{},{}\n{},{}\n{},{}\n{},{}\n{},{}\n{},{}\n{},{}\n{},{}\n{},{}\n{},{}\n{},{}\n{},{}\n{},{}\n{},{}\n"
    }
}
macro_rules! try002 {
    () => {
        "{},{}\n{},{}\n"
    }
}

fn main() {
    let s = format!(try002!(),"a","b","c","d");
    println!("{}",s);
    let s = format!(collection_csv_line_fmt_str!(),
                "a","b","c","d","e","f","g","h","i",
                "j","k","l","m","n","o","p","q","r",
                "s","t","u","v","w","x","y","z","A",
                "B","C","D","E","F");
    println!("{}",s);
}

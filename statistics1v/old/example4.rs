use std::collections::HashMap;

fn main() {
    // Type inference lets us omit an explicit type signature (which
    // would be `HashMap<String, String>` in this example).
    let mut book_reviews: HashMap<&str,&str> = HashMap::new();

    // Review some books.
    book_reviews.insert(
        "Adventures of Huckleberry Finn",
        "My favorite book.",
    );
    
    book_reviews.insert(
        "1",
        "ONE",
    );
    let brl = book_reviews.get("1").expect("broken").to_string();
    println!("trace 1:  {}",brl);
}

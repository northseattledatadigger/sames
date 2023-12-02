use std::collections::BTreeMap;

fn main() {

    // type inference lets us omit an explicit type signature (which
    // would be `BTreeMap<&str, &str>` in this example).
    let mut movie_reviews = BTreeMap::new();

    // review some movies.
    movie_reviews.insert("Office Space",       "Deals with real issues in the workplace.");
    movie_reviews.insert("Pulp Fiction",       "Masterpiece.");
    movie_reviews.insert("The Godfather",      "Very enjoyable.");
    movie_reviews.insert("The Blues Brothers", "Eye lyked it alot.");
    movie_reviews.insert("X-Files", "Never liked it.");
    movie_reviews.insert("ABC Murders", "Never liked it.");

/*
    // check for a specific one.
    if !movie_reviews.contains_key("Les Misérables") {
        println!("We've got {} reviews, but Les Misérables ain't one.",
                 movie_reviews.len());
    }

    // oops, this review has a lot of spelling mistakes, let's delete it.
    movie_reviews.remove("The Blues Brothers");

    // look up the values associated with some keys.
    let to_find = ["Up!", "Office Space"];
    for book in &to_find {
        match movie_reviews.get(book) {
           Some(review) => println!("{}: {}", book, review),
           None => println!("{} is unreviewed.", book)
        }
        review = movie_reviews.get(book);
        println!("{}:  {}", book, review)
    }
 */

    // iterate over everything.
    for (movie, review) in &movie_reviews {
        println!("{}: \"{}\"", movie, review);
    }

}

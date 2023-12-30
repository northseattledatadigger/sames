#![ allow(unused)]
use std::fs;

fn main() {
    fs::create_dir_all("/tmp/example25_test_dir").unwrap();
}

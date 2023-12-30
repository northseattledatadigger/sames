#![ allow(unused)]
// https://stackoverflow.com/questions/70123005/rust-traits-with-constant-field-defined-by-implementation
use std::fs;
use std::path::PathBuf;

trait TryConst {
    const OINK1: String;
    fn get_base(&self) -> PathBuf;
}

fn main() {
    fs::create_dir_all("/tmp/a").unwrap();
    fs::create_dir_all("/tmp/a/b/c").unwrap();
}

#![ allow(unused)]
use std::env;
use std::error::Error;
use std::path::PathBuf;

pub fn get_string_for_path(path: &PathBuf) -> String {
    return path.to_owned().into_os_string().into_string().expect("Failure here would be systemic.");
}

trait PathSet {
    fn get_base_path(&self) -> PathBuf;
}

pub struct ProjectPathSet {
    base_path:      PathBuf,
}
impl PathSet for ProjectPathSet {
    fn get_base_path(&self) -> PathBuf {
        return self.base_path.to_owned();
    }
}

pub fn init_project_path_set() -> ProjectPathSet {
    let ltoppath: PathBuf       = env::current_exe().unwrap();
    ProjectPathSet {
        base_path:          ltoppath.to_owned(),
    }
}

fn main() {
    let b = init_project_path_set();
    //let pb = get_string_for_path(&pso.base_path);
    //println!("{}",pb);
}

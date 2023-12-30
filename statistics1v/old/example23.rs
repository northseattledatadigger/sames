#![ allow(unused)]
use std::env;
use std::path::PathBuf;

pub struct PathSet {
    base_path:      PathBuf,
    project_path:   PathBuf,
    resource_one:   PathBuf,
    resource_two:   PathBuf,
}
impl PathSet {
    fn get_base_path(&self) -> PathBuf {
        return self.base_path.to_owned();
    }
    fn get_base_string(&self) -> String {
        return self.base_path.to_owned().into_os_string().into_string().unwrap();
    }
    fn get_project_path(&self) -> PathBuf {
        return self.project_path.to_owned();
    }
    fn get_project_string(&self) -> String {
        return self.project_path.to_owned().into_os_string().into_string().unwrap();
    }
    fn get_resource1_path(&self) -> PathBuf {
        return self.resource_one.to_owned();
    }
    fn get_resource1_string(&self) -> String {
        return self.resource_one.to_owned().into_os_string().into_string().unwrap();
    }
    fn get_resource2_path(&self) -> PathBuf {
        return self.resource_two.to_owned();
    }
    fn get_resource2_string(&self) -> String {
        return self.resource_two.to_owned().into_os_string().into_string().unwrap();
    }
    fn new() -> Self {
        let ltoppath: PathBuf       = env::current_exe().unwrap();
        let lprojectpath: PathBuf   = ltoppath.join("myprojectnode");
        let buffer = PathSet {
            base_path:          ltoppath.to_owned(),
            project_path:       lprojectpath.to_owned(),
            resource_one:       lprojectpath.join("myresource1node").to_owned(), 
            resource_two:       lprojectpath.join("myresource2node").to_owned(), 
        };
        return buffer;
    }
}

fn main() {
    let pso: PathSet    = PathSet::new();

    println!("
TOPPATH         {}
PROJECTPATH     {}
RESOURCEPATH1   {}
",
    pso.get_base_string(),
    pso.get_project_string(),
    pso.get_resource1_string());
}

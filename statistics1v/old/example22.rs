use std::env;
use std::path::PathBuf;

fn main() {
    let toppath: PathBuf      = env::current_exe().unwrap();
    let projectpath: PathBuf  = toppath.join("myprojectnode");
    let resourcepath: PathBuf = projectpath.join("myresourcenode");

    println!("
TOPPATH         {}
PROJECTPATH     {}
RESOURCEPATH    {}
",
    toppath.into_os_string().into_string().unwrap(),
    projectpath.into_os_string().into_string().unwrap(),
    resourcepath.into_os_string().into_string().unwrap());
}

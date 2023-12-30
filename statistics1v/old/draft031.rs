#![ allow(unused)]
// draft 031
use std::env;
use std::error::Error;
use std::path::Path;
use std::path::PathBuf;

const BIN:      &str    = "bin";
const EXAMPLES: &str    = "examples";
const EXTRAS:   &str    = "extras";
const SBIN:     &str    = "sbin";
const SLIB:     &str    = "slib";
const TESTDATA: &str    = "testdata";
const TESTS:    &str    = "tests";
const TMPBUILD: &str    = "tmpbuild";
const TMPDATA:  &str    = "tmpdata";

pub fn get_string_for_path(path: &PathBuf) -> String {
    return path.to_owned().into_os_string().into_string().expect("Failure here would be systemic.");
}

pub trait PathSet {

    fn get_project(&self)           -> PathBuf;
    fn get_projectname(&self)       -> String;
    fn get_project_bin(&self)       -> PathBuf;
    fn get_project_extras(&self)    -> PathBuf;
    fn get_project_sbin(&self)      -> PathBuf;
    fn get_project_tests(&self)     -> PathBuf;
    fn get_project_tmpbuild(&self)  -> PathBuf;

    fn get_top(&self)               -> PathBuf;
    fn get_top_sbin(&self)          -> PathBuf;
    fn get_top_slib(&self)          -> PathBuf;
    fn get_top_testdata(&self)      -> PathBuf;
    fn get_top_tests(&self)         -> PathBuf;
    fn get_tmpdata(&self)           -> PathBuf;
    //fn new()                        -> Result<Self,Box<dyn std::error::Error>> where Self Sized;
    //fn new()                        -> Result<Self,Box<dyn std::error::Error>>;
    fn new()                        -> Result<Self,Box<dyn std::error::Error>> where Self: Sized;
}

pub struct ProjectPathSet<'a> {
    projectbinpath: &'a Path,
    programpath:    PathBuf,
    project:        String,
    projectpath:    &'a Path,
    toppath:        &'a Path,
}

impl PathSet for ProjectPathSet<'_> {

    fn get_project(&self)           -> PathBuf {
        return self.projectpath.to_path_buf();
    }
    fn get_projectname(&self)       -> String {
        return self.project;
    }
    fn get_project_bin(&self)        -> PathBuf {
        return self.projectbinpath.to_path_buf();
    }
    fn get_project_extras(&self)     -> PathBuf {
        return self.projectpath.join(EXTRAS);
    }
    fn get_project_sbin(&self)       -> PathBuf {
        return self.projectpath.join(SBIN);
    }
    fn get_project_tests(&self)      -> PathBuf {
        return self.projectpath.join(TESTS);
    }
    fn get_project_tmpbuild(&self)   -> PathBuf {
        return self.projectpath.join(TMPBUILD);
    }
    fn get_top(&self)               -> PathBuf {
        return self.toppath.to_path_buf();
    }
    fn get_top_sbin(&self)           -> PathBuf {
        return self.toppath.join(SBIN);
    }
    fn get_top_slib(&self)           -> PathBuf {
        return self.toppath.join(SLIB);
    }
    fn get_top_testdata(&self)       -> PathBuf {
        return self.toppath.join(TESTDATA);
    }
    fn get_top_tests(&self)          -> PathBuf {
        return self.toppath.join(TESTS);
    }
    fn get_tmpdata(&self)           -> PathBuf {
        return self.toppath.join(TMPDATA);
    }
    fn new()                        -> Result<Self,Box<dyn std::error::Error>> where Self: Sized {
        let lprogrampath:       PathBuf = env::current_exe()?;

        let lprojectbinpath:    &Path = match lprogrampath.parent() {
            Some(b) => b,
            None    => panic!("Failure would indicate bad application install or systemic problem."),
        };
        let lprojectpath:       &Path = match lprojectbinpath.parent() {
            Some(b) => b,
            None    => panic!("Failure would indicate bad application install or systemic problem."),
        };
        let lprojectname:       String  = match lprojectpath.file_name() {
            None    => panic!("Failure would indicate bad application install or systemic problem."),
            Some(b) => match b.to_str() {
                None    => panic!("Failure would indicate bad application install or systemic problem."),
                Some(b) => b.to_string(),
            },
        };

        let ltop:               &Path = match lprojectpath.parent() {
            Some(b) => b,
            None    => panic!("Failure would indicate bad application install or systemic problem."),
        };
        let buffer = ProjectPathSet {
            projectbinpath:     lprojectbinpath,
            programpath:        lprogrampath.to_owned(),
            project:            lprojectname.to_owned(),
            projectpath:        lprojectpath,
            toppath:            ltop,
        };
        return Ok(buffer);
    }
}

fn main() {
    let pso: dyn PathSet    = match PathSet::new() {
        Err(_err)   => panic!("PathSet construction failed in main."),
        Ok(b)       => b,
    };
    println!("
TOP             {}

PROJECTNAME     {}

PROJECT         {}

PROJECTEXTRAS   {}
PROJECTTMPBUILD {}

TOPSBIN         {}
TMPDATA         {}
",
    pso.get_top(),
    pso.get_projectname(),
    pso.get_project(),
    pso.get_project_extras(),
    pso.get_project_tmpbuild(),
    pso.get_top_sbin(),
    pso.get_tmpdata());
}

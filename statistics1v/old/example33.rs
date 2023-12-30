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

    fn _get_projectbinpath(&self)   -> &Path;
    fn _get_projectpath(&self)      -> &Path;
    fn _get_toppath(&self)          -> &Path;
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
    fn new()                        -> Result<Self,Box<dyn std::error::Error>>;
    //fn new()                        -> Result<Self,Box<dyn std::error::Error>> where Self: Sized;
}

pub struct ProjectPathSet {
    programpath:    PathBuf,
}

impl PathSet for ProjectPathSet {

    fn _get_projectbinpath(&self)   -> &Path {
        let lprojectbinpath:    &Path = match self.programpath.parent() {
            Some(b) => return b,
            None    => panic!("Failure would indicate bad application install or systemic problem."),
        };
    }
    fn _get_projectpath(&self)   -> &Path {
        let lprojectbinpath = self._get_projectbinpath();
        let lprojectpath:   &Path = match lprojectbinpath.parent() {
            Some(b) => return b,
            None    => panic!("Failure would indicate bad application install or systemic problem."),
        };
    }
    fn _get_toppath(&self)   -> &Path {
        let lprojectpath    = self._get_projectpath();
        let ltop:   &Path = match lprojectpath.parent() {
            Some(b) => return b,
            None    => panic!("Failure would indicate bad application install or systemic problem."),
        };
    }
    fn get_project(&self)           -> PathBuf {
        let lprojectpath    = self._get_projectpath();
        return lprojectpath.to_path_buf();
    }
    fn get_projectname(&self)       -> String {
        let lprojectpath    = self._get_projectpath();
        let lprojectname:   String  = match lprojectpath.file_name() {
            None    => panic!("Failure would indicate bad application install or systemic problem."),
            Some(b) => match b.to_str() {
                None    => panic!("Failure would indicate bad application install or systemic problem."),
                Some(b) => b.to_string(),
            },
        };
        return lprojectname.to_owned();
    }
    fn get_project_bin(&self)        -> PathBuf {
        let lprojectbinpath = self._get_projectbinpath();
        return lprojectbinpath.to_path_buf();
    }
    fn get_project_extras(&self)     -> PathBuf {
        let lprojectpath    = self._get_projectpath();
        return lprojectpath.join(EXTRAS);
    }
    fn get_project_sbin(&self)       -> PathBuf {
        let lprojectpath    = self._get_projectpath();
        return lprojectpath.join(SBIN);
    }
    fn get_project_tests(&self)      -> PathBuf {
        let lprojectpath    = self._get_projectpath();
        return lprojectpath.join(TESTS);
    }
    fn get_project_tmpbuild(&self)   -> PathBuf {
        let lprojectpath    = self._get_projectpath();
        return lprojectpath.join(TMPBUILD);
    }
    fn get_top(&self)               -> PathBuf {
        let ltop    = self._get_toppath();
        return ltop.to_path_buf();
    }
    fn get_top_sbin(&self)           -> PathBuf {
        let ltop    = self._get_toppath();
        return ltop.join(SBIN);
    }
    fn get_top_slib(&self)           -> PathBuf {
        let ltop    = self._get_toppath();
        return ltop.join(SLIB);
    }
    fn get_top_testdata(&self)       -> PathBuf {
        let ltop    = self._get_toppath();
        return ltop.join(TESTDATA);
    }
    fn get_top_tests(&self)          -> PathBuf {
        let ltop    = self._get_toppath();
        return ltop.join(TESTS);
    }
    fn get_tmpdata(&self)           -> PathBuf {
        let ltop    = self._get_toppath();
        return ltop.join(TMPDATA);
    }
    fn new()                        -> Result<Self,Box<dyn std::error::Error>> {

        let lprogrampath:    PathBuf = env::current_exe()?;
        let buffer = ProjectPathSet {
            programpath: lprogrampath.to_owned(),
        };
        return Ok(buffer);
    }
}

fn main() {
    let pso: PathSet    = PathSet::new().expect("Failure here would be systemic");
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

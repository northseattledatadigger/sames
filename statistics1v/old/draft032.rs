#![ allow(unused)]
// draft 031
use std::env;
use std::error::Error;
use std::ffi::OsStr;
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
const TOPNAME:  &str    = "sames";

pub fn get_string_for_fnop(os_str: Option<&OsStr>) -> String {
    let buffer: String  = match os_str {
        None    => return "".to_string(),
        Some(b) => match b.to_str() {
            None    => return "".to_string(),
            Some(b) => return b.to_string(),
        },
    };
}

pub fn get_string_for_path(pathbuf: PathBuf) -> String {
    return pathbuf.to_owned().into_os_string().into_string().expect("Failure here would be systemic.");
}

pub trait PathSet {

    fn _get_projectbinpath(&self)   -> &Path;
    fn _get_projectpath(&self)      -> &Path;
    fn _get_toppath(&self)          -> &Path;
    fn get_program(&self)           -> PathBuf;
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
    fn validate(&self)              -> Result<(),Box<dyn std::error::Error>>;
}

pub struct ProjectPathSet {
    topname: String,
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
    fn get_program(&self)           -> PathBuf {
        return self.programpath.to_owned();
    }
    fn get_project(&self)           -> PathBuf {
        let lprojectpath    = self._get_projectpath();
        return lprojectpath.to_path_buf();
    }
    fn get_projectname(&self)       -> String {
        let lprojectpath            = self._get_projectpath();
        let lprojectname:   String  = get_string_for_fnop(lprojectpath.file_name());
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
    fn validate(&self)              -> Result<(),Box<dyn std::error::Error>> {
        if ! self.get_program().as_path().is_file() {
            return Err("Impossibly, running binary not seen as file.".into());
        }
        let lextras     = self.get_project_extras();
        if ! lextras.as_path().is_dir() {
            return Err("project extras directory not found.".into());
        }
        let ltopslib    = self.get_top_slib();
        if ! ltopslib.as_path().is_dir() {
            return Err("top slib directory not found.".into());
        }
        return Ok(());
    }
}

pub fn init_project_path_set() -> Result<ProjectPathSet,Box<dyn std::error::Error>> {
    let lprogrampathbuf:    PathBuf = env::current_exe()?;
    let lpbin                       = lprogrampathbuf.parent().expect("Needs to work to validate.");
    let lproject                    = lpbin.parent().expect("Needs to work to validate.");
    let ltop                        = lproject.parent().expect("Needs to work to validate.");
    let ltopname:   String          = get_string_for_fnop(ltop.file_name());
    if ltopname == TOPNAME {
        let buffer                  = ProjectPathSet {
            programpath:    lprogrampathbuf.to_owned(),
            topname:        ltopname.to_owned(),
        };
        return Ok(buffer);
    }
    return Err("Unexpected top name.".into());
}

fn main() {
    let pso: ProjectPathSet = init_project_path_set().expect("Failure here would be systemic");
    let program             = get_string_for_path(pso.get_program());
    let topstring           = get_string_for_path(pso.get_top());
    let project             = get_string_for_path(pso.get_project());
    let projectbin          = get_string_for_path(pso.get_project_bin());
    let projectextras       = get_string_for_path(pso.get_project_extras());
    let projectmpbuild      = get_string_for_path(pso.get_project_tmpbuild());
    let topsbin             = get_string_for_path(pso.get_top_sbin());
    let topslib             = get_string_for_path(pso.get_top_slib());
    let tmpdata             = get_string_for_path(pso.get_top());
    println!("
TOP             {}

PROJECTNAME     {}

PROJECT         {}

PROJECTBIN      {}
PROJECTEXTRAS   {}
PROJECTTMPBUILD {}

TOPSBIN         {}
TOPSLIB         {}
TMPDATA         {}
",
    topstring,
    pso.get_projectname(),
    project,
    projectbin,
    projectextras,
    projectmpbuild,
    topsbin,
    topslib,
    tmpdata);
}

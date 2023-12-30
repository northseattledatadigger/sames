//345678901234567890123456789012345678901234567890123456789012345678901234567890
// SamesTopLib.rs
#![ allow(unused)]

use std::env;
use std::error::Error;
use std::ffi::OsStr;
use std::path::Path;
use std::path::PathBuf;
use std::time::SystemTime;

//345678901234567890123456789012345678901234567890123456789012345678901234567890
// Constants and Environment

const BIN:          &str    = "bin";
const EXAMPLES:     &str    = "examples";
const EXTRAS:       &str    = "extras";
const KEPTFILEURLFN &str    = "InternetFileURLs.csv"
const SBIN:         &str    = "sbin";
const SLIB:         &str    = "slib";
const TESTDATA:     &str    = "testdata";
const TESTS:        &str    = "tests";
const TMPBUILD:     &str    = "tmpbuild";
const TMPDATA:      &str    = "tmpdata";
const TOPNAME:      &str    = "sames";

//345678901234567890123456789012345678901234567890123456789012345678901234567890
// Procedure and Object Code

use std::fs::File;
use std::io::{self, BufRead};
use std::path::Path;

fn get_kept_file_url(url_fs: PathBuf,f_n: String) -> Result<Option<String>,Box<dyn std::error::Error>> {
    // File hosts.txt must exist in the current path
    let restr = format!("{}$",f_n);
    let re = Regex::new(restr.as_str())?;
    let split_separator = Regex::new(r#","#)?;
    if let Ok(lines) = read_lines(url_fs) {
        // Consumes the iterator, returns an (Optional) String
        for ll in lines.iter() {
            if re.is_match(ll) {
                let result: Vec<String> = split_seperator.split(ll.as_str()).map(|s| s.to_string()).collect();
                return Ok(Some(result[0]));
            }
        }
    }
}

/*
fn get_kept_file_url(url_fs: PathBuf,f_n: String) -> Option<String> {
    # Note I'm going to just use split here and Presume the files will be
    # maintained with both filenames and URLs with NO embedded commas.
    # There are other ways, but it's not worth my bother at this time.
    let restr = format!("{}$",f_n);
    let re = Ok(re) = Regex::new(restr.as_str()) {
        re
    } else {
        return None;
    }
    let split_separator = Regex::new(r#","#).expect("Invalid separator regex");
    // unwrap occurs here and in VectorTable and needs to be re-coded.
    for llresult in read_to_string(url_fs).unwrap().lines() {
        if re.is_match(llresult) {
            let result: Vec<String> = split_seperator.split(llresult.as_str()).map(|s| s.to_string()).collect();
            return Some(result[0]);
        }
    }
    return None;
}
 */

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of SamesTopLib.rb
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
    loadtime:       SystemTime,
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
    pub fn get_keptfileurls_fs(&self)           -> PathBuf {
        let ltop    = self._get_toppath();
        return ltop.join(KEPTFILEURLFN);
    }
    pub fn get_program(&self)           -> PathBuf {
        return self.programpath.to_owned();
    }
    pub fn get_project(&self)           -> PathBuf {
        let lprojectpath    = self._get_projectpath();
        return lprojectpath.to_path_buf();
    }
    pub fn get_projectname(&self)       -> String {
        let lprojectpath            = self._get_projectpath();
        let lprojectname:   String  = get_string_for_fnop(lprojectpath.file_name());
        return lprojectname.to_owned();
    }
    pub fn get_project_bin(&self)        -> PathBuf {
        let lprojectbinpath = self._get_projectbinpath();
        return lprojectbinpath.to_path_buf();
    }
    pub fn get_project_extras(&self)     -> PathBuf {
        let lprojectpath    = self._get_projectpath();
        return lprojectpath.join(EXTRAS);
    }
    pub fn get_project_sbin(&self)       -> PathBuf {
        let lprojectpath    = self._get_projectpath();
        return lprojectpath.join(SBIN);
    }
    pub fn get_project_tests(&self)      -> PathBuf {
        let lprojectpath    = self._get_projectpath();
        return lprojectpath.join(TESTS);
    }
    pub fn get_project_tmpbuild(&self)   -> PathBuf {
        let lprojectpath    = self._get_projectpath();
        return lprojectpath.join(TMPBUILD);
    }
    pub fn get_top(&self)               -> PathBuf {
        let ltop    = self._get_toppath();
        return ltop.to_path_buf();
    }
    pub fn get_top_sbin(&self)           -> PathBuf {
        let ltop    = self._get_toppath();
        return ltop.join(SBIN);
    }
    pub fn get_top_slib(&self)           -> PathBuf {
        let ltop    = self._get_toppath();
        return ltop.join(SLIB);
    }
    pub fn get_top_testdata(&self)       -> PathBuf {
        let ltop    = self._get_toppath();
        return ltop.join(TESTDATA);
    }
    pub fn get_top_tests(&self)          -> PathBuf {
        let ltop    = self._get_toppath();
        return ltop.join(TESTS);
    }
    pub fn get_tmpdata(&self)           -> PathBuf {
        let ltop    = self._get_toppath();
        return ltop.join(TMPDATA);
    }
    pub fn validate(&self)              -> Result<(),Box<dyn std::error::Error>> {
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
    let lloadtime:          SystemTime  = SystemTime::now();
    let lprogrampathbuf:    PathBuf     = env::current_exe()?;
    let buffer                      = ProjectPathSet {
        loadtime:       lloadtime.to_owned(),
        programpath:    lprogrampathbuf.to_owned(),
    };
    return Ok(buffer);
}

//345678901234567890123456789012345678901234567890123456789012345678901234567890
// End of SamesTopLib.rb

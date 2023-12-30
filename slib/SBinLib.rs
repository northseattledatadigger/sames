//345678901234567890123456789012345678901234567890123456789012345678901234567890
// SBinLib.rs

use std::env;
use std::error::Error;
use std::fs;
use std::path::PathBuf;

fn assure_internet_data_file_copy(d_spec: PathBuf,file_name: &str,file_url: &str) -> Result<(),Box<dyn std::error::Error>> {

    fs::create_dir_all("/some/dir")?;
    FileUtils.mkdir_p dSpec
    fspec="#{dSpec}/#{fileName}"

    if File.exist?(fspec) then
        return true
    else
        `wget #{fileURL} -O#{fspec}`
    end
    return true if File.exist?(fspec)
    STDERR.puts "Could not find File #{fileName}, nor procure it from #{fileURL}."
    return false
}

fn returnIfThere(fSpec) -> Result<String,ValidationError>
    return fSpec if File.exists?(fSpec)
    raise ArgumentError, "Data file #{fSpec} not found." 
}

//345678901234567890123456789012345678901234567890123456789012345678901234567890
// End of SBinLib.rb

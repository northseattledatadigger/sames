#!/bin/bash
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# lrustxc.bash

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Constants and Includes

readonly HERE=$PWD
readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
readonly SAMESHOME="$( cd $SCRIPT_DIR/../.. &> /dev/null && pwd )"
readonly SAMESPROJECTHOME="$( cd $SCRIPT_DIR/.. &> /dev/null && pwd )"

source $SAMESPROJECTHOME/ProjectSpecs.bashenv
source $SAMESHOME/slib/RustXCLib.bashenv

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Procedures

catUsage() {
    cat <<EOU
USAGE:  $0 <options>
    -h This help text, without errors nor error exit.
EOU
}

setEnvironment() {
    local libSubtype="$1"

    # Crates always Used:
    cargo add csv
    cargo add regex

    # Crates specific to LibSubtype:

    case "$libSubtype" in
    native)
        return 0
        ;;
    polars)
        return 0
        ;;
    spark)
        return 0
        ;;
    esac
    return 1
}

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Init

CheckSetupOnly=build

export CargoCmd=build
export LibSubtype=native
export Deploy=true
export OnlyCleanTree=false
export Release=false

PrimaryOptChars="CD?"
SubProjectOptCharsFullSet="dinpsx"
SubProjectOptChars="dinps"

OptChars="$PrimaryOptChars$SubProjectOptChars"

if (( $# > 0 ))
then
    while getopts "?CcDFhKLPRNnprs" option
    do
        if setInitOptions "$option" "$OPTARG"
        then
            continue
        else
            exit 1
        fi
    done
fi

readonly ProjectLibFs=$HERE/$SameProjectName.$LibSubtype.rs
if $CheckSetupOnly
then
    dumpRustBuildEnv
    exit 0
fi

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Main

# Needs to be completely revamped: TBDxc
if [[ -f "$ProjectLibFs" ]]
then
    initTree
    cd $RustTree
    if $OnlyCleanTree
    then
        exit 0
    fi
    reInitWorkingTreeFromExhibitSource
    runCargoCmd $CargoCmd $Release
    cd $HERE
fi

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of lrustxc.bash

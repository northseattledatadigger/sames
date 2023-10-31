#!/bin/bash
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# lrustxc.bash

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Constants and Includes

readonly HERE=$PWD

source $HERE/sbin/ProjectSpecs.bashenv
source $HERE/../sbin/RustXCLib.bashenv

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Procedures

catUsage() {
    cat <<EOU
USAGE:  $0 <options>
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
    while getopts "chNnprs" option
    do
        if setInitOptions "$option"
        then
            continue
        else
            exit 1
        fi
    done
fi

readonly ProjectLibFs=$HERE/$SameProjectName.$LibSubtype.rs

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Main

if assureInFolder "$ProjectLibFs"
then
    initTree
    cd $RustTree
    if $OnlyCleanTree
    then
        exit 0
    fi
    cargo new --vcs none --lib $RustBuildName
    cd $MainBuildTreeDs
    setEnvironment
    plopRunSource
    cd $MainBuildTreeSrcDs
    if $Release
    then
        cargo build --lib --release
#        cpResultToSameBin true
    else
        cargo build --lib
#        cpResultToSameBin
    fi
    cd $HERE
fi

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of lrustxc.bash

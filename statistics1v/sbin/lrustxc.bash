#!/bin/bash
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# lrustxc.bash

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Constants and Includes

readonly HERE=$PWD
readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
readonly SAMESHOME="$( cd $SCRIPT_DIR/../.. &> /dev/null && pwd )"
readonly SAMESPROJECTHOME="$( cd $SCRIPT_DIR/.. &> /dev/null && pwd )"

if [[ $HERE != $SAMESPROJECTHOME ]]
then
    m="Please ONLY execute this script from this folder: $SAMESPROJECTHOME"
    echo "ERROR:  $m, at this time."
    exit 8
fi

source $SAMESPROJECTHOME/ProjectSpecs.bashenv
source $SAMESHOME/slib/RustXCLib.bashenv

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Procedures

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Init

DumpRustBuildEnvOnly=false

export AlternateBuildId=
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
    while getopts "?CcDdFhmrs:tX" option
    do
        #iC "if setInitOptions \"$option\" \"$OPTARG\""
        if setInitOptions "$option" "$OPTARG"
        then
            continue
        else
            exit 1
        fi
    done
fi

#export RUST_BACKTRACE=1
export RUST_BACKTRACE=full
readonly ProjectLibFs=$HERE/SamesLib.$LibSubtype.rs
if $DumpRustBuildEnvOnly
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
    if [[ -n $AlternateBuildId ]]
    then
        reInitWorkingTreeForAlternateBuild
    else
        reInitWorkingTreeFromExhibitSource
    fi
    runCargoCmd $CargoCmd $Release
    cd $HERE
else
    echoFatal "$ProjectLibFs not found."
    exit 99
fi

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of lrustxc.bash

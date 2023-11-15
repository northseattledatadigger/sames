#!/bin/bash
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# acceptancetest.bash - This is intended to uniformly access acceptance tests
# in the SAMESHOME/statistics1v/tests directory uniformly across all the 
# SamesLib.* implementations.  As such, all acceptance tests should be designed
# to comply through what happens via this script.

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Constants and Includes

readonly HERE=$PWD
readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
readonly SAMESHOME="$( cd $SCRIPT_DIR/.. &> /dev/null && pwd )"
readonly SAMESPROJECTHOME=$SCRIPT_DIR

source $SAMESPROJECTHOME/ProjectSpecs.bashenv

readonly PrimaryBatsTests=$SamesProjectTestsDs/test_SamesLib.acceptance.bats
readonly FirstTestDataSubjectFs=$SamesTestDataDs/sidewalkstreetratioupload.csv

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Default Values

CleanOuputs=false
LibraryLanguageUnderTest=ruby
LibraryVersionUnderTest=native
OutputFSpec=/dev/stdout
PrimaryOutputFSpec=$SAMESPROJECTHOME/BatsAcceptanceTests.log

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Procedures

catHeading() {
    local _lang="$1"
    local _version="$2"
    local _appfs="$3"
    local _lutfs="$4"
    local _ptest="$5"
    local _ftdsfs="$6"

    cat <<EOHEADING
Acceptance Test starting at $(date) for Language "$_lang", version "$_version"
AppUnderTestFs:         $_appfs
LibraryUnderTestFs:     $_lutfs
PrimaryBatsTests File:  $_ptest
FirstTestDataSubjectFs: $_ftdsfs

EOHEADING
}

catUsage() {
    cat <<EOU
USAGE:  $0 <options>
    -C Pre-clean out previous result files according to names used.
    -h This help text, without errors nor error exit.
    -l Specify language version under test(default '$LibraryLanguageUnderTest' of
    javascript, python3, ruby, rust)
    -O Specify no output, so just testing with pass fail result at end.
    -o Specify output filespec (default $OutputFSpec)
    -p Specify bats tests output log filespec (default $PrimaryOutputFSpec)
    -v Specify subtype version under test (default '$LibraryVersionUnderTest' of 
    amateur, naive, native, et al)
EOU
}

getLanguageExtensionForId() {
    case "$1" in
    c)
        echo -n "c"
        ;;
    c++)
        echo -n "cpp"
        ;;
    go)
        echo -n "go"
        ;;
    javascript)
        echo -n "js"
        ;;
    perl)
        echo -n "pl"
        ;;
    python3)
        echo -n "py"
        ;;
    ruby)
        echo -n "rb"
        ;;
    rust)
        echo -n "rs"
        ;;
    *)
        echoError 2 "Library Version Id '$1' is NOT recognized."
        exit 2
    esac
}

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Init

while getopts "Chl:Oop:v:" option
do
    case "${option}" in
    C)
        CleanOuputs=true
        ;;
    h)
        catUsage
        exit 0
        ;;
    l)
        if [[ -f $OPTARG ]]
        then
            LibraryLanguageUnderTest="$OPTARG"
        else
            echoError 1 "Library Language Id '$OPTARG' is NOT recognized."
            catUsage
            exit 2
        fi
        ;;
    O)
        OutputFSpec=/dev/null
        ;;
    o)
        OutputFSpec="$OPTARG"
        ;;
    p)
        PrimaryOutputFSpec="$OPTARG"
        ;;
    v)
        if [[ -f $LibraryVersionUnderTest ]]
        then
            LibraryVersionUnderTest="$OPTARG"
        else
            echoError 1 "Library Version Id '$OPTARG' is NOT recognized."
            catUsage
            exit 2
        fi
        ;;
    *)
        echoError 1 "Invalid option $option."
        catUsage
        exit 2
        ;;
    esac
done

readonly LanguageExtension=$(getLanguageExtensionForId $LibraryLanguageUnderTest)

## Begin Required Exports
## Note these 4 'exports' are required to provide access to these
## identifiers IN THE BATS TEST SCRIPT:
export AppUnderTest=$LibraryLanguageUnderTest.main.$LibraryVersionUnderTest
export AppUnderTestFs=$SamesProjectBin/$AppUnderTest
export LibraryUnderTestFs=$SAMESPROJECTHOME/$StdLibName.$LibraryVersionUnderTest.$LanguageExtension
export PrimaryOutputFSpec
export FirstTestDataSubjectFs
## End of Required Exports

if [[ ! -f $AppUnderTestFs ]]
then
    echoError 1 "App Under Test Filespec $AppUnderTestFs was NOT found."
    catUsage
    exit 1
fi

if [[ ! -f $LibraryUnderTestFs ]]
then
    echoError 1 "Library Under Test Filespec $LibraryUnderTestFs was NOT found."
    catUsage
    exit 1
fi

if $CleanOuputs
then
    if [[ -f $OutputFSpec ]]
    then
        rm -f $OutputFSpec
    fi
    if [[ -f $PrimaryOutputFSpec ]]
    then
        rm -f $PrimaryOutputFSpec
    fi
fi

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Main

catHeading $LibraryLanguageUnderTest $LibraryVersionUnderTest $AppUnderTestFs $LibraryUnderTestFs $PrimaryBatsTests $FirstTestDataSubjectFs

$PrimaryBatsTests >$OutputFSpec

echo "$(date) at end of processing."

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of acceptancetest.bash

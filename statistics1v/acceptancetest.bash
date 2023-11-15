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

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Procedures

catHeading() {
    local _lang="$2"
    local _version="$3"

    cat <<EOHEADING
Acceptance Test starting at $(date) for Language $_lang, version $_verison"
AppUnderTest:\t\t$AppUnderTest
AppUnderTestFs:\t\t$AppUnderTestFs
LibraryUnderTestFs:\t$LibraryUnderTestFs
PrimaryBatsTests File:\t$PrimaryBatsTests

EOHEADING
}

catUsage() {
    cat <<EOU
USAGE:  $0 <options>
    -h This help text, without errors nor error exit.
    -l Specify language version under test (javascript, python3, ruby, rust)
    -O Specify no output, so just testing with pass fail result at end.
    -o Specify output filespec.
    -v Specify subtype version under test (amateur, naive, native, et al)
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
        catUsage
        exit 2
    esac
}

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Init

LibraryLanguageUnderTestExtension=rb
LibraryLanguageUnderTest=ruby
LibraryVersionUnderTest=native
OutputFSpec=/dev/stdout

while getopts "hl:Oov:" option
do
    case "${option}" in
    h)
        catUsage
        exit 0
        ;;
    l)
        if [[ -f $OPTARG ]]
        then
            LibraryLanguageUnderTest="$OPTARG"
            LanguageExtension=$(getLanguageExtensionForId $OPTARG)
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

AppUnderTest=$LibraryLanguageUnderTest.main.$LibraryVersionUnderTest
AppUnderTestFs=$SamesProjectBin/$AppUnderTest
LibraryUnderTestFs=$SAMESPROJECTHOME/$StdLibName.$LibraryVersionUnderTest.$LanguageExtension

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

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Main

echoHeading

$PrimaryBatsTests >$OutputFSpec

echo "$(date) at end of processing."

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of acceptancetest.bash

#!/bin/bash
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# lrun.bash

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Constants and Includes

readonly HERE=$PWD
readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
readonly SAMESHOME="$( cd $SCRIPT_DIR/../.. &> /dev/null && pwd )"
readonly SAMESPROJECTHOME="$( cd $SCRIPT_DIR/.. &> /dev/null && pwd )"

source $SAMESPROJECTHOME/ProjectSpecs.bashenv

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Procedures

catUsage() {
    cat <<EOU
USAGE:  $0 <options>
EOU
}

listLanguageOptions() {
}

listSubTypeOptions() {
    local _implLang="$1"
}

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Init

RunMainApp=true
IntegrationTests=false
LanguageImplementation=ruby
Subtype=native
UnitTests=false

if (( $# > 0 ))
then
    while getopts "Bhil:s:u" option
    do
        case "${option}" in
        B)
            RunMainApp=false
            ;;
        h)
            catUsage
            exit 0
            ;;
        i)
            IntegrationTests=true
            ;;
        l)
            if sl_ValidateLanguageImplementation "$OPTARG"
            then
                export LanguageImplementation="$OPTARG"
            else
                echoError 1 "Invalid Lib Implementation Language Id '$OPTARG'."
                catUsage
                exit 1
            fi
            ;;
            ;;
        s)
            if sl_ValidateSubtype $_optArg
            then
                export Subtype=$_optArg
            else
                echoError 1 "Invalid Lib SubType '$_optArg'."
                catUsage
                exit 1
            fi
            ;;
        u)
            UnitTests=true
            ;;
        *)
            echoError 2 "Invalid option $option."
            catUsage
            exit 2
            ;;
        esac
    done
fi

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Main

    
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of lrun.bash

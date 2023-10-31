#!/bin/bash
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# lrun.bash

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Constants and Includes

source $HOME/sbin/SBinLib.bashenv

readonly HERE=$PWD

readonly SameBin=$HERE/bin
readonly SameBin=$HERE/lib

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Procedures

catUsage() {
    cat <<EOU
USAGE:  $0 <options>
EOU
}

validateSecondaryVariationInBin() {
    local _svO="$1"

    if [[ -f $SameBin/$ProjectName.$_svO ]]
    then
}

validateSecondaryVariationSrc() {
    local _svO="$1"

    if [[ -f $HERE/$ProjectName.$_svO ]]
        
    echoError 9 "No '$ProjectName.$OPTARG.$Rn' is not a valid secondary variation."

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Init

PrimaryExtension=rb
RunSecondaryVariation=native

if (( $# > 0 ))
then
    while getopts "chNnprs" option
    do
        case "${option}" in
        c)
            PrimaryExtension=c
            ;;
        b)
            PrimaryExtension=cpp
            ;;
        f)
            PrimaryExtension=for
            ;;
        g)
            PrimaryExtension=go
            ;;
        h)
            catUsage
            exit 0
            ;;
        j)
            PrimaryExtension=jl
            ;;
        n)
            PrimaryExtension=js
            ;;
        p)
            PrimaryExtension=pl
            ;;
        r)
            PrimaryExtension=rb
            ;;
        s)
            PrimaryExtension=rs
            ;;
        v)
            RunSecondaryVariation="$OPTARG"
            ;;
        y)
            PrimaryExtension=py
            ;;
        *)
            _Error "Invalid option $option."
            catUsage
            exit 1
            ;;
        esac
    done

fi

if validateSecondaryVariation $OPTARG
then
    RunSecondaryVariation="$OPTARG"
else
    echoError 9 "'$OPTARG' is not a valid secondary variation."
    catUsage
    exit 0
    ;;
fi

readonly ProjectLibFs=$HERE/$SameFilename.$LibSubtype.rs

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Main

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of lrun.bash

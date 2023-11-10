#!/bin/bash
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# dynamictest.bash

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Constants and Includes

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Procedures

generateCSVLineOfRandomNumbers() {
    local _numberToGenerate=$1
    local _randomNumberType=$2
    
    csvline=""
    for i in $(seq $_numberToGenerate)
    do
        rn=$(rand)
        csvline="$csvline,$rn"
    done
    echo $csvline
}

generateFileOfRandomNumberLines() {
    local _numberToGenerate=$1
    local _randomNumberType=$2
    
    csvline=""
    for i in $(seq $_numberToGenerate)
    do
        rn=$(rand)
        echo $rn
    done
}

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Init

DataInputFormat=CSVLine
DataInputType=RandomGenerated
DataOutputFormat=CSVLine
DataOutputType=STDOUT
DataOutput=STDOUT

while getopts "Bhil:s:u" option
do
    case "${option}" in
    1)
        DataOutputFormat=SimpleColumn
        ;;
    1)
        DataInputFormat=SimpleColumn
        ;;
    C)
        DataOutputFormat=CSVLine
        ;;
    c)
        DataInputFormat=CSVLine
        ;;
    F)
        DataOutput="$OPTARG"
        DataOutputType=STDOUT
    f)
        DataInputFSpec="$OPTARG"
        DataInputType=File
        ;;
    h)
        catUsage
        exit 0
        ;;
    J)
        DataOutputFormat=JSON
        ;;
    j)
        DataInputFormat=JSON
        ;;
    S)
        DataOutputType=StdOutput
        ;;
    s)
        DataInputType=StdInput
        ;;
    *)
        echoError 2 "Invalid option $option."
        catUsage
        exit 2
        ;;
    esac
done

readonly ProjectLibFs=$HERE/$SameProjectName.$LibSubtype.rs
if $CheckSetupOnly
then
    dumpRustBuildEnv
    exit 0
fi

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Main

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of dynamictest.bash

#!/bin/bash
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# generateSetOfRandomSamples.bash

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Constants and Includes

readonly MAXCOLUMNS=128
readonly MAXROWS=100000 # One Hundred Thousand.
                        # You can reconfigure to try bigger if you want.

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Procedures

catRandomGeneratorTypes() {
    cat <<EORGT
        SHUF:    Use the rand command line application, no qualifiers.
        URODd2:  Signed 2 byte integer using:       od -vAn -N2 -td2 < /dev/urandom
        URODd4:  Signed 4 byte integer using:       od -vAn -N4 -td4 < /dev/urandom
        URODd8:  Signed 8 byte integer using:.......od -vAn -N8 -td8 < /dev/urandom
        URODf4:  2 byte floating point using:       od -vAn -N2 -tf4 < /dev/urandom
        URODf8:  4 byte floating point using:       od -vAn -N4 -tf8 < /dev/urandom
        URODf16: 8 byte floating point using:.......od -vAn -N8 -tf16 < /dev/urandom
        URODo2:  2 byte octal using:                od -vAn -N2 -td2 < /dev/urandom
        URODo4:  4 byte octal using:                od -vAn -N4 -td4 < /dev/urandom
        URODo8:  8 byte octal using:................od -vAn -N8 -td8 < /dev/urandom
        URODu2:  Unsigned 2 byte integer using:     od -vAn -N2 -td2 < /dev/urandom
        URODu4:  Unsigned 4 byte integer using:     od -vAn -N4 -td4 < /dev/urandom
        URODu8:  Unsigned 8 byte integer using:.....od -vAn -N8 -td8 < /dev/urandom
        URODx2:  2 byte hexidecimal using:          od -vAn -N2 -tx2 < /dev/urandom
        URODx4:  4 byte hexidecimal using:          od -vAn -N4 -tx4 < /dev/urandom
        URODx8:  8 byte hexidecimal using:..........od -vAn -N8 -tx8 < /dev/urandom
        (NOTE That this list is maintained in three places in this script, so
        care should be taken in maintaining the list, as any change must be
        addressed in three places.  Coding it this way made sense at the time
        of writing given the nature of the script.)
EORGT
}

catUsage() {
    cat <<EOU
USAGE:  $0 <options>
while getopts "c:D:F:g:hr:" option
    -c  Display this help text without error.
    -D  list what is in the bin directory.
    -F  Exit cd-ing to the specified directory.
    -g  Random Number Genrator Type:
$( catRandomGeneratorTypes )
    -h  This help text.
    -r  Output row Dimension.  Should be a natural number from 1 to $MAXROWS.
    (You may notice I prefer to organize things in ASCII order, barring other
    over-riding logic.  I figure it's better to always know to look in sorted
    order rather than depending on constantly changing logic for placements.)
EOU
}


generateRandomDataItem() {
    local _generatorType=$1
echo "trace 0 _generatorType"
    case "$_generatorType" in
    SHUF)
        shuf -i 50000-150000 -n 1
        ;;
    esac
}

generateRandomDataRow() {
    local _columnDimension=$1
    local _generatorType=$2
    local _delimiterChar=$3
    
    for c in $(seq $_columnDimension)
    do
        generateRandomDataItem $_generatorType | tr -d '\n'
    done
    echo
}

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Init

ColumnDimension=1
DataOutputFSpec=
DataOutputType=STDOUT
DelimiterChar=NONE
GeneratorType=URODd2
RowDimension=16

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Main

for r in $(seq $RowDimension)
do
    generateRandomDataRow $ColumnDimension SHUF ","
done

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of generateSetOfRandomSamples.bash

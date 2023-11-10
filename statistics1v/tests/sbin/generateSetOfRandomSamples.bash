#!/bin/bash
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# generateSetOfRandomSamples.bash

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Constants and Includes

readonly DEFAULTColumns=1
readonly DEFAULTDelimiter=SPACE
readonly DEFAULTGeneratorType=RANDOM
readonly DEFAULTRows=16
readonly MAXCOLUMNS=128
readonly MAXROWS=100000 # One Hundred Thousand.
                        # You can reconfigure to try bigger if you want.

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Procedures

catRandomGeneratorTypes() {
    cat <<EORGT
        RANDOM:  Use the \$RANDOM environment variable.
        SHUF:    Use the shuf command line application, no qualifiers.
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
    Where options are:
    -c  Output column Dimension.  Should be a natural number from 1 to $MAXCOLUMNS.
    The default for this is presently $DEFAULTColumns.
    -D  Designates a delimiter type:  COLON, COMMA, PIPE, SEMICOLON, SPACE,
    and TAB are valid options.  The default is presently "$DEFAULTDelimiter".
    -F  Output Filespec may be specified.  Otherwise output goes to STDOUT.
    -g  Random Number Genrator Type (default is presently "$DEFAULTGeneratorType"):
$( catRandomGeneratorTypes )
    -h  This help text.
    -r  Output row Dimension.  Should be a natural number from 1 to $MAXROWS.
    The default for this is presently $DEFAULTRows.
    (You may notice I prefer to organize things in ASCII order, barring other
    over-riding logic.  I figure it's better to always know to look in sorted
    order rather than depending on constantly changing logic for placements.)
EOU
}

generateRandomDataItem() {
    local _generatorType=$1

    case "$_generatorType" in
    RANDOM)
        echo -n $RANDOM
        ;;
    shuf)
        shuf -i 50000-150000 -n 1
        ;;
    URODd2)
        od -vAn -N2 -td2 < /dev/urandom
        ;;
    URODd4)
        od -vAn -N4 -td4 < /dev/urandom
        ;;
    URODd8)
        od -vAn -N8 -td8 < /dev/urandom
        ;;
    URODf4)
        od -vAn -N2 -tf4 < /dev/urandom
        ;;
    URODf8)
        od -vAn -N4 -tf8 < /dev/urandom
        ;;
    URODf16)
        od -vAn -N8 -tf16 < /dev/urandom
        ;;
    URODo2)
        od -vAn -N2 -to2 < /dev/urandom
        ;;
    URODo4)
        od -vAn -N4 -to4 < /dev/urandom
        ;;
    URODo8)
        od -vAn -N8 -to8 < /dev/urandom
        ;;
    URODu2)
        od -vAn -N2 -tu2 < /dev/urandom
        ;;
    URODu4)
        od -vAn -N4 -tu4 < /dev/urandom
        ;;
    URODu8)
        od -vAn -N8 -tu8 < /dev/urandom
        ;;
    URODx2)
        od -vAn -N2 -tx2 < /dev/urandom
        ;;
    URODx4)
        od -vAn -N4 -tx4 < /dev/urandom
        ;;
    URODx8)
        od -vAn -N8 -tx8 < /dev/urandom
        ;;
    *)
        echo -n $RANDOM
        ;;
    esac
}

generateRandomDataRow() {
    local _columnDimension=$1
    local _generatorType=$2
    local _delimiterChar=$3
    
    for c in $(seq $_columnDimension)
    do
        if (( c > 1 ))
        then
            case "$_delimiterChar" in
            COLON)
                echo -n ":"
                ;;
            COMMA)
                echo -n ","
                ;;
            PIPE)
                echo -n "|"
                ;;
            SEMICOLON)
                echo -n ";"
                ;;
            SPACE)
                echo -n " "
                ;;
            TAB)
                echo -n "\t"
                ;;
            esac
        fi
        generateRandomDataItem $_generatorType | tr -d '\n'
    done
    echo
}

validateDimension() {
    local _dimensionNo="$1"

    if [[ $_dimensionNo =~ ^[0-9][0-9]*$ ]]
    then
        return 0
    fi
    return 1
}

validateGeneratorTypeId() {
    local _generatorType=$1

    case "$_generatorType" in
    RANDOM)
        return 0
        ;;
    shuf)
        return 0
        ;;
    URODd2)
        return 0
        ;;
    URODd4)
        return 0
        ;;
    URODd8)
        return 0
        ;;
    URODf4)
        return 0
        ;;
    URODf8)
        return 0
        ;;
    URODf16)
        return 0
        ;;
    URODo2)
        return 0
        ;;
    URODo4)
        return 0
        ;;
    URODo8)
        return 0
        ;;
    URODu2)
        return 0
        ;;
    URODu4)
        return 0
        ;;
    URODu8)
        return 0
        ;;
    URODx2)
        return 0
        ;;
    URODx4)
        return 0
        ;;
    URODx8)
        return 0
        ;;
    *)
        return 1
        ;;
    esac
}

validateGoodFilename() {
    local _fSpec="$1"

    if [[ -z "$_fSpec" ]]
    then
        return 1
    fi
    if [[ $_fSpec =~ ^[A-Za-z][A-Za-z0-9_]*$ ]]
    then
        return 0
    fi
    return 1
}

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Init

ColumnDimension=$DEFAULTColumns
DataOutputFSpec=
DataOutputType=STDOUT
DelimiterChar=$DEFAULTDelimiter
GeneratorType=$DEFAULTGeneratorType
RowDimension=$DEFAULTRows

while getopts "c:D:F:g:hr:" option
do
    case "${option}" in
    c)
        if validateDimension $OPTARG
        then
            ColumnDimension=$OPTARG
        else
            >&2 echo "'$OPTARG' is NOT a valid array dimension."
            catUsage
            exit 2
        fi
        ;;
    D)
        case "$OPTARG" in
        COLON)
            DelimiterChar=$OPTARG
            ;;
        COMMA)
            DelimiterChar=$OPTARG
            ;;
        PIPE)
            DelimiterChar=$OPTARG
            ;;
        SEMICOLON)
            DelimiterChar=$OPTARG
            ;;
        SPACE)
            DelimiterChar=$OPTARG
            ;;
        TAB)
            DelimiterChar=$OPTARG
            ;;
        *)
            >&2 echo "There is no Delimiter Type '$OPTARG' implemented."
            catUsage
            exit 2
            ;;
        esac
        ;;
    F)
        if validateGoodFilename "$OPTARG"
        then
            DataOutputFSpec=$OPTARG
            DataOutputType=FILESPEC
        else
            >&2 echo "This application will NOT accept '$OPTARG' as a filename."
            catUsage
            exit 2
        fi
        ;;
    g)
        if validateGeneratorTypeId $OPTARG
        then
            GeneratorType=$OPTARG
        else
            >&2 echo "There is no Generator Type '$OPTARG' implemented."
            catUsage
            exit 2
        fi
        ;;
    h)
        catUsage
        exit 0
        ;;
    r)
        if validateDimension $OPTARG
        then
            RowDimension=$OPTARG
        else
            >&2 echo "'$OPTARG' is NOT a valid array dimension."
            catUsage
            exit 2
        fi
        ;;
    *)
        >&2 "Invalid option $option."
        catUsage
        exit 2
        ;;
    esac
done

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Main

for r in $(seq $RowDimension)
do
    case "$DataOutputType" in
    FILESPEC)
        generateRandomDataRow $ColumnDimension $GeneratorType $DelimiterChar >>$DataOutputFSpec
        ;;
    STDOUT)
        generateRandomDataRow $ColumnDimension $GeneratorType $DelimiterChar
        ;;
    *)
        >&2 "Invalid Output Type option $DataOutputType."
        catUsage
        exit 3
        ;;
    esac
done

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of generateSetOfRandomSamples.bash

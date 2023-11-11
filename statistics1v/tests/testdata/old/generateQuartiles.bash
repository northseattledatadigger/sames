#!/bin/bash
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# generatePointStatistics.bash

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Constants and Includes

# The following are a manual duplication of what exists in the ruby version of
# the VectorOfContinuous class:
readonly ArithmeticMeanId='ArithmeticMean'
readonly CoefficientOfVariation='CoefficientOfVariation'
readonly GeometricMeanId='GeometricMean'
readonly IsEvenId='IsEven'
readonly KurtosisId='Kurtosis'
readonly MAEId='MAE' # Mean Absolute Error
readonly MaxId='Max'
readonly MedianId='Median'
readonly MinId='Min'
readonly ModeId='Mode'
readonly NId='N'
readonly SkewnessId='Skewness'
readonly StandardDeviation='StandardDeviation'
readonly SumId='Sum'

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Procedures

catUsage() {
    cat <<EOU
USAGE:  $0 <options>
while getopts "c:D:F:g:hr:" option
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

formatResultAACSV() {
    local _aMean=$1
    local _cOv=$2
    local _gMean=$3
    local _isEven=$4
    local _kurtOsis=$5
    local _mAe=$6
    local _mAx=$7
    local _mEdian=$8
    local _mIn=$9
    local _mOde=$10
    local _N=$11
    local _skewNess=$12
    local _stdDev=$13
    local _sUm=$14
    echo <<EOAACSV
"$ArithmeticMeanId", $_aMean
"$CoefficientOfVariation", $_cOv
"$GeometricMeanId", $_gMean
"$IsEvenId", $_isEven
"$KurtosisId", $_kurtOsis
"$MAEId", $_mAe
"$MaxId", $_mAx
"$MedianId", $_mEdian
"$MinId", $_mIn
"$ModeId", $_mOde
"$NId", $_N
"$SkewnessId", $_skewNess
"$StandardDeviation", $_stdDev
"$SumId", $_sUm
EOAACSV
}

formatResultCSVLine() {
    local _aMean=$1
    local _cOv=$2
    local _gMean=$3
    local _isEven=$4
    local _kurtOsis=$5
    local _mAe=$6
    local _mAx=$7
    local _mEdian=$8
    local _mIn=$9
    local _mOde=$10
    local _N=$11
    local _skewNess=$12
    local _stdDev=$13
    local _sUm=$14
    local _includeHdr=$15
    if [[ -z "$_includeHdr" ]]
    then
        _includeHdr=false
    fi
    local csvline="$_aMean,$_cOv,$_gMean,$_isEven,$_kurtOsis,$_mAe,$_mAx,$_mEdian,$_mIn,$_mOde,$_N,$_skewNess,$_stdDev,$_sUm"
    if $_includeHdr
        local csvhdr
        echo <<EOCSV
"$ArithmeticMeanId","$CoefficientOfVariation","$GeometricMeanId","$IsEvenId","$KurtosisId","$MAEId","$MaxId","$MedianId","$MinId","$ModeId","$NId","$SkewnessId","$StandardDeviation","$SumId"
$csvline
EOCSV
    then
        echo $csvline
    fi
}

generate_datamash_summary_appcsv() {
    local _inputFSpec="$1"
    local _outputFSpec="$2"
    local _singleLine="$3"
    cat <<EOCOMMENT
 2079  seq 10 | datamash sum 1 mean 1
 2080  seq 10 | datamash sum 1 stddev 1
 2081  seq 10 | datamash summary
 2085  seq 10 | datamash sum 1 geomean 1
 2086  seq 10 | datamash harmean 1 geomean 1
 2088  seq 10 | datamash harmmean 1 geomean 1
 2090  seq 10 | datamash harmmean 1 geomean 1 pskew 1
 2091  seq 10 | datamash harmmean 1 geomean 1 sskew 1
EOCOMMENT
}

generate_datamash_summary_unadorned() {
    local _inputFSpec="$1"
    local _outputFSpec="$2"
    cat <<EOCOMMENT
 2079  seq 10 | datamash sum 1 mean 1
 2080  seq 10 | datamash sum 1 stddev 1
 2081  seq 10 | datamash summary
 2085  seq 10 | datamash sum 1 geomean 1
 2086  seq 10 | datamash harmean 1 geomean 1
 2088  seq 10 | datamash harmmean 1 geomean 1
 2090  seq 10 | datamash harmmean 1 geomean 1 pskew 1
 2091  seq 10 | datamash harmmean 1 geomean 1 sskew 1
EOCOMMENT
}

generate_gnuplot_summary_appcsv() {
    local _inputFSpec="$1"
    local _outputFSpec="$2"
    local _singleLine="$3"
 #2071  seq 10 | gnuplot -e "stats '-' u 1"
 #2072  cat nums.txt | gnuplot -e "stats '-' u 1"
}

generate_pspp_summary_unadorned() {
    local _inputFSpec="$1"
    local _outputFSpec="$2"
 #2071  seq 10 | gnuplot -e "stats '-' u 1"
 #2072  cat nums.txt | gnuplot -e "stats '-' u 1"
}

generate_pspp_summary_appcsv() {
    local _inputFSpec="$1"
    local _outputFSpec="$2"
    local _singleLine="$3"
#Best pspp docs so far:  https://www.gnu.org/software/pspp/manual/pspp.html
#AND finally I found this to output to csv from pspp:
#pspp example004.sps -o x -O format=csv
}

generate_pspp_summary_unadorned() {
    local _inputFSpec="$1"
    local _outputFSpec="$2"
#Best pspp docs so far:  https://www.gnu.org/software/pspp/manual/pspp.html
#AND finally I found this to output to csv from pspp:
#pspp example004.sps -o x -O format=csv
}

generate_r_summary_appcsv() {
    local _inputFSpec="$1"
    local _outputFSpec="$2"
    local _singleLine="$3"
 #2044  R -q -e "x <- read.csv('nums.txt', header = F); summary(x); sd(x[ , 1])"
 #2075  seq 10 | R --slave -e 'x <- scan(file="stdin",quiet=TRUE); summary(x)'
}

generate_r_summary_unadorned() {
    local _inputFSpec="$1"
    local _outputFSpec="$2"
 #2044  R -q -e "x <- read.csv('nums.txt', header = F); summary(x); sd(x[ , 1])"
 #2075  seq 10 | R --slave -e 'x <- scan(file="stdin",quiet=TRUE); summary(x)'
}

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Init

AppToUse=datamash
ColumnToUse=1
DataInputFSpec=
DataOutputFSpec=/dev/stdout
DataOutputType=STDOUT
OutputFormat=Unadorned
SetToGenerate=SummaryPointStatistics

while getopts "a:c:dghi:lo:pqrt" option
do
    case "${option}" in
    a)
        AppToUse=datamash
        ;;
    c)
        ColumnToUse=$OPTARG
        ;;
    d)
        AppToUse=datamash
        ;;
    g)
        AppToUse=gnuplot
        ;;
    h)
        catUsage
        exit 0
        ;;
    i)
        DataInputFSpec="$OPTARG"
        if [[ -f $DataInputFSpec ]]
        then
            DataInputFSpec="$OPTARG"
        else
            >&2 "Input file '$OPTARG' NOT FOUND."
            catUsage
            exit 2
            ;;
        fi
        ;;
    o)
        DataOutput="$OPTARG"
        DataOutputType=FILESPEC
        ;;
    l)
        OutputFormat=CSVLine
        ;;
    p)
        AppToUse=pspp
        ;;
    q)
        SetToGenerate=Quartiles
        ;;
    r)
        AppToUse=r
        ;;
    t)
        OutputFormat=CSVTable
        ;;
    u)
        OutputFormat=Unadorned
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

if [[ $SetToGenerate = 'Quartiles' ]]
then
    case "$AppToUse" in
    datamash)
        generate_datamash_summary_appcsv >$DataOutputFSpec
        ;;
    gnuplot)
        ;;
    pspp)
        ;;
    r)
        ;;
    *)
        >&2 "$SetToGenerate output is not implemented for '$AppToUse'."
        catUsage
        exit 4
        ;;
    esac
elif [[ $SetToGenerate = 'SummaryPointStatistics' ]]
then
    case "$AppToUse" in
    datamash)
        ;;
    gnuplot)
        ;;
    pspp)
        ;;
    r)
        ;;
    *)
        >&2 "$SetToGenerate output is not implemented for '$AppToUse'."
        catUsage
        exit 4
        ;;
    esac
else
    >&2 "Programmer Error!!"
    >&2 "$SetToGenerate is NOT an implemented output set for this script."
    catUsage
    exit 4
    ;;
fi

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of generatePointStatistics.bash

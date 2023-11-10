#!/bin/bash
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# generatePointStatistics.bash

# NIU will indicate: NOT IN USE for a field for which data is not provided.

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
    Where options are:
    -B  Behead the file:  Presume the first line of the file is a CSV header, and leave it off.
    The default for this is presently $DEFAULTColumns.
    -c  Output column Dimension.  Should be a natural number from 1 to $MAXCOLUMNS.
    The default for this is presently $DEFAULTColumns.
    -d  Use the datamash app for processing.
    -g  Use the gnuplot app for processing.
    -h  This help text.
    -i  Specify the input file to use.  This is required at this time.
    -L  Set output format to CSVLineNoHdr, which is to say
    a single output line of CSV, without a header.
    -l  Set output format to CSVLineHdHdrr, which is to say
    a single output line of CSV, with a header.
    -n  Ouput using the default native format of the application chosen.
    -p  Use the pspp (similar to spss, apparently) app.
    -r  Use the r app.
    -t  Set output format to CSVTable, which is a csv file with the
    statistic name, and then value, each on it's own line, designed to be
    parsed into an associative array.
EOU
}

calculateIsEvenLocally() {
    local _n=$1
    if (( _n % 2 == 0 ))
    then
        echo -n true
    else
        echo -n false
    fi
}

formatResultCSVLine() {
    #echo "trace 0 formatResultCSVLine"
    local _aMean=$1
    local _cOv=$2
    local _gMean=$3
    local _isEven=$4
    local _kurtOsis=$5
    local _mAe=$6
    local _mAx=$7
    local _mEdian=$8
    local _mIn=$9
    local _mOde=${10}
    local _N=${11}
    local _skewNess=${12}
    local _stdDev=${13}
    local _sUm=${14}
    local _includeHdr=${15}
    if [[ -z "$_includeHdr" ]]
    then
        _includeHdr=false
    fi
    local csvline="$_aMean,$_cOv,$_gMean,$_isEven,$_kurtOsis,$_mAe,$_mAx,$_mEdian,$_mIn,$_mOde,$_N,$_skewNess,$_stdDev,$_sUm"
    if $_includeHdr
    then
        local csvhdr
        cat <<EOCSV
"$ArithmeticMeanId","$CoefficientOfVariation","$GeometricMeanId","$IsEvenId","$KurtosisId","$MAEId","$MaxId","$MedianId","$MinId","$ModeId","$NId","$SkewnessId","$StandardDeviation","$SumId"
$csvline
EOCSV
    else
        echo $csvline
    fi
}

formatResultCSVTable() {
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
    cat <<EOAACSV
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

generate_datamash_custom() {
    #echo "trace 0 generate_datamash_custom"
    # Note that headerless CSV input is presumed, as per the -t, qualifier.
    local _inputColumn="$1"
    local _inputFSpec="$2"
    local _outputCSVType="$3"

    local c=$_inputColumn

    local amean=$(      datamash -t, mean $c <$_inputFSpec  )
    local coeffv="NIU"
    local buffer=$(     datamash -t, geomean $c <$_inputFSpec  )
    local gmean=$(      printf '%.*f\n' 2 $buffer )
    local is_even
    local kurtosis=$(   datamash -t, skurt $c <$_inputFSpec  )
    local mae="NIU"
    local max=$(        datamash -t, max $c <$_inputFSpec  )
    local median=$(     datamash -t, median $c <$_inputFSpec  )
    local min=$(        datamash -t, min $c <$_inputFSpec  )
    local mode=$(       datamash -t, mode $c <$_inputFSpec  )
    local n
    local sskew=$(      datamash -t, sskew $c <$_inputFSpec  )
    local stddev=$(     datamash -t, sstdev $c <$_inputFSpec  )
    local sum=$(        datamash -t, sum $c <$_inputFSpec  )
    n=$(wc -l $_inputFSpec | awk '{print $1}')
    is_even=$(calculateIsEvenLocally $n)

    local _csvConfiguration="$1"

    if [[ $_outputCSVType = 'CSVLineHdr' ]]
    then
        formatResultCSVLine $amean $coeffv $gmean $is_even $kurtosis $mae $max $median $min $mode $n $sskew $stddev $sum true
    elif [[ $_outputCSVType = 'CSVLineNoHdr' ]]
    then
        formatResultCSVLine $amean $coeffv $gmean $is_even $kurtosis $mae $max $median $min $mode $n $sskew $stddev $sum false
    else
        formatResultCSVTable $amean $coeffv $gmean $is_even $kurtosis $mae $max $median $min $mode $n $sskew $stddev $sum
    fi
}

generate_datamash_native() {
    local _inputColumn=$1
    local _inputFSpec="$2"

    local c=$_inputColumn

    datamash -t, mean $c geomean $c skurt $c max $c median $c min $c mode $c sskew $c sstdev $c sum $c <$_inputFSpec
}

generate_gnuplot_custom() {
    local _inputFSpec="$1"

}

generate_pspp_native() {
    local _inputFSpec="$1"
 #2071  seq 10 | gnuplot -e "stats '-' u 1"
 #2072  cat nums.txt | gnuplot -e "stats '-' u 1"
}

generate_pspp_custom() {
    local _inputFSpec="$1"
#Best pspp docs so far:  https://www.gnu.org/software/pspp/manual/pspp.html
#AND finally I found this to output to csv from pspp:
#pspp example004.sps -o x -O format=csv
}

generate_r_custom() {
    local _inputFSpec="$1"
 #2044  R -q -e "x <- read.csv('nums.txt', header = F); summary(x); sd(x[ , 1])"
 #2075  seq 10 | R --slave -e 'x <- scan(file="stdin",quiet=TRUE); summary(x)'
}

generate_r_native() {
    local _inputFSpec="$1"
 #2044  R -q -e "x <- read.csv('nums.txt', header = F); summary(x); sd(x[ , 1])"
 #2075  seq 10 | R --slave -e 'x <- scan(file="stdin",quiet=TRUE); summary(x)'
}

validateDimension() {
    local _dimensionNo="$1"

    if [[ $_dimensionNo =~ ^[0-9][0-9]*$ ]]
    then
        return 0
    fi
    return 1
}

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Init

AppToUse=datamash
BeHead=false
ColumnToUse=1
InputFSpec=/dev/stdin
OutputFormat=Native

while getopts "Bc:dghi:nLlo:pqrt" option
do
    case "${option}" in
    B)  
        BeHead=true
        ;;
    c)
        if validateDimension $OPTARG
        then
            ColumnToUse=$OPTARG
        else
            >&2 echo "'$OPTARG' is NOT a valid array dimension."
            catUsage
            exit 2
        fi
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
        InputFSpec="$OPTARG"
        if [[ -f $InputFSpec ]]
        then
            InputFSpec="$OPTARG"
        else
            >&2 "Input file '$OPTARG' NOT FOUND."
            catUsage
            exit 2
        fi
        ;;
    L)
        OutputFormat=CSVLineNoHdr
        ;;
    l)
        OutputFormat=CSVLineHdr
        ;;
    n)
        OutputFormat=Native
        ;;
    p)
        AppToUse=pspp
        ;;
    r)
        AppToUse=r
        ;;
    t)
        OutputFormat=CSVTable
        ;;
    *)
        >&2 "Invalid option $option."
        catUsage
        exit 2
        ;;
    esac
done

if $BeHead
then
    OriginalInputFSpec=$InputFSpec
    TmpInputFSpec=$(mktemp)
    InputFSpec=$TmpInputFSpec
    tail -n+2 $OriginalInputFSpec >$InputFSpec
fi

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Main

if [[ $OutputFormat = 'CSVLineHdr' || $OutputFormat = 'CSVLineNoHdr' || $OutputFormat = 'CSVTable' ]]
then
    case "$AppToUse" in
    datamash)
        generate_datamash_custom $ColumnToUse $InputFSpec $OutputFormat
        ;;
    gnuplot)
        generate_gnuplot_custom $ColumnToUse $InputFSpec $OutputFormat
        ;;
    pspp)
        generate_pspp_custom $ColumnToUse $InputFSpec $OutputFormat
        ;;
    r)
        generate_r_custom $ColumnToUse $InputFSpec $OutputFormat
        ;;
    *)
        >&2 "$SetToGenerate output is not implemented for '$AppToUse'."
        catUsage
        exit 4
        ;;
    esac
elif [[ $OutputFormat = 'Native' ]]
then
    case "$AppToUse" in
    datamash)
        generate_datamash_native $ColumnToUse $InputFSpec
        ;;
    gnuplot)
        generate_gnuplot_native $ColumnToUse $InputFSpec
        ;;
    pspp)
        generate_pspp_native $ColumnToUse $InputFSpec
        ;;
    r)
        generate_r_native $ColumnToUse $InputFSpec
        ;;
    *)
        >&2 "$SetToGenerate output is not implemented for '$AppToUse'."
        catUsage
        exit 4
        ;;
    esac
else
    >&2 "Programmer Error!!"
    >&2 "Output Format '$OutputFormat' is NOT an implemented for this script."
    catUsage
    exit 4
fi

if [[ -e $TmpInputFSpec ]]
then
    rm $TmpInputFSpec
fi
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of generatePointStatistics.bash

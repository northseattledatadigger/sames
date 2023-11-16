#!/bin/bash
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# requestSamplePointStatistics.bash
# NOTE:  As of 2023/11/11, this is a working script, but limited, and not fully
# cross checked.  I'll use it this way for my automation test purposes, and then
# revisit it later for enhancements.  Perhaps if I find any big bugs in the
# mean-time, I'll make the commit comment clear about it, or even tag the check-
# in.
#

# NIU will indicate: NOT IN USE for a field for which data is not provided.

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Constants and Includes

readonly HERE=$PWD
readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
readonly SAMESHOME="$( cd $SCRIPT_DIR/../.. &> /dev/null && pwd )"
readonly SAMESPROJECTHOME="$( cd $SCRIPT_DIR/.. &> /dev/null && pwd )"

source $SAMESPROJECTHOME/ProjectSpecs.bashenv

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Constants and Includes

# The following are a manual duplication of what exists in the ruby version of
# the VectorOfContinuous class:
readonly ArithmeticMeanId='ArithmeticMean'
readonly ArMeanAADId='ArithmeticMeanAAD' # AMean Average Absolute Deviation
readonly CoefficientOfVariationId='CoefficientOfVariation'
readonly GeometricMeanId='GeometricMean'
readonly HarmonicMeanId='HarmonicMean'
readonly IsEvenId='IsEven'
readonly KurtosisId='Kurtosis'
readonly MADId='MAD' # Mean Absolute Difference:  Note I have removed this as
# it appears to be too obscure for now, and is not calculated, from what I
# found in November 2023, in any of the popular apps.  The calculation is
# still in my code, and I'll implement some basic simple unit tests for it,
# and check it by hand alone; NO acceptance tests.
readonly MaxId='Max'
readonly MedianId='Median'
readonly MedianAADId='MedianAAD' # Median Average Absolute Deviation
readonly MinId='Min'
readonly ModeId='Mode'
readonly NId='N'
readonly SkewnessId='Skewness'
readonly StandardDeviationId='StandardDeviation'
readonly SumId='Sum'

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Procedures

_calculateIsEvenLocally() {
    local _n=$1
    if (( _n % 2 == 0 ))
    then
        echo -n true
    else
        echo -n false
    fi
}

_parseColumn() {
    local _inputColumn="$1"
    local _inputFSpec="$2"

    local c=$_inputColumn

    cat $_inputFSpec | awk -F, "{print \$$c}"
}

_parseColumnToPSPPbufferFile() {
    local _inputColumn="$1"
    local _inputFSpec="$2"

    local fspec=$(mktemp --suffix=.sps)
    cat <<EOSPSTOP >$fspec
data list free / X .
begin data
EOSPSTOP
    _parseColumn $_inputColumn $_inputFSpec >>$fspec
    cat <<EOSPSBOTTOM >>$fspec
end data .

descript all
/stat=all
/format=serial.
EOSPSBOTTOM
echo $fspec
}

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

formatResultCSVLine() {
    local _aMean=$1
    local _aMeanAAD=$2
    local _cOv=$3
    local _gMean=$4
    local _hMean=$5
    local _isEven=$6
    local _kurtOsis=$7
    local _mAx=$8
    local _mEdian=${9}
    local _mEdianAAD=${10}
    local _mIn=${11}
    local _mOde=${12}
    local _N=${13}
    local _skewNess=${14}
    local _stdDev=${15}
    local _sUm=${16}
    local _includeHdr=${17}
    if [[ -z "$_includeHdr" ]]
    then
        _includeHdr=false
    fi
    local csvline="$_aMean,$_aMeanAAD,$_cOv,$_gMean,$_hMean,$_isEven,$_kurtOsis,$_mAx,$_mEdian,$mEdianAAD,$_mIn,$_mOde,$_N,$_skewNess,$_stdDev,$_sUm"
    if $_includeHdr
    then
        local csvhdr
        cat <<EOCSV
"$ArithmeticMeanId","$ArithmeticMeanAADId","$CoefficientOfVariationId","$GeometricMeanId","$HarmonicMeanId","$IsEvenId","$KurtosisId","$MaxId","$MedianId","$MedianAADId","$MinId","$ModeId","$NId","$SkewnessId","$StandardDeviationId","$SumId"
$csvline
EOCSV
    else
        echo $csvline
    fi
}

formatResultCSVTable() {
    local _aMean=$1
    local _aMeanAAD=$2
    local _cOv=$3
    local _gMean=$4
    local _hMean=$5
    local _isEven=$6
    local _kurtOsis=$7
    local _mAx=$8
    local _mEdian=${9}
    local _mEdianAAD=${10}
    local _mIn=${11}
    local _mOde=${12}
    local _N=${13}
    local _skewNess=${14}
    local _stdDev=${15}
    local _sUm=${16}
    cat <<EOAACSV
"$ArithmeticMeanId", $_aMean
"$ArMeanAADId", $_aMeanAAD
"$CoefficientOfVariationId", $_cOv
"$GeometricMeanId", $_gMean
"$HarmonicMeanId", $_hMean
"$IsEvenId", $_isEven
"$KurtosisId", $_kurtOsis
"$MaxId", $_mAx
"$MedianId", $_mEdian
"$MedianAADId", $_mEdianAAD
"$MinId", $_mIn
"$ModeId", $_mOde
"$NId", $_N
"$SkewnessId", $_skewNess
"$StandardDeviationId", $_stdDev
"$SumId", $_sUm
EOAACSV
}

formatResultQuartiles() {
    local _mIn=$1
    local _q1=$2
    local _mEdian=$3
    local _q3=$4
    local _mAx=$7
    echo "$_mIn,$_q1,$_mEdian,$_q3,$_mAx"
}

generate_datamash_custom() {
    local _aMean=$1
    local _aMeanAAD=$2
    local _cOv=$3
    local _gMean=$4
    local _hMean=$5
    local _isEven=$6
    local _kurtOsis=$7
    local _mAx=$8
    local _mEdian=${9}
    local _mEdianAAD=${10}
    local _mIn=${11}
    local _mOde=${12}
    local _N=${13}
    local _skewNess=${14}
    local _stdDev=${15}
    local _sUm=${16}
    cat <<EOAACSV
"$ArithmeticMeanId", $_aMean
"$ArMeanAADId", $_aMeanAAD
"$CoefficientOfVariationId", $_cOv
"$GeometricMeanId", $_gMean
"$HarmonicMeanId", $_hMean
"$IsEvenId", $_isEven
"$KurtosisId", $_kurtOsis
"$MaxId", $_mAx
"$MedianId", $_mEdian
"$MedianAADId", $_medianAAD
"$MinId", $_mIn
"$ModeId", $_mOde
"$NId", $_N
"$SkewnessId", $_skewNess
"$StandardDeviationId", $_stdDev
"$SumId", $_sUm
EOAACSV
}

formatResultQuartiles() {
    local _mIn=$1
    local _q1=$2
    local _mEdian=$3
    local _q3=$4
    local _mAx=$7
    echo "$_mIn,$_q1,$_mEdian,$_q3,$_mAx"
}

generate_datamash_custom() {
    local _inputColumn="$1"
    local _inputFSpec="$2"
    local _outputCSVType="$3"

    local c=$_inputColumn

    local amean=$(      datamash -t, mean $c    <$_inputFSpec  )
    local ameanaad="NIU"
    local coeffv="NIU"
    local buffer=$(     datamash -t, geomean $c <$_inputFSpec  )
    local gmean=$(      printf '%.*f\n' 2 $buffer )
    buffer=$(           datamash -t, harmmean $c <$_inputFSpec  )
    local hmean=$(      printf '%.*f\n' 2 $buffer )
    local is_even
    local kurtosis=$(   datamash -t, skurt $c   <$_inputFSpec  )
    local max=$(        datamash -t, max $c     <$_inputFSpec  )
    local median=$(     datamash -t, median $c  <$_inputFSpec  )
    local medianaad=$(  datamash -t, madraw $c  <$_inputFSpec  )
    local min=$(        datamash -t, min $c     <$_inputFSpec  )
    local mode=$(       datamash -t, mode $c    <$_inputFSpec  )
    local n
    local q1=$(         datamash -t, q1 $c      <$_inputFSpec  )
    local q3=$(         datamash -t, q3 $c      <$_inputFSpec  )
    local sskew=$(      datamash -t, sskew $c   <$_inputFSpec  )
    local stddev=$(     datamash -t, sstdev $c  <$_inputFSpec  )
    local sum=$(        datamash -t, sum $c     <$_inputFSpec  )
    n=$(wc -l $_inputFSpec | awk '{print $1}')
    is_even=$(_calculateIsEvenLocally $n)

    case $_outputCSVType in
        CSVLineHdr)
            formatResultCSVLine $amean $ameanaad $coeffv $gmean $hmean $is_even $kurtosis $max $median $medianaad $min $mode $n $sskew $stddev $sum true
            ;;
        CSVLineNoHdr)
            formatResultCSVLine $amean $ameanaad $coeffv $gmean $hmean $is_even $kurtosis $max $median $medianaad $min $mode $n $sskew $stddev $sum false
            ;;
        CSVTable)
            formatResultCSVTable $amean $ameanaad $coeffv $gmean $hmean $is_even $kurtosis $max $median $medianaad $min $mode $n $sskew $stddev $sum 
            ;;
        Quartiles)
            formatResultQuartiles $min $q1 $median $q3 $max
            ;;
    esac
}

generate_datamash_native() {
    local _inputColumn=$1
    local _inputFSpec="$2"

    local c=$_inputColumn

    datamash -t, mean $c geomean $c harmmean $c skurt $c max $c median $c madraw $c min $c mode $c sskew $c sstdev $c sum $c <$_inputFSpec
}

generate_gnuplot__native() {
    local _inputColumn=$1
    local _inputFSpec="$2"

    local c=$_inputColumn

    cat $_inputFSpec | gnuplot -e 'set datafile separator ","' -e "stats '-' u $c" 2>&1
}

generate_gnuplot_custom() {
    local _inputColumn="$1"
    local _inputFSpec="$2"
    local _outputCSVType="$3"

    local c=$_inputColumn
    local i=$_inputFSpec

    local amean=$(      generate_gnuplot__native $c "$i" | grep 'Mean:' | awk '{print $2}' )
    local ameanaad="NIU"
    local coeffv="NIU"
    local gmean="NIU"
    local hmean="NIU"
    local is_even
    local kurtosis=$(   generate_gnuplot__native $c "$i" | grep 'Kurtosis:'         | awk '{print $2}' )
    local max=$(        generate_gnuplot__native $c "$i" | grep 'Maximum:'          | awk '{print $2}' )
    local median=$(     generate_gnuplot__native $c "$i" | grep 'Median:'           | awk '{print $2}' )
    local medianaad="NIU"
    local min=$(        generate_gnuplot__native $c "$i" | grep 'Minimum:'          | awk '{print $2}' )
    local mode="NIU"
    local n=$(          generate_gnuplot__native $c "$i" | grep 'Records:'          | awk '{print $2}' )
    local q1=$(         generate_gnuplot__native $c "$i" | grep 'Quartile:'         | awk '{print $2}' | head -1 )
    local q3=$(         generate_gnuplot__native $c "$i" | grep 'Quartile:'         | awk '{print $2}' | tail -1 )
    local sskew=$(      generate_gnuplot__native $c "$i" | grep 'Skewness:'         | awk '{print $2}' )
    local stddev=$(     generate_gnuplot__native $c "$i" | grep 'Sample StdDev:'    | awk '{print $3}' )
    local sum=$(        generate_gnuplot__native $c "$i" | grep 'Sum:'              | awk '{print $2}' )

    is_even=$(_calculateIsEvenLocally $n)

    case $_outputCSVType in
        CSVLineHdr)
            formatResultCSVLine $amean $ameanaad $coeffv $gmean $hmean $is_even $kurtosis $max $median $medianaad $min $mode $n $sskew $stddev $sum true
            ;;
        CSVLineNoHdr)
            formatResultCSVLine $amean $ameanaad $coeffv $gmean $hmean $is_even $kurtosis $max $median $medianaad $min $mode $n $sskew $stddev $sum false
            ;;
        CSVTable)
            formatResultCSVTable $amean $ameanaad $coeffv $gmean $hmean $is_even $kurtosis $max $median $medianaad $min $mode $n $sskew $stddev $sum 
            ;;
        Quartiles)
            formatResultQuartiles $min $q1 $median $q3 $max
            ;;
    esac
}

generate_gnuplot_native() {
    local _inputColumn=$1
    local _inputFSpec="$2"

    local c=$_inputColumn

    generate_gnuplot__native $_inputColumn "$_inputFSpec" # So exactly the same simple thing, placed before for ASCII order.
}

generate_pspp_custom() {
    #Best pspp docs so far:  https://www.gnu.org/software/pspp/manual/pspp.html
    local _inputColumn=$1
    local _inputFSpec="$2"
    local _outputCSVType="$3"

    local ifspec=$(_parseColumnToPSPPbufferFile $_inputColumn "$_inputFSpec")
    local result=$(pspp $ifspec -O format=csv | grep '^X,')
    rm -f $ifspec

    local amean=$(      echo -n $result | cut -d, -f3)
    local ameanaad="NIU"
    local coeffv="NIU"
    local gmean="NIU"
    local hmean="NIU"
    local is_even
    local kurtosis=$(   echo -n $result | cut -d, -f7)
    local max=$(        echo -n $result | cut -d, -f13)
    local median="NIU"
    local medianaad="NIU"
    local min=$(        echo -n $result | cut -d, -f12)
    local mode="NIU"
    local n=$(          echo -n $result | cut -d, -f2)
    local q1="NIU"
    local q3="NIU"
    local sskew=$(      echo -n $result | cut -d, -f9)
    local stddev=$(     echo -n $result | cut -d, -f5)
    local sum=$(        echo -n $result | cut -d, -f14)

    is_even=$(_calculateIsEvenLocally $n)

    case $_outputCSVType in
        CSVLineHdr)
            formatResultCSVLine $amean $ameanaad $coeffv $gmean $hmean $is_even $kurtosis $max $median $medianaad $min $mode $n $sskew $stddev $sum true
            ;;
        CSVLineNoHdr)
            formatResultCSVLine $amean $ameanaad $coeffv $gmean $hmean $is_even $kurtosis $max $median $medianaad $min $mode $n $sskew $stddev $sum false
            ;;
        CSVTable)
            formatResultCSVTable $amean $ameanaad $coeffv $gmean $hmean $is_even $kurtosis $max $median $medianaad $min $mode $n $sskew $stddev $sum 
            ;;
        Quartiles)
            formatResultQuartiles $min $q1 $median $q3 $max
            ;;
    esac
}

generate_pspp_native() {
    #Best pspp docs so far:  https://www.gnu.org/software/pspp/manual/pspp.html
    local _inputColumn=$1
    local _inputFSpec="$2"
    local ifspec=$(_parseColumnToPSPPbufferFile $_inputColumn "$_inputFSpec")
    pspp $ifspec -O format=csv
    #rm -f $ifspec
}

generate_r_custom() {
 #2044  R -q -e "x <- read.csv('nums.txt', header = F); summary(x); sd(x[ , 1])"
 #2075  seq 10 | R --slave -e 'x <- scan(file="stdin",quiet=TRUE); summary(x)'
    local _inputColumn=$1
    local _inputFSpec="$2"
    local _outputCSVType="$3"

    local c=$_inputColumn

    local amean=$(  _parseColumn $c $_inputFSpec | R --slave -e 'x <- scan(file="stdin",quiet=TRUE); mean(x)' | awk '{print $2}')
    local ameanaad="NIU"
    local coeffv="NIU"
    local gmean="NIU"
    local hmean="NIU"
    local is_even
    local kurtosis="NIU"
    local max=$(    _parseColumn $c $_inputFSpec | R --slave -e 'x <- scan(file="stdin",quiet=TRUE); summary(x)' | tail -1 | awk '{print $6}')
    local median=$( _parseColumn $c $_inputFSpec | R --slave -e 'x <- scan(file="stdin",quiet=TRUE); summary(x)' | tail -1 | awk '{print $4}')
    local medianaad="NIU"
    local min=$(    _parseColumn $c $_inputFSpec | R --slave -e 'x <- scan(file="stdin",quiet=TRUE); summary(x)' | tail -1 | awk '{print $1}')
    local mode="NIU"
    local n
    local q1=$(     _parseColumn $c $_inputFSpec | R --slave -e 'x <- scan(file="stdin",quiet=TRUE); summary(x)' | tail -1 | awk '{print $2}')
    local q3=$(     _parseColumn $c $_inputFSpec | R --slave -e 'x <- scan(file="stdin",quiet=TRUE); summary(x)' | tail -1 | awk '{print $5}')
    local sskew="NIU"
    local stddev=$( _parseColumn $c $_inputFSpec | R --slave -e 'x <- scan(file="stdin",quiet=TRUE); sd(x)' | awk '{print $2}')
    local sum=$(    _parseColumn $c $_inputFSpec | R --slave -e 'x <- scan(file="stdin",quiet=TRUE); sum(x)' | awk '{print $2}')

    n=$(wc -l $_inputFSpec | awk '{print $1}')
    is_even=$(_calculateIsEvenLocally $n)

    case $_outputCSVType in
        CSVLineHdr)
            formatResultCSVLine $amean $ameanaad $coeffv $gmean $hmean $is_even $kurtosis $max $median $medianaad $min $mode $n $sskew $stddev $sum true
            ;;
        CSVLineNoHdr)
            formatResultCSVLine $amean $ameanaad $coeffv $gmean $hmean $is_even $kurtosis $max $median $medianaad $min $mode $n $sskew $stddev $sum false
            ;;
        CSVTable)
            formatResultCSVTable $amean $ameanaad $coeffv $gmean $hmean $is_even $kurtosis $max $median $medianaad $min $mode $n $sskew $stddev $sum 
            ;;
        Quartiles)
            formatResultQuartiles $min $q1 $median $q3 $max
            ;;
    esac
}

generate_r_native() {
    # Also example R -q -e "x <- read.csv('$_inputFSpec', header = F); summary(x); sd(x[ , 1])"
    local _inputColumn=$1
    local _inputFSpec="$2"

    echo "Summary:  "
    _parseColumn $_inputColumn $_inputFSpec | R --slave -e 'x <- scan(file="stdin",quiet=TRUE); summary(x)'
    echo -n "Std dev:  "
    _parseColumn $_inputColumn $_inputFSpec | R --slave -e 'x <- scan(file="stdin",quiet=TRUE); sd(x)'
    echo -n "Sum:  "
    _parseColumn $_inputColumn $_inputFSpec | R --slave -e 'x <- scan(file="stdin",quiet=TRUE); sum(x)'
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
InputFSpec=
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
    q)
        OutputFormat=Quartiles
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

if [[ -z $InputFSpec ]]
then
    echoError 1 "You must specify an input file."
    catUsage
    exit 1
fi

if $BeHead
then
    OriginalInputFSpec=$InputFSpec
    TmpInputFSpec=$(mktemp)
    InputFSpec=$TmpInputFSpec
    tail -n+2 $OriginalInputFSpec >$InputFSpec
fi

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Main

if [[ $OutputFormat = 'CSVLineHdr' || $OutputFormat = 'CSVLineNoHdr' || $OutputFormat = 'CSVTable' || $OutputFormat = 'Quartiles' ]]
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
        >&2 echo "$SetToGenerate output is not implemented for '$AppToUse'."
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

if [[ -n $TmpInputFSpec && -e $TmpInputFSpec ]]
then
    rm $TmpInputFSpec
fi
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of requestSamplePointStatistics.bash

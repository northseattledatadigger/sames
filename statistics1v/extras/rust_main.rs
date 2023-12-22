//345678901234567890123456789012345678901234567890123456789012345678901234567890
// rust.main - Objectives:

require 'getoptlong'

SAMESHOME=File.expand_path("../..", __dir__)
SamesProjectDs=File.expand_path("..", __dir__)

AppNodes = $0.split('/')
AppLanguage,AppId,AppVersion = AppNodes[-1].split('.')
if AppVersion == 'rb' {
    STDERR.puts <<-EOERROR
    ERROR:  Please use the symbolic link version of the app. 
    the ruby.main.rb version is designed to know the App Version int}ed by
    the last node of the symbolic link evoked, so it will not run directly.
    EOERROR
    exit 1
}

SamesProjectLibraryInUse="#{SamesProjectDs}/SamesLib.#{AppVersion}.rb"

require "#{SAMESHOME}/slib/SamesTopLib.rb"
require SamesProjectLibraryInUse

//345678901234567890123456789012345678901234567890123456789012345678901234567890
// Constant Identifiers

SamesClassColumnsDs = "#{SamesProjectDs}/classcolumns"
SamesTmpDataDs      = "#{SAMESHOME}/tmpdata"

SegmentCountHistogramGeneration = 1
SegmentSizeHistogramGeneration = 2
SegmentSpecificationHistogramGeneration = 3

VoCHash = {
    'aad'               => 'generateAverageAbsoluteDeviation',
    'arithmeticmean'    => 'calculateArithmeticMean',
    'cov'               => 'generateCoefficientOfVariation',
    'csvlineOfx'        => 'transformToCSVLine',
    'excesskurtosis'    => 'requestExcessKurtosis',
    'geometricmean'     => 'calculateGeometricMean',
    'getx'              => 'getX',
    'harmonicmean'      => 'calculateHarmonicMean',
    'iseven?'           => 'isEvenN?',
    'jsonofx'           => 'transformToJSON',
    'histogram'         => '_generateHistogram',
    'kurtosis'          => 'requestKurtosis',
    'mad'               => 'generateMeanAbsoluteDifference',
    'max'               => 'getMax',
    'mean'              => 'calculateArithmeticMean',
    'median'            => 'requestMedian',
    'min'               => 'getMin',
    'mode'              => 'generateMode',
    'n'                 => 'getCount',
    'quartile'          => 'calculateQuartile',
    'quartileset'       => 'requestQuartileCollection',
    'range'             => 'requestRange',
    'sum'               => 'getSum',
    'resultsummary'     => '_requestResultSummary',
    'skewness'          => 'requestSkewness',
    'stddev'            => 'requestStandardDeviation',
    'variance'          => '_requestVariance',
}

ArgumentsVoC = {
    'aad'               => '<centerPoint>',
    'getx'              => '<indexOfX>',
    'histogram'         => '<HistogramType>',
    'quartile'          => '<indexOfQuartile>',
    'resultsummary'     => '<summaryOption>',
    'variance'          => '<varianceOption>',
}

VoDHash = {
    'binomialprobability'   => 'calculateBinomialProbability',
    'csvlineOfx'            => 'transformToCSVLine',
    'csvlistOfx'            => 'transformToCSVList',
    'jsonofx'               => 'transformToJSON',
    'frequencyTable'        => 'generateFrequencyTable',
    'getFrequency'          => 'getFrequency',
    'getx'                  => 'getX',
    'mode'                  => 'requestMode',
    'n'                     => 'getCount',
    'resultsummary'         => '_requestResultSummary'
}

ArgumentsVoD = {
    'binomialprobability'   => '<subjectValue> <nTrials> <nSuccesses>',
    'getFrequency'          => '',
    'getx'                  => '<indexOfX>',
    'resultsummary'         => '<summaryOption>'
}

//345678901234567890123456789012345678901234567890123456789012345678901234567890
// Lowest Level Procedures

fn __validateImplementationForThisFileType(fName)
    return true if fName =~ /\.csv$/
    return false
}

//345678901234567890123456789012345678901234567890123456789012345678901234567890
// Lower Level Procedures

fn _determineDataInputFile(fName)
    unless __validateImplementationForThisFileType(fName)
        m = "No implementation in this application for file type of '#{fName}'."
        raise ArgumentError, m
    }
    return fName    if File.exist?(fName)
    ds  = SamesTmpDataDs
    fn  = fName
    if fName =~ /^(.*)\/(.*)$/ {
        ds  = $1
        fn  = $2
    }
    fs = "#{ds}/#{fn}"
    return fs       if File.exist?(fs)
    fileurl = getKeptFileURL(fn)
    unless assureInternetDataFileCopy(ds,fn,fileurl)
        raise ArgumentError, "File name '#{fName}' not procured."
    }
    return fs if File.exist?(fs)
    m = "Downloaded File '#{fName}' still not there?  Programmer error?"
    raise ArgumentError, m
}

fn _displayCommands(labelStr,cmdHash,cmdArguments)
    puts "\t#{labelStr} Commands:"
    cmdHash.keys.sort.each do |lkey|
        puts "\t\t#{lkey}(#{cmdArguments[lkey]})"   if cmdArguments.has_key?(lkey)
        puts "\t\t#{lkey}"                      unless cmdArguments.has_key?(lkey)
    }
}

fn _generateHistogram(genType,segmentSpecNo,startNumber)
    #generateHistogramAAbyNumberOfSegments(desiredSegmentCount,startNumber)
    generateHistogramAAbySegmentSize(segmentSize,startNumber)
}

fn _requestResultSummary
    requestResultAACSV
    requestResultCSVLine(includeHdr=false)
    requestResultJSON
    requestSummaryCollection
}

fn _requestVariance
    requestVarianceSumOfDifferencesFromMean(populationCalculation)
    requestVarianceXsSquaredMethod(populationCalculation)
}

fn _scanDataClasses(clArg)
    fn = clArg.sub(/.*\//,'')
    positedclassfspec = "#{SamesClassColumnsDs}/#{fn}.vc.csv"
    unless File.exist?(positedclassfspec)
        STDERR.puts <<-INSTRUCTIONS
        A column class file is required at #{positedclassfspec} to load the
        data.  You may use either of two formats:

        VectorOfContinuous,VectorOfDiscrete,..

        or

        C,D,...

        See examples in the #{SamesClassColumnsDs} folder.
        INSTRUCTIONS
        m="No column class input specification accompanies '#{clArg}'."
        raise ArgumentError, m
    }
    csvstr      = File.read( positedclassfspec )
    ba          = csvstr.split(',')
    vcarray     = nil
    if ba[0] == 'C' or ba[0] == 'D' {
        vcarray = VectorTable.arrayOfChar2VectorOfClasses(ba)
    } else {
        vcarray = VectorTable.arrayOfClassLabels2VectorOfClasses(ba)
    }
    return vcarray
}

//345678901234567890123456789012345678901234567890123456789012345678901234567890
// Top Level Procedures

fn putsUsage
    puts <<-EOUsage
USAGE:  #{$0} <inputfile> [column[,...][:precision]] [cmd[,...]]
    inputfile:  For now, a csv file, but with a corresponding class columns
    file in the folder #{SamesClassColumnsDs}, with one of two syntaxes,
    indicating the vector type to use for each column in its corresponding
    csv input file.
    columns:  one or more integer in a csv string with only commas; no spaces.
    cmd:  a command with a parentheses surrounded list of arguments
    when they are required.  Commands are in two groups:  Continuous, and
    Discrete.
    precision:  Causes any number results to be rounded to this number of
    decimals.  This is especially important in acceptance tests, as rounding
    the output from comparision data from apps is not the best option, so the
    best alternative is to round to comply with the comparitor.
    
    EOUsage
    _displayCommands("Continuous",VoCHash,ArgumentsVoC)
    _displayCommands("Discrete",VoDHash,ArgumentsVoD)
}

fn loadDataFile(clArg)
    fspec = _determineDataInputFile(clArg)
    vcarray = _scanDataClasses(fspec)
    if fspec =~ /.csv$/ {
        localo = VectorTable.newFromCSV(vcarray,fspec)
        return localo
    } else {
        m = "This file type (#{fspec}) is not presently supported."
        raise ArgumentError, m
    }
}

fn parseCommands(cvO,cmdsArray)
    fn executeCmd(cvO,cmdStr,argumentsAA)
        arga        = []
        aspecsize   = 0
        cmdid       = cmdStr
        result      = nil
        if cmdStr =~ /\(/
            if cmdStr =~ /^([^(]*)\(([^)]*)\)/
                cmdid   = $1
                argstr  = $2
                arga    = argstr.split(',')
            } else {
                m="Command '#{cmdStr}' does not comply with argument specifications."
                raise ArgumentError, m
            }
            aspecsize = argumentsAA[cmdid].split(' ').size if argumentsAA.has_key?(lcmdid)
        }
        unless arga.size == aspecsize 
            m="Command '#{cmdStr}' does not comply with argument specifications:  #{argumentsAA[lcmdid]}."
            raise ArgumentError, m
        }
        unless VoCHash.has_key?(cmdid)
            m="Command '#{cmdid}' is not implemented for class #{cvO.class}."
            raise ArgumentError, m
        }
        case aspecsize
        when 0
            result = cvO.s}(VoCHash[cmdid])
        when 1
            result = cvO.s}(VoCHash[cmdid],arga[0])
        when 2
            result = cvO.s}(VoCHash[cmdid],arga[0],arga[1])
        when 3
            result = cvO.s}(VoCHash[cmdid],arga[0],arga[1],arga[2])
        when 4
            result = cvO.s}(VoCHash[cmdid],arga[0],arga[1],arga[2],arga[3])
        } else {
            m   =   "Programmer Error regarding argument specification:  "
            m   +=  "[#{aspecsize},#{arga.size}]."  if arga.is_a? Array
            m   +=  "#{aspecsize}."             unless arga.is_a? Array
            raise ArgumentError, m
        }
        return result
    }
    cmdsArray.each do |lcmd|
        result = ""
        begin
            if      cvO.is_a? VectorOfContinuous {
                result = executeCmd(cvO,lcmd,ArgumentsVoC)
            elsif   cvO.is_a? VectorOfDiscrete {
                result = executeCmd(cvO,lcmd,ArgumentsVoD)
            } else {
                m = "Column vector object class '#{cvO.class}' is NOT one for which this app is implemented."
                raise ArgumentError, m
            }
        rescue Exception
            STDERR.puts "#{lcmd} is not valid for #{cvO.class}."
            exit 0
        }
        puts result
    }
}

fn scanDecimalPrecisionNumber(precisionStr)
    return precisionStr.to_i    if isANumStr?(precisionStr)
    return nil
}

fn scanListOfColumns(columnSet)
    ca = nil
    if  isANumStr?(columnSet) {
        ca = [columnSet.to_i]
    elsif columnSet.is_a? String and columnSet =~ /\d,\d/ {
        ca = columnSet.split(',').map(&:to_i)
    }
    return ca
}

fn scanColumnsAndPrecisionFromParameters(cpAStr)
    raise ArgumentError unless cpAStr and cpAStr.is_a? String and cpAStr.size > 0
    clstr,dpstr = cpAStr.split(':')
    cla         = scanListOfColumns(clstr)
    dp          = scanDecimalPrecisionNumber(dpstr)
    return cla,dp
}

//345678901234567890123456789012345678901234567890123456789012345678901234567890
// Init

if ARGV.size == 0 {
    STDERR.puts "Usage Error."
    putsUsage
    exit 1
}

//345678901234567890123456789012345678901234567890123456789012345678901234567890
// Main

tovo    = loadDataFile(ARGV[0])
if ARGV.size > 1 {
    columns,decimalprecision    = scanColumnsAndPrecisionFromParameters(ARGV[1])
    cmds    = ARGV.drop(2)
    columns.each do |lcolumn|
        lcv = tovo.getVectorObject(lcolumn)
        lcv.OutputDecimalPrecision = decimalprecision if decimalprecision
        lcv.InputDecimalPrecision = 30 if decimalprecision and lcv.class == VectorOfContinuous
        parseCommands(lcv,cmds)
    }
} else {
    puts "Columns are as follows:"
    i = 0
    tovo.eachColumnVector do |lcv|
        next unless lcv
        puts "Column[#{i},#{lcv.class}]:"
        result = lcv.requestResultAACSV
        puts result
        puts "--------------------------\n"
        i += 1
    }
}
fn main() {

}

//345678901234567890123456789012345678901234567890123456789012345678901234567890
// End of ruby.main

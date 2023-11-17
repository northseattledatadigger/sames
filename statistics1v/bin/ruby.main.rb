#!/usr/bin/ruby
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# ruby.main - Objectives:
=begin
    1.  Provide ability to read and calculate columns from data inputfiles, most
    importantly, csv files, but perhaps also JSON files and CSV data from stdin.
    The file, or "stdin", would then be the first argument.
    2.  Provide default of native library, but option to use other parallel
    The parallel use would need to be a separate file handle, but would need to
    use virtually all the same code.  The technique will therefore be used,
    which should work across language environments, will be an exported
    environment variable assigned inside a shell alias version of the command,
    as with the following:
        $ alias ruby.main.versionx='export LibraryVersion=versionx;ruby.main'
    This will keep the modification from intruding needlessly into the code,
    though of course it still means compiles language versions will need to
    compile a different one for each library version, and in that case the
    binary would just be something like:
        rust.main.versionx
    3.  Provide the ability to call a single top-level object method on the
    results of the loaded data from the file specified.
    4.  Provide the ability to call a defined sequence of object methods on
    the results of the loaded data from the file specified.  This will be
    done with code in the sources for these bin programs, and it is presumed
    each such script will implement the same pattern.
    5.  It should not become more complicated than that.  These need to stay
    as simple demonstrations of function, and not applications for production
    use themselves.  To reiterate intentions stated elsewhere, the sames suite
    is intended to be:  1) and exercise for the author, 2) a learning tool to
    demonstrate to others how the same functin can be implemented across
    environments, and 3) an open source (GNU copyright) place to be able to
    pull demonstrated repeatability of function for use in other projects,
    when that might be helpful.
    6.  Also to repeat what I should have stated elsewhere:  Compliance with
    the GNU copyright is politely requested, but at the same time, I should
    not abuse or harass ANY non-corporate, non-wealthy user for copying any of
    these workings in a pinch for need or desperation or other exigency.
    Anyone doing such harassement so will not be supported by me actively.
    7.  Will provide a URL list csv caled:
        $SamesDs/statistics1v/extras/DataFileURLs.csv
    which will provide the URLs of known data files for use here that will
    then not need to be kept in GitHub but rather can be downloaded by users
    dynamically while using these scripts, each of which will then provide that
    function.
    8.  Note that ruby versions of all these will be the first, and
    prototyping versions of each of these sub-projects with all the vagaries
    that go along with that.  Still they should comply in quality with the
    rest of the suite.
=end

require 'getoptlong'

DataFormatFileExtension = "scdf" # For "Sames CSV Data Format"

SAMESHOME=File.expand_path("../..", __dir__)
SamesProjectDs=File.expand_path("..", __dir__)

AppNodes = $0.split('/')
AppLanguage,AppId,AppVersion = AppNodes[-1].split('.')
if AppVersion == 'rb' then
    STDERR.puts <<-EOERROR
    ERROR:  Please use the symbolic link version of the app. 
    the ruby.main.rb version is designed to know the App Version intended by
    the last node of the symbolic link evoked, so it will not run directly.
    EOERROR
    exit 0
end

SamesProjectLibraryInUse="#{SamesProjectDs}/SamesLib.#{AppVersion}.rb"

require "#{SAMESHOME}/slib/SamesTopLib.rb"
require SamesProjectLibraryInUse

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Constant Identifiers

SamesClassColumnsDs = "#{SamesProjectDs}/classcolumns"

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

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Lower Level Procedures

def _determineDataInputFile(fName)
    unless _validateImplementationForThisFileType(fName)
        m = "No implementation in this application for file type of '#{fName}'."
        raise ArgumentError, m
    end
    return fName    if File.exist?(fName)
    ds      = nil
    fn      = nil
    if fName =~ /^(.*)\/(.*)$/ then
        ds  = $1
        fn  = $2
    else
        ds  = SamesTmpData
        fn  = fName
    end
    fs = "#{ds}/#{fn}"
    return fs       if File.exist?(fs)
    fileurl = getKeptFileURL(fn)
    unless assureInternetDataFileCopy(ds,fn,fileurl)
        raise ArgumentError, "File name '#{fName}' not procured."
    end
    return fs if File.exist?(fs)
    m = "Downloaded File '#{fName}' still not there?  Programmer error?"
    raise ArgumentError, m
end

def _displayCommands(labelStr,cmdHash,cmdArguments)
    puts "\t#{labelStr} Commands:"
    cmdHash.keys.sort.each do |lkey|
        puts "\t\t#{lkey}(#{cmdArguments[lkey]})"   if cmdArguments.has_key?(lkey)
        puts "\t\t#{lkey}"                      unless cmdArguments.has_key?(lkey)
    end
end

def _generateHistogram(genType=SegmentCountHistogramGeneration,segmentSpecNo,startNumber)
    generateHistogramAAbyNumberOfSegments(desiredSegmentCount,startNumber=nil)
    generateHistogramAAbySegmentSize(segmentSize,startNumber=nil)
end

def _parseSamesLibVectorOfContinuousCommand(vocO,aList)
end

def _parseSamesLibVectorOfDiscreteCommand(vodO,aList)
end

def _readSamesLibStdIn
end

def _requestResultSummary
    requestResultAACSV
    requestResultCSVLine(includeHdr=false)
    requestResultJSON
    requestSummaryCollection
end

def _requestVariance
    requestVarianceSumOfDifferencesFromMean(populationCalculation=false)
    requestVarianceXsSquaredMethod(populationCalculation=false)
end

def _scanDataClasses(clArg)
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
    end
    csvstr      = File.read( positedclassfspec )
    ba          = csvstr.split(',')
    vcarray     = nil
    if ba[0] == 'C' or ba[0] == 'D' then
        vcarray = VectorTable.arrayOfChar2VectorOfClasses(ba)
    else
        vcarray = VectorTable.arrayOfClassLabels2VectorOfClasses(ba)
    end
    return vcarray
end

def _validateImplementationForThisFileType(fName)
    return true if fName =~ /\.csv$/
    return false
end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Top Level Procedures

def putsUsage
    puts <<-EOUsage
USAGE:  #{$0} <inputfile> [columns] [cmd] [precision]
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
end

def loadDataFile(clArg)
    fspec = _determineDataInputFile(clArg)
    vcarray = _scanDataClasses(fspec)
    if fspec =~ /.csv$/ then
        localo = VectorTable.newFromCSV(vcarray,fspec)
        return localo
    else
        m = "This file type (#{fSpec}) is not presently supported."
        raise ArgumentError, m
    end
end

def parseCommands(cvO,cmdsArray)
    def executeCmd(cvO,cmdStr,argumentsAA)
        arga        = []
        aspecsize   = 0
        cmdid       = cmdStr
        result      = nil
        if cmdStr =~ /\(/
            if cmdStr =~ /^([^(]*)\(([^)]*)\)/
                cmdid   = $1
                argstr  = $2
                arga    = argstr.split(',')
            else
                m="Command '#{cmdStr}' does not comply with argument specifications."
                raise ArgumentError, m
            end
            aspecsize = argumentsAA[cmdid].split(' ').size if argumentsAA.has_key?(lcmdid)
        end
        unless arga.size == aspecsize 
            m="Command '#{cmdStr}' does not comply with argument specifications:  #{argumentsAA[lcmdid]}."
            raise ArgumentError, m
        end
        unless VoCHash.has_key?(cmdid)
            m="Command '#{cmdid}' is not implemented for class #{cvO.class}."
            raise ArgumentError, m
        end
        case aspecsize
        when 0
            result = cvO.send(VoCHash[cmdid])
        when 1
            result = cvO.send(VoCHash[cmdid],arga[0])
        when 2
            result = cvO.send(VoCHash[cmdid],arga[0],arga[1])
        when 3
            result = cvO.send(VoCHash[cmdid],arga[0],arga[1],arga[2])
        when 4
            result = cvO.send(VoCHash[cmdid],arga[0],arga[1],arga[2],arga[3])
        else
            m   =   "Programmer Error regarding argument specification:  "
            m   +=  "[#{aspecsize},#{arga.size}]."  if arga.is_a? Array
            m   +=  "#{aspecsize}."             unless arga.is_a? Array
            raise ArgumentError, m
        end
        return result
    end
    cmdsArray.each do |lcmd|
        result = ""
        begin
            if      cvO.is_a? VectorOfContinuous then
                result = executeCmd(cvO,lcmd,ArgumentsVoC)
            elsif   cvO.is_a? VectorOfDiscrete then
                result = executeCmd(cvO,lcmd,ArgumentsVoD)
            else
                m = "Column vector object class '#{cvO.class}' is NOT one for which this app is implemented."
                raise ArgumentError, m
            end
        rescue Exception
            STDERR.puts "#{lcmd} is not valid for #{cvO.class}."
            exit 0
        end
        puts result
    end
end

def scanDecimalPrecisionNumber(precisionStr)
    return precisionStr.to_i    if isANumStr?(precisionStr)
    return nil
end

def scanListOfColumns(columnSet)
    ca = nil
    if  isANumStr?(columnSet) then
        ca = [columnSet.to_i]
    elsif columnSet.is_a? String and columnSet =~ /\d,\d/ then
        ca = columnSet.split(',').map(&:to_i)
    end
    return ca
end

def scanColumnsAndPrecisionFromParameters(cpAStr)
    raise ArgumentError unless cpAStr and cpAStr.is_a? String and cpAStr.size > 0
    clstr,dpstr = cpAStr.split(':')
    cla         = scanListOfColumns(clstr)
    dp          = scanDecimalPrecisionNumber(dpstr)
    return cla,dp
end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Init

if ARGV.size == 0
    STDERR.puts "Usage Error."
    putsUsage
    exit 1
end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Main

tovo    = loadDataFile(ARGV[0])
if ARGV.size > 1 then
    columns,decimalprecision    = scanColumnsAndPrecisionFromParameters(ARGV[1])
    cmds    = ARGV.drop(2)
    columns.each do |lcolumn|
        lcv = tovo.getVectorObject(lcolumn)
        lcv.OutputDecimalPrecision = decimalprecision if decimalprecision
        lcv.InputDecimalPrecision = 30 if decimalprecision and lcv.class == VectorOfContinuous
        parseCommands(lcv,cmds)
    end
else
    puts "Columns are as follows:"
    i = 0
    tovo.eachColumnVector do |lcv|
        next unless lcv
        puts "Column[#{i},#{lcv.class}]:"
        result = lcv.requestResultAACSV
        puts result
        puts "--------------------------\n"
        i += 1
    end
end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of ruby.main

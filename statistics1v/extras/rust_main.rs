//345678901234567890123456789012345678901234567890123456789012345678901234567890
// rust.main - Objectives:
// NOTE:  For first pass at least, I'll use match blocks to deal with commands
// instead of arrays like I did in other languages, as that seems to comply
// better with rust's model of memory management.  It would be interesting to
// see if anyone has done the array of commands way, or even a function
// executed from a string with varying argument lists, but I see no sign of
// such functionality, and it seems likely it would not be allowed.

use std::env;
use std::process;

const SamesProjectLibraryInUse  = "{SamesProjectDs}/SamesLib.{AppVersion}.rs";

require "{SAMESHOME}/slib/SamesTopLib.rb";
require SamesProjectLibraryInUse;

//345678901234567890123456789012345678901234567890123456789012345678901234567890
// Constant Identifiers

SamesClassColumnsDs = "{SamesProjectDs}/classcolumns";
SamesTmpDataDs      = "{SAMESHOME}/tmpdata";

SegmentCountHistogramGeneration = 1;
SegmentSizeHistogramGeneration = 2;
SegmentSpecificationHistogramGeneration = 3;

fn parse_vector_of_continuous_calls(command_string: String, voxo: VectorOfContinuous, argv: Vec<String>, argc: usize) -> String {
    let bool_data:          bool;
    let bool_result:        Option<bool>;
    let btree_map_data:     BTreeMap<String,String>;
    let btree_map_result:   Option<BTreeMap<String,String>>;
    let float_data:         f64;
    let float_result:       Option<f64>;
    let histogram_data:     Vec<(f64,f64,usize)>;
    let histogram_result:   Option<Vec<(f64,f64,usize)>>;
    let string_data:        String;
    let string_result:      Option<String>;
    let vector_data:        Option<Vec<f64>>;
    let vector_result:      Vec<f64>;
    match command_string {
        'aad'               => float_result     = generate_average_absolute_deviation(),
        'arithmeticmean'    => float_result     = calculate_arithmetic_mean(),
        'cov'               => float_result     = generate_coefficient_of_variation(),
        'csvlineOfx'        => string_result    = transform_to_csv_line(),
        'excesskurtosis'    => float_result     = request_excess_kurtosis(),
        'geometricmean'     => float_result     = calculate_geometric_mean(),
        'getx'              => float_result     = get_x(),
        'harmonicmean'      => float_result     = calculate_harmonic_mean(),
        'iseven?'           => bool_result      = is_even_n(),
        'jsonofx'           => string_result    = transform_to_json(),
        'histogram'         => histogram_result = _generate_histogram(),
        'kurtosis'          => float_result     = request_kurtosis(),
        'mad'               => float_result     = generate_mean_absolute_difference(),
        'max'               => float_result     = get_max(),
        'mean'              => float_result     = calculate_arithmetic_mean(),
        'median'            => float_result     = request_median(),
        'min'               => float_result     = get_min(),
        'mode'              => float_result     = generate_mode(),
        'n'                 => integer_result   = get_count(),
        'quartile'          => float_result     = calculate_quartile(),
        'quartileset'       => btree_map_result = request_quartile_collection(),
        'range'             => float_result     = request_range(),
        'sum'               => float_result     = get_sum(),
        'resultsummary'     => btree_map_result = _request_result_summary(),
        'skewness'          => float_result     = request_skewness(),
        'stddev'            => float_result     = request_standard_deviation(),
        'variance'          => float_result     = _request_variance(),
    }
}

    //get_frequency_aa(&self,subject_value: String) -> Option<BTreeMap<String,u32>>;

fn parse_vector_of_discrete_calls(command_string: String, voxo: VectorOfDiscrete, argv: Vec<String>, argc: usize) -> String {
    match command_string {
        'binomialprobability'   => float_result     = calculate_binomial_probability(),
        'csvlineOfx'            => string_result    = transform_to_csv_line(),
        'csvlistOfx'            => string_result    = transform_to_csv_list(),
        'jsonofx'               => string_result    = transform_to_json(),
        'frequency_table'       => string_result    = generate_frequency_table(),
        'get_frequency'         => string_result    = get_frequency(),
        'get_x'                 => string_result    = get_x(),
        'mode'                  => string_result    = request_mode(),
        'n'                     => integer_result   = get_count(),
        'resultsummary'         => btree_map_result = _request_result_summary()
    }
}

//345678901234567890123456789012345678901234567890123456789012345678901234567890
// Lowest Level Procedures

fn __validateImplementationForThisFileType(fName) -> bool {
    return true if fName =~ /\.csv$/;
    return false;
}

//345678901234567890123456789012345678901234567890123456789012345678901234567890
// Lower Level Procedures

fn _determineDataInputFile(fName) -> Result<String,ValidationError> {
    if ! __validateImplementationForThisFileType(fName) {
        m = "No implementation in this application for file type of '{fName}'.";
        raise ArgumentError, m;
    }
    return fName    if File.exist?(fName);
    ds  = SamesTmpDataDs;
    def = fName;
    if fName =~ /^(.*)\/(.*)$/ {
        ds  = $1;
        fn  = $2;
    }
    fs = "{ds}/{fn}";
    return fs       if File.exist?(fs);
    fileurl = getKeptFileURL(fn);
    if ! assureInternetDataFileCopy(ds,fn,fileurl) {
        raise ArgumentError, "File name '{fName}' not procured.";
    }
    if File.exist?(fs) {
        return fs
    }
    m = "Downloaded File '{fName}' still not there?  Programmer error?";
    raise ArgumentError, m;
}

fn _generateHistogram(genType,segmentSpecNo,startNumber) {
    //generateHistogramAAbyNumberOfSegments(desiredSegmentCount,startNumber);
    generateHistogramAAbySegmentSize(segmentSize,startNumber);
}

fn _requestResultSummary {
    requestResultAACSV();
    requestResultCSVLine(includeHdr=false);
    requestResultJSON();
    requestSummaryCollection();
}

fn _requestVariance {
    requestVarianceSumOfDifferencesFromMean(populationCalculation);
    requestVarianceXsSquaredMethod(populationCalculation);
}

fn _scanDataClasses(clArg) {
    fn = clArg.sub(/.*\//,'');
    positedclassfspec = "{SamesClassColumnsDs}/{fn}.vc.csv";
    if ! File.exist?(positedclassfspec);
        println!("
        A column class file is required at {positedclassfspec} to load the
        data.  You may use either of two formats:

        VectorOfContinuous,VectorOfDiscrete,..

        or

        C,D,...

        See examples in the {SamesClassColumnsDs} folder.
        ",SamesClassColumnsDs);
        m="No column class input specification accompanies '{clArg}'."
        raise ArgumentError, m
    }
    csvstr      = File.read( positedclassfspec );
    ba          = csvstr.split(',');
    vcarray     = nil;
    if ba[0] == 'C' or ba[0] == 'D' {
        vcarray = VectorTable.arrayOfChar2VectorOfClasses(ba);
    } else {
        vcarray = VectorTable.arrayOfClassLabels2VectorOfClasses(ba);
    }
    return vcarray;
}

//345678901234567890123456789012345678901234567890123456789012345678901234567890
// Top Level Procedures

fn printlnUsage(script_name: &str) {
    println!("
USAGE:  {} <inputfile> [column[,...][:precision]] [cmd[,...]]
    inputfile:  For now, a csv file, but with a corresponding class columns
    file in the folder {SamesClassColumnsDs}, with one of two syntaxes,
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
",script_name);
    _displayCommands("Continuous",VoCHash,ArgumentsVoC);
    _displayCommands("Discrete",VoDHash,ArgumentsVoD);
}

fn loadDataFile(clArg) -> Result<VectorTable,ValidationError> {
    let fspec   = _determineDataInputFile(clArg);
    let vcarray = _scanDataClasses(fspec);
    if fspec =~ /.csv$/ {
        localo = VectorTable.newFromCSV(vcarray,fspec)
        return localo
    } else {
        m = "This file type ({fspec}) is not presently supported."
        raise ArgumentError, m
    }
}

fn parse_commands(cvO,cmdsArray) {
    fn executeCmd(cvO,cmdStr,argumentsAA) {
        arga        = [];
        aspecsize   = 0;
        cmdid       = cmdStr;
        result      = nil;
        if cmdStr =~ /\(/
            if cmdStr =~ /^([^(]*)\(([^)]*)\)/
                cmdid   = $1;
                argstr  = $2;
                arga    = argstr.split(',');
            } else {
                m="Command '{cmdStr}' does not comply with argument specifications.";
                raise ArgumentError, m;
            }
            aspecsize = argumentsAA[cmdid].split(' ').size if argumentsAA.has_key?(lcmdid);
        }
        unless arga.size == aspecsize 
            m="Command '{cmdStr}' does not comply with argument specifications:  {argumentsAA[lcmdid]}.";
            raise ArgumentError, m;
        }
        unless VoCHash.has_key?(cmdid)
            m="Command '{cmdid}' is not implemented for class {cvO.class}.";
            raise ArgumentError, m;
        }
        match aspecsize
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
            m   +=  "[{aspecsize},{arga.size}]."  if arga.is_a? Array
            m   +=  "{aspecsize}."             unless arga.is_a? Array
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
                m = "Column vector object class '{cvO.class}' is NOT one for which this app is implemented."
                raise ArgumentError, m
            }
        rescue Exception
            STDERR.puts "{lcmd} is not valid for {cvO.class}."
            exit 0
        }
        puts result
    }
}

fn scan_decimal_precision_number(precisionStr) {
    return precisionStr.to_i    if isANumStr?(precisionStr);
    return nil;
}

fn scan_list_of_columns(columnSet) {
    ca = nil;
    if  isANumStr?(columnSet) {
        ca = [columnSet.to_i];
    elsif columnSet.is_a? String and columnSet =~ /\d,\d/ {
        ca = columnSet.split(',').map(&:to_i);
    }
    return ca;
}

fn scan_columns_and_precision_from_parameters(cpAStr) {
    raise ArgumentError unless cpAStr and cpAStr.is_a? String and cpAStr.size > 0;
    clstr,dpstr = cpAStr.split(':');
    cla         = scanListOfColumns(clstr);
    dp          = scanDecimalPrecisionNumber(dpstr);
    return cla,dp;
}

//345678901234567890123456789012345678901234567890123456789012345678901234567890
// Init

let args: Vec<String> = env::args().collect();
if args.len <= 1 {
    STDERR.puts "Usage Error.";
    printlnUsage(args[0]);
    process::exit(0);
}

//345678901234567890123456789012345678901234567890123456789012345678901234567890
// Main

fn main() {
    tovo    = loadDataFile(ARGV[0])
    if ARGV.size > 1 {
        columns,decimalprecision    = scanColumnsAndPrecisionFromParameters(ARGV[1]);
        cmds    = ARGV.drop(2);
        columns.each do |lcolumn|;
            lcv = tovo.getVectorObject(lcolumn);
            lcv.OutputDecimalPrecision = decimalprecision if decimalprecision;
            lcv.InputDecimalPrecision = 30 if decimalprecision and lcv.class == VectorOfContinuous;
            parseCommands(lcv,cmds);
        }
    } else {
        puts "Columns are as follows:";
        i = 0;
        tovo.eachColumnVector do |lcv|
            next unless lcv;
            puts "Column[{i},{lcv.class}]:";
            result = lcv.requestResultAACSV;
            puts result;
            puts "--------------------------\n";
            i += 1;
        }
    }

}

//345678901234567890123456789012345678901234567890123456789012345678901234567890
// End of ruby.main

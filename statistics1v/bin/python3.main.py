#!/usr/bin/python3
# python3.main.py
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Constants and Includes

import numbers
import operator
#import methodcaller
#from operator import methodcaller
import os
import random
import re
import sys 

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Constant Identifiers

SegmentCountHistogramGeneration = 1
SegmentSizeHistogramGeneration = 2
SegmentSpecificationHistogramGeneration = 3

VoCHash = {
    'aad'               : 'generateAverageAbsoluteDeviation',
    'arithmeticmean'    : 'calculateArithmeticMean',
    'cov'               : 'generateCoefficientOfVariation',
    'csvlineOfx'        : 'transformToCSVLine',
    'excesskurtosis'    : 'requestExcessKurtosis',
    'geometricmean'     : 'calculateGeometricMean',
    'getx'              : 'getX',
    'harmonicmean'      : 'calculateHarmonicMean',
    'iseven?'           : 'isEvenN',
    'jsonofx'           : 'transformToJSON',
    'histogram'         : '_generateHistogram',
    'kurtosis'          : 'requestKurtosis',
    'mad'               : 'generateMeanAbsoluteDifference',
    'max'               : 'getMax',
    'mean'              : 'calculateArithmeticMean',
    'median'            : 'requestMedian',
    'min'               : 'getMin',
    'mode'              : 'generateMode',
    'n'                 : 'getCount',
    'quartile'          : 'calculateQuartile',
    'quartileset'       : 'requestQuartileCollection',
    'range'             : 'requestRange',
    'sum'               : 'getSum',
    'resultsummary'     : '_requestResultSummary',
    'skewness'          : 'requestSkewness',
    'stddev'            : 'requestStandardDeviation',
    'variance'          : '_requestVariance',
}

ArgumentsVoC = {
    'aad'               : '<centerPoint>',
    'getx'              : '<indexOfX>',
    'histogram'         : '<HistogramType>',
    'quartile'          : '<indexOfQuartile>',
    'resultsummary'     : '<summaryOption>',
    'variance'          : '<varianceOption>',
}

VoDHash = {
    'binomialprobability'   : 'calculateBinomialProbability',
    'csvlineOfx'            : 'transformToCSVLine',
    'csvlistOfx'            : 'transformToCSVList',
    'jsonofx'               : 'transformToJSON',
    'frequencyTable'        : 'generateFrequencyTable',
    'getFrequency'          : 'getFrequency',
    'getx'                  : 'getX',
    'mode'                  : 'requestMode',
    'n'                     : 'getCount',
    'resultsummary'         : '_requestResultSummary'
}

ArgumentsVoD = {
    'binomialprobability'   : '<subjectValue> <nTrials> <nSuccesses>',
    'getFrequency'          : '',
    'getx'                  : '<indexOfX>',
    'resultsummary'         : '<summaryOption>'
}

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Lowest Level Procedures

def __validateImplementationForThisFileType(fName):
    res = r".csv$"
    result = re.search(r"\.csv$",fName)
    if result is None:
        return False
    return True

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Lower Level Procedures

def _determineDataInputFile(fName):
    if not __validateImplementationForThisFileType(fName):
        m = f"No implementation in this application for file type of '{fName}'."
        raise ValueError( m )
    if os.path.isfile(fName):
        return fName    
    ds  = SamesTmpDataDs
    fn  = fName
    reresult = re.match(r"^(.*)\/(.*)$",fName)
    if reresult is not None:
        ds  = reresult[0]
        fn  = reresult[1]
    fs = "#{ds}/#{fn}"
    if os.path.isfile(fs):
        return fs
    fileurl = getKeptFileURL(fn)
    if not assureInternetDataFileCopy(ds,fn,fileurl):
        raise ArgumentError( f"File name '{fName}' not procured." )
    if os.path.isfile(fs):
        return fs
    m = f"Downloaded File '{fName}' still not there?  Programmer error?"
    raise ArgumentError( m )

def _displayCommands(labelStr,cmdHash,cmdArguments):
    print(f"\t{labelStr} Commands:")
    for lkey in sorted(cmdHash):
        if lkey in cmdArguments:
            print(f"\t\t{lkey}({cmdArguments[lkey]})")
        else:
            print(f"\t\t{lkey}")

def _executeCmd(cvO,cmdStr,argumentsAA):
    arga        = []
    aspecsize   = 0
    cmdid       = cmdStr
    result      = None
    if re.match("\(",cmdStr):
        reresult = re.match(r"^([^(]*)\(([^)]*)\)",cmdStr)
        if reresult:
            cmdid   = reresult[0]
            argstr  = reresult[1]
            arga    = argstr.split(',')
        else:
            m="Command '#{cmdStr}' does not comply with argument specifications."
            raise ArgumentError( m )

        if lcmdid in argumentsAA:
            ba          = argumentsAA[cmdid].split(' ')
            aspecsize   = len(ba)

    if len(arga) != aspecsize:
        m="Command '#{cmdStr}' does not comply with argument specifications:  #{argumentsAA[lcmdid]}."
        raise ArgumentError( m )

    if not cmdid in VoCHash:
        m=f"Command '{cmdid}' is not implemented for class #{cvO.__class__}."
        raise ValueError( m )

    match aspecsize:
        case 0:
            result  = operator.methodcaller(VoCHash[cmdid])(cvO)
        case 1:
            result  = operator.methodcaller(VoCHash[cmdid])(cvO,arga[0])
        case 2:
            result  = operator.methodcaller(VoCHash[cmdid])(cvO,arga[0],arga[1])
        case 3:
            result  = operator.methodcaller(VoCHash[cmdid])(cvO,arga[0],arga[1],arga[2])
        case 4:
            result  = operator.methodcaller(VoCHash[cmdid])(cvO,arga[0],arga[1],arga[2],arga[3])
        case _:
            m       =   "Programmer Error regarding argument specification:  "
            if type(arga) is list:
                m +=  "[#{aspecsize},#{arga.size}]."
            else:
                m +=  "#{aspecsize}."
            raise ArgumentError( m )

    return result

def _generateHistogram(genType,segmentSpecNo,startNumber):
    #generateHistogramAAbyNumberOfSegments(desiredSegmentCount,startNumber)
    generateHistogramAAbySegmentSize(segmentSize,startNumber)

def _requestResultSummary():
    pass

def _requestVariance():
    #requestVarianceSumOfDifferencesFromMean(populationCalculation)
    requestVarianceXsSquaredMethod(populationCalculation)

def _scanDataClasses(clArg):
    fn = re.sub(".*\/",'',clArg)
    positedclassfspec = f"{SamesClassColumnsDs}/{fn}.vc.csv"
    #print(f"trace 2 _scanDataClasses({clArg}): {fn}, {positedclassfspec}")
    if not os.path.isfile(positedclassfspec):
        m = f"A column class file is required at #{positedclassfspec} to load the"
        m += """
        data.  You may use either of two formats:

        VectorOfContinuous,VectorOfDiscrete,..

        or

        C,D,...

        """
        m += f"See examples in the {SamesClassColumnsDs} folder."
        m += f"No column class input specification accompanies '{clArg}'."
        raise ValueError( m )
    cvstr = None
    with open(positedclassfspec, 'r') as fp:
        csvstr   = fp.read()
        #print(f"trace 6 _scanDataClasses({clArg}): {csvstr}")
    ba          = csvstr.split(',')
    vcarray     = None
    if ba[0] == 'C' or ba[0] == 'D':
        vcarray = sames.VectorTable.arrayOfChar2VectorOfClasses(ba)
    else:
        vcarray = sames.VectorTable.arrayOfClassLabels2VectorOfClasses(ba)
    return vcarray

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Top Level Procedures

def putsUsage(sName,sccDs,):
    m=f"""
    USAGE:  {sName} <inputfile> [column[,...][:precision]] [cmd[,...]]
    inputfile:  For now, a csv file, but with a corresponding class columns
    file in the folder {sccDs}, with one of two syntaxes,
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
    """
    print(m)
    _displayCommands("Continuous",VoCHash,ArgumentsVoC)
    _displayCommands("Discrete",VoDHash,ArgumentsVoD)

def loadDataFile(clArg):
    fspec = _determineDataInputFile(clArg)
    vcarray = _scanDataClasses(fspec)
    if re.search(r".csv$",fspec):
        localo = sames.VectorTable.newFromCSV(vcarray,fspec)
        return localo
    else:
        m = f"This file type ({fspec}) is not presently supported."
        raise ValueError( m )

def parseCommands(cvO,cmdsArray):

    for lcmd in cmdsArray:
        result = ""
        #try:

        if      ( isinstance(cvO,sames.VectorOfContinuous) ):
            result = _executeCmd(cvO,lcmd,ArgumentsVoC)
        elif    ( isinstance(cvO,sames.VectorOfDiscrete) ):
            result = _executeCmd(cvO,lcmd,ArgumentsVoD)
        else:
            m = f"Column vector object class '#{cvO.__class__}' is NOT one for which this app is implemented."
            raise ValueError( m )

        #except:
            #raise ValueError( f"{lcmd} is not valid for {cvO.__class__}." )

        print( result )

def scanDecimalPrecisionNumber(precisionStr):
    if sames.isANumStr(precisionStr):
        return int(precisionStr)
    return None

def scanListOfColumns(columnSet):
    ca = None
    if  sames.isANumStr(columnSet):
        ca = [int(columnSet)]
    elif isinstance(columnSet,str): 
        if re.search(r"\d,\d",columnSet):
            ba = columnSet.split(',')
            ca = [int(x) for x in ba]
        else:
            raise ValueError(f"Cannot scan '{columnSet}'.")
    return ca

def scanColumnsAndPrecisionFromParameters(cpAStr):
    if not cpAStr:
        raise ValueError
    if not isinstance(cpAStr,str): 
        raise ValueError
    if len(cpAStr) <= 0:
        raise ValueError
    clstr       = cpAStr
    dpstr       = None
    if re.search(r":",cpAStr):
        clstr,dpstr = cpAStr.split(':')
    cla         = scanListOfColumns(clstr)
    dp          = scanDecimalPrecisionNumber(dpstr)
    
    return cla,dp

if __name__ == '__main__':

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Init
    #print(f"trace 0 Init:  {sys.argv[0]},{len(sys.argv)}")

    ScriptPath      = os.path.realpath(__file__)
    HERE            = os.path.dirname(__file__)
    HOME            = os.getenv('HOME') # None

    SAMESHOME       = os.path.abspath(os.path.join(HERE, '../..'))
    sys.path.append(SAMESHOME) # Not sure this is necessary.

    TestDataDs      = f"{SAMESHOME}/testdata"

    SAMESSLIB       = os.path.abspath(os.path.join(SAMESHOME, 'slib'))
    sys.path.append(SAMESSLIB)

    import SBinLib as sbl

    SamesProjectDs  = os.path.abspath(os.path.join(HERE, '..'))

    SamesClassColumnsDs = f"{SamesProjectDs}/classcolumns"
    SamesTmpDataDs      = f"{SAMESHOME}/tmpdata"

    #print(f"trace 3 Init:  {sys.argv[0]},{len(sys.argv)}")
    if len(sys.argv) < 2:
        m = "Usage Error."
        print(m, file=sys.stderr)
        putsUsage(sys.argv[0],SamesClassColumnsDs)
        sys.exit()

    #print(f"trace 4 Init:  {sys.argv[0]},{len(sys.argv)}")
    AppNodes = sys.argv[0].split('/')
    AppLanguage,AppId,AppVersion = AppNodes[-1].split('.')
    if AppVersion == 'py':
        m = """
        ERROR:  Please use the symbolic link version of the app. 
        the ruby.main.rb version is designed to know the App Version intended by
        the last node of the symbolic link evoked, so it will not run directly.
        """
        raise ValueError(m)
        sys.exit()

    #print(f"trace 5 Init:  {sys.argv[0]},{len(sys.argv)}")
    sys.path.append(SamesProjectDs)
    Python3LibFs    = f"{SamesProjectDs}/SamesLib_{AppVersion}.py"

    #print(f"trace 6 Init:  {sys.argv[0]},{len(sys.argv)}")
    if os.path.isfile(Python3LibFs):
        match AppVersion:
            case "amateur":
                #import SamesLib_amateur as sames
                print("Not Yet Implemented.")
            case "enhanced":
                #import SamesLib_enhanced as sames
                print("Not Yet Implemented.")
            case "naive":
                #import SamesLib_naive as sames
                print("Not Yet Implemented.")
            case "native":
                import SamesLib_native as sames
            case "numpy":
                #import SamesLib_numpy as sames
                print("Not Yet Implemented.")
            case "pandas":
                #import SamesLib_pandas as sames
                print("Not Yet Implemented.")
            case "polars":
                print("Not Yet Implemented.")
            case "vernacular": # This might be one I'll refactor to comply more meticulously with Python mores, if I can ever stand to do it.
                #import SamesLib_vernacular as sames
                print("Not Yet Implemented.")
            case _:
                m = f"."
                raise ValueError(m)
                m = f"Library Under Test {Python3LibFs} NOT found."
                raise ValueError(m)

    #print(f"trace 8 Init:  {sys.argv[0]},{len(sys.argv)}")
    FirstTestFileFs = sbl.returnIfThere(f"{TestDataDs}/sidewalkstreetratioupload.csv")
    #print(f"trace 9 Init:  {sys.argv[0]},{len(sys.argv)}")

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Main

    #print(f"trace 0 Main:  {sys.argv[0]},{len(sys.argv)}")
    #if len(sys.argv) > 1:
        #print(f"trace 0a Main:  {sys.argv[1]}")
    tovo    = loadDataFile(sys.argv[1])
    #print(f"trace 1 Main:  {sys.argv[0]},{len(sys.argv)}, {tovo.__class__}")
    if len(sys.argv) > 2:
        #print(f"trace 2 Main:  {sys.argv[0]},{len(sys.argv)}")
        columns,decimalprecision    = scanColumnsAndPrecisionFromParameters(sys.argv[2])
        cmds    = sys.argv[3:]
        for lcolumn in columns:
            lcv = tovo.getVectorObject(lcolumn)
            if decimalprecision is not None:
                lcv.OutputDecimalPrecision = decimalprecision
                if lcv.__class__ == sames.VectorOfContinuous:
                    lcv.InputDecimalPrecision = 30
            parseCommands(lcv,cmds)
    else:
        #print(f"trace 5 Main:  {sys.argv[0]},{len(sys.argv)}")
        print("Columns are as follows:")
        i = 0
        for lcv in tovo.TableOfVectors:
            if lcv is None:
                continue
            print(f"Column[{i},{lcv.__class__}]:")
            result = lcv.requestResultAACSV()
            print(result)
            print("--------------------------\n")
            i += 1
    #print(f"trace 9 Main:  {sys.argv[0]},{len(sys.argv)}")

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of python3.main.py

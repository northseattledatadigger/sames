#!/usr/bin/python3
# python3.main.py
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Constants and Includes

import numbers
import os
import random
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
# Lower Level Procedures

def _determineDataInputFile(fName):
    pass

def _displayCommands(labelStr,cmdHash,cmdArguments):
    print(f"\t{labelStr} Commands:")
    for lkey in sorted(cmdHash):
        if lkey in cmdArguments:
            print(f"\t\t{lkey}({cmdArguments[lkey]})")
        else:
            print(f"\t\t{lkey}")

def _generateHistogram(genType,segmentSpecNo,startNumber):
    pass

def _parseSamesLibVectorOfContinuousCommand(vocO,aList):
    pass

def _parseSamesLibVectorOfDiscreteCommand(vodO,aList):
    pass

def _readSamesLibStdIn():
    pass

def _requestResultSummary():
    pass

def _scanDataClasses(clArg,dSpec):
    fn = clArg.sub(".*\/",'')
    positedclassfspec = f"{SamesClassColumnsDs}/{fn}.vc.csv"
    if not os.path.isfile(positedclassfspec):
        m = f"A column class file is required at #{positedclassfspec} to load the"
        m += """
        data.  You may use either of two formats:

        VectorOfContinuous,VectorOfDiscrete,..

        or

        C,D,...

        """
        m += f"See examples in the #{SamesClassColumnsDs} folder."
        m += f"No column class input specification accompanies '{clArg}'."
        raise ArgumentError( m )
    cvstr = None
    with open(positedclassfspec, 'r') as fp:
        cvstr = fp.read()
    ba          = csvstr.split(',')
    vcarray     = None
    if ba[0] == 'C' or ba[0] == 'D':
        vcarray = VectorTable.arrayOfChar2VectorOfClasses(ba)
    else:
        vcarray = VectorTable.arrayOfClassLabels2VectorOfClasses(ba)
    return vcarray

def _validateImplementationForThisFileType(fName):
    if re.match("\.csv$",fName):
        return True
    return False

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
    
    _displayCommands("Continuous",VoCHash,ArgumentsVoC)
    _displayCommands("Discrete",VoDHash,ArgumentsVoD)

def loadDataFile(clArg):
    pass

def parseCommands(cvO,cmdsArray):
    pass

def scanDecimalPrecisionNumber(precisionStr):
    pass

def scanListOfColumns(columnSet):
    pass

def scanColumnsAndPrecisionFromParameters(cpAStr):
    pass

if __name__ == '__main__':

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Init

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

    SamesClassColumnsDs = "#{SamesProjectDs}/classcolumns"

    if len(sys.argv) < 2:
        m = "Usage Error."
        print(m, file=sys.stderr)
        putsUsage(sys.argv[0],SamesClassColumnsDs)
        sys.exit()

    SubType = sys.argv.pop()

    sys.path.append(SamesProjectDs)
    Python3LibFs    = f"{SamesProjectDs}/SamesLib_{SubType}.py"

    if os.path.isfile(Python3LibFs):
        match SubType:
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

    FirstTestFileFs = sbl.returnIfThere(f"{TestDataDs}/sidewalkstreetratioupload.csv")

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Main

    tovo    = loadDataFile(sys.argv[1])
    if len(sys.argv) > 2:
        columns,decimalprecision    = scanColumnsAndPrecisionFromParameters(sys.argv[2])
        cmds    = sys.argv[2:]
        for lcolumn in columns:
            lcv = tovo.getVectorObject(lcolumn)
            if decimalprecision is not None:
                lcv.OutputDecimalPrecision = decimalprecision
                if lcv.__class__ == sames.VectorOfContinuous:
                    lcv.InputDecimalPrecision = 30
            parseCommands(lcv,cmds)
    else:
        print("Columns are as follows:")
        i = 0
        for lcv in tovo.VectorOfX:
            if lcv is None:
                continue
            print(f"Column[{i},{lcv.__class__}]:")
            result = lcv.requestResultAACSV()
            print(result)
            print("--------------------------\n")
            i += 1

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of python3.main.py

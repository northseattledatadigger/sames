#!/usr/bin/python3
# python3.main.py
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Constants and Includes

import numbers
import os
import random
import sys 

def _determineDataInputFile(fName):
    pass

def _displayCommands(labelStr,cmdHash,cmdArguments):
    #puts "\t#{labelStr} Commands:"
    #cmdHash.keys.sort.each do |lkey|
        #puts "\t\t#{lkey}(#{cmdArguments[lkey]})"   if cmdArguments.has_key?(lkey)
        #puts "\t\t#{lkey}"                      unless cmdArguments.has_key?(lkey)
    pass

def _generateHistogram(genType=SegmentCountHistogramGeneration,segmentSpecNo,startNumber):
    pass

def _parseSamesLibVectorOfContinuousCommand(vocO,aList):
    pass

def _parseSamesLibVectorOfDiscreteCommand(vodO,aList):
    pass

def _readSamesLibStdIn():
    pass

def _requestResultSummary():
    pass

def _scanDataClasses(clArg):
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

def _validateImplementationForThisFileType(fName)
    #return true if fName =~ /\.csv$/
    return false

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Top Level Procedures

def putsUsage():
    print "
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
    
    "
    _displayCommands("Continuous",VoCHash,ArgumentsVoC)
    _displayCommands("Discrete",VoDHash,ArgumentsVoD)

def loadDataFile(clArg):
    pass

def parseCommands(cvO,cmdsArray):
    pass

def scanDecimalPrecisionNumber(precisionStr):
    pass

def scanListOfColumns(columnSet)
    pass

def scanColumnsAndPrecisionFromParameters(cpAStr)
    pass

if __name__ == '__main__':

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Init

    if len(sys.argv) != 2:
        raise ValueError("Must provide test subset id as sole argument.")

    SubType = sys.argv.pop()

    #print(f"trace 1 {SubType}")
    ScriptPath      = os.path.realpath(__file__)
    #print(f"trace 2 {ScriptPath}")
    HERE            = os.path.dirname(__file__)
    HOME            = os.getenv('HOME') # None

    SAMESHOME       = os.path.abspath(os.path.join(HERE, '../..'))
    #print(f"trace 3 {SAMESHOME}")
    sys.path.append(SAMESHOME) # Not sure this is necessary.

    TestDataDs      = f"{SAMESHOME}/testdata"

    SAMESSLIB       = os.path.abspath(os.path.join(SAMESHOME, 'slib'))
    sys.path.append(SAMESSLIB)

    import SBinLib as sbl

    SamesProjectDs  = os.path.abspath(os.path.join(HERE, '..'))
    #print(f"trace 4 {SamesProjectDs}")
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

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of python3.main.py


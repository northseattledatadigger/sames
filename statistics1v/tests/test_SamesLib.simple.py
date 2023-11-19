#!/usr/bin/python3

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# test_SamesLib.simple.py

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Constants and Imports

import os
import sys 

if len(sys.argv) != 2:
    raise ValueError("Must provide test subset id as sole argument.")

SubType         = sys.argv[1]

ScriptPath      = os.path.realpath(__file__)
HERE            = os.path.dirname(__file__)
HOME            = os.getenv('HOME') # None

SAMESHOME       = os.path.abspath(os.path.join(HERE, '../..'))
sys.path.append(SAMESHOME) # Not sure this is necessary.

SamesProjectDs  = os.path.abspath(os.path.join(HERE, '..'))
sys.path.append(SamesProjectDs) # Not sure this is necessary.
Python3LibFs    = f"{SamesProjectDs}/SamesLib_{SubType}.py"

if os.path.isfile(Python3LibFs):
    match SubType:
        case "amateur":
            print("Not Yet Implemented.")
        case "naive":
            print("Not Yet Implemented.")
        case "native":
            #import SamesLib_native as s
            from SamesLib_native import *
        case "pandas":
            print("Not Yet Implemented.")
        case "polars":
            print("Not Yet Implemented.")
        case _:
            m = f"."
            raise ValueError(m)
            m = f"Library Under Test {Python3LibFs} NOT found."
            raise ValueError(m)

import pytest

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Tests

# describe 'generateModefromFrequencyAA(faaA)'

def test_Raises_ValueError_if_argument_not_dictionary():
    """
    Raises an ArgumentError unless the argument passed is a Hash.
    """

    with pytest.raises(ValueError) as excinfo:
        generateModefromFrequencyAA(nil)
    assert str(excinfo.value) == "Only argument must be frequency dictionary."

    with pytest.raises(ValueError) as excinfo:
        generateModefromFrequencyAA(333)
    assert str(excinfo.value) == "Only argument must be frequency dictionary."

    with pytest.raises(ValueError) as excinfo:
        generateModefromFrequencyAA("a string")
    assert str(excinfo.value) == "Only argument must be frequency dictionary."

    with pytest.raises(ValueError) as excinfo:
        generateModefromFrequencyAA([])
    assert str(excinfo.value) == "Only argument must be frequency dictionary."

#it "returns takes a frequency Associative Array, and returns a mode point statistic." do
    #h = {'1234' => 528, 528 => 3, "A longer string" => 0, "x" => 55555 }
    #result = generateModefromFrequencyAA(h)
    #assert_equal "x", result


# describe 'isANumStr?'

'''
# it "Discerns if value has a String that could be parsed as a number."
def test_isANumStr_sees_number_strings():
    result = isANumStr('1234')
    assert result == true
    result = isANumStr('1234.56789')
    assert result == true
    result = isANumStr('.1234')
    assert result == true
    result = isANumStr('1234.0')
    assert result == true
    result = isANumStr('12 34')
    assert result == false
    result = isANumStr('12x4')
    assert result == false
    result = isANumStr('A')
    assert result == false
    result = isANumStr('%')
    assert result == false

# it "Rejects non-strings."
def test_isANumStr_rejects_non_strings():
    result = isANumStr(1234)
    assert result == false
    v = 15.993
    result = isANumStr(v)
    assert result == false
    v = 0.1234
    result = isANumStr(v)
    assert result == false
'''

##2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of test_SamesLib.simple.py

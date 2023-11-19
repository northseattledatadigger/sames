#!/usr/bin/python3

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# test_SamesLib_simple.py

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Constants and Imports

import os
import sys 

if len(sys.argv) != 2:
    raise ValueError("Must provide test subset id as sole argument.")

'''
SubType         = sys.argv[1]

ScriptPath      = os.path.realpath(__file__)
HERE            = os.path.dirname(__file__)
HOME            = os.getenv('HOME') # None

SAMESHOME       = os.path.abspath(os.path.join(HERE, '../..'))
sys.path.append(SAMESHOME) # Not sure this is necessary.

SamesProjectDs  = os.path.abspath(os.path.join(HERE, '..'))
sys.path.append(SamesProjectDs) # Not sure this is necessary.
Python3LibFs    = f"{SamesProjectDs}/SamesLib_{SubType}.py"

from SamesLib_native import *
'''

#!/usr/bin/python3

import os
import sys 

HereDs          = os.path.realpath(__file__)
HomeDs          = os.getenv('HOME') # None

sames_home      = "../" + HereDs
SAMESHOME       = os.path.abspath(sames_home)
sys.path.append(os.path.abspath(SAMESHOME))           # Not sure what this was for.

Python3LibFs    = f"{SAMESHOME}/slib/SamesTopLib.py"

if os.path.isfile(Python3LibFs):
    from Python3LibFs import *
else:
    m = "Sole argument must be valid filename of Ruby library."
    raise ValueError(m)
end

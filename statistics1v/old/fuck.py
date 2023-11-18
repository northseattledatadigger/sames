#!/usr/bin/python3

import os
import sys 

print(f"{len(sys.argv)}")
sys.exit(0)
if len(sys.argv) != 2:
    raise ValueError("Must provide test subset id as sole argument.")
end
SubType         = sys.argv[1]

HERE            = os.path.realpath(__file__)
HOME            = os.getenv('HOME') # None

sames_home      = "../../" + HERE
SAMESHOME       = os.path.abspath(project_home)
sys.path.append(os.path.abspath(SAMESHOME))           # Not sure what this was for.

project_home    = "../" + HERE
SamesProjectDs  = os.path.abspath(project_home)
sys.path.append(os.path.abspath(SamesProjectDs))    # Not sure what this was for.
Python3LibFs    = f"{SamesProjectDs}/SamesLib.{SubType}.py"

if os.path.isfile(Python3LibFs):
    from Python3LibFs import *
else:
    m = "Sole argument must be valid filename of Ruby library."
    raise ValueError(m)
end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# SBinLib.py

import os
import sys

def assureInternetDataFileCopy(dSpec,fileName,fileURL):

    os.mkdir(dSpec)
    fspec   = f"{dSpec}/{fileName}"

    if os.path.isfile(fspec):
        return True
    else:
        os.system(f"wget {fileURL} -O{fspec}")
    if os.path.isfile(fspec):
        return true
    m=f"Could not find File {fileName}, nor procure it from {fileURL}."
    print(m, file=sys.stderr)
    return False

def returnIfThere(fSpec):
    if os.path.isfile(fSpec):
        return fSpec
    m=f"Data file {fSpec} not found." 
    raise ValueError( m )

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of SBinLib.py

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# SamesTopLib.py

import os

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Constants and Environment

SamesSBin           = f"#{SAMESHOME}/sbin"
SamesExamplesDs     = f"{SAMESHOME}/examples"
SamesTopLibDs       = f"{SAMESHOME}/slib"
SamesTestData       = f"{SAMESHOME}/testdata"
SamesTmpData        = f"{SAMESHOME}/tmpdata"

Python3LibFs        = f"{SamesTopLibDs}/SBinLib.rb"

if not os.path.isfile(Python3LibFs):
    m = "Sole argument must be valid filename of Ruby library."
    raise ValueError(m)
end

from Python3LibFs import *

StdLibName          = 'SamesLib'

KeptFileURLs        = f"{SAMESHOME}/InternetFileURLs.csv"

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Procedures

def getKeptFileURL(fN):
    # Note I'm going to just use split here and Presume the files will be
    # maintained with both filenames and URLs with NO embedded commas.
    # There are other ways, but it's not worth my bother at this time.
    File.open(KeptFileURLs) do |fp|
        fp.each_line do |ll|
            if ll =~ /#{fN}$/ then
                url,fn = ll.split(',')
                return url
    raise ValueError("No such '#{fN}' file found in #{KeptFileURLs}.")

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of SamesTopLib.py

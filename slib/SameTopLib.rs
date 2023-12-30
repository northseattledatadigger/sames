//345678901234567890123456789012345678901234567890123456789012345678901234567890
// SamesTopLib.rb

unless File.exist?( SAMESHOME )
    raise ArgumentError, "FATAL:  SAMESHOME is required, but was missing."
end

//345678901234567890123456789012345678901234567890123456789012345678901234567890
// Constants and Environment

const SamesSBin           = "#{SAMESHOME}/sbin"
const SamesExamplesDs     = "#{SAMESHOME}/examples"
const SamesTopLibDs       = "#{SAMESHOME}/slib"
const SamesTestData       = "#{SAMESHOME}/testdata"
const SamesTmpData        = "#{SAMESHOME}/tmpdata"

require "#{SamesTopLibDs}/SBinLib.rb"

StdLibName='SamesLib'

KeptFileURLs="#{SAMESHOME}/InternetFileURLs.csv"

//345678901234567890123456789012345678901234567890123456789012345678901234567890
// Procedures

def getKeptFileURL(fN)
    # Note I'm going to just use split here and Presume the files will be
    # maintained with both filenames and URLs with NO embedded commas.
    # There are other ways, but it's not worth my bother at this time.
    File.open(KeptFileURLs) do |fp|
        fp.each_line do |ll|
            if ll =~ /#{fN}$/ then
                url,fn = ll.split(',')
                return url
            end
        end
    end
    raise ArgumentError, "No such '#{fN}' file found in #{KeptFileURLs}."
end

//345678901234567890123456789012345678901234567890123456789012345678901234567890
// End of SamesTopLib.rb

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# SBinLib.rb

require 'fileutils'

def assureInternetDataFileCopy(dSpec,fileName,fileURL)

    FileUtils.mkdir_p dSpec
    fspec="#{dSpec}/#{fileName}"

    if File.exist?(fspec) then
        return true
    else
        `wget #{fileURL} -O#{fspec}`
    end
    return true if File.exist?(fspec)
    STDERR.puts "Could not find File #{fileName}, nor procure it from #{fileURL}."
    return false
end

def returnIfThere(fSpec)
    return fSpec if File.exists?(fSpec)
    raise ArgumentError, "Data file #{fSpec} not found." 
end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of SBinLib.rb

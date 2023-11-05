#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# SamesLib.native.rb

require "bigdecimal"

#2345678901234567890123456789012345678901234567890123456789012345678901234567890

def genFactorial(nA)
    raise ArgumentError unless nA.is_a? Integer
    nf = Math.gamma(nA + 1)
    return nf
end

def isANumStr?(strA)
    return false    unless strA.is_a? String
    return false    unless strA =~ /^-?\d*\.?\d+$/
    return true
end

def isNumericVector?(vA)
    return true if vA.all? { |lve| lve.is_a? Numeric }
    return false
end

def isUsableNumber?(cA)
    return true         if cA.is_a? Numeric
    return true         if isANumStr?(cA)
    return false
end

def isUsableNumberVector?(vA)
    return true if vA.all? { |lve| isUsableNumber?(lve) }
    return false
end

def validateStringNumberRange(xFloat)
    if xFloat.is_a? String then
        abbuffer = BigDecimal(xFloat)
        afbuffer = xFloat.to_f
        unless abbuffer == afbuffer
            raise RangeError, "#{xFloat} larger than float capacity for this app."
        end
    end
end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of SamesLib.native.rb

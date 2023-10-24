#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# WPMS2023.rb
# These activities are designed to run literally, without special optimizations,
# as much as possible like the formulations referenced in late 2023 copies of:
#   https://en.wikipedia.org/wiki/Standard_deviation
#   https://www.calculatorsoup.com/calculators/statistics/mean-median-mode.php

require 'csv'

#2345678901234567890123456789012345678901234567890123456789012345678901234567890

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

class VectorOfX

    def genCount
        n = @VectorOfContinuous.size
        return n
    end

    def pushX(xFloat)
        raise ArgumentError unless isUsableNumber?(xFloat)
        lfn = xFloat.to_f
        @VectorOfContinuous.push(lfn)
    end

end

class VectorOfContinuous < VectorOfX

    class << self

        def newAfterValidation(arrayA)
            v = Array.new
            arrayA.each do |le|
                raise ArgumentError unless isUsableNumber?(le)
                v.push(le.to_f)
            end
            localo = self.new(v)
            return localo
        end

        def newAfterInvalidatedDropped(arrayA)
            v = Array.new
            arrayA.each do |le|
                next unless isUsableNumber?(le)
                v.push(le.to_f)
            end
            localo = self.new(v)
            return localo
        end

    end

    def initialize(vectorX=Array.new)
        @VectorOfContinuous = vectorX
        @UseSumOfXs = false
    end

    def assureXsPrecision(precisionSpec)
        raise ArgumentError, "Not Yet Implemented."
    end

    def genInterQuartileRange
        n = @VectorOfContinuous.size
                                # Subtract one here
                                # to get the offset.
        q1os    = 1                 - 1
        q2os    = ( n + 1 ) / 4     - 1
        q3os    = ( n / 2 )         - 1
        q4os    = 3 * ( q2os + 1 )  - 1
        qendos  = n                 - 1
        return q1os,  q2os,  q3os,  q4os,  qendos
    end

    def genMax
        svox = @VectorOfContinuous.sort
        return svox[-1]
    end

    def genMean
        n = @VectorOfContinuous.size.to_f
        sumxs = @VectorOfContinuous.sum.to_f
        return ( sumxs / n ).round(4)
    end

    def genMeanStdDev
        variance = nil
        if @UseSumOfXs then
            variance = genVarianceXsSquaredMethod
        else
            variance = genVarianceSumOfDifferencesFromMean
        end
        stddev = Math.sqrt(variance).round(4)
    end

    def genMedian
        n = @VectorOfContinuous.size
        svox = @VectorOfContinuous.sort
        if n % 2 == 0 then
            nm2 = ( n + 1 ) / 2
            return svox[nm2]
        else
            nm2a = n / 2
            x1 = svox[nm2a]
            nm2b = nm2a + 1
            x2 = svox[nm2b]
            x3 = ( x1 + x2 ).to_f / 2.0
            return x3.round(4)
        end
    end

    def genMin
        svox = @VectorOfContinuous.sort
        return svox[0]
    end

    def genMinMax
        svox = @VectorOfContinuous.sort
        return svox[0], svox[-1]
    end

    def genMode
        # This is broken.  Do NOT debug until later.  TBD
        h = Hash.new
        @VectorOfContinuous.each do |lx|
            h[lx] = 1   unless h.has_key?(lx)
            h[lx] += 1      if h.has_key?(lx)
        end
        x = 0
        m = 0
        h.keys.each do |lx|
            if h[lx] > m then
                x = lx
                m = h[lx]
            end
        end
        return x
    end

    def genNIsEven?
        n = @VectorOfContinuous.size
        return true if n % 2 == 0
        return false
    end

    def genOutliers(stdDev,numberOfStdDevs=1)
        raise ArgumentError, "Not Yet Implemented."
    end

    def genQuartiles
        qos0, qos1, qos2, qos3, qos4, qose = genInterQuartileRange
        svox = @VectorOfContinuous.sort
        return svox[qos0], svox[qos2], svox[qos3], svox[qos4], svox[qos3]
    end

    def genRange
        svox = @VectorOfContinuous.sort
        return svox[0], svox[-1]
    end

    def genSum
        sumxs = @VectorOfContinuous.sum
        return sumxs
    end

    def genVarianceSumOfDifferencesFromMean
        mu = genMean
        n = @VectorOfContinuous.size
        sumofdiffsquared = 0
        @VectorOfContinuous.reduce(0) do |sumxssquared, lx|
            xlessmu = lx - mu
            sumofdiffsquared += ( xlessmu * xlessmu )
        end
        v = sumofdiffsquared / ( n - 1 )
        return v
    end

    def genVarianceXsSquaredMethod
        mu = genMean
        n = @VectorOfContinuous.size
        sumxssquared = 0
        @VectorOfContinuous.reduce(0) do |sumxssquared, lx|
            sumxssquared += lx * lx
        end
        v = ( sumxssquared - ( mu * mu ) ) / ( n - 1 )
        return v
    end

    def pushX(xFloat)
        raise ArgumentError unless isUsableNumber?(xFloat)
        lfn = xFloat.to_f
        @VectorOfContinuous.push(lfn)
    end

    attr_accessor :UseSumOfXs

end

class VectorOfDiscrete < VectorOfX
    # TBD for use with columns having discrete values.
end

class VectorTable

    class << self

        def isAllowedDataVectorClass?(vectorClass)
            return false    unless vectorClass.is_a? Class
            return true         if vectorClass.ancestors.include? VectorOfX
            return false
        end

        def newFromCSV(fSpec,vcSpec,skipFirstLine=true)
            localo = self.new(vcSpec)
            File.open(fSpec) do |fp|
                i = 0
                fp.each_line do |ll|
                    sll = ll.strip
                    unless ( i == 0 and skipFirstLine )
                        columns = sll.parse_csv
                        localo.pushTableRow(columns)
                    end
                    i += 1
                end
            end
            return localo
        end

    end

    def initialize(vectorOfClasses)
        raise ArgumentError unless vectorOfClasses.is_a? Array
        @TableOfVectors     = Array.new
        @VectorOfClasses    = vectorOfClasses
        i = 0
        @VectorOfClasses.each do |lci|
            if lci then
                raise ArgumentError unless self.class.isAllowedDataVectorClass?(lci)
                @TableOfVectors[i] = lci.new        if lci
            else
                @TableOfVectors[i] = nil        
            end
            i += 1
        end
    end

    def getVectorObject(indexNo)
        unless VectorTable.isAllowedDataVectorClass?( @TableOfVectors[indexNo].class )
            raise ArgumentError, "Column #{indexNo} not configured for Data Processing."
        end
        return @TableOfVectors[indexNo]
    end

    def pushTableRow(arrayA)
        i = 0
        @TableOfVectors.each do |lvoe|
            if lvoe.is_a? VectorOfX then
                lvoe.pushX(arrayA[i])
            end
            i += 1
        end
    end

end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of WPMS2023.rb

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# SamesLib.native.rb
# These activities are designed to run literally, without special optimizations,
# as much as possible like the formulations referenced in late 2023 copies of:
#   https://en.wikipedia.org/wiki/Standard_deviation
#   https://www.calculatorsoup.com/calculators/statistics/mean-median-mode.php

# NOTE On floating point ranges:  I'm not completely comfortable with the
# behavior I've seen with large floating point numbers.  It may be I'm just
# too inexperienced, and I need to revisit it later, after I've seen how the
# other language environments deal with it, and do some other research.  For
# now, I have some cautions that may be pretty amateur, but at least they
# do some checking.  xc 2023/11/01

# NOTE: On looking across languages, I've gone through my code and changed
# all references to Hash, Dictionary, Map, etc to "AA", for Associative Array,
# as that seemed to be the name the Wikipedia favored the day I looked around
# for a dominant term:  https://en.wikipedia.org/wiki/Associative_array
# As such, if you see the string "AA" in names, it is trying to indicate the
# subject or main data handled is an "Associative Array".  In particular, in
# the past I have used "Larry Wall's" term Hash, which is probably less than
# helpful. (I ruled out "AssArr" as needlessly distracting.)

# NOTE:  Starting 2023/11/08, I'm changing my usage as follows:
#       1.  A routine that pretty much directly uses existing language
#       methods to access or calculate some data will be prefixed get:
#           getFactorial, getSum, getCount
#       2.  A routine that mostly actually does a calculation, no loops,
#       or major subroutine calls (other than buffer updates), just formulas
#       or sequences of calculations, will be prefixed with calculate:
#           calculateGeometricMean, calculateQuartile,
#       3.  Anything that requires looping, or to a great extent uses other
#       methods, entirely or along with calculations, will be prefixed with
#       generate:
#           generateMode, generateStandardDeviation, 
#       4.  The term I will used when an output array or associative array is
#           "generated", will be "collection".
#       5.  The term I will use when the calculation is completely farmed out
#       to other routines is then request:
#           requestKurtosis.
#       

require "bigdecimal"
require 'csv'
require 'json'

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Global Support Routines

def getFactorial(nA)
    raise ArgumentError unless nA.is_a? Integer
    nf = Math.gamma(nA + 1)
    return nf
end

def generateModefromFrequencyAA(faaA)
    raise ArgumentError unless faaA.is_a? Hash
    x = 0
    m = 0
    faaA.keys.each do |lx|
        if faaA[lx] > m then
            x = lx
            m = faaA[lx]
        end
    end
    return x
end

def isANumStr?(strA)
    return false    unless strA.is_a? String
    return false    unless strA =~ /^-?\d*\.?\d+$/
    return true
end

def isNumericVector?(vA)
    raise ArgumentError unless vA.is_a? Array
    return true if vA.all? { |lve| lve.is_a? Numeric }
    return false
end

def isUsableNumber?(cA)
    return true         if cA.is_a? Numeric
    return true         if isANumStr?(cA)
    return false
end

def isUsableNumberVector?(vA)
    raise ArgumentError unless vA.is_a? Array
    return true if vA.all? { |lve| isUsableNumber?(lve) }
    return false
end

def validateStringNumberRange(xFloat)
    unless xFloat.is_a? String
        raise ArgumentError, "Validation is ONLY for Strings."
    end
    abbuffer = BigDecimal(xFloat)
    afbuffer = xFloat.to_f
    unless abbuffer == afbuffer
        raise RangeError, "#{xFloat} larger than float capacity for this app."
    end
end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# HistogramOfX

class HistogramOfX

    class RangeOccurrence 

        def initialize(startNo,stopNo)
            raise ArgumentError unless startNo.is_a? Numeric
            raise ArgumentError unless stopNo.is_a? Numeric
            @Count      = 0
            @StartNo    = startNo
            @StopNo     = stopNo
        end

        def addToCount
            @Count += 1
        end

        def hasOverlap?(startNo,stopNo)
            raise ArgumentError unless startNo.is_a? Numeric
            raise ArgumentError unless stopNo.is_a? Numeric
            return true if @StartNo <= startNo and startNo < @StopNo
            return true if @StartNo < stopNo and stopNo <= @StopNo
            return false
        end

        def isInRange?(xFloat)
            raise ArgumentError unless xFloat.is_a? Numeric
            return false unless xFloat >= @StartNo
            return false unless xFloat < @StopNo
            return true
        end

        attr_reader :Count
        attr_reader :StartNo
        attr_reader :StopNo
        
    end

    class << self

        def newFromDesiredSegmentCount(startNo,maxNo,desiredSegmentCount,extraMargin=0)
            raise ArgumentError unless startNo.is_a? Numeric
            raise ArgumentError unless maxNo.is_a? Numeric
            raise ArgumentError unless desiredSegmentCount.is_a? Integer
            raise ArgumentError unless extraMargin.is_a? Numeric
            # xc 20231106:  Don't worry about cost of passing the AA around until efficiency passes later.
            totalbreadth    = ( maxNo - startNo + 1 + extraMargin ).to_f
            dscf            = desiredSegmentCount.to_f
            segmentsize     = totalbreadth / dscf
            #STDERR.puts "trace segmentsize:  #{segmentsize}"
            localo          = self.newFromUniformSegmentSize(startNo,maxNo,segmentsize)
            return localo
        end

        def newFromUniformSegmentSize(startNo,maxNo,segmentSize)
            raise ArgumentError unless startNo.is_a? Numeric
            raise ArgumentError unless maxNo.is_a? Numeric
            raise ArgumentError unless segmentSize.is_a? Numeric
            # xc 20231106:  Don't worry about cost of passing the AA around until efficiency passes later.
            localo          = HistogramOfX.new(startNo,maxNo)
            bottomno        = startNo
            topno           = bottomno + segmentSize
            while bottomno <= maxNo
                localo.setOccurrenceRange(bottomno,topno)
                bottomno    = topno
                topno       += segmentSize
            end
            return localo
        end

    end

    def _validateNoOverlap(startNo,stopNo)
        raise ArgumentError unless startNo.is_a? Numeric
        raise ArgumentError unless stopNo.is_a? Numeric
        @FrequencyAA.values.each do |lroo|
            if lroo.hasOverlap?(startNo,stopNo)
                m = "Range [#{startNo},#{stopNo}] overlaps with another range:  [#{lroo.StartNo},#{lroo.StopNo}]."
                raise ArgumentError, m
            end
        end
    end

    def initialize(lowestValue,highestValue=nil)
        raise ArgumentError unless lowestValue.is_a? Numeric
        raise ArgumentError unless highestValue.is_a? Numeric
        @FrequencyAA    = Hash.new
        @Max            = highestValue
        @Min            = lowestValue
    end

    def addToCounts(xFloat)
        raise ArgumentError unless xFloat.is_a? Numeric
        @FrequencyAA.keys.sort.each do |lstartno|
            lroo = @FrequencyAA[lstartno]
            if xFloat < lroo.StopNo then
                lroo.addToCount
                return
            end
        end
        m = "Programmer Error:  "
        m += "No Frequency range found for xFloat:  '#{xFloat}'."
        raise ArgumentError, m
    end

    def generateCountCollection
        orderedlist = Array.new
        @FrequencyAA.keys.sort.each do |lstartno|
            lroo = @FrequencyAA[lstartno]
            orderedlist.push([lstartno,lroo.StopNo,lroo.Count])
        end
        return orderedlist
    end

    def setOccurrenceRange(startNo,stopNo)
        raise ArgumentError unless startNo.is_a? Numeric
        raise ArgumentError unless stopNo.is_a? Numeric
        raise ArgumentError unless startNo < stopNo
        _validateNoOverlap(startNo,stopNo)
        @FrequencyAA[startNo]   = RangeOccurrence.new(startNo,stopNo)
    end

    def validateRangesComplete
        i = 0
        lroo = nil
        previous_lroo = nil
        @FrequencyAA.keys.sort.each do |lstartno|
            lroo = @FrequencyAA[lstartno]
            unless lstartno == lroo.StartNo
                raise RangeError, "Programmer Error on startno assignments."
            end
            if i == 0 then
                unless lroo.StartNo <= @Min
                    m = "Range [#{lroo.StartNo},#{lroo.StopNo}] "
                    m += " starts after the minimum designated value '#{@Min}."
                    raise RangeError, m
                end
            else
                unless lroo.StartNo == previous_lroo.StopNo
                    m = "Range [#{previous_lroo.StartNo},#{previous_lroo.StopNo}]"
                    m += " is not adjacent to the next range "
                    m += "[#{lroo.StartNo},#{lroo.StopNo}]."
                    raise RangeError, m
                end
            end
            i += 1
            previous_lroo = lroo
        end
        unless @Max <= lroo.StopNo
            m = "Range [#{lroo.StartNo},#{lroo.StopNo}] "
            m += " ends before the maximum value '#{@Max}."
            raise RangeError, m
        end

    end

    attr_reader :FrequencyAA
    attr_reader :Max
    attr_reader :Min
        
end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# SumsOfPowers

class SumsOfPowers

    # NOTE:  The main merit to doing it this way is as a teaching or illustration
    # tool to show the two parallel patterns.  Probably this is not a good way
    # to implement it in most or any production situations.

    class << self

        def calculatePearsonsFirstSkewnessCoefficient(aMean,modeFloat,stdDev)
            raise ArgumentError unless aMean.is_a? Numeric
            raise ArgumentError unless modeFloat.is_a? Numeric
            raise ArgumentError unless stdDev.is_a? Numeric
            # See 2023/11/05 "Pearson's first skewness coefficient" in:
            #   https://en.wikipedia.org/wiki/Skewness
            sc  = ( aMean - modeFloat ) / stdDev
            return sc
        end

        def calculatePearsonsSecondSkewnessCoefficient(aMean,medianFloat,stdDev)
            raise ArgumentError unless aMean.is_a? Numeric
            raise ArgumentError unless medianFloat.is_a? Numeric
            raise ArgumentError unless stdDev.is_a? Numeric
            # See 2023/11/05 "Pearson's second skewness coefficient" in:
            #   https://en.wikipedia.org/wiki/Skewness
            sc  = ( aMean - medianFloat ) / stdDev
            return sc
        end

    end

    def _calculateSecondMomentSubjectXs
        #   Sum( xi - mu )**2 == Sum(xi**2) - (1/n)(amean**2)
        # Note I checked this one at:
        #   https://math.stackexchange.com/questions/2569510/proof-for-sum-of-squares-formula-statistics-related
        #
        if @DiffFromMeanInputsUsed
            raise ArgumentError, "May ONLY be used with Sum of Xs Data."
        end
        nreciprocal = ( 1.0 / @N.to_f )
        first  = @SumPowerOf2
        second = nreciprocal * ( @ArithmeticMean**2)
        ssx = first - second
        return ssx
    end

    def _calculateThirdMomentSubjectXs
        # My algegra, using unreduced arithmetic mean parts because that becomes complicated
        # when going to sample means, leads to a simple Pascal Triangle pattern:
        # My algegra: Sum( xi - mu )**3 ==
        #   Sum(xi**3) - 3*Sum(xi**2)*amean + 3*Sum(xi)*(amean**2) - mu**3
        if @DiffFromMeanInputsUsed
            raise ArgumentError, "May ONLY be used with Sum of Xs Data."
        end
        first   = @SumPowerOf3
        second  = 3 * @SumPowerOf2  *   @ArithmeticMean
        third   = 3 * @SumOfXs      * ( @ArithmeticMean**2 )
        fourth  = @ArithmeticMean**3
        result  = first - second + third - fourth
        return result
    end

    def _calculateFourthMomentSubjectXs
        # My algegra, using unreduced arithmetic mean parts because that becomes complicated
        # when going to sample means, leads to a simple Pascal Triangle pattern:
        # My algegra: Sum( xi - mu )**4 ==
        #   Sum(xi**4) - 4*Sum(xi**3)*amean + 6*Sum(xi**2)(amean**2) - 4**Sum(xi)*(amean**3) + mu**4
        if @DiffFromMeanInputsUsed
            raise ArgumentError, "May ONLY be used with Sum of Xs Data."
        end
        first   = @SumPowerOf4
        second  = 4 * @SumPowerOf3 * @ArithmeticMean
        third   = 6 * @SumPowerOf2 * ( @ArithmeticMean**2 )
        fourth  = 4 * @SumOfXs * @ArithmeticMean**3
        fifth   = @ArithmeticMean**4
        result  = first - second + third - fourth + fifth
        return result
    end

    def initialize(populationDistribution=false)
        @ArithmeticMean         = 0
        @N                      = 0
        @DiffFromMeanInputsUsed    = false
        @Population             = populationDistribution

        @SumOfXs                = 0
        @SumPowerOf2            = 0
        @SumPowerOf3            = 0
        @SumPowerOf4            = 0
    end

    def addToSums(sFloat)
        unless @DiffFromMeanInputsUsed then
            @N += 1
            @SumOfXs        += sFloat   

            @ArithmeticMean = ( @SumOfXs.to_f / @N.to_f )
        end
        @SumPowerOf2        += sFloat * sFloat
        @SumPowerOf3        += sFloat * sFloat * sFloat
        @SumPowerOf4        += sFloat * sFloat * sFloat * sFloat
    end

    def calculateExcessKurtosis_2_JR_R
        #trace genExcessKurtosis_2_JR_R:  18.0, 708.0, 39.333333333333336, 60.0, 11.111111111111112, 0.5399999999999996
        #  2018-01-04 by Jonathan Regenstein https://rviews.rstudio.com/2018/01/04/introduction-to-kurtosis/
        unless @DiffFromMeanInputsUsed
            raise ArgumentError, "May NOT be used with Sum of Xs Data."
        end
        nf          = @N.to_f
        numerator   = @SumPowerOf4 / nf
        denominator = ( @SumPowerOf2 / nf ) ** 2 
        ek          = ( numerator / denominator ) - 3
        #puts "trace genExcessKurtosis_2_JR_R:  #{nf}, #{@SumPowerOf4}, #{numerator}, #{@SumPowerOf2}, #{denominator}, #{ek}"
        return ek
    end

    def generateExcessKurtosis_3_365datascience
        #  https://365datascience.com/calculators/kurtosis-calculator/
        unless @DiffFromMeanInputsUsed
            raise ArgumentError, "May NOT be used with Sum of Xs Data."
        end
        nf                  = @N.to_f
        stddev              = generateStandardDeviation
        s4                  = stddev**4

        leftnumerator       = nf * ( nf + 1.0 )
        leftdenominator     = ( nf - 1.0 ) * ( nf - 2.0 ) * ( nf - 3.0 )
        left                = leftnumerator / leftdenominator

        middle              = @SumPowerOf4 / s4

        rightnumerator      = 3 * ( ( nf - 1 )**2 )
        rightdenominator    = ( nf - 2.0 ) * ( nf - 3.0 )
        right               = rightnumerator / rightdenominator
        ek                  = left * middle - right
        return ek
    end

    def calculateKurtosis_Biased_DiffFromMeanCalculation
        # See 2023/11/05 "Standard biased estimator" in:
        #   https://en.wikipedia.org/wiki/Kurtosis
        unless @DiffFromMeanInputsUsed
            raise ArgumentError, "May NOT be used with Sum of Xs Data."
        end
        nreciprocal     = ( 1.0 / @N.to_f )
        numerator       = nreciprocal * @SumPowerOf4
        denominternal   = nreciprocal * @SumPowerOf2
        denominator     = denominternal * denominternal
        g2              = numerator / denominator
        return g2
    end

    def calculateKurtosis_Unbiased_DiffFromMeanCalculation
        # See 2023/11/05 "Standard unbiased estimator" in:
        #   https://en.wikipedia.org/wiki/Kurtosis
        unless @N > 3
            raise ArgumentError, "This formula wll not be executed for N <= 3."
        end
        unless @DiffFromMeanInputsUsed
            raise ArgumentError, "May NOT be used with Sum of Xs Data."
        end
        #STDERR.puts "\ntrace 1 genKurtosis_Unbiased_DiffFromMeanCalculation:  #{@ArithmeticMean},#{@N},#{@DiffFromMeanInputsUsed},#{@Population},#{@SumOfXs},#{@SumPowerOf2},#{@SumPowerOf3},#{@SumPowerOf4}"
        nf = @N.to_f

        leftnumerator       = ( nf + 1.0 ) * nf * ( nf - 1.0 )
        leftdenominator     = ( nf - 2.0 ) * ( nf - 3.0 )
        left                = leftnumerator / leftdenominator

        middle              = @SumPowerOf4 / ( @SumPowerOf2**2 )

        rightnumerator      = ( nf - 1.0 )**2
        rightdenominator    = ( nf - 2.0 ) * ( nf - 3.0 )
        right               = rightnumerator / rightdenominator
        sue_G2              = left * middle - right
        #STDERR.puts "\nsue_G2              = left * middle * right: #{sue_G2}              = #{left} * #{middle} * #{right}"

        return sue_G2
    end

    def calculateNaturalEstimatorOfPopulationSkewness_g1
        # See 2023/11/05 "Sample Skewness" in:
        #   https://en.wikipedia.org/wiki/Skewness
        inside_den      = nil
        nreciprocal     = ( 1.0 / @N.to_f )
        numerator       = nil
        if @DiffFromMeanInputsUsed then
            inside_den  = nreciprocal * @SumPowerOf2
            numerator   = nreciprocal * @SumPowerOf3
        else
            second      = _calculateSecondMomentSubjectXs
            third       = _calculateThirdMomentSubjectXs

            inside_den  = nreciprocal * second
            numerator   = nreciprocal * third
        end
        denominator     = ( Math.sqrt( inside_den ) )**3
        g1              = numerator / denominator
        return g1
    end

    def calculateVarianceUsingSubjectAsDiffs
        unless @DiffFromMeanInputsUsed
            raise ArgumentError, "May NOT be used with Sum of Xs Data."
        end
        nf              = @N.to_f
        v = @SumPowerOf2 / ( nf - 1.0 ) unless @Population
        v = @SumPowerOf2 / nf               if @Population
        #STDERR.puts "trace 8 #{self.class}.genVarianceUsingSubjectAsDiffs:  #{v}, #{nf}, #{@Population}, #{@SumPowerOf2}"
        return v
    end

    def calculateVarianceUsingSubjectAsSumXs
        if @DiffFromMeanInputsUsed
            raise ArgumentError, "May ONLY be used with Sum of Xs Data."
        end
        ameansquared = @ArithmeticMean * @ArithmeticMean
        nf              = @N.to_f
        if @Population then
            v = ( @SumPowerOf2 - nf * ameansquared ) / nf
        else
            v = ( @SumPowerOf2 - nf * ameansquared ) / ( nf - 1.0 )
        end
        #STDERR.puts "trace 8 #{self.class}.genVarianceUsingSubjectAsSumXs: #{v}, #{nf}, #{@Population}, #{@SumPowerOf2}, #{ameansquared}"
        return v
    end

    def generateNaturalEstimatorOfPopulationSkewness_b1
        # See 2023/11/05 "Sample Skewness" in:
        #   https://en.wikipedia.org/wiki/Skewness
        nreciprocal     = ( 1.0 / @N.to_f )
        numerator       = nil
        if @DiffFromMeanInputsUsed then
            numerator   = nreciprocal * @SumPowerOf3
        else
            thirdmoment = _calculateThirdMomentSubjectXs
            numerator   = nreciprocal * thirdmoment
        end
        stddev          = generateStandardDeviation
        denominator     = stddev**3
        b1              = numerator / denominator
        return b1
    end

    def generateStandardDeviation
        sc = self.class
        #STDERR.puts "trace 0 #{sc}.genStandardDeviation:  #{@ArithmeticMean},#{@N},#{@DiffFromMeanInputsUsed},#{@Population},#{@SumOfXs},#{@SumPowerOf2},#{@SumPowerOf3},#{@SumPowerOf4}"
        v = nil
        if @DiffFromMeanInputsUsed then
            v = calculateVarianceUsingSubjectAsDiffs
        else
            v = calculateVarianceUsingSubjectAsSumXs
        end
        stddev = Math.sqrt(v)
        return stddev
    end

    def generateThirdDefinitionOfSampleSkewness_G1
        # See 2023/11/05 "Sample Skewness" in:
        #   https://en.wikipedia.org/wiki/Skewness
        b1      = generateNaturalEstimatorOfPopulationSkewness_b1
        nf      = @N.to_f
        k3      = ( nf**2 ) * b1
        k2_3s2  = ( nf - 1 ) * ( nf - 2 )
        ss_G1   = k3 / k2_3s2
        return ss_G1
    end

    def requestKurtosis
        # This of course needs to be expanded to use both diffs from mean ANd sum of Xs calculation.
        kurtosis = calculateKurtosis_Unbiased_DiffFromMeanCalculation
        return kurtosis
    end

    def requestSkewness(formulaId=3)
        #NOTE:  There is NO POPULATION Skewness at this time.
        if @Population then
            m = "There is no POPULATION skewness formula implemented at this time."
            raise ArgumentError, m
        end
        skewness = nil
        case formulaId
        when 1
            skewness = generateNaturalEstimatorOfPopulationSkewness_b1
        when 2
            skewness = calculateNaturalEstimatorOfPopulationSkewness_g1
        when 3
            skewness = generateThirdDefinitionOfSampleSkewness_G1
        else
            m = "There is no skewness formula #{formulaId} implemented at this time."
            raise ArgumentError, m
        end
        return skewness
    end

    def setToDiffsFromMeanState(sumXs,nA)
        raise ArgumentError unless sumXs.is_a? Numeric
        raise ArgumentError unless nA.is_a? Integer
        if @N > 0 then
            m = "#{@N} values have already been added to the sums."
            m += " You must reinit the object before setting to the Diffs From Mean state."
            raise ArgumentError, m
        end
        @DiffFromMeanInputsUsed = true
        @N                      = nA
        @SumOfXs                = sumXs

        @ArithmeticMean         = ( sumXs.to_f / nA.to_f )
    end

    attr_accessor :Population

    attr_reader :ArithmeticMean
    attr_reader :DiffFromMeanInputsUsed
    attr_reader :N
    attr_reader :SumOfXs
    attr_reader :SumPowerOf2
    attr_reader :SumPowerOf3
    attr_reader :SumPowerOf4

end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# VectorOfX Base Class

class VectorOfX

    BlankFieldOnBadData     = 0
    DefaultFillOnBadData    = 1
    FailOnBadData           = 2
    SkipRowOnBadData        = 3
    ZeroFieldOnBadData      = 4

    def _assureSortedVectorOfX(forceSort=false)
        if forceSort then
            @SortedVectorOfX = @VectorOfX.sort
            return
        end
        if not @SortedVectorOfX or ( @SortedVectorOfX.size != @VectorOfX.size ) then
            @SortedVectorOfX = @VectorOfX.sort
        end
    end

    def initialize(aA=nil)
        if aA then
            raise ArgumentError unless aA.is_a? Array
        end
        # The following is ONLY for testing:
        @SortedVectorOfX    = nil
        @VectorOfX          = Array.new  unless aA
        @VectorOfX          = aA             if aA
    end

    def getCount
        return @VectorOfX.size
    end

    def getX(indexA,sortedVector=false)
        raise ArgumentError, "Index Argument Missing:  Required."       unless indexA.is_a? Integer
        raise ArgumentError, "Index Argument Not found in VectorOfX."   unless @VectorOfX[indexA]
        return @VectorOfX[indexA]   unless sortedVector
        return @SortedVectorOfX[indexA] if sortedVector and @SortedVectorOfX.has_key?(indexA)
        return nil
    end

    def pushX(xFloat)
        raise ArgumentError, "Pure Virtual"
    end

    def requestResultAACSV(xFloat)
        raise ArgumentError, "Pure Virtual"
    end

    def requestResultCSVLine(xFloat)
        raise ArgumentError, "Pure Virtual"
    end

    def requestResultJSON(xFloat)
        raise ArgumentError, "Pure Virtual"
    end

    def transformToCSVLine
        b = @VectorOfX.to_csv
        return b
    end

    def transformToJSON
        b = @VectorOfX.to_json
        return b
    end

    attr_reader :SortedVectorOfX
    attr_reader :VectorOfX

end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# VectorOfContinouos for floating point based distributions.  All Xs floats.

class VectorOfContinuous < VectorOfX

    ArithmeticMeanId            = 'ArithmeticMean'
    ArMeanAADId                 = 'AMeanAAD' # Average Absolute Deviation
    # Note, I have Max and Min available for AAD, but presume these will not be used formally.
    COVPopulationId             = 'PopulationCoefficientOfVariation'
    COVSampleId                 = 'SampleCoefficientOfVariation'
    CoefficientOfVariationId    = 'CoefficientOfVariation'
    GeometricMeanId             = 'GeometricMean'
    GMeanAADId                  = 'GMeanAAD' # Geometric Mean Average Absolute Deviation
    HarmonicMeanId              = 'HarmonicMean'
    HMeanAADId                  = 'HMeanAAD' # Harmonic Mean Average Absolute Deviation
    IsEvenId                    = 'IsEven'
    KurtosisId                  = 'Kurtosis'
    MADId                       = 'MAD' # Mean Absolute Difference
    MaxId                       = 'Max'
    MedianAADId                 = 'MedianAAD'# Median Absolute Deviation
    MedianId                    = 'Median'
    MinId                       = 'Min'
    ModeAADId                   = 'ModeAAD' # Mode Absolute Deviation
    ModeId                      = 'Mode'
    NId                         = 'N'
    SkewnessId                  = 'Skewness'
    StandardDeviation           = 'StandardDeviation'
    StddevDiffsPopId            = 'StddevDiffsPop'
    StddevDiffsSampleId         = 'StddevDiffsSample'
    StddevSumxsPopId            = 'StddevSumxsPop'
    StddevSumxsSampleId         = 'StddevSumxsSample'
    SumId                       = 'Sum'

    class << self

        def newAfterInvalidatedDropped(arrayA,relayErrors=false)
            raise ArgumentError unless arrayA.is_a? Array
            localo = self.new
            v = Array.new
            i = 0
            arrayA.each do |le|
                sle = le.strip
                next unless isUsableNumber?(sle)
                b = sle.to_f
                localo.pushX(b)
                i += 1
            end
            return localo
        end

    end

    def _addUpXsToSumsOfPowers(populationCalculation=false,sumOfDiffs=true)
        sopo    = SumsOfPowers.new(populationCalculation)
        if sumOfDiffs then
            n       = getCount
            sum     = getSum
            sopo.setToDiffsFromMeanState(sum,n)
        end
        if sumOfDiffs then
            amean   = calculateArithmeticMean
            @VectorOfX.each do |lx|
                diff = lx - amean
                sopo.addToSums(diff)
            end
        else # sum of Xs
            @VectorOfX.each do |lx|
                sopo.addToSums(lx)
            end
        end
        return sopo
    end

    def _decideHistogramStartNumber(startNumber=nil)
        startno = getMin        unless startNumber
        startno = startNumber.to_f  if startNumber
        return startno
    end

    def initialize(vectorX=Array.new)
        raise ArgumentError unless vectorX.is_a? Array
        @InputDecimalPrecision          = 4
        @OutputDecimalPrecision         = 4
        @Population                     = false
        @SOPo                           = nil
        @SortedVectorOfX                = nil
        @UseDiffFromMeanCalculations    = true
        @ValidateStringNumbers          = false
        @VectorOfX                      = vectorX
    end

    def calculateArithmeticMean
        nf          = @VectorOfX.size.to_f
        sumxs       = @VectorOfX.sum.to_f
        unrounded   = sumxs / nf
        rounded     = unrounded.round(@OutputDecimalPrecision)
        return rounded
    end

    def calculateGeometricMean
        exponent    = ( 1.0 / @VectorOfX.size.to_f )
        productxs   = @VectorOfX.reduce(1, :*)
        unrounded   = productxs**exponent
        rounded     = unrounded.round(@OutputDecimalPrecision)
        return rounded
    end

    def calculateHarmonicMean
        nf          = @VectorOfX.size.to_f
        sumrecips   = @VectorOfX.inject { |sum, x| sum + 1.0 / x.to_f } 
        unrounded   = nf / sumrecips
        rounded     = unrounded.round(@OutputDecimalPrecision)
        return rounded
    end

    def calculateQuartile(qNo)
        raise ArgumentError unless qNo.is_a? Integer
        raise ArgumentError unless 0 <= qNo
        raise ArgumentError unless qNo < 5
        _assureSortedVectorOfX
        n                       = getCount
        nf                      = n.to_f
        qindexfloat             = qNo * ( nf - 1.0 ) / 4.0
        thisquartilefraction    = qindexfloat % 1
        qvalue = nil
        if thisquartilefraction % 1 == 0 then
            qi                  = qindexfloat.to_i
            qvalue              = @SortedVectorOfX[qi]
        else
            portion0            = 1.0 - thisquartilefraction
            portion1            = 1.0 - portion0
            qi0                 = qindexfloat.to_i
            qi1                 = qi0 + 1
            qvalue              = @SortedVectorOfX[qi0] * portion0 + @SortedVectorOfX[qi1] * portion1
        end
        return qvalue
    end

    def generateAverageAbsoluteDeviation(centralPointType=ArithmeticMeanId)
        cpf = nil
        case centralPointType
        when ArithmeticMeanId
            cpf = calculateArithmeticMean
        when GeometricMeanId
            cpf = calculateGeometricMean
        when HarmonicMeanId
            cpf = calculateHarmonicMean
        when MaxId
            cpf = getMax
        when MedianId
            cpf = requestMedian
        when MinId
            cpf = generateMode
        when ModeId
            cpf = getMax
        else
            m = "This Average Absolute Mean formula has not implemented a statistic for central point '#{centralPointType}' at this time."
            raise ArgumentError, m
        end
        nf                      = @VectorOfX.size.to_f
        sumofabsolutediffs      = 0
        @VectorOfX.each do |lx|
            previous            = sumofabsolutediffs
            sumofabsolutediffs  += ( lx - cpf ).abs
            if previous > sumofabsolutediffs then
                # These need review.  
                raise RangeError, "previous #{previous} > sumofdiffssquared #{sumofabsolutediffs}"
            end
        end
        unrounded               = sumofabsolutediffs / nf
        rounded                 = unrounded.round(@OutputDecimalPrecision)
        return rounded
    end

    def generateCoefficientOfVariation
        @SOPo       = _addUpXsToSumsOfPowers(@Population,@SumOfDiffs) unless @SOPo
        amean       = @SOPo.ArithmeticMean
        stddev      = @SOPo.generateStandardDeviation
        unrounded   = stddev / amean
        rounded     = unrounded.round(@OutputDecimalPrecision)
        return rounded
    end

    def generateHistogramAAbyNumberOfSegments(desiredSegmentCount,startNumber=nil)
        raise ArgumentError unless desiredSegmentCount.is_a? Integer
        if startNumber then
            raise ArgumentError unless startNumber.is_a? Numeric
        end
        max             = getMax
        startno         = _decideHistogramStartNumber(startNumber)
        histo = HistogramOfX.newFromDesiredSegmentCount(startno,max,desiredSegmentCount)
        histo.validateRangesComplete
        @VectorOfX.each do |lx|
            histo.addToCounts(lx)
        end
        resultvectors   = histo.generateCountCollection
        return resultvectors
    end

    def generateHistogramAAbySegmentSize(segmentSize,startNumber=nil)
        raise ArgumentError unless segmentSize.is_a? Numeric
        if startNumber then
            raise ArgumentError unless startNumber.is_a? Numeric
        end
        max             = getMax
        startno         = _decideHistogramStartNumber(startNumber)
        histo = HistogramOfX.newFromUniformSegmentSize(startno,max,segmentSize)
        histo.validateRangesComplete
        @VectorOfX.each do |lx|
            histo.addToCounts(lx)
        end
        resultvectors   = histo.generateCountCollection
        return resultvectors
    end

    def generateMeanAbsoluteDifference
        # https://en.wikipedia.org/wiki/Mean_absolute_difference
        nf                          = @VectorOfX.size.to_f
        sumofabsolutediffs          = 0
        @VectorOfX.each do |lxi|
            @VectorOfX.each do |lxj|
                sumofabsolutediffs  += ( lxi - lxj ).abs
            end
        end
        denominator                 = nf * ( nf - 1.0 )
        unrounded                   = sumofabsolutediffs / denominator
        rounded                     = unrounded.round(@OutputDecimalPrecision)
        return rounded
    end

    def generateMode
        lfaa            = Hash.new # Init local frequency associative array.
        @VectorOfX.each do |lx|
            lfaa[lx]    = 1   unless lfaa.has_key?(lx)
            lfaa[lx]    += 1      if lfaa.has_key?(lx)
        end
        x               = generateModefromFrequencyAA(lfaa)
        return x
    end

    def getMax
        _assureSortedVectorOfX
        return @SortedVectorOfX[-1]
    end

    def getMin(sVoX=nil)
        _assureSortedVectorOfX
        return @SortedVectorOfX[0]
    end

    def getSum
        sumxs = @VectorOfX.sum
        return sumxs
    end

    def isEvenN?
        n = @VectorOfX.size
        return true if n % 2 == 0
        return false
    end

    def pushX(xFloat,onBadData=VectorOfX::FailOnBadData)
        unless isUsableNumber?(xFloat)
            case onBadData
            when VectorOfX::BlankFieldOnBadData
                raise ArgumentError, "May Not Blank Fields"
            when VectorOfX::DefaultFillOnBadData
                xFloat=0.0
            when VectorOfX::FailOnBadData
                raise ArgumentError, "#{xFloat} not usable number."
            when VectorOfX::SkipRowOnBadData
                return
            when VectorOfX::ZeroFieldOnBadData
                xFloat=0.0
            else
                raise ArgumentError, "Unimplemented onBadData value:  #{onBadData}."
            end
        end
        validateStringNumberRange(xFloat) if @ValidateStringNumbers
        lfn = xFloat.to_f.round(@InputDecimalPrecision)
        @VectorOfX.push(lfn)
    end

    def requestExcessKurtosis(formulaId=3)
        unless @UseDiffFromMeanCalculations
            raise ArgumentError, "May NOT be used with Sum of Xs Data."
        end
        @SOPo           = _addUpXsToSumsOfPowers(@Population) unless @SOPo
        unrounded       = nil
        case formulaId
        when 2
            unrounded   = @SOPo.calculateExcessKurtosis_2_JR_R
        when 3
            unrounded   = @SOPo.generateExcessKurtosis_3_365datascience
        else
            m="There is no excess kurtosis formula #{formulaId} implemented at this time."
            raise ArgumentError, m
        end
        rounded         = unrounded.round(@OutputDecimalPrecision)
        return rounded
    end

    def requestKurtosis
        @SOPo       = _addUpXsToSumsOfPowers(@Population) unless @SOPo
        unrounded   = @SOPo.requestKurtosis
        rounded     = unrounded.round(@OutputDecimalPrecision)
        return rounded
    end

    def requestMedian
        q2 = calculateQuartile(2)
        return q2
    end

    def requestQuartileCollection
        qos0 = calculateQuartile(0)
        qos1 = calculateQuartile(1)
        qos2 = calculateQuartile(2)
        qos3 = calculateQuartile(3)
        qos4 = calculateQuartile(4)
        return [qos0,qos1,qos2,qos3,qos4]
    end

    def requestRange
        _assureSortedVectorOfX
        return @SortedVectorOfX[0], @SortedVectorOfX[-1]
    end

    def requestResultAACSV
        scaa = requestSummaryCollection
        return <<-EOAACSV
"#{ArithmeticMeanId}", #{scaa[ArithmeticMeanId]}
"#{ArMeanAADId}", #{scaa[ArMeanAADId]}
"#{CoefficientOfVariationId}", #{scaa[CoefficientOfVariationId]}
"#{GeometricMeanId}", #{scaa[GeometricMeanId]}
"#{HarmonicMeanId}", #{scaa[HarmonicMeanId]}
"#{IsEvenId}", #{scaa[IsEvenId]}
"#{KurtosisId}", #{scaa[KurtosisId]}
"#{MADId}", #{scaa[MADId]}
"#{MaxId}", #{scaa[MaxId]}
"#{MedianId}", #{scaa[MedianId]}
"#{MedianAADId}", #{scaa[MedianAADId]}
"#{MinId}", #{scaa[MinId]}
"#{ModeId}", #{scaa[ModeId]}
"#{NId}", #{scaa[NId]}
"#{SkewnessId}", #{scaa[SkewnessId]}
"#{StandardDeviation}", #{scaa[StandardDeviation]}
"#{SumId}", #{scaa[SumId]}
EOAACSV
    end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
    def requestResultCSVLine(includeHdr=false)
        scaa        = requestSummaryCollection
        csvline     =   "#{scaa[ArithmeticMeanId]},#{scaa[ArMeanAADId]},"
        csvline     +=  "#{scaa[CoefficientOfVariationId]},"
        csvline     +=  "#{scaa[GeometricMeanId]},#{scaa[HarmonicMeanId]},"
        csvline     +=  "#{scaa[IsEvenId]},#{scaa[KurtosisId]},#{scaa[MADId]},"
        csvline     +=  "#{scaa[MaxId]},#{scaa[MedianId]},#{scaa[MedianAADId]},"
        csvline     +=  "#{scaa[MinId]},#{scaa[ModeId]},#{scaa[NId]},"
        csvline     +=  "#{scaa[SkewnessId]},#{scaa[StandardDeviation]},"
        csvline     +=  "#{scaa[SumId]}"
        if includeHdr then
            csvhdr  =   "#{ArithmeticMeanId},#{ArMeanAADId},"
            csvhdr  +=  "#{CoefficientOfVariationId},#{GeometricMeanId},"
            csvhdr  +=  "#{HarmonicMeanId},#{IsEvenId},#{KurtosisId},#{MADId},"
            csvhdr  +=  "#{MaxId},#{MedianId},#{MedianAADId},#{MinId},#{ModeId},"
            csvhdr  +=  "#{NId},#{SkewnessId},#{StandardDeviation},#{SumId}"
            return <<EOCSV
#{csvhdr}
#{csvline}
EOCSV
        else
            return csvline
        end
    end

    def requestResultJSON
        scaa = requestSummaryCollection
        jsonstr = scaa.to_json
        return jsonstr
    end

    def requestSkewness(formulaId=3)
        @SOPo = _addUpXsToSumsOfPowers(@Population) unless @SOPo
        unrounded = @SOPo.requestSkewness(formulaId)
        rounded = unrounded.round(@OutputDecimalPrecision)
    end

    def requestStandardDeviation
        @SOPo = _addUpXsToSumsOfPowers(@Population,@UseDiffFromMeanCalculations)
        unroundedstddev = @SOPo.generateStandardDeviation
        if unroundedstddev == 0.0 then
            raise RangeError, "Zero Result indicates squareroot error:  #{unroundedstddev}"
        end
        stddev = unroundedstddev.round(@OutputDecimalPrecision)
        return stddev
    end

    def requestSummaryCollection
        #NOTE:  Some of these are ONLY for sample.  For now, this is best used ONLY for Samples.
        #@SOPo                   = _addUpXsToSumsOfPowers(@Population,@UseDiffFromMeanCalculations)
        @SOPo                   = _addUpXsToSumsOfPowers(false,@UseDiffFromMeanCalculations)
        amean                   = calculateArithmeticMean
        ameanaad                = generateAverageAbsoluteDeviation
        coefficientofvariation  = generateCoefficientOfVariation
        gmean                   = calculateGeometricMean
        hmean                   = calculateHarmonicMean
        is_even                 = isEvenN?
        kurtosis                = "SumXsCalc Not Yet Available"
        kurtosis                = @SOPo.requestKurtosis.round(@OutputDecimalPrecision) if @UseDiffFromMeanCalculations
        mad                     = generateMeanAbsoluteDifference
        median                  = requestMedian
        medianaad               = generateAverageAbsoluteDeviation(MedianId)
        min,max                 = requestRange
        mode                    = generateMode
        n                       = getCount
        skewness                = @SOPo.requestSkewness.round(@OutputDecimalPrecision)
        stddev                  = @SOPo.generateStandardDeviation.round(@OutputDecimalPrecision)
        sum                     = getSum
        return {
            ArithmeticMeanId            => amean,
            ArMeanAADId                 => ameanaad,
            CoefficientOfVariationId    => coefficientofvariation,
            GeometricMeanId             => gmean,
            HarmonicMeanId              => hmean,
            IsEvenId                    => is_even,
            KurtosisId                  => kurtosis,
            MADId                       => mad,
            MaxId                       => max,
            MedianId                    => median,
            MedianAADId                 => medianaad,
            MinId                       => min,
            ModeId                      => mode,
            NId                         => n,
            SkewnessId                  => skewness,
            StandardDeviation           => stddev,   
            SumId                       => sum
        }
    end

    def requestVarianceSumOfDifferencesFromMean(populationCalculation=false)
        @SOPo = _addUpXsToSumsOfPowers(populationCalculation)
        v = @SOPo.calculateVarianceUsingSubjectAsDiffs
        # Note rounding is not done here, as it would be double rounded with stddev.
        return v
    end

    def requestVarianceXsSquaredMethod(populationCalculation=false)
        @SOPo = _addUpXsToSumsOfPowers(populationCalculation,false)
        v = @SOPo.calculateVarianceUsingSubjectAsSumXs
        # Note rounding is not done here, as it would be double rounded with stddev.
        return v
    end

    attr_accessor   :InputDecimalPrecision
    attr_accessor   :OutputDecimalPrecision
    attr_accessor   :Population
    attr_accessor   :SOPo
    attr_accessor   :UseDiffFromMeanCalculations
    attr_accessor   :ValidateStringNumbers

end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# VectorOfDiscrete - catchall for arbitrary X that could be a string.

class VectorOfDiscrete < VectorOfX

    def initialize(vectorX=Array.new)
        @FrequenciesAA          = Hash.new
        @OutputDecimalPrecision = 4
        @VectorOfX              = vectorX
        @VectorOfX.each do |lx|
            @FrequenciesAA[lx]  += 1    if @FrequenciesAA.has_key?(lx)
            @FrequenciesAA[lx]  = 1 unless @FrequenciesAA.has_key?(lx)
        end
    end

    def calculateBinomialProbability(subjectValue,nTrials,nSuccesses)
        #STDERR.puts "\ntrace 0 calculateBinomialProbability(#{subjectValue},#{nTrials},#{nSuccesses})"
        raise ArgumentError unless subjectValue
        raise ArgumentError unless nTrials.is_a? Integer
        raise ArgumentError unless nSuccesses.is_a? Integer
        n_failures          = nTrials - nSuccesses

        samplecount         = getCount
        samplecountf        = samplecount.to_f

        freqcountf          = @FrequenciesAA[subjectValue].to_f

        psuccess1trial      = freqcountf / samplecountf # Probability of success in 1 trial.

        pfailure1trial      = 1.0 - psuccess1trial
        #STDERR.puts "\ntrace 5 calculateBinomialProbability #{samplecountf},#{freqcountf},#{psuccess1trial},#{pfailure1trial}"

        pfailurefactor      = pfailure1trial**n_failures
        psuccessfactor      = psuccess1trial**nSuccesses
        #STDERR.puts "\ntrace 6 calculateBinomialProbability #{pfailurefactor},#{psuccessfactor}"

        successpermutations = getFactorial(nSuccesses)
        failurepermutations = getFactorial(nTrials - nSuccesses)
        trials_permutations = getFactorial(nTrials)
        #STDERR.puts "\ntrace 7 calculateBinomialProbability #{successpermutations},#{failurepermutations},#{trials_permutations}"
        numerator           = trials_permutations * psuccessfactor * pfailurefactor
        denominator         = successpermutations * failurepermutations
        binomialprobability = numerator / denominator
        #STDERR.puts "\ntrace 8 calculateBinomialProbability #{numerator},#{denominator},#{binomialprobability}"
        return binomialprobability
    end

    def getFrequency(subjectValue)
        raise ArgumentError unless subjectValue
        return @FrequenciesAA[subjectValue]
    end

    def pushX(xItem,onBadData=VectorOfX::FailOnBadData)
        unless xItem and "#{xItem}".size > 0
            case onBadData
            when VectorOfX::BlankFieldOnBadData
                xItem=" "
            when VectorOfX::DefaultFillOnBadData
                xFloat=" "
            when VectorOfX::FailOnBadData
                raise ArgumentError, "#{xItem} not usable value."
            when VectorOfX::SkipRowOnBadData
                return
            when VectorOfX::ZeroFieldOnBadData
                xItem=0.0
            else
                raise ArgumentError, "Unimplemented onBadData value:  #{onBadData}."
            end
        end
        @FrequenciesAA[xItem] += 1       if @FrequenciesAA.has_key?(xItem)
        @FrequenciesAA[xItem] = 1    unless @FrequenciesAA.has_key?(xItem)
        @VectorOfX.push(xItem)
        return true
    end

    def requestMode
        x = generateModefromFrequencyAA(@FrequenciesAA)
        return x
    end

    attr_accessor   :OutputDecimalPrecision

    attr_reader     :FrequenciesAA

end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# VectorTable for reading and processing contents of 2 dimentional matrices.

class VectorTable

    class << self

        def isAllowedDataVectorClass?(vectorClass)
            return false    unless vectorClass.is_a? Class
            return true         if vectorClass.ancestors.include? VectorOfX
            return false
        end

        def newFromCSV(vcSpec,fSpec,onBadData=VectorOfX::DefaultFillOnBadData,skipFirstLine=true)
            localo = self.new(vcSpec)
            File.open(fSpec) do |fp|
                i = 0
                fp.each_line do |ll|
                    sll = ll.strip
                    unless ( i == 0 and skipFirstLine )
                        columns = sll.parse_csv
                        localo.pushTableRow(columns,onBadData)
                    end
                    i += 1
                end
            end
            return localo
        end

    end

    def initialize(vectorOfClasses)
        raise ArgumentError, "Argument Passed '#{vectorOfClasses.class}' NOT ARRAY" unless vectorOfClasses.is_a? Array
        @TableOfVectors     = Array.new
        @VectorOfClasses    = vectorOfClasses
        i = 0
        @VectorOfClasses.each do |lci|
            if lci then
                raise ArgumentError, "Class '#{lci.class}' Not Valid" unless self.class.isAllowedDataVectorClass?(lci)
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

    def pushTableRow(arrayA,onBadData=VectorOfX::DefaultFillOnBadData)
        raise ArgumentError unless arrayA.is_a? Array
        raise ArgumentError unless arrayA.size == @TableOfVectors.size
        raise ArgumentError if onBadData == VectorOfX::SkipRowOnBadData
        i = 0
        @TableOfVectors.each do |lvoe|
            if lvoe.is_a? VectorOfX then
                lvoe.pushX(arrayA[i],onBadData)
            end
            i += 1
        end
    end

end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of SamesLib.native.rb

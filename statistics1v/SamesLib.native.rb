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

require "bigdecimal"
require 'csv'

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Global Support Routines

def genFactorial(nA)
    raise ArgumentError unless nA.is_a? Integer
    nf = Math.gamma(nA + 1)
    return nf
end

def genModeFromFrequencyAA(faaA)
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
            @Count      = 0
            @StartNo    = startNo
            @StopNo     = stopNo
        end

        def addToCount
            @Count += 1
        end

        def hasOverlap?(startNo,stopNo)
            return true if @StartNo <= startNo and startNo < @StopNo
            return true if @StartNo < stopNo and stopNo <= @StopNo
            return false
        end

        def isInRange?(xFloat)
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
            #STDERR.puts "trace 0 newFromDesiredSegmentCount(#{startNo},#{maxNo},#{desiredSegmentCount},#{extraMargin})"
            # xc 20231106:  Don't worry about cost of passing the AA around until efficiency passes later.
            totalbreadth    = ( maxNo - startNo + 1 + extraMargin ).to_f
            dscf            = desiredSegmentCount.to_f
            segmentsize     = totalbreadth / dscf
            #STDERR.puts "trace segmentsize:  #{segmentsize}"
            localo          = self.newFromUniformSegmentSize(startNo,maxNo,segmentsize)
            return localo
        end

        def newFromUniformSegmentSize(startNo,maxNo,segmentSize)
            #STDERR.puts "trace 0 newFromUniformSegmentSize(#{startNo},#{maxNo},#{segmentSize})"
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
        @FrequencyAA.values.each do |lroo|
            if lroo.hasOverlap?(startNo,stopNo)
                m = "Range [#{startNo},#{stopNo}] overlaps with another range:  [#{lroo.StartNo},#{lroo.StopNo}]."
                raise ArgumentError, m
            end
        end
    end

    def initialize(lowestValue,highestValue=nil)
        @FrequencyAA    = Hash.new
        @Max            = highestValue
        @Min            = lowestValue
    end

    def addToCounts(xFloat)
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

    def genOrderedListOfCountVectors
        orderedlist = Array.new
        @FrequencyAA.keys.sort.each do |lstartno|
            lroo = @FrequencyAA[lstartno]
            orderedlist.push([lstartno,lroo.StopNo,lroo.Count])
        end
        return orderedlist
    end

    def setOccurrenceRange(startNo,stopNo)
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
                raise ArgumentError, "Programmer Error on startno assignments."
            end
            if i == 0 then
                unless lroo.StartNo <= @Min
                    m = "Range [#{lroo.StartNo},#{lroo.StopNo}] "
                    m += " starts after the minimum designated value '#{@Min}."
                    raise ArgumentError, m
                end
            else
                unless lroo.StartNo == previous_lroo.StopNo
                    m = "Range [#{previous_lroo.StartNo},#{previous_lroo.StopNo}]"
                    m += " is not adjacent to the next range "
                    m += "[#{lroo.StartNo},#{lroo.StopNo}]."
                    raise ArgumentError, m
                end
            end
            i += 1
            previous_lroo = lroo
        end
        unless @Max <= lroo.StopNo
            m = "Range [#{lroo.StartNo},#{lroo.StopNo}] "
            m += " ends before the maximum value '#{@Max}."
            raise ArgumentError, m
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

        def genPearsonsFirstSkewnessCoefficient(aMean,modeFloat,stdDev)
            # See 2023/11/05 "Pearson's first skewness coefficient" in:
            #   https://en.wikipedia.org/wiki/Skewness
            sc  = ( aMean - modeFloat ) / stdDev
            return sc
        end

        def genPearsonsSecondSkewnessCoefficient(aMean,medianFloat,stdDev)
            # See 2023/11/05 "Pearson's second skewness coefficient" in:
            #   https://en.wikipedia.org/wiki/Skewness
            sc  = ( mu - medianFloat ) / sd
            return sc
        end

    end

    def _secondMomentSubjectXs
        #   Sum( xi - mu )**2 == Sum(xi**2) - (1/n)(amean**2)
        # Note I checked this one at:
        #   https://math.stackexchange.com/questions/2569510/proof-for-sum-of-squares-formula-statistics-related
        #
        if @IsInputDiffFromMean
            raise ArgumentError, "May ONLY be used with Sum of Xs Data."
        end
        nreciprocal = ( 1.0 / @N.to_f )
        first  = @SumPowerOf2
        second = nreciprocal * ( @ArithmeticMean**2)
        ssx = first - second
        return ssx
    end

    def _thirdMomentSubjectXs
        # My algegra, using unreduced arithmetic mean parts because that becomes complicated
        # when going to sample means, leads to a simple Pascal Triangle pattern:
        # My algegra: Sum( xi - mu )**3 ==
        #   Sum(xi**3) - 3*Sum(xi**2)*amean + 3*Sum(xi)*(amean**2) - mu**3
        if @IsInputDiffFromMean
            raise ArgumentError, "May ONLY be used with Sum of Xs Data."
        end
        first   = @SumPowerOf3
        second  = 3 * @SumPowerOf2  *   @ArithmeticMean
        third   = 3 * @SumOfXs      * ( @ArithmeticMean**2 )
        fourth  = @ArithmeticMean**3
        result  = first - second + third - fourth
        return result
    end

    def _fourthMomentSubjectXs
        # My algegra, using unreduced arithmetic mean parts because that becomes complicated
        # when going to sample means, leads to a simple Pascal Triangle pattern:
        # My algegra: Sum( xi - mu )**4 ==
        #   Sum(xi**4) - 4*Sum(xi**3)*amean + 6*Sum(xi**2)(amean**2) - 4**Sum(xi)*(amean**3) + mu**4
        if @IsInputDiffFromMean
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

    def initialize(sumXs,nA,populationDistribution=false,isDiffsFromMeanCalculation=true)

        @IsInputDiffFromMean    = isDiffsFromMeanCalculation
        @Population             = populationDistribution

        @N                      = nA
        @SumOfXs                = sumXs

        @ArithmeticMean         = ( sumXs.to_f / nA.to_f )

        @SumPowerOf2            = 0
        @SumPowerOf3            = 0
        @SumPowerOf4            = 0
    end

    def addToSums(sFloat)
        @SumPowerOf2 += sFloat * sFloat
        @SumPowerOf3 += sFloat * sFloat * sFloat
        @SumPowerOf4 += sFloat * sFloat * sFloat * sFloat
    end

    def genExcessKurtosis_2_JR_R
        #  2018-01-04 by Jonathan Regenstein https://rviews.rstudio.com/2018/01/04/introduction-to-kurtosis/
        unless @IsInputDiffFromMean
            raise ArgumentError, "May NOT be used with Sum of Xs Data."
        end
        nf          = @N.to_f
        numerator   = @SumPowerOf4 / nf
        denominator = ( @SumPowerOf2 / nf ) ** 2 
        ek          = ( numerator / denominator ) - 3
        return ek
    end

    def genExcessKurtosis_3_365datascience
        #  https://365datascience.com/calculators/kurtosis-calculator/
        nf                  = @N.to_f
        stddev              = genStandardDeviation
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

    def genKurtosis
        kurtosis = genKurtosis_Unbiased_DiffFromMeanCalculation
        return kurtosis
    end

    def genKurtosis_Biased_DiffFromMeanCalculation
        # See 2023/11/05 "Standard biased estimator" in:
        #   https://en.wikipedia.org/wiki/Kurtosis
        unless @IsInputDiffFromMean
            raise ArgumentError, "May NOT be used with Sum of Xs Data."
        end
        nreciprocal     = ( 1.0 / @N.to_f )
        numerator       = nreciprocal * @SumPowerOf4
        denominternal   = nreciprocal * @SumPowerOf2
        denominator     = denominternal * denominternal
        g2              = numerator / denominator
        return g2
    end

    def genKurtosis_Unbiased_DiffFromMeanCalculation
        # See 2023/11/05 "Standard unbiased estimator" in:
        #   https://en.wikipedia.org/wiki/Kurtosis
        nf = @N.to_f

        leftnumerator       = ( nf + 1.0 ) * nf * ( nf - 1.0 )
        leftdenominator     = ( nf - 2.0 ) * ( nf - 3.0 )
        left                = leftnumerator / leftdenominator

        middle              = @SumPowerOf4 / ( @SumPowerOf2**2 )

        rightnumerator      = ( nf - 1.0 )**2
        rightdenominator    = ( nf - 2.0 ) * ( nf - 3.0 )
        right               = rightnumerator / rightdenominator
        sue_G2              = left * middle - right
        #STDERR.puts "sue_G2              = left * middle * right: #{sue_G2}              = #{left} * #{middle} * #{right}"
        return sue_G2
    end

    def genNaturalEstimatorOfPopulationSkewness_b1
        # See 2023/11/05 "Sample Skewness" in:
        #   https://en.wikipedia.org/wiki/Skewness
        nreciprocal     = ( 1.0 / @N.to_f )
        numerator       = nil
        if @IsInputDiffFromMean then
            numerator   = nreciprocal * @SumPowerOf3
        else
            thirdmoment = _thirdMomentSubjectXs
            numerator   = nreciprocal * thirdmoment
        end
        stddev          = genStandardDeviation
        denominator     = stddev**3
        b1              = numerator / denominator
        return b1
    end

    def genNaturalEstimatorOfPopulationSkewness_g1
        # See 2023/11/05 "Sample Skewness" in:
        #   https://en.wikipedia.org/wiki/Skewness
        inside_den      = nil
        nreciprocal     = ( 1.0 / @N.to_f )
        numerator       = nil
        if @IsInputDiffFromMean then
            inside_den  = nreciprocal * @SumPowerOf2
            numerator   = nreciprocal * @SumPowerOf3
        else
            second      = _secondMomentSubjectXs
            third       = _thirdMomentSubjectXs

            inside_den  = nreciprocal * second
            numerator   = nreciprocal * third
        end
        denominator     = ( Math.sqrt( inside_den ) )**3
        g1              = numerator / denominator
        return g1
    end

    def genSkewness(formulaId=3)
        #NOTE:  There is NO POPULATION Skewness at this time.
        if @Population then
            m = "There is no POPULATION skewness formula implemented at this time."
            raise ArgumentError, m
        end
        skewness = nil
        case formulaId
        when 1
            skewness = genNaturalEstimatorOfPopulationSkewness_b1
        when 2
            skewness = genNaturalEstimatorOfPopulationSkewness_g1
        when 3
            skewness = genThirdDefinitionOfSampleSkewness_G1
        else
            m = "There is no skewness formula #{formulaId} implemented at this time."
            raise ArgumentError, m
        end
        return skewness
    end

    def genStandardDeviation
        v = nil
        if @IsInputDiffFromMean then
            v = genVarianceUsingSubjectAsDiffs
        else
            v = genVarianceUsingSubjectAsSumXs
        end
        stddev = Math.sqrt(v)
        return stddev
    end

    def genThirdDefinitionOfSampleSkewness_G1
        # See 2023/11/05 "Sample Skewness" in:
        #   https://en.wikipedia.org/wiki/Skewness
        b1      = genNaturalEstimatorOfPopulationSkewness_b1
        nf      = @N.to_f
        k3      = ( nf**2 ) * b1
        k2_3s2  = ( nf - 1 ) * ( nf - 2 )
        ss_G1   = k3 / k2_3s2
        return ss_G1
    end

    def genVarianceUsingSubjectAsDiffs
        nf              = @N.to_f
        v = @SumPowerOf2 / ( nf - 1.0 ) unless @Population
        v = @SumPowerOf2 / nf               if @Population
        return v
    end

    def genVarianceUsingSubjectAsSumXs
        ameansquared = @ArithmeticMean * @ArithmeticMean
        nf              = @N.to_f
        if @Population then
            v = ( @SumPowerOf2 - ameansquared ) / nf
        else
            v = ( @SumPowerOf2 - nf * ameansquared ) / ( nf - 1.0 )
        end
        return v
    end

    attr_accessor :Population

    attr_reader :ArithmeticMean
    attr_reader :IsInputDiffFromMean
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

    def _assureSortedVectorOfX
        @SortedVectorOfX = @VectorOfX.sort  unless @SortedVectorOfX
    end

    def initialize(aA=nil)
        # The following is ONLY for testing:
        @SortedVectorOfX    = nil
        @VectorOfX          = Array.new  unless aA
        @VectorOfX          = aA             if aA
    end

    def getCount
        return @VectorOfX.size
    end

    def pushX(xFloat)
        raise ArgumentError, "Pure Virtual"
    end

    attr_reader :SortedVectorOfX
    attr_reader :VectorOfX

end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# VectorOfContinouos for floating point based distributions.  All Xs floats.

class VectorOfContinuous < VectorOfX

    ArithmeticMeanId            = 'ArithmeticMean'
    COVPopulationId             = 'PopulationCoefficientOfVariation'
    COVSampleId                 = 'SampleCoefficientOfVariation'
    GeometricMeanId             = 'GeometricMean'
    IsEvenId                    = 'IsEven'
    KurtosisId                  = 'Kurtosis'
    MAEId                       = 'MAE' # Mean Absolute Error
    MaxId                       = 'Max'
    MedianId                    = 'Median'
    MinId                       = 'Min'
    ModeId                      = 'Mode'
    NId                         = 'N'
    SkewnessId                  = 'Skewness'
    StddevDiffsPopId            = 'StddevDiffsPop'
    StddevDiffsSampleId         = 'StddevDiffsSample'
    StddevSumxsPopId            = 'StddevSumxsPop'
    StddevSumxsSampleId         = 'StddevSumxsSample'
    SumId                       = 'Sum'

    class << self

        def newAfterInvalidatedDropped(arrayA,relayErrors=false)
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
        n       = getCount
        sum     = genSum

        sopo    = SumsOfPowers.new(sum,n,populationCalculation,sumOfDiffs)
        if sumOfDiffs then
            amean   = genArithmeticMean
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
        startno = genMin        unless startNumber
        startno = startNumber.to_f  if startNumber
        return startno
    end

    def initialize(vectorX=Array.new)
        @InputDecimalPrecision  = 4
        @OutputDecimalPrecision = 4
        @Population       = false
        @SOPo                   = nil
        @SortedVectorOfX        = nil
        @UseSumOfDiffs          = true
        @ValidateStringNumbers  = false
        @VectorOfX              = vectorX
    end

=begin
trace 6 calculateQuartile(1):  29.0, 7.25, 0.25, 7.0
trace 8 calculateQuartile:  7, 8, 3 * 0.75 + 4 * 0.25 == 3.25
trace 6 calculateQuartile(2):  9.0, 2.5, 0.5, 4.0
trace 8 calculateQuartile:  4, 5, 5 * 0.5 + 6 * 0.5 == 5.5
trace 6 calculateQuartile(2):  9.0, 2.5, 0.5, 4.0
trace 8 calculateQuartile:  4, 5, 5 * 0.5 + 6 * 0.5 == 5.5
trace 6 calculateQuartile(2):  9.0, 2.5, 0.5, 4.0
trace 8 calculateQuartile:  4, 5, 5 * 0.5 + 6 * 0.5 == 5.5
trace 6 calculateQuartile(2):  12.0, 3.25, 0.25, 5.5
trace 8 calculateQuartile:  5, 6, 6 * 0.75 + 7 * 0.25 == 6.25
trace 6 calculateQuartile(1):  5.0, 1.5, 0.5, 0.5, 1.0
trace 8 calculateQuartile:  1, 2, 2 * 0.5 + 3 * 0.5 == 2.5
1,2,3,4,5
=end
    def calculateQuartile(qNo)
        _assureSortedVectorOfX
        n = getCount
        nf = n.to_f
        qindexfloat             = qNo * ( nf - 1.0 ) / 4.0
        thisquartilefraction    = qindexfloat % 1
        qvalue = nil
        #STDERR.puts "trace 6 calculateQuartile(#{qNo}):  #{nf}, #{thisquartilefraction}, #{qindexfloat}"
       if thisquartilefraction % 1 == 0 then
            qi      = qindexfloat.to_i
            qvalue  = @SortedVectorOfX[qi]
            #STDERR.puts "trace 7 calculateQuartile:  #{qi}, #{qvalue}"
        else
            portion0    = 1.0 - thisquartilefraction
            portion1    = 1.0 - portion0
            qi0         = qindexfloat.to_i
            qi1         = qi0 + 1
            qvalue      = @SortedVectorOfX[qi0] * portion0 + @SortedVectorOfX[qi1] * portion1
            #STDERR.puts "trace 8 calculateQuartile:  #{qi0}, #{qi1}, #{@SortedVectorOfX[qi0]} * #{portion0} + #{@SortedVectorOfX[qi1]} * #{portion1} == #{qvalue}"
       end
        return qvalue
    end

    def genArithmeticMean
        n           = @VectorOfX.size.to_f
        sumxs       = @VectorOfX.sum.to_f
        unrounded   = ( sumxs / n )
        rounded     = unrounded.round(@OutputDecimalPrecision)
        return rounded
    end

    def genCoefficientOfVariation
        @SOPo = _addUpXsToSumsOfPowers(@Population,@SumOfDiffs) unless @SOPo
        amean       = @SOPo.ArithmeticMean
        stddev      = @SOPo.genStandardDeviation
        unrounded   = stddev / amean
        rounded     = unrounded.round(@OutputDecimalPrecision)
        #STDERR.puts "trace 6 genCoefficientOfVariation #{amean}, #{stddev}, #{@Population}, #{@SumOfDiffs}, #{unrounded}, #{rounded}"
        return rounded
        
    end

    def genGeometricMean
        exponent    = ( 1.0 / @VectorOfX.size.to_f )
        productxs   = @VectorOfX.reduce(1, :*)
        unrounded   = productxs**exponent
        rounded     = unrounded.round(@OutputDecimalPrecision)
        return rounded
    end

    def genHistogramAAbyNumberOfSegments(desiredSegmentCount,startNumber=nil)
        max             = genMax
        startno         = _decideHistogramStartNumber(startNumber)
        histo = HistogramOfX.newFromDesiredSegmentCount(startno,max,desiredSegmentCount)
        histo.validateRangesComplete
        @VectorOfX.each do |lx|
            histo.addToCounts(lx)
            a = histo.genOrderedListOfCountVectors
            #STDERR.puts "trace genHistogramAAbyNumberOfSegments:  #{a}"
        end
        resultvectors   = histo.genOrderedListOfCountVectors
        return resultvectors
    end

    def genHistogramAAbySegmentSize(segmentSize,startNumber=nil)
        max             = genMax
        startno         = _decideHistogramStartNumber(startNumber)
        histo = HistogramOfX.newFromUniformSegmentSize(startno,max,segmentSize)
        histo.validateRangesComplete
        @VectorOfX.each do |lx|
            histo.addToCounts(lx)
        end
        resultvectors   = histo.genOrderedListOfCountVectors
        return resultvectors
    end

    def genExcessKurtosis(formulaId=3)
        @SOPo = _addUpXsToSumsOfPowers(@Population) unless @SOPo
        unrounded = nil
        case formulaId
        when 2
            unrounded = @SOPo.genExcessKurtosis_2_JR_R
        when 3
            unrounded = @SOPo.genExcessKurtosis_3_365datascience
        else
            m = "There is no excess kurtosis formula #{formulaId} implemented at this time."
            raise ArgumentError, m
        end
        rounded = unrounded.round(@OutputDecimalPrecision)
        return rounded
    end

    def genKurtosis
        @SOPo = _addUpXsToSumsOfPowers(@Population) unless @SOPo
        unrounded = @SOPo.genKurtosis
        rounded = unrounded.round(@OutputDecimalPrecision)
        return rounded
    end

    def genMax
        _assureSortedVectorOfX
        return @SortedVectorOfX[-1]
    end

    def genMeanAbsoluteError
        amean                   = genArithmeticMean
        nf                      = @VectorOfX.size.to_f
        sumofabsolutediffs      = 0
        @VectorOfX.each do |lx|
            previous            = sumofabsolutediffs
            sumofabsolutediffs  += ( lx - amean ).abs
            if previous > sumofabsolutediffs then
                # These need review.  
                raise RangeError, "previous #{previous} > sumofdiffssquared #{sumofabsolutediffs}"
            end
        end
        unrounded                     = sumofabsolutediffs / nf
        rounded = unrounded.round(@OutputDecimalPrecision)
        return rounded
    end

    def genMedian(sVoX=nil)
        q2 = calculateQuartile(2)
        return q2
    end

    def genMin(sVoX=nil)
        _assureSortedVectorOfX
        return @SortedVectorOfX[0]
    end

    def genMode
        lfaa            = Hash.new # Init local frequency associative array.
        @VectorOfX.each do |lx|
            lfaa[lx]    = 1   unless lfaa.has_key?(lx)
            lfaa[lx]    += 1      if lfaa.has_key?(lx)
        end
        x               = genModeFromFrequencyAA(lfaa)
        return x
    end

    def genQuartiles(sVoX=nil)
        qos0 = calculateQuartile(0)
        qos1 = calculateQuartile(1)
        qos2 = calculateQuartile(2)
        qos3 = calculateQuartile(3)
        qos4 = calculateQuartile(4)
        return [qos0,qos1,qos2,qos3,qos4]
    end

    def genRange(sVoX=nil)
        _assureSortedVectorOfX
        return @SortedVectorOfX[0], @SortedVectorOfX[-1]
    end

    def genSkewness(formulaId=3)
        @SOPo = _addUpXsToSumsOfPowers(@Population) unless @SOPo
        unrounded = @SOPo.genSkewness(formulaId)
        rounded = unrounded.round(@OutputDecimalPrecision)
    end

    def genSegmentFrequencyCritical(segmentRange,subRangeStep)
        # Intended to determine peaks and troughs.
        raise ArgumentError, "Not yet implemented."
    end

    def genStandardDeviation
        @SOPo = _addUpXsToSumsOfPowers(@Population,@UseSumOfDiffs)
        unroundedstddev = @SOPo.genStandardDeviation
        if unroundedstddev == 0.0 then
            raise RangeError, "Zero Result indicates squareroot error:  #{unroundedstddev}"
        end
        stddev = unroundedstddev.round(@OutputDecimalPrecision)
        return stddev
    end

    def genSum
        sumxs = @VectorOfX.sum
        return sumxs
    end

    def genVarianceSumOfDifferencesFromMean(populationCalculation=false)
        @SOPo = _addUpXsToSumsOfPowers(populationCalculation)
        v = @SOPo.genVarianceUsingSubjectAsDiffs
        # Note rounding is not done here, as it would be double rounded with stddev.
        return v
    end

    def genVarianceXsSquaredMethod(populationCalculation=false)
        @SOPo = _addUpXsToSumsOfPowers(populationCalculation,false)
        v = @SOPo.genVarianceUsingSubjectAsSumXs
        # Note rounding is not done here, as it would be double rounded with stddev.
        return v
    end

    def getSummaryStatistics
        @SOPo                   = _addUpXsToSumsOfPowers(true,true)
        amean                   = @SOPo.ArithmeticMean
        popcov                  = genCoefficientOfVariation
        gmean                   = genGeometricMean
        is_even                 = isEvenN?
        kurtosis                = @SOPo.genKurtosis.round(@OutputDecimalPrecision)
        mae                     = genMeanAbsoluteError.round(@OutputDecimalPrecision)
        median                  = genMedian
        min,max                 = genRange
        mode                    = genMode
        n                       = getCount
        population_stddev_diffs = @SOPo.genStandardDeviation.round(@OutputDecimalPrecision)
        #STDERR.puts "trace getSummaryStatistics population_stddev_diffs #{population_stddev_diffs}"
        @SOPo.Population        = false
        sample_stddev_diffs     = @SOPo.genStandardDeviation.round(@OutputDecimalPrecision)
        #STDERR.puts "trace getSummaryStatistics sample_stddev_diffs #{sample_stddev_diffs}"
        samplecov               = genCoefficientOfVariation
        nilSOPo
        @SOPo                   = _addUpXsToSumsOfPowers(true,false)
        @SOPo.Population        = true
        population_stddev_sumxs = @SOPo.genStandardDeviation.round(@OutputDecimalPrecision)
        #STDERR.puts "trace getSummaryStatistics population_stddev_sumxs #{population_stddev_sumxs}"
        @SOPo.Population        = false
        sample_stddev_sumxs     = @SOPo.genStandardDeviation.round(@OutputDecimalPrecision)
        #STDERR.puts "trace getSummaryStatistics sample_stddev_sumxs #{sample_stddev_sumxs}"
        skewness                = @SOPo.genSkewness.round(@OutputDecimalPrecision)
        sum                     = genSum
        return {
            ArithmeticMeanId    => amean,
            COVPopulationId     => popcov,
            COVSampleId         => samplecov,
            GeometricMeanId     => gmean,
            IsEvenId            => is_even,
            KurtosisId          => kurtosis,
            MAEId               => mae,
            MaxId               => max,
            MedianId            => median,
            MinId               => min,
            ModeId              => mode,
            NId                 => n,
            SkewnessId          => skewness,
            StddevDiffsPopId    => population_stddev_diffs,   
            StddevDiffsSampleId => sample_stddev_diffs,
            StddevSumxsPopId    => population_stddev_sumxs,
            StddevSumxsSampleId => sample_stddev_sumxs,
            SumId               => sum
        }

    end

    def isEvenN?
        n = @VectorOfX.size
        return true if n % 2 == 0
        return false
    end

    def nilSOPo
        @SOPo = nil
    end

    def pushX(xFloat)
        raise ArgumentError, "#{xFloat} not usable number." unless isUsableNumber?(xFloat)
        validateStringNumberRange(xFloat) if @ValidateStringNumbers
        lfn = xFloat.to_f.round(@InputDecimalPrecision)
        @VectorOfX.push(lfn)
    end

    attr_accessor   :InputDecimalPrecision
    attr_accessor   :OutputDecimalPrecision
    attr_accessor   :Population
    attr_accessor   :UseSumOfDiffs
    attr_accessor   :ValidateStringNumbers

    attr_reader     :SOPo

end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# VectorOfDiscrete - catchall for arbitrary X that could be a string.

class VectorOfDiscrete < VectorOfX

    def genMode
        x = genModeFromFrequencyAA(@FrequenciesAA)
        return x
    end

    def initialize(vectorX=Array.new)
        @FrequenciesAA = Hash.new
        @OutputDecimalPrecision = 4
        @VectorOfX = vectorX
        @VectorOfX.each do |lx|
            @FrequenciesAA[lx] += 1       if @FrequenciesAA.has_key?(lx)
            @FrequenciesAA[lx] = 1    unless @FrequenciesAA.has_key?(lx)
        end
    end

    def genBinomialProbability(subjectValue,nTrials,nSuccesses)
        vn      = getCount
        kf      = genFactorial(nSuccesses)
        nf      = genFactorial(nTrials)
        nlkf    = genFactorial(nTrials - nSuccesses)
        vp1     = @FrequenciesAA[lx].to_f / vn.to_f
        olvp1   = 1 - vp1
        rp      = nf / ( nf * nlkf ) * vp1 * olvp1
        return rp
    end

    def pushX(xItem)
        @FrequenciesAA[xItem] += 1       if @FrequenciesAA.has_key?(xItem)
        @FrequenciesAA[xItem] = 1    unless @FrequenciesAA.has_key?(xItem)
        @VectorOfX.push(xItem)
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
# End of SamesLib.native.rb

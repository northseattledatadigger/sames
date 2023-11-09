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
    if xFloat.is_a? String then
        abbuffer = BigDecimal(xFloat)
        afbuffer = xFloat.to_f
        unless abbuffer == afbuffer
            raise RangeError, "#{xFloat} larger than float capacity for this app."
        end
    end
end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# VectorOfX Base Class

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

        def genPearsonsFirstSkewnessCoefficient(aMean,medianFloat,stdDev)
            # See 2023/11/05 "Pearson's first skewness coefficient" in:
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
        @ArithmeticMean = @SumPowerOf1 / nf
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
        @ArithmeticMean = @SumPowerOf1 / nf
        first   = @SumPowerOf3
        second  = 3 * @SumPowerOf2 * @ArithmeticMean
        third   = 3 * @SumPowerOf1 * ( @ArithmeticMean**2 )
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
        @ArithmeticMean = @SumPowerOf1 / nf
        first   = @SumPowerOf4
        second  = 4 * @SumPowerOf3 * @ArithmeticMean
        third   = 6 * @SumPowerOf2 * ( @ArithmeticMean**2 )
        fourth  = 4 * @SumPowerOf1 * @ArithmeticMean**3
        fifth   = @ArithmeticMean**4
        result  = first - second + third - fourth + fifth
        return result
    end

    def _validateXFloatByState(xFloat)
        if @IsInputDiffFromMean then
            return if xfloat.nil? # Not needed in this case.
            raise ArgumentError, "xFloat Exists when it should be missing."
        end
        return if xfloat.is_a? Numeric # Needed in this case.
        raise ArgumentError, "xFloat Missing when required."
    end

    def initialize(populationDistribution=false,sumOfXsCalculation=false)

        @IsInputDiffFromMean    = sumOfXsCalculation
        @Population             = populationDistribution

        @N                      = 0
        @SumOfXs                = 0 unless @IsInputDiffFromMean
        @SumPowerOf1            = 0     if @IsInputDiffFromMean
        @SumPowerOf2            = 0
        @SumPowerOf3            = 0
        @SumPowerOf4            = 0

        @ArithmeticMean         = nil
        @Kurtosis               = nil
        @Skewness               = nil
        @StdDev                 = nil
        @Variance               = nil
    end

    def addToSums(sFloat,xFloat=nil)
        _validateXFloatByState(xFloat)
        @N += 1
        @SumOfXs     += xFloat       if sumOfXsCalculation
        @SumPowerOf1 += sFloat   unless sumOfXsCalculation
        @SumPowerOf2 += sFloat * sFloat
        @SumPowerOf3 += sFloat * sFloat * sFloat
        @SumPowerOf4 += sFloat * sFloat * sFloat * sFloat
    end

    def genArithmeticMean
        nf = @N.to_f
        if @IsInputDiffFromMean then
            @ArithmeticMean = @SumXs / nf
        else
            @ArithmeticMean = @SumPowerOf1 / nf
        end
        return @ArithmeticMean
    end

    def genKurtosis
        @Kurtosis = genKurtosis_Unbiased_DiffFromMeanCalculation
        return @Kurtosis
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
        left                = leftsidenumerator / leftsidedenominator

        middle              = @SumPowerOf4 / ( @SumPowerOf2**2 )

        rightnumerator      = ( nf - 1.0 )**2
        rightdenominator    = ( nf - 2.0 ) * ( nf - 3.0 )
        right               = rightnumerator / rightdenominator

        sue_G2              = left * middle * right
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
        stdev           = genStdDev(false)
        denominator     = s**3
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
        case formulaId
        when 1
            @Skewness = calculateNaturalEstimatorOfPopulationSkewness_b1
        when 2
            @Skewness = calculateNaturalEstimatorOfPopulationSkewness_g1
        when 3
            @Skewness = generateThirdDefinitionOfSampleSkewness_G1
        else
            m = "There is no skewness formula #{formulaId} implemented at this time."
            raise ArgumentError, m
        end
        return @Skewness
    end

    def genStdDev(populationCalculation)
        v = nil
        if @IsInputDiffFromMean then
            v = genVarianceUsingSubjectAsDiffs(populationCalculation)
        else
            v = genVarianceUsingSubjectAsSumXs(populationCalculation)
        end
        s = Math.sqrt(v)
        return s
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

    def genVarianceUsingSubjectAsDiffs(populationCalculation)
        v = @SumPowerOf2 / ( @N - 1 )   unless populationCalculation
        v = @SumPowerOf2 / @N               if populationCalculation
        return v
    end

    def genVarianceUsingSubjectAsSumXs(populationCalculation)
        amean = genArithmeticMean
        if populationCalculation then
            v = ( @SumPowerOf2 - ( mu * mu ) ) / @N
        else
            part1 = @SumPowerOf2 / ( @N - 1 )
            ameansquared = amean * amean
            part2 = ameanssquared / ( @N * ( @N - 1 ) )
            v = part1 - part2
        end
        return v
    end

end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# VectorOfX Base Class

class VectorOfX

    def _assureSortedVectorOfX
        @SortedVectorOfX = @VectorOfX.sort  unless @SortedVectorOfX
    end

    def getCount
        return @VectorOfX.size
    end

    def initialize(aA=nil)
        # The following is ONLY for testing:
        @SortedVectorOfX    = nil
        @VectorOfX          = Array.new  unless aA
        @VectorOfX          = aA             if aA
    end

    def listVectorElementsForVisualExamination(toStdError=false)
        i = 0
        @VectorOfX.each do |lx|
            puts        "Element[#{i}]:  #{lx}" unless toStdError
            STDERR.puts "Element[#{i}]:  #{lx}"     if toStdError
            i += 1
        end
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

    ArithmeticMeanId    = 'ArithmeticMean'
    GeometricMeanId     = 'GeometricMean'
    IsEvenId            = 'IsEven'
    KurtosisId          = 'Kurtosis'
    MAEId               = 'MAE' # Mean Absolute Error
    MaxId               = 'Max'
    MedianId            = 'Median'
    MinId               = 'Min'
    ModeId              = 'Mode'
    NId                 = 'N'
    SkewnessId          = 'Skewness'
    StddevDiffsPop      = 'StddevDiffsPop'
    StddevDiffsSample   = 'StddevDiffsSample'
    StddevSumxsPop      = 'StddevSumxsPop'
    StddevSumxsSample   = 'StddevSumxsSample'
    SumId               = 'Sum'

    class << self

        def newAfterInvalidatedDropped(arrayA,relayErrors=false)
            localo = self.new
            v = Array.new
            i = 0
            arrayA.each do |le|
                begin
                    localo.pushX(le.to_f)
                rescue error
                    if relayErrors
                        STDERR.puts "Scan Error on element #{i}, value #{le}."
                        STDERR.puts error
                    end
                end
                i += 1
            end
            return localo
        end

    end

    def _decideHistogramStartNumber(startNumber=nil)
        startno = genMin        unless startNumber
        startno = startNumber.to_f  if startNumber
        return startno
    end

    def _genHistogramInitialAA(startNo,segmentSize)
        # Don't worry about cost of passing the AA around until efficiency passes later.
        bottomno    = startNo
        lrsaa       = Hash.new
        topno       = bottomno + segmentSize
        max         = genMax
        while bottomno < max
            rangeo          = Range.new(bottomno,topno)
            lrsaa[rangeo]   = Array.new
            bottomno        = topno
            topno           += segmentSize
        end
        return lrsaa
    end

    def _reuseMSPairIfProvided(aMeanStdDevPair=nil)
        if aMeanStdDevPair then
            raise ArgumentError aMeanStdDevPair.is_a? Array
            raise ArgumentError aMeanStdDevPair.size >= 2
            raise ArgumentError unless aMeanStdDevPair[0].is_a? Float
            raise ArgumentError unless aMeanStdDevPair[1].is_a? Float
            return aMeanStdDevPair[0], aMeanStdDevPair[1]
        mu = genArithmeticMean
        sd = genStandardDeviation
        return mu, sd
    end

    def initialize(vectorX=Array.new)
        @InputDecimalPrecision = 4
        @OutputDecimalPrecision = 4
        @PopulationStdDev = false
        @SortedVectorOfX = nil
        @UseSumOfXs = false
        @ValidateStringNumbers = false
        @VectorOfX = vectorX
    end

    def calculateQuartile(qNo)
        _assureSortedVectorOfX
        n = getCount
        nf = n.to_f
        qindexfloat             = qNo * ( nf - 1.0 ) / 4.0
        qindexremainderfloat    = qindexfloat % 4
        qvalue = nil
        if qindexremainderfloat == 0 then
            qi      = qindexfloat.to_i
            qvalue  = @SortedVectorOfX[qi]
        else
            portion0    = qindexremainderfloat - 1.0
            portion1    = 1.0 - portion0
            qi0         = qindexfloat.to_i
            qi1         = qi0 + 1
            qvalue      = @SortedVectorOfX[qi0] * portion0 + @SortedVectorOfX[qi1] * portion1
        end
        return qvalue
    end

    def genArithmeticMean
        n = @VectorOfX.size.to_f
        sumxs = @VectorOfX.sum.to_f
        return ( sumxs / n ).round(@OutputDecimalPrecision)
    end

    def genGeometricMean
        n = @VectorOfX.size.to_f
        sumxs = @VectorOfX.sum.to_f
        return ( sumxs / n ).round(@OutputDecimalPrecision)
    end

    def genHistogramAA(rangeSegmentAA)
        # Should be reviewed later to see if a generator might be faster.
        @VectorOfX.each do |lx|
            rangeSegmentAA.keys.each do |lro|
                if lro.includes?(lx) then
                    rangeSegmentAA[lro].push(lx)
                    break
                end
            end
        end
    end

    def genHistogramAAbyNumberOfSegments(segmentCount,extraMargin=2.0,startNumber=nil)
        startno         = _decideHistogramStartNumber(startNumber)
        max             = genMax
        totalbreadth    = ( max - startno ) + extraMargin
        scf             = segmentCount.to_f
        segmentsize     = ( totalbreadth / scf ).round
        lrsaa           = _genHistogramInitialAA(startno,segmentsize)
        genHistogramAA(lrsaa)
        return lrsaa
    end

    def genHistogramAAbySegmentSize(segmentSize,startNumber=nil)
        startno         = _decideHistogramStartNumber(startNumber)
        lrsaa           = _genHistogramInitialAA(startno,segmentSize)
        genHistogramAA(lrsaa)
        return lrsaa
    end

    def genSampleKurtosis(aMeanStdDevPair=nil)
        amean, stddev = _reuseMSPairIfProvided(aMeanStdDevPair)
    end

    def genMax
        _assureSortedVectorOfX
        return @SortedVectorOfX[-1]
    end

    def genMeanAbsoluteError
        mu = genMean
        n = @VectorOfX.size
        sumofabsolutediffs = 0
        @VectorOfX.each do |lx|
            previous = sumofabsolutediffs
            sumofabsolutediff += ( lx - mu ).abs
            if previous > sumofabsolutediffs then
                raise RangeError, "previous #{previous} > sumofdiffssquared #{sumofabsolutediffs}"
            end
        end
        mae = sumofabsolutediffs / n
        return mae
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
        lfaa = Hash.new # Init local frequency associative array.
        @VectorOfX.each do |lx|
            lfaa[lx] = 1   unless lfaa.has_key?(lx)
            lfaa[lx] += 1      if lfaa.has_key?(lx)
        end
        x = genModeFromFrequencyAA(lfaa)
        return x
    end

    def genNIsEven?
        n = @VectorOfX.size
        return true if n % 2 == 0
        return false
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

    def genSampleSkewness(aMeanStdDevPair=nil)
        amean, stddev = _reuseMSPairIfProvided(aMeanStdDevPair)
    end

    def genStandardDeviation
        variance = nil
        if @UseSumOfXs then
            variance = genVarianceXsSquaredMethod(@PopulationStdDev)
        else
            variance = genVarianceSumOfDifferencesFromMean(@PopulationStdDev)
        end
        stddev = Math.sqrt(variance).round(@OutputDecimalPrecision)
        if stddev == 0.0 then
            raise RangeError, "Zero Result indicates squareroot error:  #{stddev}"
        end
        return stddev
    end

    def genSum
        sumxs = @VectorOfX.sum
        return sumxs
    end

    def genVarianceSumOfDifferencesFromMean(populationCalculation=false)
        mu = genMean
        n = @VectorOfX.size
        sumofdiffsquared = 0
        @VectorOfX.each do |lx|
            previous = sumofdiffsquared
            xlessmu = lx - mu
            sumofdiffsquared += ( xlessmu * xlessmu )
            #STDERR.puts "trace diffs v: #{previous} > #{sumofdiffsquared}"
            if previous > sumofdiffsquared then
                raise RangeError, "previous #{previous} > sumofdiffssquared #{sumofdiffsquared}"
            end
        end
        v = sumofdiffsquared / ( n - 1 )    unless populationCalculation
        v = sumofdiffsquared / n                if populationCalculation
        # Note rounding is not done here, as it would be double rounded with stddev.
        return v
    end

    def genVarianceXsSquaredMethod(populationCalculation=false)
        mu = genMean
        n = @VectorOfX.size
        sumxssquared = 0
        @VectorOfX.each do |lx|
            previous = sumxssquared
            sumxssquared += lx * lx
            #STDERR.puts "trace sumxs v: #{previous} > #{sumxssquared}"
            if previous > sumxssquared then
                raise RangeError, "previous #{previous} > sumxssquared #{sumxssquared}"
            end
        end
        v = ( sumxssquared - ( mu * mu ) ) / ( n - 1 )  unless populationCalculation
        v = ( sumxssquared - ( mu * mu ) ) / n              if populationCalculation
        # Note rounding is not done here, as it would be double rounded with stddev.
        return v
    end

    def getSummaryStatistics
        iseven    = genNIsEven?
        mean        = genMean
        median      = genMedian
        min,max     = genRange
        mode        = genMode
        n           = getCount
        @PopulationStdDev = true
        @UseSumOfXs = false
        population_stddev_diffs = genStandardDeviation
        @UseSumOfXs = true
        population_stddev_sumxs = genStandardDeviation
        @UseSumOfXs = false
        @PopulationStdDev = false
        sample_stddev_diffs     = genStandardDeviation
        @UseSumOfXs = true
        sample_stddev_sumx      = genStandardDeviation
        @UseSumOfXs = false
        sum                     = genSum
        return {
            IsEvenId            => iseven,
            MAEId               => mae,
            MaxId               => max,
            MeanId              => mean,
            MedianId            => median,
            MinId               => min,
            ModeId              => mode,
            NId                 => n,
            PopStddevDiffsId    => population_stddev_diffs,
            PopStddevSumXsId    => population_stddev_sumxs,
            SamStddevDiffsId    => sample_stddev_diffs,
            SamStddevSumXsId    => sample_stddev_sumxs,
            SumId               => sum
        }
    end

    def pushX(xFloat)
        raise ArgumentError, "#{xFloat} not usable number." unless isUsableNumber?(xFloat)
        VectorOfContinuous::validateStringNumber(xFloat) if @ValidateStringNumbers
        lfn = xFloat.to_f.round(@InputDecimalPrecision)
        @VectorOfX.push(lfn)
    end

    attr_accessor   :InputDecimalPrecision
    attr_accessor   :OutputDecimalPrecision
    attr_accessor   :PopulationStdDev
    attr_accessor   :UseSumOfXs
    attr_accessor :ValidateStringNumbers

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

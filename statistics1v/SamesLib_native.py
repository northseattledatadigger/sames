#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# SamesLib_native.py
# These activities are designed to run literally, without special optimizations,
# as much as possible like the formulations referenced in late 2023 copies of:
#   https://en.wikipedia.org/wiki/Standard_deviation
#   https://www.calculatorsoup.com/calculators/statistics/mean-median-mode.php

import csv
from decimal import Decimal
import json
import math
import numbers
import re

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Global Support Routines


def generateModefromFrequencyAA(faaA):
    if isinstance(faaA, dict):
        x = 0
        m = 0
        for lx, lfrequency in faaA.items():
            if lfrequency > m:
                x = lx
                m = lfrequency
        return x
    else:
        raise ValueError("Only argument must be frequency dictionary.")

def isANumStr(strA):
    if ( not isinstance(strA,str) ): 
        return False
    if ( re.search(r'^-?\d*\.?\d+$',strA) ):
        return True
    return False

def isNumericVector(vA):
    if not type(vA) is list:
        raise ValueError("Only list arguments accepted.")
    if len(vA) == 0:
        return False
    if ( all(isinstance(lve,numbers.Number) for lve in vA) ):
        return True
    return False

def isUsableNumber(cA):
    if ( isinstance(cA,numbers.Number) ):
        return True
    if ( isANumStr(cA) ):
        return True
    return False

def isUsableNumberVector(vA):
    if not type(vA) is list:
        raise ValueError("Only list arguments accepted.")
    if len(vA) == 0:
        return False
    if ( all(isUsableNumber(lve) for lve in vA) ):
        return True
    return False

def validateStringNumberRange(xFloat):
    if ( not isinstance(xFloat,str) ): 
        raise ValueError("Validation is ONLY for Strings.")
    x = None
    try:
        x = float(xFloat)
    except ValueError:
        raise IndexError(f"{xFloat} larger than float capacity for this app.")
    if ( math.isinf(x) ): 
        raise IndexError(f"{xFloat} larger than float capacity for this app.")

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# HistogramOfX and RangeOccurrence

class RangeOccurrence:

    def __init__(self,startNo,stopNo):
        if ( not isinstance(startNo,numbers.Number) ):
            raise ValueError
        if ( not isinstance(stopNo,numbers.Number) ):
            raise ValueError
        self.Count      = 0
        self.StartNo    = startNo
        self.StopNo     = stopNo

    def addToCount(self):
        self.Count += 1

    def hasOverlap(self,startNo,stopNo):
        if ( not isinstance(startNo,numbers.Number) ):
            raise ValueError
        if ( not isinstance(stopNo,numbers.Number) ):
            raise ValueError
        if ( self.StartNo <= startNo and startNo < self.StopNo ):
            return True
        if ( self.StartNo < stopNo and stopNo <= self.StopNo ):
            return True
        return False

    def isInRange(xFloat):
        if ( not isinstance(xFloat,numbers.Number) ):
            raise ValueError
        if ( xFloat < self.StartNo ):
            return False
        if ( self.StopNo <= xFloat ):
            return False
        return True

class HistogramOfX:

    def __init__(self,lowestValue,highestValue):
        if ( not isinstance(lowestValue,numbers.Number) ):
            raise ValueError(f"lowestValue argument '{lowestValue}' is not a number.")
        if ( not isinstance(highestValue,numbers.Number) ):
            raise ValueError(f"highestValue argument '{highestValue}' is not a number.")
        self.FrequencyAA    = {}
        self.Max            = highestValue
        self.Min            = lowestValue

    def _validateNoOverlap(self,startNo,stopNo):
        if ( not isinstance(startNo,numbers.Number) ):
            raise ValueError(f"startNo argument '{startNo}' is not a number.")
        if ( not isinstance(stopNo,numbers.Number) ):
            raise ValueError(f"stopNo argument '{stopNo}' is not a number.")
        for lroo in self.FrequencyAA.values():
            if lroo.hasOverlap(startNo,stopNo):
                m = "Range [#{startNo},#{stopNo}] overlaps with another range:  [#{lroo.StartNo},#{lroo.StopNo}]."
                raise ValueError(m)

    def addToCounts(self,xFloat):
        print(f"trace 0 addToCounts:  {self.__class__}, {type(self)}, {xFloat}\n")
        if ( not isinstance(xFloat,numbers.Number) ):
            raise ValueError(f"xFloat argument '{xFloat}' is not a number.")
        print(f"trace 1 addToCounts:  {xFloat}, {type(self.FrequencyAA)}, {len(self.FrequencyAA)}\n")
        for lstartno in sorted(self.FrequencyAA):
            print(f"trace lstartno:  {lstartno}\n")
            lroo = self.FrequencyAA[lstartno]
            if xFloat < lroo.StopNo:
                lroo.addToCount
                return
        print(f"trace 8 addToCounts:  {xFloat}\n")
        m = "Programmer Error:  "
        m += "No Frequency range found for xFloat:  '#{xFloat}'."
        raise ValueError( m )

    def generateCountCollection(self):
        orderedlist = Array.new
        for lstartno in sorted(self.FrequencyAA):
            lroo = self.FrequencyAA[lstartno]
            orderedlist.push([lstartno,lroo.StopNo,lroo.Count])
        return orderedlist

    @classmethod
    def newFromDesiredSegmentCount(cls,startNo,maxNo,desiredSegmentCount,extraMargin=0):
        if ( not isinstance(startNo,numbers.Number) ):
            raise ValueError(f"startNo argument '{startNo}' is not a number.")
        if ( not isinstance(maxNo,numbers.Number) ):
            raise ValueError(f"maxNo argument '{maxNo}' is not a number.")
        if ( type(desiredSegmentCount) != int ):
            raise ValueError(f"desiredSegmentCount argument '{desiredSegmentCount}' is not an integer.")
        if ( not isinstance(extraSegment,numbers.Number) ):
            raise ValueError(f"extraSegment argument '{extraSegment}' is not a number.")
        # xc 20231106:  Don't worry about cost of passing the AA around until efficiency passes later.
        totalbreadth    = float( maxNo - startNo + 1 + extraMargin )
        dscf            = float(desiredSegmentCount)
        segmentsize     = totalbreadth / dscf
        #STDERR.puts "trace segmentsize:  #{segmentsize}"
        localo          = cls.newFromUniformSegmentSize(startNo,maxNo,segmentsize)
        return localo

    @classmethod
    def newFromUniformSegmentSize(cls,startNo,maxNo,segmentSize):
        if ( not isinstance(startNo,numbers.Number) ):
            raise ValueError(f"startNo argument '{startNo}' is not a number.")
        if ( not isinstance(stopNo,numbers.Number) ):
            raise ValueError(f"stopNo argument '{stopNo}' is not a number.")
        if ( not isinstance(segmentSize,numbers.Number) ):
            raise ValueError(f"segmentSize argument '{segmentSize}' is not a number.")
        # xc 20231106:  Don't worry about cost of passing the AA around until efficiency passes later.
        localo          = HistogramOfX(startNo,maxNo)
        bottomno        = startNo
        topno           = bottomno + segmentSize
        while bottomno <= maxNo:
            localo.setOccurrenceRange(bottomno,topno)
            bottomno    = topno
            topno       += segmentSize
        return localo

    def setOccurrenceRange(self,startNo,stopNo):
        if ( not isinstance(startNo,numbers.Number) ):
            raise ValueError(f"startNo argument '{startNo}' is not a number.")
        if ( not isinstance(stopNo,numbers.Number) ):
            raise ValueError(f"stopNo argument '{stopNo}' is not a number.")
        if stopNo <= startNo:
            raise ValueError(f"stopNo must be larger than startNo.")
        self._validateNoOverlap(startNo,stopNo)
        self.FrequencyAA[startNo] = RangeOccurrence(startNo,stopNo)

    def validateRangesComplete(self):
        i = 0
        lroo = None
        previous_lroo = None
        for lstartno in sorted(self.FrequencyAA):
            lroo = self.FrequencyAA[lstartno]
            if lstartno != lroo.StartNo:
                raise IndexError( "Programmer Error on startno assignments." )
            if i == 0:
                if lroo.StartNo > self.Min:# NOTE:  Start may be before the minimum,
                                           # but NOT after it, as minimum value must
                                           # be included in the first segment.
                    m = "Range [#{lroo.StartNo},#{lroo.StopNo}] "
                    m += " starts after the minimum designated value '#{self.Min}."
                    raise IndexError( m )
            else:
                if lroo.StartNo != previous_lroo.StopNo:
                    m = "Range [#{previous_lroo.StartNo},#{previous_lroo.StopNo}]"
                    m += " is not adjacent to the next range "
                    m += "[#{lroo.StartNo},#{lroo.StopNo}]."
                    raise IndexError( m )
            i += 1
            previous_lroo = lroo

        if self.Max > lroo.StopNo:
            m = "Range [#{lroo.StartNo},#{lroo.StopNo}] "
            m += " ends before the maximum value '#{self.Max}."
            raise IndexError( m )


'''
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# SumsOfPowers

class SumsOfPowers

    # NOTE:  The main merit to doing it this way is as a teaching or illustration
    # tool to show the two parallel patterns.  Probably this is not a good way
    # to implement it in most or any production situations.

    class << self

        def calculatePearsonsFirstSkewnessCoefficient(aMean,modeFloat,stdDev)
            raise ValueError unless aMean.is_a? Numeric
            raise ValueError unless modeFloat.is_a? Numeric
            raise ValueError unless stdDev.is_a? Numeric
            # See 2023/11/05 "Pearson's first skewness coefficient" in:
            #   https://en.wikipedia.org/wiki/Skewness
            sc  = ( aMean - modeFloat ) / stdDev
            return sc
        end

        def calculatePearsonsSecondSkewnessCoefficient(aMean,medianFloat,stdDev)
            raise ValueError unless aMean.is_a? Numeric
            raise ValueError unless medianFloat.is_a? Numeric
            raise ValueError unless stdDev.is_a? Numeric
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
            raise ValueError, "May ONLY be used with Sum of Xs Data."
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
            raise ValueError, "May ONLY be used with Sum of Xs Data."
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
            raise ValueError, "May ONLY be used with Sum of Xs Data."
        end
        first   = @SumPowerOf4
        second  = 4 * @SumPowerOf3 * @ArithmeticMean
        third   = 6 * @SumPowerOf2 * ( @ArithmeticMean**2 )
        fourth  = 4 * @SumOfXs * @ArithmeticMean**3
        fifth   = @ArithmeticMean**4
        result  = first - second + third - fourth + fifth
        return result
    end

    def initialize(populationDistribution=False)
        @ArithmeticMean         = 0
        @N                      = 0
        @DiffFromMeanInputsUsed    = False
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
            raise ValueError, "May NOT be used with Sum of Xs Data."
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
            raise ValueError, "May NOT be used with Sum of Xs Data."
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
            raise ValueError, "May NOT be used with Sum of Xs Data."
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
            raise ValueError, "This formula wll not be executed for N <= 3."
        end
        unless @DiffFromMeanInputsUsed
            raise ValueError, "May NOT be used with Sum of Xs Data."
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
            raise ValueError, "May NOT be used with Sum of Xs Data."
        end
        nf              = @N.to_f
        v = @SumPowerOf2 / ( nf - 1.0 ) unless @Population
        v = @SumPowerOf2 / nf               if @Population
        #STDERR.puts "trace 8 #{self.class}.genVarianceUsingSubjectAsDiffs:  #{v}, #{nf}, #{@Population}, #{@SumPowerOf2}"
        return v
    end

    def calculateVarianceUsingSubjectAsSumXs
        if @DiffFromMeanInputsUsed
            raise ValueError, "May ONLY be used with Sum of Xs Data."
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
            raise ValueError, m
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
            raise ValueError, m
        end
        return skewness
    end

    def setToDiffsFromMeanState(sumXs,nA)
        raise ValueError unless sumXs.is_a? Numeric
        raise ValueError unless nA.is_a? Integer
        if @N > 0 then
            m = "#{@N} values have already been added to the sums."
            m += " You must reinit the object before setting to the Diffs From Mean state."
            raise ValueError, m
        end
        @DiffFromMeanInputsUsed = True
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
    ExcludeRowOnBadData     = 2
    FailOnBadData           = 3
    SkipRowOnBadData        = 4
    ZeroFieldOnBadData      = 5

    def _assureSortedVectorOfX(forceSort=False)
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
            raise ValueError unless aA.is_a? Array
        end
        # The following is ONLY for testing:
        @SortedVectorOfX    = nil
        @VectorOfX          = Array.new  unless aA
        @VectorOfX          = aA             if aA
    end

    def getCount
        return @VectorOfX.size
    end

    def getX(indexA,sortedVector=False)
        raise ValueError, "Index Argument Missing:  Required."       unless indexA.is_a? Integer
        raise ValueError, "Index Argument Not found in VectorOfX."   unless @VectorOfX[indexA]
        return @VectorOfX[indexA]   unless sortedVector
        return @SortedVectorOfX[indexA] if sortedVector and @SortedVectorOfX.has_key?(indexA)
        return nil
    end

    def pushX(xFloat,onBadData)
        raise ValueError, "Pure Virtual"
    end

    def requestResultAACSV
        raise ValueError, "Pure Virtual"
    end

    def requestResultCSVLine
        raise ValueError, "Pure Virtual"
    end

    def requestResultJSON
        raise ValueError, "Pure Virtual"
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
    MADId                       = 'MAD' # Mean Absolute Difference  NOTE that this will not be addressed in acceptance tests due to a paucity of presence in common apps.
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

        def newAfterInvalidatedDropped(arrayA,relayErrors=False)
            raise ValueError unless arrayA.is_a? Array
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

    def _addUpXsToSumsOfPowers(populationCalculation=False,sumOfDiffs=True)
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
        raise ValueError unless vectorX.is_a? Array
        @InputDecimalPrecision          = 4
        @OutputDecimalPrecision         = 4
        @Population                     = False
        @SOPo                           = nil
        @SortedVectorOfX                = nil
        @UseDiffFromMeanCalculations    = True
        @ValidateStringNumbers          = False
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
        raise ValueError unless qNo.is_a? Integer
        raise ValueError unless 0 <= qNo
        raise ValueError unless qNo < 5
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
            raise ValueError, m
        end
        nf                      = @VectorOfX.size.to_f
        sumofabsolutediffs      = 0
        @VectorOfX.each do |lx|
            previous            = sumofabsolutediffs
            sumofabsolutediffs  += ( lx - cpf ).abs
            if previous > sumofabsolutediffs then
                # These need review.  
                raise IndexError, "previous #{previous} > sumofdiffssquared #{sumofabsolutediffs}"
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
        raise ValueError unless desiredSegmentCount.is_a? Integer
        if startNumber then
            raise ValueError unless startNumber.is_a? Numeric
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
        raise ValueError unless segmentSize.is_a? Numeric
        if startNumber then
            raise ValueError unless startNumber.is_a? Numeric
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
        return True if n % 2 == 0
        return False
    end

    def pushX(xFloat,onBadData=VectorOfX::FailOnBadData)
        unless isUsableNumber?(xFloat)
            case onBadData
            when VectorOfX::BlankFieldOnBadData
                raise ValueError, "May Not Blank Fields"
            when VectorOfX::DefaultFillOnBadData
                xFloat=0.0
            when VectorOfX::FailOnBadData
                raise ValueError, "#{xFloat} not usable number."
            when VectorOfX::SkipRowOnBadData
                return
            when VectorOfX::ZeroFieldOnBadData
                xFloat=0.0
            else
                raise ValueError, "Unimplemented onBadData value:  #{onBadData}."
            end
        end
        validateStringNumberRange(xFloat) if @ValidateStringNumbers
        lfn = xFloat.to_f.round(@InputDecimalPrecision)
        @VectorOfX.push(lfn)
    end

    def requestExcessKurtosis(formulaId=3)
        unless @UseDiffFromMeanCalculations
            raise ValueError, "May NOT be used with Sum of Xs Data."
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
            raise ValueError, m
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
        # NOTE: Mean Absolute Diffence is no longer featured here.
        scaa = requestSummaryCollection
        return <<-EOAACSV
"#{ArithmeticMeanId}", #{scaa[ArithmeticMeanId]}
"#{ArMeanAADId}", #{scaa[ArMeanAADId]}
"#{CoefficientOfVariationId}", #{scaa[CoefficientOfVariationId]}
"#{GeometricMeanId}", #{scaa[GeometricMeanId]}
"#{HarmonicMeanId}", #{scaa[HarmonicMeanId]}
"#{IsEvenId}", #{scaa[IsEvenId]}
"#{KurtosisId}", #{scaa[KurtosisId]}
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
    def requestResultCSVLine(includeHdr=False)
        # NOTE: Mean Absolute Diffence is no longer featured here.
        scaa        = requestSummaryCollection
        csvline     =   "#{scaa[ArithmeticMeanId]},#{scaa[ArMeanAADId]},"
        csvline     +=  "#{scaa[CoefficientOfVariationId]},"
        csvline     +=  "#{scaa[GeometricMeanId]},#{scaa[HarmonicMeanId]},"
        csvline     +=  "#{scaa[IsEvenId]},#{scaa[KurtosisId]},"
        csvline     +=  "#{scaa[MaxId]},#{scaa[MedianId]},#{scaa[MedianAADId]},"
        csvline     +=  "#{scaa[MinId]},#{scaa[ModeId]},#{scaa[NId]},"
        csvline     +=  "#{scaa[SkewnessId]},#{scaa[StandardDeviation]},"
        csvline     +=  "#{scaa[SumId]}"
        if includeHdr then
            csvhdr  =   "#{ArithmeticMeanId},#{ArMeanAADId},"
            csvhdr  +=  "#{CoefficientOfVariationId},#{GeometricMeanId},"
            csvhdr  +=  "#{HarmonicMeanId},#{IsEvenId},#{KurtosisId},"
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
            raise IndexError, "Zero Result indicates squareroot error:  #{unroundedstddev}"
        end
        stddev = unroundedstddev.round(@OutputDecimalPrecision)
        return stddev
    end

    def requestSummaryCollection
        #NOTE:  Some of these are ONLY for sample.  For now, this is best used ONLY for Samples.
        #@SOPo                   = _addUpXsToSumsOfPowers(@Population,@UseDiffFromMeanCalculations)
        @SOPo                   = _addUpXsToSumsOfPowers(False,@UseDiffFromMeanCalculations)
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

    def requestVarianceSumOfDifferencesFromMean(populationCalculation=False)
        @SOPo = _addUpXsToSumsOfPowers(populationCalculation)
        v = @SOPo.calculateVarianceUsingSubjectAsDiffs
        # Note rounding is not done here, as it would be double rounded with stddev.
        return v
    end

    def requestVarianceXsSquaredMethod(populationCalculation=False)
        @SOPo = _addUpXsToSumsOfPowers(populationCalculation,False)
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
        raise ValueError unless subjectValue
        raise ValueError unless nTrials.is_a? Integer
        raise ValueError unless nSuccesses.is_a? Integer
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

        successpermutations = math.factorial(nSuccesses)
        failurepermutations = math.factorial(nTrials - nSuccesses)
        trials_permutations = math.factorial(nTrials)
        #STDERR.puts "\ntrace 7 calculateBinomialProbability #{successpermutations},#{failurepermutations},#{trials_permutations}"
        numerator           = trials_permutations * psuccessfactor * pfailurefactor
        denominator         = successpermutations * failurepermutations
        binomialprobability = numerator / denominator
        #STDERR.puts "\ntrace 8 calculateBinomialProbability #{numerator},#{denominator},#{binomialprobability}"
        return binomialprobability
    end

    def getFrequency(subjectValue)
        raise ValueError unless subjectValue
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
                raise ValueError, "#{xItem} not usable value."
            when VectorOfX::SkipRowOnBadData
                return
            when VectorOfX::ZeroFieldOnBadData
                xItem=0.0
            else
                raise ValueError, "Unimplemented onBadData value:  #{onBadData}."
            end
        end
        @FrequenciesAA[xItem] += 1       if @FrequenciesAA.has_key?(xItem)
        @FrequenciesAA[xItem] = 1    unless @FrequenciesAA.has_key?(xItem)
        @VectorOfX.push(xItem)
        return True
    end

    def requestMode
        x = generateModefromFrequencyAA(@FrequenciesAA)
        return x
    end

    def requestResultAACSV
        # NOTE: Mean Absolute Diffence is no longer featured here.
        mode    = requestMode
        n       = getCount
        frequencies = ""
        @FrequenciesAA.keys.sort.each do |lfkey|
            frequencies += "\"Value: '#{lfkey}'\", \"Frequency:  #{@FrequenciesAA[lfkey]}\"\n"
        end
        content = <<-EOAACSV
"N", #{n}
#{frequencies}
"Mode", #{mode}
EOAACSV
    end

    def requestResultCSVLine
        raise ValueError, "Not Implemented"
    end

    def requestResultJSON
        raise ValueError, "Not Implemented"
    end

    attr_accessor   :OutputDecimalPrecision

    attr_reader     :FrequenciesAA

end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# VectorTable for reading and processing contents of 2 dimentional matrices.

class VectorTable

    class << self

        def arrayOfChar2VectorOfClasses(aA)
            oa = Hash.new
            aA.each do |lc|
                case lc
                when 'C'
                    oa.push(VectorOfContinuous)
                when 'D'
                    oa.push(VectorOfDiscrete)
                else
                    STDERR.puts "Allowed class identifier characters are {C,D} in this context."
                    raise ValueError, "Identifier '#{lc}' is not recognized."
                end
            end
            return oa
        end

        def arrayOfClassLabels2VectorOfClasses(aA)
            oa = Array.new
            aA.each do |llabel|
                case llabel
                when /VectorOfContinuous/
                    oa.push(VectorOfContinuous)
                when /VectorOfDiscrete/
                    oa.push(VectorOfDiscrete)
                else
                    oa = "Identifier '#{llabel}' is not recognized as a class of X in this context."
                    raise ValueError, m
                end
            end
            return oa
        end

        def isAllowedDataVectorClass?(vectorClass)
            return False    unless vectorClass.is_a? Class
            return True         if vectorClass.ancestors.include? VectorOfX
            return False
        end

        def newFromCSV(vcSpec,fSpec,onBadData=VectorOfX::ExcludeRowOnBadData,seeFirstLineAsHdr=True)
            def skipIndicated(onBadData,ll)
                if onBadData == VectorOfX::ExcludeRowOnBadData then
                    return True if ll =~ /,,/
                end
                return False
            end
            localo = self.new(vcSpec)
            File.open(fSpec) do |fp|
                i = 0
                fp.each_line do |ll|
                    next if skipIndicated(onBadData,ll)
                    sll = ll.strip
                    if ( i == 0 ) then
                        if seeFirstLineAsHdr then
                            hdrcolumns = sll.parse_csv
                            localo.useArrayForColumnIdentifiers(hdrcolumns)
                            i += 1
                            next
                        end
                    end
                    columns = sll.parse_csv
                    localo.pushTableRow(columns,onBadData)
                    i += 1
                end
            end
            return localo
        end

    end

    def initialize(vectorOfClasses)
        raise ValueError, "Argument Passed '#{vectorOfClasses.class}' NOT ARRAY" unless vectorOfClasses.is_a? Array
        @TableOfVectors     = Array.new
        @VectorOfClasses    = vectorOfClasses
        @VectorOfHdrs       = Array.new
        i = 0
        @VectorOfClasses.each do |lci|
            if lci then
                raise ValueError, "Class '#{lci.class}' Not Valid" unless self.class.isAllowedDataVectorClass?(lci)
                @TableOfVectors[i] = lci.new        if lci
            else
                @TableOfVectors[i] = nil        
            end
            @VectorOfHdrs.push("Column #{i}") # Use offset index as column numbers, NOT traditional.
            i += 1
        end
    end

    def eachColumnVector
        @TableOfVectors.each do |lvo|
            yield lvo
        end
    end

    def getColumnCount
        return @TableOfVectors.size
    end

    def getRowCount(columnIndex=0)
        # As of 2023/11/14 I have put little thought into regular data, and hope simple
        # validations will keep it away for now.
        return @TableOfVectors[columnIndex].size
    end

    def getVectorObject(indexNo)
        unless 0 <= indexNo and indexNo < @TableOfVectors.size
            raise ValueError, "Index number '#{indexNo}' provided is out of range {0,#{@TableOfVectors.size-1}}."
        end
        unless VectorTable.isAllowedDataVectorClass?( @TableOfVectors[indexNo].class )
            raise ValueError, "Column #{indexNo} not configured for Data Processing."
        end
        return @TableOfVectors[indexNo]
    end

    def pushTableRow(arrayA,onBadData=VectorOfX::DefaultFillOnBadData)
        raise ValueError unless arrayA.is_a? Array
        raise ValueError unless arrayA.size == @TableOfVectors.size
        raise ValueError if onBadData == VectorOfX::SkipRowOnBadData
        i = 0
        @TableOfVectors.each do |lvoe|
            if lvoe.is_a? VectorOfX then
                lvoe.pushX(arrayA[i],onBadData)
            end
            i += 1
        end
    end

    def useArrayForColumnIdentifiers(hdrColumns)
        raise ValueError unless hdrColumns.is_a? Array
        unless hdrColumns.size == @VectorOfHdrs.size
            m = "hdr columns passed has size #{hdrColumns.size}, but requires #{@VectorOfHdrs.size}"
            raise ValueError, m
        end
        @VectorOfHdrs = hdrColumns
    end

end
'''

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of SamesLib_native.py

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# SamesLib_native.py
# These activities are designed to run literally, without special optimizations,
# as much as possible like the formulations referenced in late 2023 copies of:
#   https://en.wikipedia.org/wiki/Standard_deviation
#   https://www.calculatorsoup.com/calculators/statistics/mean-median-mode.php

import array
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
# NOTE:  Because Python3, unlike Ruby, is such a hodgepodge of inconsistent
# constructs and confusing extra decorations, I decided to pull RangeOccurrence
# out into indepencent space instead of having it as a nested class, for the
# Python3 version.  This makes it simpler and clearer, and I will need to do
# similar things in other non-class oriented languages anyway.

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

    def isInRange(self,xFloat):
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
        if ( not isinstance(xFloat,numbers.Number) ):
            raise ValueError(f"xFloat argument '{xFloat}' is not a number.")
        for lstartno in sorted(self.FrequencyAA):
            lroo = self.FrequencyAA[lstartno]
            if xFloat < lroo.StopNo:
                lroo.addToCount()
                return
        m = "Programmer Error:  "
        m += "No Frequency range found for xFloat:  '#{xFloat}'."
        raise ValueError( m )

    def generateCountCollection(self):
        orderedlist = []
        for lstartno in sorted(self.FrequencyAA):
            lroo = self.FrequencyAA[lstartno]
            orderedlist.append([lstartno,lroo.StopNo,lroo.Count])
        return orderedlist

    @classmethod
    def newFromDesiredSegmentCount(cls,startNo,maxNo,desiredSegmentCount,extraMargin=0):
        if ( not isinstance(startNo,numbers.Number) ):
            raise ValueError(f"startNo argument '{startNo}' is not a number.")
        if ( not isinstance(maxNo,numbers.Number) ):
            raise ValueError(f"maxNo argument '{maxNo}' is not a number.")
        if ( type(desiredSegmentCount) != int ):
            raise ValueError(f"desiredSegmentCount argument '{desiredSegmentCount}' is not an integer.")
        if ( not isinstance(extraMargin,numbers.Number) ):
            raise ValueError(f"extraMargin argument '{extraMargin}' is not a number.")
        # xc 20231106:  Don't worry about cost of passing the AA around until efficiency passes later.
        totalbreadth    = float( maxNo - startNo + 1 + extraMargin )
        dscf            = float(desiredSegmentCount)
        segmentsize     = totalbreadth / dscf
        localo          = cls.newFromUniformSegmentSize(startNo,maxNo,segmentsize)
        return localo

    @classmethod
    def newFromUniformSegmentSize(cls,startNo,maxNo,segmentSize):
        if ( not isinstance(startNo,numbers.Number) ):
            raise ValueError(f"startNo argument '{startNo}' is not a number.")
        if ( not isinstance(maxNo,numbers.Number) ):
            raise ValueError(f"maxNo argument '{maxNo}' is not a number.")
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


#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# SumsOfPowers

class SumsOfPowers:

    # NOTE:  The main merit to doing it this way is as a teaching or illustration
    # tool to show the two parallel patterns.  Probably this is not a good way
    # to implement it in most or any production situations.

    def __init__(self,populationDistribution=False):
        self.ArithmeticMean         = 0.0
        self.N                      = 0
        self.DiffFromMeanInputsUsed = False
        self.Population             = populationDistribution

        self.SumOfXs                = 0.0
        self.SumPowerOf2            = 0.0
        self.SumPowerOf3            = 0.0
        self.SumPowerOf4            = 0.0

    def _calculateFourthMomentSubjectXs(self):
        # My algegra, using unreduced arithmetic mean parts because that becomes complicated
        # when going to sample means, leads to a simple Pascal Triangle pattern:
        # My algegra: Sum( xi - mu )**4 ==
        #   Sum(xi**4) - 4*Sum(xi**3)*amean + 6*Sum(xi**2)(amean**2) - 4**Sum(xi)*(amean**3) + mu**4
        if self.DiffFromMeanInputsUsed:
            raise ValueError( "May ONLY be used with Sum of Xs Data." )

        first   = self.SumPowerOf4
        second  = 4 * self.SumPowerOf3 * self.ArithmeticMean
        third   = 6 * self.SumPowerOf2 * ( self.ArithmeticMean**2 )
        fourth  = 4 * self.SumOfXs * self.ArithmeticMean**3
        fifth   = self.ArithmeticMean**4
        result  = first - second + third - fourth + fifth
        return result

    def _calculateSecondMomentSubjectXs(self):
        #   Sum( xi - mu )**2 == Sum(xi**2) - (1/n)(amean**2)
        # Note I checked this one at:
        #   https://math.stackexchange.com/questions/2569510/proof-for-sum-of-squares-formula-statistics-related
        #
        if self.DiffFromMeanInputsUsed:
            raise ValueError( "May ONLY be used with Sum of Xs Data." )
        nf      = float( self.N )
        #print(f"trace 2 _calculateSecondMomentSubjectXs: {nf}")
        nreciprocal = 1.0 / nf
        #print(f"trace 3 _calculateSecondMomentSubjectXs: {nreciprocal}")
        first   = self.SumPowerOf2
        #print(f"trace 4 _calculateSecondMomentSubjectXs: {first}")
        second  = nreciprocal * ( self.ArithmeticMean**2 )
        #print(f"trace 5 _calculateSecondMomentSubjectXs: {second}")
        ssx     = first - second
        #print(f"trace 8 _calculateSecondMomentSubjectXs: {ssx}")
        return ssx

    def _calculateThirdMomentSubjectXs(self):
        # My algegra, using unreduced arithmetic mean parts because that becomes complicated
        # when going to sample means, leads to a simple Pascal Triangle pattern:
        # My algegra: Sum( xi - mu )**3 ==
        #   Sum(xi**3) - 3*Sum(xi**2)*amean + 3*Sum(xi)*(amean**2) - mu**3
        if self.DiffFromMeanInputsUsed:
            raise ValueError( "May ONLY be used with Sum of Xs Data." )
        first   = self.SumPowerOf3
        second  = 3 * self.SumPowerOf2  *   self.ArithmeticMean
        third   = 3 * self.SumOfXs      * ( self.ArithmeticMean**2 )
        fourth  = self.ArithmeticMean**3
        result  = first - second + third - fourth
        return result

    def addToSums(self,sFloat):
        if not self.DiffFromMeanInputsUsed:
            self.N += 1
            self.SumOfXs        += sFloat   

            self.ArithmeticMean = ( float( self.SumOfXs ) / float( self.N ) )

        self.SumPowerOf2        += sFloat * sFloat
        self.SumPowerOf3        += sFloat * sFloat * sFloat
        self.SumPowerOf4        += sFloat * sFloat * sFloat * sFloat

    def calculateExcessKurtosis_2_JR_R(self):
        #trace genExcessKurtosis_2_JR_R:  18.0, 708.0, 39.333333333333336, 60.0, 11.111111111111112, 0.5399999999999996
        #  2018-01-04 by Jonathan Regenstein https://rviews.rstudio.com/2018/01/04/introduction-to-kurtosis/
        if not self.DiffFromMeanInputsUsed:
            raise ValueError( "May NOT be used with Sum of Xs Data." )

        nf          = float( self.N )
        numerator   = self.SumPowerOf4 / nf
        denominator = ( self.SumPowerOf2 / nf ) ** 2 
        ek          = ( numerator / denominator ) - 3
        #puts "trace genExcessKurtosis_2_JR_R:  #{nf}, #{self.SumPowerOf4}, #{numerator}, #{self.SumPowerOf2}, #{denominator}, #{ek}"
        return ek

    def generateExcessKurtosis_3_365datascience(self):
        #  https://365datascience.com/calculators/kurtosis-calculator/
        if not self.DiffFromMeanInputsUsed:
            raise ValueError( "May NOT be used with Sum of Xs Data." )

        nf                  = float( self.N )
        stddev              = generateStandardDeviation
        s4                  = stddev**4

        leftnumerator       = nf * ( nf + 1.0 )
        leftdenominator     = ( nf - 1.0 ) * ( nf - 2.0 ) * ( nf - 3.0 )
        left                = leftnumerator / leftdenominator

        middle              = self.SumPowerOf4 / s4

        rightnumerator      = 3 * ( ( nf - 1 )**2 )
        rightdenominator    = ( nf - 2.0 ) * ( nf - 3.0 )
        right               = rightnumerator / rightdenominator
        ek                  = left * middle - right
        return ek

    def calculateKurtosis_Biased_DiffFromMeanCalculation(self):
        # See 2023/11/05 "Standard biased estimator" in:
        #   https://en.wikipedia.org/wiki/Kurtosis
        if not self.DiffFromMeanInputsUsed:
            raise ValueError( "May NOT be used with Sum of Xs Data." )

        nreciprocal     = ( 1.0 / float( self.N ) )
        numerator       = nreciprocal * self.SumPowerOf4
        denominternal   = nreciprocal * self.SumPowerOf2
        denominator     = denominternal * denominternal
        g2              = numerator / denominator
        return g2

    def calculateKurtosis_Unbiased_DiffFromMeanCalculation(self):
        # See 2023/11/05 "Standard unbiased estimator" in:
        #   https://en.wikipedia.org/wiki/Kurtosis
        if not self.N > 3:
            raise ValueError( "This formula wll not be executed for N <= 3." )

        if not self.DiffFromMeanInputsUsed:
            raise ValueError( "May NOT be used with Sum of Xs Data." )

        #print(f"\ntrace 1 genKurtosis_Unbiased_DiffFromMeanCalculation:  {self.ArithmeticMean},{self.N},{self.DiffFromMeanInputsUsed},{self.Population},{self.SumOfXs},{self.SumPowerOf2},{self.SumPowerOf3},{self.SumPowerOf4}")
        nf = float( self.N )

        #print(f"\ntrace 2 genKurtosis_Unbiased_DiffFromMeanCalculation:  {nf}")
        leftnumerator       = ( nf + 1.0 ) * nf * ( nf - 1.0 )
        #print(f"\ntrace 3 genKurtosis_Unbiased_DiffFromMeanCalculation:  {leftnumerator}")
        leftdenominator     = ( nf - 2.0 ) * ( nf - 3.0 )
        #print(f"\ntrace 4 genKurtosis_Unbiased_DiffFromMeanCalculation:  {leftdenominator}")
        left                = leftnumerator / leftdenominator
        #print(f"\ntrace 5 genKurtosis_Unbiased_DiffFromMeanCalculation:  {left}, {self.SumPowerOf4}, {self.SumPowerOf2}")

        middle              = self.SumPowerOf4 / ( self.SumPowerOf2**2 )
        #print(f"\ntrace 6 genKurtosis_Unbiased_DiffFromMeanCalculation:  {middle}")

        rightnumerator      = ( nf - 1.0 )**2
        #print(f"\ntrace 7 genKurtosis_Unbiased_DiffFromMeanCalculation:  {rightnumerator}")
        rightdenominator    = ( nf - 2.0 ) * ( nf - 3.0 )
        #print(f"\ntrace 8 genKurtosis_Unbiased_DiffFromMeanCalculation:  {rightdenominator}")
        right               = rightnumerator / rightdenominator
        #print(f"\ntrace 9 genKurtosis_Unbiased_DiffFromMeanCalculation:  {right}")
        sue_G2              = left * middle - right
        #print(f"\ntrace a genKurtosis_Unbiased_DiffFromMeanCalculation:  {sue_G2}")
        #STDERR.puts "\nsue_G2              = left * middle * right: #{sue_G2}              = #{left} * #{middle} * #{right}"

        return sue_G2

    def calculateNaturalEstimatorOfPopulationSkewness_g1(self):
        # See 2023/11/05 "Sample Skewness" in:
        #   https://en.wikipedia.org/wiki/Skewness
        inside_den      = None
        nreciprocal     = ( 1.0 / float( self.N ) )
        numerator       = None
        if self.DiffFromMeanInputsUsed:
            inside_den  = nreciprocal * self.SumPowerOf2
            numerator   = nreciprocal * self.SumPowerOf3
        else:
            second      = _calculateSecondMomentSubjectXs
            third       = _calculateThirdMomentSubjectXs

            inside_den  = nreciprocal * second
            numerator   = nreciprocal * third

        denominator     = ( math.sqrt( inside_den ) )**3
        g1              = numerator / denominator
        return g1

    @classmethod
    def calculatePearsonsFirstSkewnessCoefficient(cls,aMean,modeFloat,stdDev):
        if not isinstance(aMean,numbers.Number):
            raise ValueError
        if not isinstance(modeFloat,numbers.Number):
            raise ValueError
        if not isinstance(stdDev,numbers.Number):
            raise ValueError
        # See 2023/11/05 "Pearson's first skewness coefficient" in:
        #   https://en.wikipedia.org/wiki/Skewness
        sc  = ( aMean - modeFloat ) / stdDev
        return sc

    @classmethod
    def calculatePearsonsSecondSkewnessCoefficient(cls,aMean,medianFloat,stdDev):
        if not isinstance(aMean,numbers.Number):
            raise ValueError
        if not isinstance(medianFloat,numbers.Number):
            raise ValueError
        if not isinstance(stdDev,numbers.Number):
            raise ValueError
        # See 2023/11/05 "Pearson's second skewness coefficient" in:
        #   https://en.wikipedia.org/wiki/Skewness
        sc  = ( aMean - medianFloat ) / stdDev
        return sc


    def calculateVarianceUsingSubjectAsDiffs(self):
        if not self.DiffFromMeanInputsUsed:
            raise ValueError( "May NOT be used with Sum of Xs Data." )

        nf              = float( self.N )
        v               = None
        if self.Population:
            v = self.SumPowerOf2 / nf
        else:
            v = self.SumPowerOf2 / ( nf - 1.0 )
        #STDERR.puts "trace 8 #{self.class}.genVarianceUsingSubjectAsDiffs:  #{v}, #{nf}, #{self.Population}, #{self.SumPowerOf2}"
        return v

    def calculateVarianceUsingSubjectAsSumXs(self):
        if self.DiffFromMeanInputsUsed:
            raise ValueError( "May ONLY be used with Sum of Xs Data." )

        ameansquared = self.ArithmeticMean * self.ArithmeticMean
        nf              = float( self.N )
        if self.Population:
            v = ( self.SumPowerOf2 - nf * ameansquared ) / nf
        else:
            v = ( self.SumPowerOf2 - nf * ameansquared ) / ( nf - 1.0 )

        #STDERR.puts "trace 8 #{self.class}.genVarianceUsingSubjectAsSumXs: #{v}, #{nf}, #{self.Population}, #{self.SumPowerOf2}, #{ameansquared}"
        return v

    def generateNaturalEstimatorOfPopulationSkewness_b1(self):
        # See 2023/11/05 "Sample Skewness" in:
        #   https://en.wikipedia.org/wiki/Skewness
        nreciprocal     = ( 1.0 / float( self.N ) )
        numerator       = None
        if self.DiffFromMeanInputsUsed:
            numerator   = nreciprocal * self.SumPowerOf3
        else:
            thirdmoment = self._calculateThirdMomentSubjectXs()
            numerator   = nreciprocal * thirdmoment

        stddev          = self.generateStandardDeviation()
        denominator     = stddev**3
        b1              = numerator / denominator
        return b1

    def generateStandardDeviation(self):
        v = None
        if self.DiffFromMeanInputsUsed:
            v = self.calculateVarianceUsingSubjectAsDiffs()
        else:
            v = self.calculateVarianceUsingSubjectAsSumXs()

        stddev = math.sqrt(v)
        return stddev

    def generateThirdDefinitionOfSampleSkewness_G1(self):
        # See 2023/11/05 "Sample Skewness" in:
        #   https://en.wikipedia.org/wiki/Skewness
        b1      = self.generateNaturalEstimatorOfPopulationSkewness_b1()
        nf      = float( self.N )
        k3      = ( nf**2 ) * b1
        k2_3s2  = ( nf - 1 ) * ( nf - 2 )
        ss_G1   = k3 / k2_3s2
        return ss_G1

    def requestKurtosis(self):
        # This of course needs to be expanded to use both diffs from mean ANd sum of Xs calculation.
        kurtosis = self.calculateKurtosis_Unbiased_DiffFromMeanCalculation()
        return kurtosis

    def requestSkewness(self,formulaId=3):
        #NOTE:  There is NO POPULATION Skewness at this time.
        if self.Population:
            m = "There is no POPULATION skewness formula implemented at this time."
            raise ValueError( m )
        skewness = None
        match formulaId:
            case 1:
                skewness = self.generateNaturalEstimatorOfPopulationSkewness_b1()
            case 2:
                skewness = self.calculateNaturalEstimatorOfPopulationSkewness_g1()
            case 3:
                skewness = self.generateThirdDefinitionOfSampleSkewness_G1()
            case _:
                m = "There is no skewness formula #{formulaId} implemented at this time."
                raise ValueError( m )

        return skewness

    def setToDiffsFromMeanState(self,sumXs,nA):
        if not isinstance(sumXs,numbers.Number):
            raise ValueError
        if type(nA) != int:
            raise ValueError
        if self.N > 0:
            m = "#{self.N} values have already been added to the sums."
            m += " You must reinit the object before setting to the Diffs From Mean state."
            raise ValueError( m )
        self.DiffFromMeanInputsUsed = True
        self.N                      = nA
        self.SumOfXs                = sumXs

        self.ArithmeticMean         = ( float( sumXs ) / float( nA ) )

'''
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# VectorOfX Base Class

class VectorOfX:

    BlankFieldOnBadData     = 0
    DefaultFillOnBadData    = 1
    ExcludeRowOnBadData     = 2
    FailOnBadData           = 3
    SkipRowOnBadData        = 4
    ZeroFieldOnBadData      = 5

    def _assureSortedVectorOfX(self,forceSort=False):
        if forceSort then
            self.SortedVectorOfX = self.VectorOfX.sort
            return
        if not self.SortedVectorOfX or ( self.SortedVectorOfX.size != self.VectorOfX.size ) then
            self.SortedVectorOfX = self.VectorOfX.sort

    def __init__(aA=None):
        if aA then
            raise ValueError if not aA.is_a? Array
        # The following is ONLY for testing:
        self.SortedVectorOfX    = None
        self.VectorOfX          = Array.new  if not aA
        self.VectorOfX          = aA             if aA

    def getCount(self):
        return self.VectorOfX.size

    def getX(self,indexA,sortedVector=False):
        raise ValueError, "Index Argument Missing:  Required."       if not indexA.is_a? Integer
        raise ValueError, "Index Argument Not found in VectorOfX."   if not self.VectorOfX[indexA]
        return self.VectorOfX[indexA]   if not sortedVector
        return self.SortedVectorOfX[indexA] if sortedVector and self.SortedVectorOfX.has_key?(indexA)
        return None

    def pushX(self,xFloat,onBadData):
        raise ValueError, "Pure Virtual"

    def requestResultAACSV(self):
        raise ValueError, "Pure Virtual"

    def requestResultCSVLine(self):
        raise ValueError, "Pure Virtual"

    def requestResultJSON(self):
        raise ValueError, "Pure Virtual"

    def transformToCSVLine(self):
        b = self.VectorOfX.to_csv
        return b

    def transformToJSON(self):
        b = self.VectorOfX.to_json
        return b


#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# VectorOfContinouos for floating point based distributions.  All Xs floats.

class VectorOfContinuous(VectorOfX):

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

    @classmethod
    def newAfterInvalidatedDropped(cls,arrayA,relayErrors=False):
        raise ValueError if not arrayA.is_a? Array
        localo = self.new
        v = Array.new
        i = 0
        arrayA.each do |le|
            sle = le.strip
            next if not isUsableNumber?(sle)
            b = float( sle )
            localo.pushX(b)
            i += 1
        return localo

    def _addUpXsToSumsOfPowers(self,populationCalculation=False,sumOfDiffs=True):
        sopo    = SumsOfPowers.new(populationCalculation)
        if sumOfDiffs:
            n       = getCount
            sum     = getSum
            sopo.setToDiffsFromMeanState(sum,n)
        if sumOfDiffs:
            amean   = calculateArithmeticMean
            self.VectorOfX.each do |lx|
                diff = lx - amean
                sopo.addToSums(diff)
        else: # sum of Xs
            self.VectorOfX.each do |lx|
                sopo.addToSums(lx)
        end
        return sopo

    def _decideHistogramStartNumber(self,startNumber=None):
        startno = getMin            if not startNumber
        startno = float( startNumber )  if startNumber
        return startno

    def initialize(self,vectorX=Array.new):
        raise ValueError if not vectorX.is_a? Array
        self.InputDecimalPrecision          = 4
        self.OutputDecimalPrecision         = 4
        self.Population                     = False
        self.SOPo                           = None
        self.SortedVectorOfX                = None
        self.UseDiffFromMeanCalculations    = True
        self.ValidateStringNumbers          = False
        self.VectorOfX                      = vectorX

    def calculateArithmeticMean(self):
        nf          = float( self.VectorOfX.size )
        sumxs       = float( self.VectorOfX.sum )
        unrounded   = sumxs / nf
        rounded     = unrounded.round(self.OutputDecimalPrecision)
        return rounded

    def calculateGeometricMean(self):
        exponent    = ( 1.0 / float( self.VectorOfX.size ) )
        productxs   = self.VectorOfX.reduce(1, :*)
        unrounded   = productxs**exponent
        rounded     = unrounded.round(self.OutputDecimalPrecision)
        return rounded

    def calculateHarmonicMean(self):
        nf          = float( self.VectorOfX.size )
        sumrecips   = self.VectorOfX.inject { |sum, x| sum + 1.0 / float( x ) } 
        unrounded   = nf / sumrecips
        rounded     = unrounded.round(self.OutputDecimalPrecision)
        return rounded

    def calculateQuartile(self,qNo):
        raise ValueError if not qNo.is_a? Integer
        raise ValueError if not 0 <= qNo
        raise ValueError if not qNo < 5
        _assureSortedVectorOfX
        n                       = getCount
        nf                      = float( n )
        qindexfloat             = qNo * ( nf - 1.0 ) / 4.0
        thisquartilefraction    = qindexfloat % 1
        qvalue = None
        if thisquartilefraction % 1 == 0 then
            qi                  = int( qindexfloat )
            qvalue              = self.SortedVectorOfX[qi]
        else:
            portion0            = 1.0 - thisquartilefraction
            portion1            = 1.0 - portion0
            qi0                 = int( qindexfloat )
            qi1                 = qi0 + 1
            qvalue              = self.SortedVectorOfX[qi0] * portion0 + self.SortedVectorOfX[qi1] * portion1
        return qvalue

    def generateAverageAbsoluteDeviation(self,centralPointType=ArithmeticMeanId):
        cpf = None
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
        else:
            m = "This Average Absolute Mean formula has not implemented a statistic for central point '#{centralPointType}' at this time."
            raise ValueError, m
        nf                      = float( self.VectorOfX.size )
        sumofabsolutediffs      = 0
        self.VectorOfX.each do |lx|
            previous            = sumofabsolutediffs
            sumofabsolutediffs  += ( lx - cpf ).abs
            if previous > sumofabsolutediffs then
                # These need review.  
                raise IndexError, "previous #{previous} > sumofdiffssquared #{sumofabsolutediffs}"
        end
        unrounded               = sumofabsolutediffs / nf
        rounded                 = unrounded.round(self.OutputDecimalPrecision)
        return rounded

    def generateCoefficientOfVariation(self):
        self.SOPo       = _addUpXsToSumsOfPowers(self.Population,self.SumOfDiffs) if not self.SOPo
        amean       = self.SOPo.ArithmeticMean
        stddev      = self.SOPo.generateStandardDeviation
        unrounded   = stddev / amean
        rounded     = unrounded.round(self.OutputDecimalPrecision)
        return rounded

    def generateHistogramAAbyNumberOfSegments(self,desiredSegmentCount,startNumber=None):
        raise ValueError if not desiredSegmentCount.is_a? Integer
        if startNumber then
            raise ValueError if not startNumber.is_a? Numeric
        max             = getMax
        startno         = _decideHistogramStartNumber(startNumber)
        histo = HistogramOfX.newFromDesiredSegmentCount(startno,max,desiredSegmentCount)
        histo.validateRangesComplete
        self.VectorOfX.each do |lx|
            histo.addToCounts(lx)
        resultvectors   = histo.generateCountCollection
        return resultvectors

    def generateHistogramAAbySegmentSize(self,segmentSize,startNumber=None):
        raise ValueError if not segmentSize.is_a? Numeric
        if startNumber then
            raise ValueError if not startNumber.is_a? Numeric
        max             = getMax
        startno         = _decideHistogramStartNumber(startNumber)
        histo = HistogramOfX.newFromUniformSegmentSize(startno,max,segmentSize)
        histo.validateRangesComplete
        self.VectorOfX.each do |lx|
            histo.addToCounts(lx)
        resultvectors   = histo.generateCountCollection
        return resultvectors

    def generateMeanAbsoluteDifference(self):
        # https://en.wikipedia.org/wiki/Mean_absolute_difference
        nf                          = float( self.VectorOfX.size )
        sumofabsolutediffs          = 0.0
        self.VectorOfX.each do |lxi|
            self.VectorOfX.each do |lxj|
                sumofabsolutediffs  += ( lxi - lxj ).abs
        end
        denominator                 = nf * ( nf - 1.0 )
        unrounded                   = sumofabsolutediffs / denominator
        rounded                     = unrounded.round(self.OutputDecimalPrecision)
        return rounded

    def generateMode(self):
        lfaa            = Hash.new # Init local frequency associative array.
        self.VectorOfX.each do |lx|
            lfaa[lx]    = 1   if not lfaa.has_key?(lx)
            lfaa[lx]    += 1      if lfaa.has_key?(lx)
        x               = generateModefromFrequencyAA(lfaa)
        return x

    def getMax(self):
        _assureSortedVectorOfX
        return self.SortedVectorOfX[-1]

    def getMin(self,sVoX=None):
        _assureSortedVectorOfX
        return self.SortedVectorOfX[0]

    def getSum(self):
        sumxs = self.VectorOfX.sum
        return sumxs

    def isEvenN?(self):
        n = self.VectorOfX.size
        return True if n % 2 == 0
        return False

    def pushX(self,xFloat,onBadData=VectorOfX::FailOnBadData):
        if not isUsableNumber?(xFloat)
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
            else:
                raise ValueError, "Unimplemented onBadData value:  #{onBadData}."
        end
        validateStringNumberRange(xFloat) if self.ValidateStringNumbers
        lfn = float(xFloat)
        lrn = round(lfn,self.InputDecimalPrecision)
        self.VectorOfX.push(lrn)

    def requestExcessKurtosis(self,formulaId=3):
        if not self.UseDiffFromMeanCalculations
            raise ValueError, "May NOT be used with Sum of Xs Data."
        self.SOPo       = _addUpXsToSumsOfPowers(self.Population) if not self.SOPo
        unrounded       = None
        case formulaId
        when 2
            unrounded   = self.SOPo.calculateExcessKurtosis_2_JR_R
        when 3
            unrounded   = self.SOPo.generateExcessKurtosis_3_365datascience
        else:
            m="There is no excess kurtosis formula #{formulaId} implemented at this time."
            raise ValueError, m
        rounded         = unrounded.round(self.OutputDecimalPrecision)
        return rounded

    def requestKurtosis(self):
        self.SOPo       = _addUpXsToSumsOfPowers(self.Population) if not self.SOPo
        unrounded   = self.SOPo.requestKurtosis
        rounded     = unrounded.round(self.OutputDecimalPrecision)
        return rounded

    def requestMedian(self):
        q2 = calculateQuartile(2)
        return q2

    def requestQuartileCollection(self):
        qos0 = calculateQuartile(0)
        qos1 = calculateQuartile(1)
        qos2 = calculateQuartile(2)
        qos3 = calculateQuartile(3)
        qos4 = calculateQuartile(4)
        return [qos0,qos1,qos2,qos3,qos4]

    def requestRange(self):
        _assureSortedVectorOfX
        return self.SortedVectorOfX[0], self.SortedVectorOfX[-1]

    def requestResultAACSV(self):
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

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
    def requestResultCSVLine(self,includeHdr=False):
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
        else:
            return csvline
    end

    def requestResultJSON(self):
        scaa = requestSummaryCollection
        jsonstr = scaa.to_json
        return jsonstr

    def requestSkewness(self,formulaId=3):
        self.SOPo = _addUpXsToSumsOfPowers(self.Population) if not self.SOPo
        unrounded = self.SOPo.requestSkewness(formulaId)
        rounded = unrounded.round(self.OutputDecimalPrecision)

    def requestStandardDeviation(self):
        self.SOPo = _addUpXsToSumsOfPowers(self.Population,self.UseDiffFromMeanCalculations)
        unroundedstddev = self.SOPo.generateStandardDeviation
        if unroundedstddev == 0.0 then
            raise IndexError, "Zero Result indicates squareroot error:  #{unroundedstddev}"
        stddev = unroundedstddev.round(self.OutputDecimalPrecision)
        return stddev

    def requestSummaryCollection(self):
        #NOTE:  Some of these are ONLY for sample.  For now, this is best used ONLY for Samples.
        #self.SOPo                   = _addUpXsToSumsOfPowers(self.Population,self.UseDiffFromMeanCalculations)
        self.SOPo                   = _addUpXsToSumsOfPowers(False,self.UseDiffFromMeanCalculations)
        amean                   = calculateArithmeticMean
        ameanaad                = generateAverageAbsoluteDeviation
        coefficientofvariation  = generateCoefficientOfVariation
        gmean                   = calculateGeometricMean
        hmean                   = calculateHarmonicMean
        is_even                 = isEvenN?
        kurtosis                = "SumXsCalc Not Yet Available"
        kurtosis                = self.SOPo.requestKurtosis.round(self.OutputDecimalPrecision) if self.UseDiffFromMeanCalculations
        mad                     = generateMeanAbsoluteDifference
        median                  = requestMedian
        medianaad               = generateAverageAbsoluteDeviation(MedianId)
        min,max                 = requestRange
        mode                    = generateMode
        n                       = getCount
        skewness                = self.SOPo.requestSkewness.round(self.OutputDecimalPrecision)
        stddev                  = self.SOPo.generateStandardDeviation.round(self.OutputDecimalPrecision)
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

    def requestVarianceSumOfDifferencesFromMean(self,populationCalculation=False):
        self.SOPo = _addUpXsToSumsOfPowers(populationCalculation)
        v = self.SOPo.calculateVarianceUsingSubjectAsDiffs
        # Note rounding is not done here, as it would be double rounded with stddev.
        return v

    def requestVarianceXsSquaredMethod(self,populationCalculation=False):
        self.SOPo = _addUpXsToSumsOfPowers(populationCalculation,False)
        v = self.SOPo.calculateVarianceUsingSubjectAsSumXs
        # Note rounding is not done here, as it would be double rounded with stddev.
        return v


#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# VectorOfDiscrete - catchall for arbitrary X that could be a string.

class VectorOfDiscrete(VectorOfX):

    def initialize(self,vectorX=Array.new):
        self.FrequenciesAA          = Hash.new
        self.OutputDecimalPrecision = 4
        self.VectorOfX              = vectorX
        self.VectorOfX.each do |lx|
            self.FrequenciesAA[lx]  += 1    if self.FrequenciesAA.has_key?(lx)
            self.FrequenciesAA[lx]  = 1 if not self.FrequenciesAA.has_key?(lx)
    end

    def calculateBinomialProbability(self,subjectValue,nTrials,nSuccesses):
        #STDERR.puts "\ntrace 0 calculateBinomialProbability(#{subjectValue},#{nTrials},#{nSuccesses})"
        raise ValueError if not subjectValue
        raise ValueError if not nTrials.is_a? Integer
        raise ValueError if not nSuccesses.is_a? Integer
        n_failures          = nTrials - nSuccesses

        samplecount         = getCount
        samplecountf        = float( samplecount )

        freqcountf          = float( self.FrequenciesAA[subjectValue] )

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

    def getFrequency(self,subjectValue):
        raise ValueError if not subjectValue
        return self.FrequenciesAA[subjectValue]

    def pushX(self,xItem,onBadData=VectorOfX::FailOnBadData):
        if not xItem and "#{xItem}".size > 0
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
            else:
                raise ValueError, "Unimplemented onBadData value:  #{onBadData}."
        self.FrequenciesAA[xItem] += 1       if self.FrequenciesAA.has_key?(xItem)
        self.FrequenciesAA[xItem] = 1    if not self.FrequenciesAA.has_key?(xItem)
        self.VectorOfX.push(xItem)
        return True

    def requestMode(self):
        x = generateModefromFrequencyAA(self.FrequenciesAA)
        return x

    def requestResultAACSV(self):
        # NOTE: Mean Absolute Diffence is no longer featured here.
        mode    = requestMode
        n       = getCount
        frequencies = ""
        self.FrequenciesAA.keys.sort.each do |lfkey|
            frequencies += "\"Value: '#{lfkey}'\", \"Frequency:  #{self.FrequenciesAA[lfkey]}\"\n"
        content = <<-EOAACSV
"N", #{n}
#{frequencies}
"Mode", #{mode}
EOAACSV

    def requestResultCSVLine(self):
        raise ValueError, "Not Implemented"

    def requestResultJSON(self):
        raise ValueError, "Not Implemented"

    attr_accessor   :OutputDecimalPrecision

    attr_reader     :FrequenciesAA


#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# VectorTable for reading and processing contents of 2 dimentional matrices.

class VectorTable:

    class << self

        def arrayOfChar2VectorOfClasses(self,aA):
            oa = Hash.new
            aA.each do |lc|
                case lc
                when 'C'
                    oa.push(VectorOfContinuous)
                when 'D'
                    oa.push(VectorOfDiscrete)
                else:
                    STDERR.puts "Allowed class identifier characters are {C,D} in this context."
                    raise ValueError, "Identifier '#{lc}' is not recognized."
            end
            return oa

        def arrayOfClassLabels2VectorOfClasses(self,aA):
            oa = Array.new
            aA.each do |llabel|
                case llabel
                when /VectorOfContinuous/
                    oa.push(VectorOfContinuous)
                when /VectorOfDiscrete/
                    oa.push(VectorOfDiscrete)
                else:
                    oa = "Identifier '#{llabel}' is not recognized as a class of X in this context."
                    raise ValueError, m
            end
            return oa

        def isAllowedDataVectorClass?(self,vectorClass):
            return False    if not vectorClass.is_a? Class
            return True         if vectorClass.ancestors.include? VectorOfX
            return False

        def newFromCSV(self,vcSpec,fSpec,onBadData=VectorOfX::ExcludeRowOnBadData,seeFirstLineAsHdr=True):
            def skipIndicated(self,onBadData,ll):
                if onBadData == VectorOfX::ExcludeRowOnBadData then
                    return True if ll =~ /,,/
                return False
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
                    columns = sll.parse_csv
                    localo.pushTableRow(columns,onBadData)
                    i += 1
            return localo


    def initialize(self,vectorOfClasses):
        raise ValueError, "Argument Passed '#{vectorOfClasses.class}' NOT ARRAY" if not vectorOfClasses.is_a? Array
        self.TableOfVectors     = Array.new
        self.VectorOfClasses    = vectorOfClasses
        self.VectorOfHdrs       = Array.new
        i = 0
        self.VectorOfClasses.each do |lci|
            if lci then
                raise ValueError, "Class '#{lci.class}' Not Valid" if not self.class.isAllowedDataVectorClass?(lci)
                self.TableOfVectors[i] = lci.new        if lci
            else:
                self.TableOfVectors[i] = None        
            self.VectorOfHdrs.push("Column #{i}") # Use offset index as column numbers, NOT traditional.
            i += 1

    def eachColumnVector(self):
        self.TableOfVectors.each do |lvo|
            yield lvo

    def getColumnCount(self):
        return self.TableOfVectors.size

    def getRowCount(self,columnIndex=0):
        # As of 2023/11/14 I have put little thought into regular data, and hope simple
        # validations will keep it away for now.
        return self.TableOfVectors[columnIndex].size

    def getVectorObject(self,indexNo):
        if not 0 <= indexNo and indexNo < self.TableOfVectors.size
            raise ValueError, "Index number '#{indexNo}' provided is out of range {0,#{self.TableOfVectors.size-1}}."
        if not VectorTable.isAllowedDataVectorClass?( self.TableOfVectors[indexNo].class )
            raise ValueError, "Column #{indexNo} not configured for Data Processing."
        return self.TableOfVectors[indexNo]

    def pushTableRow(self,arrayA,onBadData=VectorOfX::DefaultFillOnBadData):
        raise ValueError if not arrayA.is_a? Array
        raise ValueError if not arrayA.size == self.TableOfVectors.size
        raise ValueError if onBadData == VectorOfX::SkipRowOnBadData
        i = 0
        self.TableOfVectors.each do |lvoe|
            if lvoe.is_a? VectorOfX then
                lvoe.pushX(arrayA[i],onBadData)
            i += 1
    end

    def useArrayForColumnIdentifiers(self,hdrColumns):
        raise ValueError if not hdrColumns.is_a? Array
        if not hdrColumns.size == self.VectorOfHdrs.size
            m = "hdr columns passed has size #{hdrColumns.size}, but requires #{self.VectorOfHdrs.size}"
            raise ValueError, m
        self.VectorOfHdrs = hdrColumns

'''

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of SamesLib_native.py

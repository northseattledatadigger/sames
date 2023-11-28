#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# SamesLib_native.py
# These activities are designed to run literally, without special optimizations,
# as much as possible like the formulations referenced in late 2023 copies of:
#   https://en.wikipedia.org/wiki/Standard_deviation
#   https://www.calculatorsoup.com/calculators/statistics/mean-median-mode.php

# NOTE:  2023/11/23 Reminded starkly of my inexperience with the None argument
# problem, which anyone with a consistent amount of tim would be intimate with.
# I commit therefore to keep an eye out for problems on this hereafter, and
# review around it at least one more time.  

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
                m = f"Range [{startNo},{stopNo}] overlaps with another range:  [{lroo.StartNo},{lroo.StopNo}]."
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
        m += f"No Frequency range found for xFloat:  '{xFloat}'."
        raise ValueError( m )

    def generateCountCollection(self):
        orderedlist = []
        for lstartno in sorted(self.FrequencyAA):
            lroo = self.FrequencyAA[lstartno]
            orderedlist.append([lstartno,lroo.StopNo,lroo.Count])
        return orderedlist

    @classmethod
    def newFromDesiredSegmentCount(cls,startNo,maxNo,desiredSegmentCount,extraMargin=None):
        if extraMargin is None:
            extraMargin = 0
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
                    m = f"Range [{lroo.StartNo},{lroo.StopNo}] "
                    m += f" starts after the minimum designated value '{self.Min}."
                    raise IndexError( m )
            else:
                if lroo.StartNo != previous_lroo.StopNo:
                    m = f"Range [{previous_lroo.StartNo},{previous_lroo.StopNo}]"
                    m += " is not adjacent to the next range "
                    m += f"[{lroo.StartNo},{lroo.StopNo}]."
                    raise IndexError( m )
            i += 1
            previous_lroo = lroo

        if self.Max > lroo.StopNo:
            m = f"Range [{lroo.StartNo},{lroo.StopNo}] "
            m += f" ends before the maximum value '{self.Max}."
            raise IndexError( m )


#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# SumsOfPowers

class SumsOfPowers:

    # NOTE:  The main merit to doing it this way is as a teaching or illustration
    # tool to show the two parallel patterns.  Probably this is not a good way
    # to implement it in most or any production situations.

    def __init__(self,populationDistribution):
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
        #print(f"trace genExcessKurtosis_2_JR_R:  {nf}, {self.SumPowerOf4}, {numerator}, {self.SumPowerOf2}, {denominator}, {ek}")
        return ek

    def generateExcessKurtosis_3_365datascience(self):
        #  https://365datascience.com/calculators/kurtosis-calculator/
        if not self.DiffFromMeanInputsUsed:
            raise ValueError( "May NOT be used with Sum of Xs Data." )

        nf                  = float( self.N )
        stddev              = self.generateStandardDeviation()
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
        #STDERR.puts "\nsue_G2              = left * middle * right: {sue_G2}              = {left} * {middle} * {right}"

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
        #STDERR.puts "trace 8 {self.class}.genVarianceUsingSubjectAsDiffs:  {v}, {nf}, {self.Population}, {self.SumPowerOf2}"
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

        #STDERR.puts "trace 8 {self.class}.genVarianceUsingSubjectAsSumXs: {v}, {nf}, {self.Population}, {self.SumPowerOf2}, {ameansquared}"
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

    def requestSkewness(self,formulaId=None):
        if formulaId is None:
            formulaId = 3
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
                m = f"There is no skewness formula {formulaId} implemented at this time."
                raise ValueError( m )

        return skewness

    def setToDiffsFromMeanState(self,sumXs,nA):
        if not isinstance(sumXs,numbers.Number):
            raise ValueError
        if type(nA) != int:
            raise ValueError
        if self.N > 0:
            m = f"{self.N} values have already been added to the sums."
            m += f" You must reinit the object before setting to the Diffs From Mean state."
            raise ValueError( m )
        self.DiffFromMeanInputsUsed = True
        self.N                      = nA
        self.SumOfXs                = sumXs

        self.ArithmeticMean         = ( float( sumXs ) / float( nA ) )

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

    def _assureSortedVectorOfX(self,forceSort):
        if forceSort:
            self.SortedVectorOfX = sorted(self.VectorOfX)
            return
        if type(self.SortedVectorOfX) is list:
            #print(f"trace x1 {self.SortedVectorOfX[0]}")
            svxl    = len(self.SortedVectorOfX)
            #print(f"trace x2 {svxl}")
            vxl     = len(self.VectorOfX)
            #print(f"trace x3 {vxl}")
            if vxl == svxl:
                return
        #print(f"trace x8")
        self.SortedVectorOfX = sorted(self.VectorOfX)
        #print(f"trace x9 {self.SortedVectorOfX}")

    def __init__(self,aA=None):
        # Each daughter must make its own constructor.
        # The following is ONLY for testing:
        if aA is not None:
            if type(aA) is list:
                self.VectorOfX  = aA
            else:
                raise(ValueError)
        else:
            self.VectorOfX      = []
        self.SortedVectorOfX    = None

    def getCount(self):
        l = len(self.VectorOfX)
        return l

    def getX(self,indexA,sortedVector=None):
        if type(indexA) != int:
            raise ValueError("Index Argument Missing:  Required.")     
        if not self.VectorOfX[indexA]:
            raise ValueError("Index Argument Not found in VectorOfX.") 
        if sortedVector and self.SortedVectorOfX[indexA]:
            self._assureSortedVectorOfX(False) # in case update occurred from pushX.
            return self.SortedVectorOfX[indexA]                       
        else:
            return self.VectorOfX[indexA]

    def pushX(self,xFloat,onBadData):
        raise ValueError( "Pure Virtual" )

    def requestResultAACSV(self):
        raise ValueError( "Pure Virtual" )

    def requestResultCSVLine(self):
        raise ValueError( "Pure Virtual" )

    def requestResultJSON(self):
        raise ValueError( "Pure Virtual" )

    def transformToCSVLine(self):
        b = ""
        for lx in self.VectorOfX:
            if len(b) > 0:
                b += ","
            if isinstance(lx,str):
                b += f"\"{lx}\""
            else:
                b += str(lx)
        return b

    def transformToJSON(self):
        b = json.dumps(self.VectorOfX)
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

    def __init__(self,vectorX=None):
        if vectorX is None: # embedding the assignment in the argument definition yields a bug. 20231122xc
            self.VectorOfX          = []
        elif type(vectorX) is list:
            self.VectorOfX          = vectorX
        else:
            raise ValueError
        #print(f"trace 3 VectorOfContinuous constructor:  {vectorX},{self.VectorOfX}")
        self.InputDecimalPrecision          = 4
        self.OutputDecimalPrecision         = 4
        self.Population                     = False
        self.SOPo                           = None
        self.SortedVectorOfX                = None
        self.UseDiffFromMeanCalculations    = True
        self.ValidateStringNumbers          = False

    def _addUpXsToSumsOfPowers(self,populationCalculation,sumOfDiffs=None):
        if sumOfDiffs is None:
            sumOfDiffs = True
        sopo    = SumsOfPowers(populationCalculation)
        if sumOfDiffs:
            n       = self.getCount()
            sumxs   = self.getSum()
            sopo.setToDiffsFromMeanState(sumxs,n)
        if sumOfDiffs:
            amean   = self.calculateArithmeticMean()
            for lx in self.VectorOfX:
                diff = lx - amean
                sopo.addToSums(diff)
        else: # sum of Xs
            for lx in self.VectorOfX:
                sopo.addToSums(lx)
        return sopo

    def _decideHistogramStartNumber(self,startNumber):
        startno = None
        if startNumber is not None:
            startno = float( startNumber )
        else:
            startno = self.getMin()
        return startno

    def calculateArithmeticMean(self):
        n           = self.getCount()
        nf          = float( n )
        sumxs       = self.getSum()
        unrounded   = sumxs / nf
        rounded     = round(unrounded,self.OutputDecimalPrecision)
        return rounded

    def calculateGeometricMean(self):
        n               = self.getCount()
        exponent        = ( 1.0 / float( n ) )
        productxs       = 1.0
        for lx in self.VectorOfX:
            productxs   *= lx
        unrounded       = productxs**exponent
        rounded         = round(unrounded,self.OutputDecimalPrecision)
        return rounded

    def calculateHarmonicMean(self):
        #print(f"trace 0 calculateHarmonicMean: {self.getCount()}")
        n               = self.getCount()
        nf              = float( n )
        sumrecips       = 0.0
        i = 0
        for lx in self.VectorOfX:
            if lx == 0:
                raise ZeroDivisionError
            sumrecips   += 1.0 / lx
            i += 1
        unrounded       = nf / sumrecips
        rounded         = round(unrounded,self.OutputDecimalPrecision)
        return rounded

    def calculateQuartile(self,qNo):
        if type(qNo) != int:
            raise ValueError
        if qNo < 0:
            raise ValueError
        if 5 <= qNo:
            raise ValueError
        self._assureSortedVectorOfX(False)
        n                       = self.getCount()
        nf                      = float( n )
        qindexfloat             = qNo * ( nf - 1.0 ) / 4.0
        thisquartilefraction    = qindexfloat % 1
        qvalue = None
        if thisquartilefraction % 1 == 0:
            qi                  = int( qindexfloat )
            qvalue              = self.SortedVectorOfX[qi]
        else:
            portion0            = 1.0 - thisquartilefraction
            portion1            = 1.0 - portion0
            qi0                 = int( qindexfloat )
            qi1                 = qi0 + 1
            qvalue              = self.SortedVectorOfX[qi0] * portion0 + self.SortedVectorOfX[qi1] * portion1
        return qvalue

    def generateAverageAbsoluteDeviation(self,centralPointType=None):
        if centralPointType is None:
            centralPointType    = VectorOfContinuous.ArithmeticMeanId

        cpf = None
        match centralPointType:
            case VectorOfContinuous.ArithmeticMeanId:
                cpf = self.calculateArithmeticMean()
            case VectorOfContinuous.GeometricMeanId:
                cpf = self.calculateGeometricMean()
            case VectorOfContinuous.HarmonicMeanId:
                cpf = self.calculateHarmonicMean()
            case VectorOfContinuous.MaxId:
                cpf = self.getMax()
            case VectorOfContinuous.MedianId:
                cpf = self.requestMedian()
            case VectorOfContinuous.MinId:
                cpf = self.generateMode()
            case VectorOfContinuous.ModeId:
                cpf = self.getMax()
            case _:
                m = f"This Average Absolute Mean formula has not implemented a statistic for central point '{centralPointType}' at this time."
                raise ValueError( m )
        n                       = len( self.VectorOfX )
        nf                      = float( n )
        sumofabsolutediffs      = 0
        for lx in self.VectorOfX:
            previous            = sumofabsolutediffs
            sumofabsolutediffs  += abs( lx - cpf )
            if previous > sumofabsolutediffs:
                # These need review.  
                raise IndexError( f"previous {previous} > sumofdiffssquared {sumofabsolutediffs}" )
        unrounded               = sumofabsolutediffs / nf
        rounded                 = round(unrounded,self.OutputDecimalPrecision)
        return rounded

    def generateCoefficientOfVariation(self):
        if not self.SOPo:
            self.SOPo   = _addUpXsToSumsOfPowers(self.Population,self.SumOfDiffs)
        amean           = self.SOPo.ArithmeticMean
        stddev          = self.SOPo.generateStandardDeviation()
        unrounded       = stddev / amean
        rounded         = round(unrounded,self.OutputDecimalPrecision)
        return rounded

    def generateHistogramAAbyNumberOfSegments(self,desiredSegmentCount,startNumber=None):
        if type(desiredSegmentCount) != int:
            raise ValueError
        if startNumber:
            if not isinstance(startNumber,numbers.Number):
                raise ValueError
        maxx            = self.getMax()
        startno         = self._decideHistogramStartNumber(startNumber)
        histo           = HistogramOfX.newFromDesiredSegmentCount(startno,maxx,desiredSegmentCount)
        histo.validateRangesComplete()
        for lx in self.VectorOfX:
            histo.addToCounts(lx)
        resultvectors   = histo.generateCountCollection()
        return resultvectors

    def generateHistogramAAbySegmentSize(self,segmentSize,startNumber):
        if not isinstance(segmentSize,numbers.Number):
            raise ValueError
        if startNumber:
            if not isinstance(startNumber,numbers.Number):
                raise ValueError
        maxx            = self.getMax()
        startno         = self._decideHistogramStartNumber(startNumber)
        histo           = HistogramOfX.newFromUniformSegmentSize(startno,maxx,segmentSize)
        histo.validateRangesComplete()
        for lx in self.VectorOfX:
            histo.addToCounts(lx)
        resultvectors   = histo.generateCountCollection()
        return resultvectors

    def generateMeanAbsoluteDifference(self):
        # https://en.wikipedia.org/wiki/Mean_absolute_difference
        n                           = self.getCount()
        nf                          = float( n )
        sumofabsolutediffs          = 0.0
        for lxi in self.VectorOfX:
            for lxj in self.VectorOfX:
                sumofabsolutediffs  += abs( lxi - lxj )

        denominator                 = nf * ( nf - 1.0 )
        unrounded                   = sumofabsolutediffs / denominator
        rounded                     = round(unrounded,self.OutputDecimalPrecision)
        return rounded

    def generateMode(self):
        lfaa                = {} # Init local frequency associative array.
        for lx in self.VectorOfX:
            if lx in lfaa:
                lfaa[lx]    += 1
            else:
                lfaa[lx]    = 1
        x                   = generateModefromFrequencyAA(lfaa)
        return x

    def getMax(self):
        self._assureSortedVectorOfX(False)
        return self.SortedVectorOfX[-1]

    def getMin(self):
        self._assureSortedVectorOfX(False)
        return self.SortedVectorOfX[0]

    def getSum(self):
        unrounded   = sum(self.VectorOfX)
        rounded     = round(unrounded,self.OutputDecimalPrecision)
        return rounded

    def isEvenN(self):
        n = self.getCount()
        if n % 2 == 0:
            return True
        return False

    @classmethod
    def newAfterInvalidatedDropped(cls,arrayA,relayErrors):
        localo = cls()
        if not type(arrayA) is list:
            raise ValueError
        v = []
        i = 0
        for le in arrayA:
            sle = le
            if isinstance(le,str):
                sle = le.strip()
            if not isUsableNumber(sle):
                continue
            b = float( sle )
            count = localo.getCount()
            localo.pushX(b)
            i += 1
            count = localo.getCount()
        return localo

    def pushX(self,xFloat,onBadData=None):
        if onBadData is None:
            onBadData = VectorOfX.FailOnBadData
        if not isUsableNumber(xFloat):
            match onBadData:
                case VectorOfX.BlankFieldOnBadData:
                    raise ValueError( "May Not Blank Fields" )
                case VectorOfX.DefaultFillOnBadData:
                    xFloat=0.0
                case VectorOfX.FailOnBadData:
                    raise ValueError( "{xFloat} not usable number." )
                case VectorOfX.SkipRowOnBadData:
                    return
                case VectorOfX.ZeroFieldOnBadData:
                    xFloat=0.0
                case _:
                    raise ValueError( "Unimplemented onBadData value:  {onBadData}." )
        if self.ValidateStringNumbers:
            self.validateStringNumberRange(xFloat)
        lfn = float(xFloat)
        lrn = round(lfn,self.InputDecimalPrecision)
        #print(f"trace 8 voco.pushX:  {xFloat},{lfn},{lrn},{self.getCount()}")
        self.VectorOfX.append(lrn)

    def requestExcessKurtosis(self,formulaId):
        if not self.UseDiffFromMeanCalculations:
            raise ValueError( "May NOT be used with Sum of Xs Data." )
        if not self.SOPo:
            self.SOPo   = self._addUpXsToSumsOfPowers(self.Population,True)
        unrounded       = None
        match formulaId:
            case 2:
                unrounded   = self.SOPo.calculateExcessKurtosis_2_JR_R()
            case 3:
                unrounded   = self.SOPo.generateExcessKurtosis_3_365datascience()
            case _:
                m="There is no excess kurtosis formula {formulaId} implemented at this time."
                raise ValueError( m )

        rounded         = round(unrounded,self.OutputDecimalPrecision)
        return rounded

    def requestKurtosis(self):
        if not self.SOPo:
            self.SOPo   = self._addUpXsToSumsOfPowers(self.Population)
        unrounded       = self.SOPo.requestKurtosis()
        rounded         = round(unrounded,self.OutputDecimalPrecision)
        return rounded

    def requestMedian(self):
        q2 = self.calculateQuartile(2)
        return q2

    def requestQuartileCollection(self):
        qos0 = self.calculateQuartile(0)
        qos1 = self.calculateQuartile(1)
        qos2 = self.calculateQuartile(2)
        qos3 = self.calculateQuartile(3)
        qos4 = self.calculateQuartile(4)
        return [qos0,qos1,qos2,qos3,qos4]

    def requestRange(self):
        self._assureSortedVectorOfX(False)
        return self.SortedVectorOfX[0], self.SortedVectorOfX[-1]

    def requestResultAACSV(self):
        # NOTE: Mean Absolute Diffence is no longer featured here.
        scaa = self.requestSummaryCollection()
        content =   ""
        content +=  f"\"{VectorOfContinuous.ArithmeticMeanId}\", {scaa[VectorOfContinuous.ArithmeticMeanId]}\n"
        content +=  f"\"{VectorOfContinuous.ArMeanAADId}\", {scaa[VectorOfContinuous.ArMeanAADId]}\n"
        content +=  f"\"{VectorOfContinuous.CoefficientOfVariationId}\", {scaa[VectorOfContinuous.CoefficientOfVariationId]}\n"
        content +=  f"\"{VectorOfContinuous.GeometricMeanId}\", {scaa[VectorOfContinuous.GeometricMeanId]}\n"
        content +=  f"\"{VectorOfContinuous.HarmonicMeanId}\", {scaa[VectorOfContinuous.HarmonicMeanId]}\n"
        content +=  f"\"{VectorOfContinuous.IsEvenId}\", {scaa[VectorOfContinuous.IsEvenId]}\n"
        content +=  f"\"{VectorOfContinuous.KurtosisId}\", {scaa[VectorOfContinuous.KurtosisId]}\n"
        content +=  f"\"{VectorOfContinuous.MaxId}\", {scaa[VectorOfContinuous.MaxId]}\n"
        content +=  f"\"{VectorOfContinuous.MedianId}\", {scaa[VectorOfContinuous.MedianId]}\n"
        content +=  f"\"{VectorOfContinuous.MedianAADId}\", {scaa[VectorOfContinuous.MedianAADId]}\n"
        content +=  f"\"{VectorOfContinuous.MinId}\", {scaa[VectorOfContinuous.MinId]}\n"
        content +=  f"\"{VectorOfContinuous.ModeId}\", {scaa[VectorOfContinuous.ModeId]}\n"
        content +=  f"\"{VectorOfContinuous.NId}\", {scaa[VectorOfContinuous.NId]}\n"
        content +=  f"\"{VectorOfContinuous.SkewnessId}\", {scaa[VectorOfContinuous.SkewnessId]}\n"
        content +=  f"\"{VectorOfContinuous.StandardDeviation}\", {scaa[VectorOfContinuous.StandardDeviation]}\n"
        content +=  f"\"{VectorOfContinuous.SumId}\", {scaa[VectorOfContinuous.SumId]}\n"
        return content

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
    def requestResultCSVLine(self,includeHdr=None):
        # NOTE: Mean Absolute Diffence is no longer featured here.
        scaa        = self.requestSummaryCollection()
        csvline     =   f"\"{scaa[VectorOfContinuous.ArithmeticMeanId]}\",\"{scaa[VectorOfContinuous.ArMeanAADId]}\","
        csvline     +=  f"\"{scaa[VectorOfContinuous.CoefficientOfVariationId]}\","
        csvline     +=  f"\"{scaa[VectorOfContinuous.GeometricMeanId]}\",\"{scaa[VectorOfContinuous.HarmonicMeanId]}\","
        csvline     +=  f"\"{scaa[VectorOfContinuous.IsEvenId]}\",\"{scaa[VectorOfContinuous.KurtosisId]}\","
        csvline     +=  f"\"{scaa[VectorOfContinuous.MaxId]}\",\"{scaa[VectorOfContinuous.MedianId]}\",\"{scaa[VectorOfContinuous.MedianAADId]}\","
        csvline     +=  f"\"{scaa[VectorOfContinuous.MinId]}\",\"{scaa[VectorOfContinuous.ModeId]}\",\"{scaa[VectorOfContinuous.NId]}\","
        csvline     +=  f"\"{scaa[VectorOfContinuous.SkewnessId]}\",\"{scaa[VectorOfContinuous.StandardDeviation]}\","
        csvline     +=  f"\"{scaa[VectorOfContinuous.SumId]}\""
        if includeHdr:
            csvhdr  =   f"\"{ArithmeticMeanId}\",\"{ArMeanAADId}\","
            csvhdr  +=  f"\"{CoefficientOfVariationId}\",\"{GeometricMeanId}\","
            csvhdr  +=  f"\"{HarmonicMeanId}\",\"{IsEvenId}\",\"{KurtosisId}\","
            csvhdr  +=  f"\"{MaxId}\",\"{MedianId}\",\"{MedianAADId}\",\"{MinId}\",\"{ModeId}\","
            csvhdr  +=  f"\"{NId}\",\"{SkewnessId}\",\"{StandardDeviation}\",\"{SumId}\""
            return f"{csvhdr}\n{csvline}\n"
        else:
            return csvline

    def requestResultJSON(self):
        scaa    = self.requestSummaryCollection()
        jsonstr = json.dumps(self.VectorOfX)
        return jsonstr

    def requestSkewness(self,formulaId=None):
        if formulaId is None:
            formulaId = 3
        if not self.SOPo:
            self.SOPo   = self._addUpXsToSumsOfPowers(self.Population,True)
        unrounded       = self.SOPo.requestSkewness(formulaId)
        rounded         = round(unrounded,self.OutputDecimalPrecision)
        return rounded

    def requestStandardDeviation(self):
        if not self.SOPo:
            self.SOPo   = self._addUpXsToSumsOfPowers(self.Population,self.UseDiffFromMeanCalculations)
        unroundedstddev = self.SOPo.generateStandardDeviation()
        if unroundedstddev == 0.0:
            raise IndexError( "Zero Result indicates squareroot error:  {unroundedstddev}" )
        stddev = round(unroundedstddev,self.OutputDecimalPrecision)
        return stddev

    def requestSummaryCollection(self):
        #NOTE:  Some of these are ONLY for sample.  For now, this is best used ONLY for Samples.
        #self.SOPo               = self._addUpXsToSumsOfPowers(self.Population,self.UseDiffFromMeanCalculations)
        self.SOPo               = self._addUpXsToSumsOfPowers(False,self.UseDiffFromMeanCalculations)
        amean                   = self.calculateArithmeticMean()
        ameanaad                = self.generateAverageAbsoluteDeviation()
        coefficientofvariation  = self.generateCoefficientOfVariation()
        gmean                   = self.calculateGeometricMean()
        hmean                   = self.calculateHarmonicMean()
        is_even                 = self.isEvenN()
        kurtosis                = "SumXsCalc Not Yet Available"
        if self.UseDiffFromMeanCalculations:
            unrounded           = self.SOPo.requestKurtosis()
            kurtosis            = round(unrounded,self.OutputDecimalPrecision)
        mad                     = self.generateMeanAbsoluteDifference()
        median                  = self.requestMedian()
        medianaad               = self.generateAverageAbsoluteDeviation(VectorOfContinuous.MedianId)
        xmin,xmax               = self.requestRange()
        mode                    = self.generateMode()
        n                       = self.getCount()
        unrounded               = self.SOPo.requestSkewness(3)
        skewness                = round(unrounded,self.OutputDecimalPrecision)
        unrounded               = self.SOPo.generateStandardDeviation()
        stddev                  = round(unrounded,self.OutputDecimalPrecision)
        xsum                    = self.getSum()
        return {
            VectorOfContinuous.ArithmeticMeanId:           amean,
            VectorOfContinuous.ArMeanAADId:                ameanaad,
            VectorOfContinuous.CoefficientOfVariationId:   coefficientofvariation,
            VectorOfContinuous.GeometricMeanId:            gmean,
            VectorOfContinuous.HarmonicMeanId:             hmean,
            VectorOfContinuous.IsEvenId:                   is_even,
            VectorOfContinuous.KurtosisId:                 kurtosis,
            VectorOfContinuous.MADId:                      mad,
            VectorOfContinuous.MaxId:                      xmax,
            VectorOfContinuous.MedianId:                   median,
            VectorOfContinuous.MedianAADId:                medianaad,
            VectorOfContinuous.MinId:                      xmin,
            VectorOfContinuous.ModeId:                     mode,
            VectorOfContinuous.NId:                        n,
            VectorOfContinuous.SkewnessId:                 skewness,
            VectorOfContinuous.StandardDeviation:          stddev,   
            VectorOfContinuous.SumId:                      xsum
        }

    def requestVarianceSumOfDifferencesFromMean(self,populationCalculation=None):
        if populationCalculation is None:
            populationCalculation = False
        self.SOPo = self._addUpXsToSumsOfPowers(populationCalculation)
        v = self.SOPo.calculateVarianceUsingSubjectAsDiffs()
        # Note rounding is not done here, as it would be double rounded with stddev.
        return v

    def requestVarianceXsSquaredMethod(self,populationCalculation=None):
        if populationCalculation is None:
            populationCalculation = False
        self.SOPo = self._addUpXsToSumsOfPowers(populationCalculation,False)
        v = self.SOPo.calculateVarianceUsingSubjectAsSumXs()
        # Note rounding is not done here, as it would be double rounded with stddev.
        return v


#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# VectorOfDiscrete - catchall for arbitrary X that could be a string.

class VectorOfDiscrete(VectorOfX):

    def __init__(self,vectorX=None):
        if vectorX is None: # embedding the assignment in the argument definition yields a bug. 20231122xc
            self.VectorOfX          = []
        elif type(vectorX) is list:
            self.VectorOfX          = vectorX
        else:
            raise ValueError
        self.FrequenciesAA          = {}
        self.OutputDecimalPrecision = 4.0
        for lx in self.VectorOfX:
            if lx in self.FrequenciesAA:
                self.FrequenciesAA[lx]  += 1   
            else:
                self.FrequenciesAA[lx]  = 1

    def calculateBinomialProbability(self,subjectValue,nTrials,nSuccesses):
        #STDERR.puts "\ntrace 0 calculateBinomialProbability({subjectValue},{nTrials},{nSuccesses})"
        if not subjectValue: # Re-assess this later, for here and Ruby.
            raise ValueError
        if type(nTrials) != int:
            raise ValueError
        if type(nSuccesses) != int:
            raise ValueError
        n_failures          = nTrials - nSuccesses

        samplecount         = self.getCount()
        samplecountf        = float( samplecount )

        freqcountf          = float( self.FrequenciesAA[subjectValue] )

        psuccess1trial      = freqcountf / samplecountf # Probability of success in 1 trial.

        pfailure1trial      = 1.0 - psuccess1trial
        #STDERR.puts "\ntrace 5 calculateBinomialProbability {samplecountf},{freqcountf},{psuccess1trial},{pfailure1trial}"

        pfailurefactor      = pfailure1trial**n_failures
        psuccessfactor      = psuccess1trial**nSuccesses
        #STDERR.puts "\ntrace 6 calculateBinomialProbability {pfailurefactor},{psuccessfactor}"

        successpermutations = math.factorial(nSuccesses)
        failurepermutations = math.factorial(nTrials - nSuccesses)
        trials_permutations = math.factorial(nTrials)
        #print(f"\ntrace 7 calculateBinomialProbability {successpermutations},{failurepermutations},{trials_permutations}")
        numerator           = float( trials_permutations * psuccessfactor * pfailurefactor )
        denominator         = float( successpermutations * failurepermutations )
        result              = numerator / denominator
        return result

    def getFrequency(self,subjectValue):
        if not subjectValue:
            raise ValueError
        return self.FrequenciesAA[subjectValue]

    def pushX(self,xItem,onBadData=None):
        if onBadData is None:
            onBadData = VectorOfX.FailOnBadData
        if not xItem and len(f"{xItem}") > 0:
            match onBadData:
                case VectorOfX.BlankFieldOnBadData:
                    xItem=" "
                case VectorOfX.DefaultFillOnBadData:
                    xFloat=" "
                case VectorOfX.FailOnBadData:
                    raise ValueError( f"{xItem} not usable value." )
                case VectorOfX.SkipRowOnBadData:
                    return
                case VectorOfX.ZeroFieldOnBadData:
                    xItem=0.0
                case _:
                    raise ValueError( f"Unimplemented onBadData value:  {onBadData}." )

        if xItem in self.FrequenciesAA:
            self.FrequenciesAA[xItem] += 1
        else:
            self.FrequenciesAA[xItem] = 1
        #print(f"trace 7 voco.pushX:  {xItem},{self.getCount()}")
        self.VectorOfX.append(xItem)
        #print(f"trace 8 voco.pushX:  {xItem},{self.getCount()}")
        return True

    def requestMode(self):
        x = generateModefromFrequencyAA(self.FrequenciesAA)
        return x

    def requestResultAACSV(self):
        # NOTE: Mean Absolute Diffence is no longer featured here.
        mode    = self.requestMode()
        n       = self.getCount()
        content = f"\"N\", {n}\n"
        for lfkey in sorted(self.FrequenciesAA):
            content += f"\"Value: '{lfkey}'\", \"Frequency:  {self.FrequenciesAA[lfkey]}\"\n"
        content += f"\"Mode\", {mode}"
        return content

    def requestResultCSVLine(self):
        raise ValueError( "Not Implemented" )

    def requestResultJSON(self):
        raise ValueError( "Not Implemented" )


#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# VectorTable for reading and processing contents of 2 dimentional matrices.
# NOTE:  Indexing for columns and vectors in this class are reversed from normal
# in accommodation of the way things are used.

class VectorTable:

    @classmethod
    def _skipIndicated(cls,onBadData,ll):
        if onBadData == VectorOfX.ExcludeRowOnBadData:
            if ( re.search(r',,',ll) ):
                return True
        return False

    @classmethod
    def arrayOfChar2VectorOfClasses(cls,aA):
        oa = []
        for lc in aA:
            match lc:
                case 'C':
                    oa.append(VectorOfContinuous)
                case 'D':
                    oa.append(VectorOfDiscrete)
                case _:
                    m = "Allowed class identifier characters are {C,D} in this context."
                    m +=  f"\nIdentifier '{lc}' is not recognized."
                    raise ValueError( m )

        return oa

    @classmethod
    def arrayOfClassLabels2VectorOfClasses(cls,aA):
        oa = []
        for llabel in aA:
            llas = llabel.strip()
            match llas:
                case 'VectorOfContinuous':
                    oa.append(VectorOfContinuous)
                case 'VectorOfDiscrete':
                    oa.append(VectorOfDiscrete)
                case _:
                    m = f"Identifier '{llas}' is not recognized as a class of X in this context."
                    raise ValueError( m )

        return oa

    @classmethod
    def isAllowedDataVectorClass(cls,vectorClass):
        if issubclass( vectorClass, VectorOfX ):
            return True
        return False

    @classmethod
    def newFromCSV(cls,vcSpec,fSpec,onBadData=None,seeFirstLineAsHdr=None):
        if onBadData is None:
            onBadData   = VectorOfX.ExcludeRowOnBadData
        if seeFirstLineAsHdr is None:
            seeFirstLineAsHdr = True
        localo = cls(vcSpec)
        with open(fSpec) as fp:
            i = 0
            for ll in fp:
                if cls._skipIndicated(onBadData,ll):
                    continue
                sll = ll.strip()
                if i == 0:
                    if seeFirstLineAsHdr:
                        hdrcolumns = list(csv.reader([sll]))[0]
                        localo.useArrayForColumnIdentifiers(hdrcolumns)
                        i += 1
                        continue
                columns = list(csv.reader([sll]))[0] # More evidence that python is a programming sewer.
                localo.pushTableRow(columns,onBadData)
                i += 1
        return localo


    def __init__(self,vectorOfClasses):
        if not type(vectorOfClasses) is list:
            raise ValueError( f"Argument Passed '{vectorOfClasses.__class__}' NOT ARRAY" )
        self.TableOfVectors     = []
        self.VectorOfClasses    = vectorOfClasses
        self.VectorOfHdrs       = []
        i = 0
        for lci in self.VectorOfClasses:
            if lci is not None:
                if not self.__class__.isAllowedDataVectorClass(lci):
                    raise ValueError( f"Class '{lci.__class__}' Not Valid" )
                b = lci()
                self.TableOfVectors.append(b)
            else:
                self.TableOfVectors.append(None)
            self.VectorOfHdrs.append(f"Column {i}") # Use offset index as column numbers, NOT traditional.
            i += 1

    def getColumnCount(self):
        ccount = len( self.TableOfVectors )
        return ccount

    def getRowCount(self,columnIndex):
        # As of 2023/11/14 I have put little thought into regular data, and hope simple
        # validations will keep it away for now.
        rcount = len( self.TableOfVectors[columnIndex] )
        return rcount

    def getVectorObject(self,indexNo):
        ccount = self.getColumnCount()
        if not 0 <= indexNo and indexNo < ccount:
            raise ValueError( f"Index number '{indexNo}' provided is out of range {0,{self.TableOfVectors.size-1}}." )
        if not VectorTable.isAllowedDataVectorClass( self.TableOfVectors[indexNo].__class__ ):
            raise ValueError( f"Column {indexNo} not configured for Data Processing." )
        return self.TableOfVectors[indexNo]

    def pushTableRow(self,arrayA,onBadData=None):
        if onBadData is None:
            onBadData   = VectorOfX.DefaultFillOnBadData

        if not type(arrayA) is list:
            raise ValueError
        laa = len(arrayA)
        lcc = self.getColumnCount()
        if laa != lcc:
            raise ValueError
        if onBadData == VectorOfX.SkipRowOnBadData:
            raise ValueError
        i = 0
        for lvoe in self.TableOfVectors:
            if ( isinstance(lvoe,VectorOfX) ):
                lvoe.pushX(arrayA[i],onBadData)
            i += 1

    def useArrayForColumnIdentifiers(self,hdrColumns):
        if not type(hdrColumns) is list:
            raise ValueError
        lhc = len(hdrColumns)
        lcc = self.getColumnCount()
        if lhc != lcc:
            m = f"hdr columns passed has size {hdrColumns.size}, but requires {self.VectorOfHdrs.size}"
            raise ValueError( m )
        self.VectorOfHdrs = hdrColumns

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of SamesLib_native.py

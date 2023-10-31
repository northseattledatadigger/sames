#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# WPMS2023.py - Initial prototype was  WPMS2023.rb.  See that file for full
#History.  The other language implementations will tend to stay behind that one.
#For instance, as I am having trouble with mode and quartiles in the Ruby
#verison, I will leave them out of this one for now.
#
#2345678901234567890123456789012345678901234567890123456789012345678901234567890

import csv
import re

#2345678901234567890123456789012345678901234567890123456789012345678901234567890

def isANumStr(strA):
    # TBR:  Looking for less ugly Python3 construct here, but still simple and
    # clear like in Ruby:
    if ( not isinstance(stra,str) ): 
        return False
    if ( not re.search(r'^-?\d*\.?\d+$/',strA) ):
        return False
    return True

def isNumericVector(vA):
    if ( any(isinstance(lve,Numbers.number) for lve in vA) ):
        return True
    return False

def isUsableNumber(cA):
    if ( isinstance(cA,Numbers.number) ):
        return True
    if ( isANumStr(cA) ):
        return True
    return False

def isUsableNumberVector(vA):
    if ( all(isUsableNumber(lve) for lve in vA) ):
        return True
    return False

class VectorOfX(object):

    def __init__(vectorX=[]):
        if vectorX is None:
            self.VectorOfX = []
        else:
            self.VectorOfX = vectorX

    def genCount():
        n = self.VectorOfX.size
        return n

class VectorOfContinuous(VectorOfX):

    @classmethod
    def newAfterValidation(arrayA):
        v = Array.new
        for le in arrayA:
            if not isUsableNumber(le):
                m = f"Element '{le}' should be number, this form not usable."
                raise ValueError(m)
            v.push(float(le))
        localo = self.new(v)
        return localo

    @classmethod
    def newAfterInvalidatedDropped(arrayA):
        v = Array.new
        for le in arrayA:
            if not isUsableNumber(le):
                continue
            v.push(float(le))
        localo = self.new(v)
        return localo

    def __init__(vectorX):
        super().__init__(vectorX)
        self.UseSumOfXs = False

    def assureXsPrecision(precisionSpec):
        raise ValueError("Not Yet Implemented.")

    def genInterQuartileRange():
        n = self.VectorOfX.size
                                # Subtract one here
                                # to get the offset.
        q1os    = 1                 - 1
        q2os    = ( n + 1 ) / 4     - 1
        q3os    = ( n / 2 )         - 1
        q4os    = 3 * ( q2os + 1 )  - 1
        qendos  = n                 - 1
        return q1os,  q2os,  q3os,  q4os,  qendos

    def genMax():
        svox = self.VectorOfX.sort
        return svox[-1]

    def genMean():
        n = self.VectorOfX.size.to_f
        sumxs = self.VectorOfX.sum.to_f
        return ( sumxs / n ).round(4)

    def genMeanStdDev():
        variance = nil
        if this.UseSumOfXs:
            variance = genVarianceXsSquaredMethod
        else:
            variance = genVarianceSumOfDifferencesFromMean
        stddev = Math.sqrt(variance).round(4)

    def genMedian():
        n = self.VectorOfX.size
        svox = self.VectorOfX.sort
        if ( n % 2 == 0 ):
            nm2 = ( n + 1 ) / 2
            return svox[nm2]
        else:
            nm2a = n / 2
            x1 = svox[nm2a]
            nm2b = nm2a + 1
            x2 = svox[nm2b]
            x3 = ( x1 + x2 ).to_f / 2.0
            return x3.round(4)

    def genMin():
        svox = self.VectorOfX.sort
        return svox[0]

    def genMinMax():
        svox = self.VectorOfX.sort
        return svox[0], svox[-1]

    def genMode():
        h = Hash.new
        for lx in self.VectorOfX:
            if lx in h:
                h[lx] += 1
            else:
                h[lx] = 1
        x = 0
        m = 0
        for lx in h:
            if h[lx] > m:
                x = lx
                m = h[lx]
        return x

    def genNIsEven():
        n = self.VectorOfX.size
        if ( n % 2 ) == 0:
            return True
        return False

    def genOutliers(stdDev,numberOfStdDevs=1):
        raise ValueError("Not Yet Implemented.")

    def genQuartiles():
        qos0, qos1, qos2, qos3, qos4, qose = genInterQuartileRange
        svox = self.VectorOfX.sort
        return svox[qos0], svox[qos2], svox[qos3], svox[qos4], svox[qos3]

    def genRange():
        nm1 = self.VectorOfX.size - 1
        svox = self.VectorOfX.sort
        return svox[0], svox[nm1]

    def genSum():
        sumxs = sum(self.VectorOfX)
        return sumxs

    def genVarianceSumOfDifferencesFromMean():
        mu = genMean
        n = self.VectorOfX.size
        sumofdiffsquared = 0
        for lx in self.VectorOfX:
            xlessmu = lx - mu
            sumofdiffsquared += ( xlessmu * xlessmu )
        v = sumofdiffsquared / ( n - 1 )
        return v

    def genVarianceXsSquaredMethod():
        mu = genMean
        n = self.VectorOfX.size
        sumxssquared = 0
        for lx in self.VectorOfX:
            sumxssquared += lx * lx
        v = ( sumxssquared - ( mu * mu ) ) / ( n - 1 )
        return v

    def pushX(xFloat):
        if not isUsableNumber(xFloat):
            raise ValueError
        lfn = xFloat.to_f
        self.VectorOfX.push(lfn)

    def pushX(xFloat):
        if ( not isNumber(xFloat) ):
            raise ValueError
        self.VectorOfX.push(xFloat)


class VectorOfDiscrete(VectorOfX):
    # TBD for use with columns having discrete values.

    def __init__(vectorX):
        super().__init__(vectorX)
        self.UseSumOfXs = False


class VectorTable(object):

    @classmethod
    def isAllowedDataVectorClass(vectorClass):
        if issubclass(vectorClass, Vecto):
            return True
        return False

    @classmethod
    def newFromCSV(fSpec,vcSpec,skipFirstLine=None):
        if skipFirstLine is None:
            skipFirstLine = true
            
        localo = self.new(vcSpec)
        with open(fSpec) as fp:
            i = 0
            for ll in fp:
                sll = ll.strip
                if not ( i == 0 and skipFirstLine ):
                    columns = sll.parse_csv
                    localo.pushTableRow(columns)
                i += 1
        return localo


    def __init__(vectorOfClasses):
        if not type(vectorOfClasses) is list:
            raise ValueError
        this.TableOfVectors     = Array.new
        this.VectorOfClasses    = vectorOfClasses
        for i, v in enumerate(this.VectorOfClasses):
            if lci:
                if not isAllowedDataVectorClass(lci):
                    raise ValueError 
            if lci:
                this.TableOfVectors[i] = lci.new
            else:
                this.TableOfVectors[i] = None

    def getVectorObject(indexNo):
        if not VectorTable.isAllowedDataVectorClass( this.TableOfVectors[indexNo] ):
            raise ValueError(f"Column {indexNo} not configured for Data Processing.")
        return this.TableOfVectors[indexNo]

    def pushTableRow(arrayA):
        for lvoe, buffer in zip(this.TableOfVectors,arrayA):
            if isinstance(lvoe, VectorOfX):
                lvoe.pushX(buffer)


#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of WPMS2023.py

    def _validateXFloatByState(xFloat)
        if @IsInputDiffFromMean then
            return if xFloat.is_a? Numeric # Needed when xbar - x is primary.
            raise ArgumentError, "xFloat Exists when it should be missing."
        end
            return if xFloat.nil? # Not needed as the primary IS xFloat.
        raise ArgumentError, "xFloat Missing when required."
    end

    def genArithmeticMean
        raise RangeError, "No Values of X exist." unless @N > 0
        nf = @N.to_f
        if @IsInputDiffFromMean then
            @ArithmeticMean = @SumXs / nf
        else
            @ArithmeticMean = @SumPowerOf1 / nf
        end
        return @ArithmeticMean
    end

    def initialize(startNo,segmentSize,maxNo)
        # xc 20231106:  Don't worry about cost of passing the AA around until efficiency passes later.
        @StartNo        = startNo
        @Se        = startNo
        bottomno        = @StartNo
        topno           = bottomno + segmentSize
        while bottomno < maxNo
            @FrequencyAA[bottomno]  = RangeOccurrence.new(bottomno,topno)
            bottomno        = topno
            topno           += segmentSize
        end
    end

    end

    def initialize(lowestValue,highestValue)
        @FrequencyAA    = Hash.new
        @Max            = highestValue
        @Min            = lowestValue
    end

    def setOccurrenceRange(startNo,stopNo)
        raise ArgumentError unless startNo < stopNo
        _validateNoOverlap       
    end

    def validateNoInsideGaps
    end

    def genMax
        _assureSortedVectorOfX
        return @SortedVectorOfX[-1]
    end

    def genMeanAbsoluteError
        amean                   = genMean
        n                       = @VectorOfX.size
        sumofabsolutediffs      = 0
        @VectorOfX.each do |lx|
            previous            = sumofabsolutediffs
            sumofabsolutediff   += ( lx - mu ).abs
            if previous > sumofabsolutediffs then
                raise RangeError, "previous #{previous} > sumofdiffssquared #{sumofabsolutediffs}"
            end
        end
        mae                     = sumofabsolutediffs / n
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
        lfaa            = Hash.new # Init local frequency associative array.
        @VectorOfX.each do |lx|
            lfaa[lx]    = 1   unless lfaa.has_key?(lx)
            lfaa[lx]    += 1      if lfaa.has_key?(lx)
        end
        x               = genModeFromFrequencyAA(lfaa)
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
        @SOPo = _addUpXsToSumsOfPowers(@PopulationStdDev) unless @SOPo
    end

    def genSplitNumbers(int1A,int2A)
        sum = int1A.to_f + int2A.to_f
        average = sum / 2
        return average
    end

    class FrequenciesResuls < VectorOfResults

        CSVHeader = "Value,Frequency"
        HTMLHeader =<<-EOHDR
        <tr>
            <th>Value</th>
            <th>Frequency</th>
        </tr>
        EOHDR
        JSONTOPID = "FrequenciesId"

        def _representDataInCSV
            def genElement(lValue)
                return <<-EOFREQ
                <tr>
                    <th>#{lValue}</th>
                    <td>#{@FrequencyHash[lValue]}</td>
                </tr>
                EOFREQ
            end
            csvrows = ""
            @FrequencyHash.keys.sort.each do |lvalue|
                csvrows += "\"#{lvalue}\",#{@FrequencyHash[lvalue]}"
            end
            return csvrows
        end

        def _representDataInHTML
            def genElement(lValue)
                return <<-EOFREQ
                <tr>
                    <th>#{lValue}</th>
                    <td>#{@FrequencyHash[lValue]}</td>
                </tr>
                EOFREQ
            end
            htmlrows = ""
            @FrequencyHash.keys.sort.each do |lvalue|
                htmlrows += genElement(lvalue)
            end
            return htmlrows
        end

        def _representDataInJSON
            def genElement(valStr,freqA)
                return <<-EOElement
                {
                    value: #{valStr};
                    frequency: #{freqA};
                }
                EOElement
            end
            jsonstr = ""
            @FrequenciesHash.keys.each do |lxv|
                jsonstr += genElement(lxv,@FrequenciesHash[lxv])
            end
            return jsonstr
        end

        def _representDataInLateXBarGraph
        end

        def _representDataInLateXHistogram
        end

        def _representDataInLateXPieChart
        end

        def _representDataInLateXPlot
        end

        def _representDataInLateXTable
        end

        def initialize(frequenciesHash)
            @FrequenciesHash = frequenciesHash
        end

    end

n = 5
5/4 = 1.25 => 0.75 * 2 + 0.25 * 3 == 1.5 + 0.75 == 2.25
6/4 = 1.50j
7/4 = 1.75
# 1.50 = 0.5 * 1 + 0.5 * 2 == 1.5
# 1.75 = 0.25 * 1 + 0.75 * 2 == 0.25 + 1.5 
6 / 4 = 1.5
7 / 4 = 1.75
6 = 6
7 = 7
        # 1 2 3 4 5
        # 1 2 3 4 5 6
n:
case 5:
0 = 0 * ( 5 / 4 )
1 = 1 * ( 5 / 4 )
2 = 2 * ( 5 / 4 )
3 = 3 * ( 5 / 4 )
4 = 4 * ( 5 / 4 )
case 6:
0 = 0 * ( 6 / 4 )
2 = 1 * ( 6 / 4 )
4 = 2 * ( 6 / 4 )
6 = 3 * ( 6 / 4 )
8 = 4 * ( 6 / 4 )
n-1:
        # 1 2 3 4 5
        # 1 2 3 4 5 6
        # 1 2 3 4 5 6 7
case 5:
0 = 0 * ( 4 / 4 )
1 = 1 * ( 4 / 4 ) should be 1, half of index of median of 3, which is 2
2 = 2 * ( 4 / 4 )
3 = 3 * ( 4 / 4 )
4 = 4 * ( 4 / 4 )
case 6:
0 = 0 * ( 5 / 4 )
1.25 = 1 * ( 5 / 4 ) should be 1.25, half of index of median of ( 3 + 4 ) / 2 which is half of indices 2 and 3, or 2.5
2.5 = 2 * ( 5 / 4 )
3.75 = 3 * ( 5 / 4 )
5 = 4 * ( 5 / 4 )
case 7:
0 = 0 * ( 6 / 4 )
1.5 = 1 * ( 6 / 4 )
3 = 2 * ( 6 / 4 )
4.5 = 3 * ( 6 / 4 )
6 = 4 * ( 6 / 4 )
case 8:
0 = 0 * ( 7 / 4 )
1.75 = 1 * ( 7 / 4 )
3.5 = 2 * ( 7 / 4 )
5.25 = 3 * ( 7 / 4 )
7 = 4 * ( 7 / 4 )

qif     = qno * ( n - 1 ) / 4
qmfb    = qif % 4
qmfp0   = qmfb - 1
qmfp1   = 1 - qmfp0
if qmfb == 0 then
    qi = qif.to_i
    q = sortedx[qi]
else
    qi0 = qif * qifp0
    qi1 = ( qif + 1 ) * qifp1
    q = sortedx[qi0] +  sortedx[qi1]
end

        if n % 2 == 0 then
            nm2 = ( n + 1 ) / 2
            return svox[nm2]
        else
            nm2a = n / 2
            x1 = svox[nm2a]
            nm2b = nm2a + 1
            x2 = svox[nm2b]
            x3 = ( x1 + x2 ).to_f / 2.0
            return x3.round(@OutputDecimalPrecision)
        end
    def WrongcalculateQuartile(qNo,sortedVectorOfX)
        n = getCount
        qindex = ( qNo * ( n - 1 ) / 4 )
        tween2 = ( qNo * ( n - 1 ) % 4 ) != 0
        qvalue = nil
        if tween2 then
            qvalue = genSplitNumbers(@VectorOfX[qindex],@VectorOfX[qindex+1])
        else
            qvalue = @VectorOfX[qindex]
        end
        return qvalue
    end


        qvalue = nil
        case qNo
        when 0
            qvalue = genMin
        when 1
            qindex = ((n + 1)/4)
            if ( n + 1 ) % 4 == 0 then
                qvalue = @VectorOfX[qindex]
            else
                qvalue = genSplitNumbers(@VectorOfX[qindex],@VectorOfX[qindex+1])
            end
            qvalue = Quartile(Q1) = ((n + 1)/4)th Term 
        when 2
            qvalue = genMedian
        when 3
        when 4
            qvalue = genMax
        else
            raise ArgumentError, "Not a valid Quartile id."
        end
    Second Quartile(Q2) = ((n + 1)/2)th Term
    Third Quartile(Q3) = (3(n + 1)/4)th Term

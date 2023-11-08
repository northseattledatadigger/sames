    def _reuseMSPairIfProvided(aMeanStdDevPair=nil)
        if aMeanStdDevPair then
            raise ArgumentError aMeanStdDevPair.is_a? Array
            raise ArgumentError aMeanStdDevPair.size >= 2
            raise ArgumentError unless aMeanStdDevPair[0].is_a? Float
            raise ArgumentError unless aMeanStdDevPair[1].is_a? Float
            return aMeanStdDevPair[0], aMeanStdDevPair[1]
        end
        mu = genArithmeticMean
        sd = genStandardDeviation
        return mu, sd
    end


    end

    def genStandardDeviation
        @SOPo = _addUpXsToSumsOfPowers(@PopulationStdDev)
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

    def _addUpXsToSumsOfPowers(populationCalculation=false)
        sopo = SumsOfPowers.new(populationCalculation)
        if @UseSumOfXs then
            @VectorOfX.each do |lx|
                diff = lx - amean
                sopo.addToSums(diff,lx)
            end
        else
            @VectorOfX.each do |lx|
                sopo.addToSums(lx)
            end
        end
        return sopo
    end

    def genVarianceSumOfDifferencesFromMean(populationCalculation=false)
        sopo = _addUpXsToSumsOfPowers(populationCalculation)
        v = sopo.genVarianceUsingSubjectAsDiffs
        # Note rounding is not done here, as it would be double rounded with stddev.
        return v
    end

    def genVarianceXsSquaredMethod(populationCalculation=false)
        sopo = _addUpXsToSumsOfPowers(populationCalculation,true)
        v = sopo.genVarianceUsingSubjectAsSumXs
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

    def nilSOPo
        @SOPo = nil
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
    attr_accessor   :ValidateStringNumbers

    attr_reader     :SOPo
=end
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

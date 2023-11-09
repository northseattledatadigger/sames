
    it "Has a genSummaryStatistics method which returns a list of all it has." do
        a  = [1,2,3,4,4,4,4,3,2,1]
        localo = VectorOfContinuous.new(a)
        assert_equal localo.getCount, 10
STDERR.puts "trace #NOTE:  BEGIN Calculations Here:"
        asaa = localo.getSummaryStatistics
        assert asaa.is_a? Hash
        assert_equal asaa.size,                                     18

        assert_equal asaa[VectorOfContinuous::ArithmeticMeanId],    2.8
        assert_equal asaa[VectorOfContinuous::COVPopulationId],     0.4165
        assert_equal asaa[VectorOfContinuous::COVSampleId],         0.439
        assert_equal asaa[VectorOfContinuous::GeometricMeanId],     2.4915
        assert_equal asaa[VectorOfContinuous::IsEvenId],            true
        assert_equal asaa[VectorOfContinuous::KurtosisId],          4.163
        assert_equal asaa[VectorOfContinuous::MAEId],               1.04
        assert_equal asaa[VectorOfContinuous::MaxId],               4
        assert_equal asaa[VectorOfContinuous::MedianId],            3.0
        assert_equal asaa[VectorOfContinuous::MinId],               1
        assert_equal asaa[VectorOfContinuous::ModeId],              4
        assert_equal asaa[VectorOfContinuous::NId],                 10
        assert_equal asaa[VectorOfContinuous::SkewnessId],          0.9316
STDERR.puts "trace #NOTE:  BEGIN ERROR HERE:"
        assert_equal asaa[VectorOfContinuous::StddevDiffsPopId],    1.1662
        assert_equal asaa[VectorOfContinuous::StddevDiffsSampleId], 1.2293
        assert_equal asaa[VectorOfContinuous::StddevSumxsPopId],    2.0513
        assert_equal asaa[VectorOfContinuous::StddevSumxsSampleId], 2.1958
        assert_equal asaa[VectorOfContinuous::SumId],               32
STDERR.puts "trace #NOTE:  END ERROR HERE:"
=begin
=end
    end


    it "Provides mean, standard deviation, median and mode." do
        a0  = [0,1,2,3,4,5,6,7,8,9,8,7,8]
        l0o = VectorOfContinuous.new(a0)
        amean = ssd = med = mod = psd = qua = nil
        assert_nothing_raised do
            amean   = l0o.genArithmeticMean
            mae     = l0o.genMeanAbsoluteError
            ssd     = l0o.genStandardDeviation
            l0o.PopulationStdDev    = true
            psd     = l0o.genStandardDeviation
            l0o.PopulationStdDev    = false
            med     = l0o.genMedian
            mod     = l0o.genMode
            qua     = l0o.genQuartiles
        end
        STDERR.puts "trace #{amean}, #{ssd}, #{psd}, #{med}, #{mod}, #{qua.size}"
        assert amean == 5.2308
=begin
        assert mae == 2.9999
        assert med == 6.5
        assert mod == 8
        assert psd == 2.8596 # 2.8596354300679 according to online calculator
        assert ssd == 2.9764
        assert qua.is_a? Array
        assert qua.size == 5
        assert qua[0] == 0
        assert qua[1] == 2
        assert qua[2] == 5
        assert qua[3] == 7
        assert qua[4] == 9
        #STDERR.puts "trace #{qua[0]}, #{qua[1]}, #{qua[2]}, #{qua[3]}, #{qua[4]}"
=end
    end

    it "Provides a number of useful calculations, including quartiles, sum, n ." do
        a0          = [0,1,2,3,4,5,6,7,8,9]
        a1          = [0.0,1.1,2.2,3.3,4.4,5.5,6.6,7.7,8.8,9.9]
        a2          = [99.336,5.9,0x259,441133.7,1234,1.5,99,5876.1234]
        aall        = a0 + a1 + a2
        lallo       = VectorOfContinuous.new(aall)
        n = max1 = min1 = max2 = min2 = mu = ssd = med = mod = niseven = rangens = qua = nil
=begin
        assert_nothing_raised do
            max1        = lallo.genMax
            min1        = lallo.genMin
            min2,max2   = lallo.genRange
            amean       = lallo.genArithmeticMean
            med         = lallo.genMedian
            mod         = lallo.genMode
            n           = lallo.getCount
            ni_seven    = lallo.isEvenN?
            rangens     = lallo.genRange
            qua         = lallo.genQuartiles
            ssd         = lallo.genStandardDeviation
        end
        #STDERR.puts "trace #{mu}, #{ssd}, #{med}, #{mod}, #{qua.size}, #{max1}, #{max2}, #{min1}, #{min2}, #{n}, #{niseven}"
        #trace 16040.895, 83317.9287, 6, 0, 5, 441133.7, 441133.7, 0, 0, 28, true

        assert max1     == 441133.7
        assert max2     == 441133.7
        assert min1     == 0
        assert min2     == 0
        assert med      == 6
        assert mod      == 0
        assert amean    == 16040.895
        assert n        == 28
        assert niseven  == true
        #STDERR.puts "trace #{qua[0]}, #{qua[1]}, #{qua[2]}, #{qua[3]}, #{qua[4]}"
        assert qua.is_a? Array
        assert qua.size == 5
        assert qua[0]   == 0
        assert qua[1]   == 2.2
        assert qua[2]   == 5.9
        assert qua[3]   == 9
        assert qua[4]   == 441133.7
        assert qua[0]   == min1
        assert qua[4]   == max1
        assert ssd      == 83317.9287
=end
    end

    it "Provides two variance methods." do
        a2a         = [99.336,5.9,41133.7,1234,1.5,99,5876.1234,55,0,27.3]
        l2o         = VectorOfContinuous.new(a2a)
        v1 = v1p = v2 = v2p = nil
=begin
        assert_nothing_raised do
            v1          = l2o.genVarianceSumOfDifferencesFromMean
            v1p         = l2o.genVarianceSumOfDifferencesFromMean(true) # Population calculation
            v2          = l2o.genVarianceXsSquaredMethod
            v2p         = l2o.genVarianceXsSquaredMethod(true) # Population calculation
        end
        #STDERR.puts "trace #{v1}, #{v1p}, #{v2}, #{v2p}"
        s1 = s1p = s2 = s2p = nil
        assert_nothing_raised do
            s1          = l2o.genStandardDeviation
        end
        l2o.PopulationStdDev = true
        assert_nothing_raised do
            s2          = l2o.genStandardDeviation
        end
        l2o.PopulationStdDev    = false
        l2o.UseSumOfXs          = true
        assert_nothing_raised do
            s1p         = l2o.genStandardDeviation
        end
        l2o.PopulationStdDev = true
        assert_nothing_raised do
            s2p         = l2o.genStandardDeviation
        end
        l2o.PopulationStdDev    = false
        l2o.UseSumOfXs          = false
        #STDERR.puts "trace #{s1}, #{s1p}, #{s2}, #{s2p}"
        a2b         = [9999999999.99999,9999999999.99999,9999999999.99999]
        #STDERR.puts "trace 1 overflow test: #{a2b.size},#{a2b}"
        l2bo        = VectorOfContinuous.new(a2b)
        #l2bo.listVectorElementsForVisualExamination
        s = v = nil
        assert_nothing_raised do
            v           = l2bo.genVarianceSumOfDifferencesFromMean
        end
        assert_raise RangeError do
            s           = l2bo.genStandardDeviation
        end
        #STDERR.puts "trace 9 overflow test: #{v},#{s}"
=end
    end

    it "Input routine pushX validates arguments." do
        lvo = VectorOfContinuous.new
        assert_raise ArgumentError do
            lvo.pushX("asdf")
        end
        assert_raise ArgumentError do
            lvo.pushX("0x9")
        end
        assert_raise ArgumentError do
            lvo.pushX("1234..56")
        end
        assert_raise ArgumentError do
            lvo.pushX("2 34")
        end
        lvo.ValidateStringNumbers = true
        assert_raise RangeError do
            lvo.pushX("9999999999999999999999999999")
        end
    end

end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Tests for VectorOfDiscrete

describe VectorOfDiscrete do

    it "Constructs with no argument." do
        assert_nothing_raised do
            VectorOfDiscrete.new
        end
        localo = VectorOfDiscrete.new
        assert localo.is_a? VectorOfDiscrete
        localo.pushX(5.333)
        localo.pushX("Any old string")
        #assert localo.size == 2
    end

    it "Constructs with a Ruby Array." do
        assert_nothing_raised do
            VectorOfDiscrete.new([1.5,99,5876.1234,"some old string"])
        end
        localo = VectorOfDiscrete.new([1.5,99,5876.1234,"some old string"])
        assert localo.is_a? VectorOfDiscrete
        #assert localo.size == 4
    end

    it "Has a Bournoulli probability calculation." do
        a = [1,2,3,4,5,6,7,8,9,8]
        localo = VectorOfDiscrete.new(a)
        assert_respond_to localo, :genBinomialProbability
        #result = localo.genBinomialProbability(8,3,1)
        #assert result == 0.25
    end

    it "Has accessor for output decimal precision." do
        localo = VectorOfDiscrete.new
        assert_respond_to localo, :OutputDecimalPrecision
    end

    it "Has reader for the internals." do
        localo = VectorOfDiscrete.new
        assert_respond_to localo, :VectorOfX
        assert_respond_to localo, :FrequenciesAA
    end

end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Tests for VectorTable

describe VectorTable do
# Primary Example:  ./testdata/doexampledata.csv
#year_month,month_of_release,passenger_type,direction,sex,age,estimate,standard_error,status
#2001-01,2020-09,Long-term migrant,Arrivals,Female,0-4 years,344,0,Final

    it "Constructs with just a class/column argument." do
           #2001-01,2020-09,Long-term migrant,Arrivals,Male,0-4 years,341,0,Final
        vcsa = [nil,nil,nil,nil,nil,nil,VectorOfContinuous,VectorOfContinuous,nil]
        assert_nothing_raised do
            VectorTable.new(vcsa)
        end
        localo = VectorTable.new(vcsa)
        assert localo.is_a? VectorTable
    end
    
    it "Allows adding a data row's of vector elements." do
           #2001-01,2020-09,Long-term migrant,Arrivals,Male,0-4 years,341,0,Final
        vcsa = [nil,nil,nil,nil,nil,nil,VectorOfContinuous,VectorOfContinuous,nil]
        localo = VectorTable.new(vcsa)
        a = ['Nil0','Nil1','Nil2','Nil3','Nil4','Nil5',123456,77,'Nil8']
        localo.pushTableRow(a)
        lvi6o = localo.getVectorObject(6)
        assert lvi6o.is_a? VectorOfContinuous
        lvi7o = localo.getVectorObject(7)
        assert lvi7o.is_a? VectorOfContinuous
    end

    it "Allows a user to load column values from a CSV file (and make all the calculations on vectors filled)." do
           #2001-01,2020-09,Long-term migrant,Arrivals,Male,0-4 years,341,0,Final
        vcsa    = [nil,nil,nil,nil,nil,nil,VectorOfContinuous,VectorOfContinuous,nil]
        localo  = VectorTable.newFromCSV(FirstTestFileFs,vcsa)
        lvi6o = localo.getVectorObject(6)
        amean = lvi6o.genArithmeticMean
        ssd = lvi6o.genStandardDeviation
=begin
        #STDERR.puts "trace mu:  #{mu}"
        #STDERR.puts "trace ssd:  #{ssd}"
        #assert mu == 437.2062 # was true for original entire file.
        assert mu == 151.3896 # for truncated file.
        #assert ssd == 1195.4808 # was true for original entire file.
        assert ssd == 463.7498 # for truncated file.
        lvi7o = localo.getVectorObject(7)
        mu = lvi7o.genMean
        ssd = lvi7o.genStandardDeviation
        #STDERR.puts "trace mu:  #{mu}"
        #STDERR.puts "trace ssd:  #{ssd}"
        #assert mu == 0.5492 # for full file.
        assert mu == 12.5068 # for truncated file.
        #assert ssd == 4.0465 # for full file.
        assert ssd == 15.7267 # for truncated file.
=end
    end

end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of test_SamesLib.rb

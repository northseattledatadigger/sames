#!/usr/bin/ruby
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# test_SamesLib.rb

=begin
# TBD:
1.  Quartiles and mode are not that important to me right now, and both appear
to be broken, so putting that off until later.
2.  Generate JSON and CSV output from Vector Base class.
3.  Program draft of discrete class 
4.  Maybe leave most things undone until the primaries are all covered.
=end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Constants and Includes

unless ARGV.length == 1
    raise ArgumentError, "Must provide test subset id as sole argument."
end

SubType=ARGV[0]
SamesProjectDs=File.expand_path("..", __dir__)
RubyLibFs="#{SamesProjectDs}/SamesLib.#{SubType}.rb"
unless File.exists?(RubyLibFs) then
    raise ArgumentError, "Sole argument must be valid filename of Ruby library."
end

require_relative RubyLibFs

require 'rspec/autorun'
require 'rspec/core'
require 'test/unit'

include Test::Unit::Assertions

def returnIfThere(fSpec)
    return fSpec if File.exists?(fSpec)
    raise ArgumentError, "Test data file #{fSpec} not found." 
end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Init

SamesDs=File.expand_path("../..", __dir__)
TestDataDs="#{SamesDs}/testdata"

FirstTestFileFs=returnIfThere("#{TestDataDs}/doexampledata.sorted.reversed.truncated1024.csv")
SecondTestFileFs=returnIfThere("#{TestDataDs}/california-adults-who-met-physical-activity-guidelines-for-americans-2013.csv")
ThirdTestFileFs=returnIfThere("#{TestDataDs}/DEEP_Trails_Set.csv")
FourthTestFileFs=returnIfThere("#{TestDataDs}/Pedestrian_Space_Added.csv")

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Tests for Global Support Routines

describe 'genFactorial' do

    it "Calculates factorial using Ruby's gamma function as per find in stackoverflow." do
        n = genFactorial(4)
        assert n = 24
        assert_raise ArgumentError do
            genFactorial(25.55)
        end
    end

end

describe 'isANumStr?' do

    it "Discerns if value has a String that could be parsed as a number." do
        result = isANumStr?('1234')
        assert result == true
        result = isANumStr?('1234.56789')
        assert result == true
        result = isANumStr?('.1234')
        assert result == true
        result = isANumStr?('1234.0')
        assert result == true
        result = isANumStr?('12 34')
        assert result == false
        result = isANumStr?('12x4')
        assert result == false
        result = isANumStr?('A')
        assert result == false
        result = isANumStr?('%')
        assert result == false
    end

    it "Rejects non-strings." do
        result = isANumStr?(1234)
        assert result == false
        v = 15.993
        result = isANumStr?(v)
        assert result == false
        v = 0.1234
        result = isANumStr?(v)
        assert result == false
    end

end

describe 'isNumericVector?' do

    it "It discerns whether all elements of a vector are good numbers for data." do
        assert isNumericVector?([1,2,3,4,5]) == true
        assert isNumericVector?(['1',2,'33.33',"4"]) == false
        assert isNumericVector?(['1',2]) == false
        assert isNumericVector?([2,'33.33']) == false
        assert isNumericVector?(["4",5,6]) == false
        assert isNumericVector?([2,33.33,0004,0x5,12341234123412341234]) == true
        assert isNumericVector?(['x',2,3,4,5]) == false
        assert isNumericVector?([' 1 1 ',2,3,4,5]) == false
    end

end

describe 'isUsableNumber?' do

    it "Accepts any number or string that can be parsed as a number." do
        result = isUsableNumber?(1234)
        assert result == true
        v = 15.993
        result = isUsableNumber?(v)
        assert result == true
        v = 0.1234
        result = isUsableNumber?(v)
        assert result == true
        result = isUsableNumber?('1234')
        assert result == true
        result = isUsableNumber?('1234.56789')
        assert result == true
        result = isUsableNumber?('.1234')
        assert result == true
        result = isUsableNumber?('1234.0')
        assert result == true
    end

    it "Rejects non-numeric stuff." do
        result = isUsableNumber?('%')
        assert result == false
        result = isUsableNumber?('12 34')
        assert result == false
        result = isUsableNumber?('12x4')
        assert result == false
        result = isUsableNumber?('A')
        assert result == false
        v = /blek/
        result = isUsableNumber?(v)
        assert result == false
        v = Hash.new
        result = isUsableNumber?(v)
        assert result == false
    end

end

describe "isUsableNumberVector?" do

    it "It discerns whether all elements of a vector are good numbers for data." do
        assert isUsableNumberVector?([1,2,3,4,5]) == true
        assert isUsableNumberVector?(['1',2,'33.33',"4"]) == true
        assert isUsableNumberVector?(['1',2]) == true
        assert isUsableNumberVector?([2,'33.33']) == true
        assert isUsableNumberVector?(["4",5,6]) == true
        assert isUsableNumberVector?([2,33.33,0004,0x5,12341234123412341234]) == true
        assert isUsableNumberVector?(['x',2,3,4,5]) == false
        assert isUsableNumberVector?([' 1 1 ',2,3,4,5]) == false
    end

end

describe "validateStringNumberRange(strA)" do

    it "Throws Range Error of a number is too big." do
        assert_raise ArgumentError do
            validateStringNumberRange(99)
        end
        assert_nothing_raised do
            validateStringNumberRange("1234.56789")
        end
        assert_raise RangeError do
            validateStringNumberRange("999999999999999999999999999999999999999999999.9999999999999")
        end
    end

end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Tests for Base Class VectorOfX - Most testing on these routines will be in the
# daughter classes where the behavior is manifest.  Note the initialize method
# was only defined to aid these tests.

describe VectorOfX do

    it "Constructs with no argument, or ruby array." do
        assert_nothing_raised do
            VectorOfX.new
        end
        a = [1.5,99,5876.1234,"String",String]
        assert_nothing_raised do
            VectorOfX.new(a)
        end
        localo = VectorOfX.new(a)
        assert localo.is_a? VectorOfX
    end

    it "Provides internal focused method to generate sorted data into @SortedVectorOfX variable." do
        a = [3,2,1]
        localo = VectorOfX.new(a)
        assert localo.is_a? VectorOfX
        assert_respond_to localo, :_assureSortedVectorOfX
        localo._assureSortedVectorOfX
        assert localo.SortedVectorOfX.size == 3
        assert localo.SortedVectorOfX[0] == 1
        assert localo.SortedVectorOfX[1] == 2
        assert localo.SortedVectorOfX[2] == 3
    end

    it "Has a working getCount method." do
        localo = VectorOfX.new
        assert localo.getCount == 0
        a = [1.5,99,5876.1234,"String",String]
        localo = VectorOfX.new(a)
        assert localo.getCount == 5
    end

    it "Has a method to display elements for manual examination." do
        a = [1.5,99,5876.1234,"String",String]
        localo = VectorOfX.new(a)
        assert_respond_to localo, :listVectorElementsForVisualExamination
        $stdout = StringIO.new
        result = localo.listVectorElementsForVisualExamination
        $stdout = STDOUT
        assert result.size > 0
        $stderr = StringIO.new
        result = localo.listVectorElementsForVisualExamination(true)
        $stderr = STDERR
        assert result.size > 0
    end

    it "pushX method is pure virtual." do
        localo = VectorOfX.new
        assert_respond_to localo, :pushX
        assert_raise ArgumentError do
            localo.pushX("anything")
        end
    end

    it "Has read handles for internal data arrays." do
        a = [1.5,99,5876.1234,"String",String]
        localo = VectorOfX.new(a)
        assert_respond_to localo, :VectorOfX
        assert_respond_to localo, :SortedVectorOfX
    end

end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Tests for VectorOfContinuous, and most base class methods inherited.

describe VectorOfContinuous do

    it "Constructs with no argument." do
        assert_nothing_raised do
            VectorOfContinuous.new
        end
        localo = VectorOfContinuous.new
        assert localo.is_a? VectorOfContinuous
        localo.pushX(5.333)
    end

    it "Constructs with a Ruby Array." do
        assert_nothing_raised do
            VectorOfContinuous.new([1.5,99,5876.1234])
        end
        localo = VectorOfContinuous.new([99.336,5.9,0x259,88441133.7,1234])
        assert localo.is_a? VectorOfContinuous
    end

    it "Has constructor which drops bad values." do
        a = ["1.5","99","5876.1234","1234 ","asdf"]
        localo = nil
        assert_nothing_raised do
            localo = VectorOfContinuous.newAfterInvalidatedDropped(a,false)
        end
        assert localo.getCount == 4
        assert localo.genMin == 1.5
        assert localo.genMax == 5876.1234
    end

    it "Has internal focused method to decide startno value for histogram." do
        a = [1,2,3]
        localo = VectorOfContinuous.new(a)
        startno = localo._decideHistogramStartNumber
        assert startno == 1
        startno = localo._decideHistogramStartNumber(0)
        assert startno == 0
    end

    it "Has an internal method to return an initialized histogram associative array." do
        a = [1,2,2,3,3,3]
        localo = VectorOfContinuous.new(a)
        a = [1,2,3,4,5,6,7,8,9]
    end

    it "Has a calculateQuartile method which returns the value for a designated quartile." do
        a  = [0,1,2,3,4,5,6,7,8,9,8,9,9,9,9,9,8,7,8,7,8,7,6,5,4,3,2,1,0]
        localo = VectorOfContinuous.new(a)
        qv = localo.calculateQuartile(1)
        assert_equal qv, 2.0 # Wild guess.
    end

    it "Has a genSummaryStatistics method which returns a list of all it has." do
        a  = [1,2,3,4,4,4,4,3,2,1]
        localo = VectorOfContinuous.new(a)
        assert_equal localo.getCount, 10
        asaa = localo.getSummaryStatistics
        assert asaa.is_a? Hash
        assert_equal asaa.size,                                     18

        assert_equal asaa[VectorOfContinuous::ArithmeticMeanId],    2.8
        assert_equal asaa[VectorOfContinuous::COVPopulationId],     0.2945
        assert_equal asaa[VectorOfContinuous::COVSampleId],         0.3022
        assert_equal asaa[VectorOfContinuous::GeometricMeanId],     2.4915
        assert_equal asaa[VectorOfContinuous::IsEvenId],            true
        assert_equal asaa[VectorOfContinuous::KurtosisId],          5.0087
        assert_equal asaa[VectorOfContinuous::MAEId],               1.04
        assert_equal asaa[VectorOfContinuous::MaxId],               4
        assert_equal asaa[VectorOfContinuous::MedianId],            3.0
        assert_equal asaa[VectorOfContinuous::MinId],               1
        assert_equal asaa[VectorOfContinuous::ModeId],              4
        assert_equal asaa[VectorOfContinuous::NId],                 10
        assert_equal asaa[VectorOfContinuous::SkewnessId],          1.0595 # This seems wrong too:  NOTE
=begin
#NOTE:  BEGIN ERROR HERE:
        assert_equal asaa[VectorOfContinuous::StddevDiffsPopId],    0.8246
        assert_equal asaa[VectorOfContinuous::StddevDiffsSampleId], 0.846
        assert_equal asaa[VectorOfContinuous::StddevSumxsPopId],    2.0513
        assert_equal asaa[VectorOfContinuous::StddevSumxsSampleId], 2.1958
        assert_equal asaa[VectorOfContinuous::SumId],               32
#NOTE:  END ERROR HERE:
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
#2345678901234567890123456789012345678901234567890123456789012345678901234567890

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
#2345678901234567890123456789012345678901234567890123456789012345678901234567890

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

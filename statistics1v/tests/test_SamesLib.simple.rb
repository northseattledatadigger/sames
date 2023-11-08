#!/usr/bin/ruby
# test_SamesLib.simple.rb - Simple coverage for efficient first step sanity
# checks.
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

SamesDs=File.expand_path("../..", __dir__)
TestDataDs="#{SamesDs}/testdata"

FirstTestFileFs=returnIfThere("#{TestDataDs}/doexampledata.sorted.reversed.truncated1024.csv")

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
# Tests for Base Class VectorOfX
#
# Most testing on these routines will be in the daughter classes where the
# behavior is manifest.  Note the initialize method was only defined to aid
# these tests.

describe VectorOfX do

    it "has a _assureSortedVectorOfX method for internal updates to the SortedVectorOfX vector." do
    end

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

    it "has a getCount method to get value of n." do
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
        assert_equal 4, localo.getCount
        assert_equal 1.5, localo.genMin
        assert_equal 5876.1234, localo.genMax
    end

    it "Has internal focused method to construct a new SumsOfPowers object for moment statistics." do
        a = [1,2,3]
        localo  = VectorOfContinuous.new(a)
        assert_equal localo.getCount, 3
        assert_respond_to localo, :_addUpXsToSumsOfPowers
        sopo    = localo._addUpXsToSumsOfPowers
        assert sopo.is_a? SumsOfPowers
    end

    it "Has internal focused method to decide startno value for histogram." do
        a = [1,2,3]
        localo = VectorOfContinuous.new(a)
        assert_equal localo.getCount, 3
        startno = localo._decideHistogramStartNumber
        assert startno == 1
        startno = localo._decideHistogramStartNumber(0)
        assert startno == 0
    end

    it "Has a calculateQuartile method which returns the value for a designated quartile." do
        a  = [0,1,2,3,4,5,6,7,8,9,8,9,9,9,9,9,8,7,8,7,8,7,6,5,4,3,2,1,0]
        sa = a.sort
        #puts "trace a:  #{a}, #{sa}, #{a.size}"
        localo = VectorOfContinuous.new(a)
        qv = localo.calculateQuartile(1)
        assert_equal qv, 3
    end

    it "Calculates mean in two places." do
        a = [1,2,3]
        localo = VectorOfContinuous.new(a)
        vocoam   = localo.genArithmeticMean
        sopoam  = localo._addUpXsToSumsOfPowers.ArithmeticMean
        assert_equal vocoam, sopoam
    end

    it "Generates a coefficient of variation." do
        a = [1,2,3,4,5,6,7,8.9]
        localo = VectorOfContinuous.new(a)
        amean       = localo.genArithmeticMean
        stddev      = localo.genStandardDeviation
        herecov     = ( stddev / amean ).round(localo.OutputDecimalPrecision)
        cov         = localo.genCoefficientOfVariation
        assert_equal cov, herecov
    end

    it "Generates a geometric mean." do
        a = [2,2,2,2]
        localo = VectorOfContinuous.new(a)
        amean       = localo.genArithmeticMean
        gmean       = localo.genGeometricMean
        assert_equal amean, gmean
        a = [1,2,3,4,5,6,7,8,9]
        localo = VectorOfContinuous.new(a)
        amean       = localo.genArithmeticMean
        gmean       = localo.genGeometricMean
        assert amean > gmean
    end

    it "Has two methods to Generate a matrix of histogram data." do
        a = [1,2,3,4,5,6,7,8,9]
        localo = VectorOfContinuous.new(a)
        hdaa = localo.genHistogramAAbyNumberOfSegments(3,1)
        assert_equal 3, hdaa.size
        hdaa = localo.genHistogramAAbyNumberOfSegments(3,0)
        assert_equal 3, hdaa.size
        hdaa = localo.genHistogramAAbyNumberOfSegments(3,-1)
        assert_equal 3, hdaa.size
        hdaa = localo.genHistogramAAbyNumberOfSegments(4,1)
        assert_equal 4, hdaa.size
        hdaa = localo.genHistogramAAbyNumberOfSegments(5,0)
        assert_equal 5, hdaa.size
        hdaa = localo.genHistogramAAbySegmentSize(2,1)
        diff0 = hdaa[0][1] - hdaa[0][0]
        #STDERR.puts "trace diff0 = hdaa[0][1] - hdaa[0][0]:  #{diff0} == #{hdaa[0][1]} - #{hdaa[0][0]}"
        assert_equal diff0, 2.0
        diff1 = hdaa[1][1] - hdaa[1][0]
        assert_equal diff1, 2
        hdaa = localo.genHistogramAAbySegmentSize(3,0)
        diff2 = hdaa[2][1] - hdaa[2][0]
        assert_equal diff2, 3
    end

    it "Can calculate kurtosis." do
        a = [1,2,3,4,5,6,7,8,9]
        localo = VectorOfContinuous.new(a)
        ek = localo.genExcessKurtosis(2)
        #STDERR.puts "trace ek:  #{ek}"
        assert_equal -1.23, ek
        ek = localo.genExcessKurtosis
        assert_equal -1.2, ek
        k = localo.genKurtosis
        #STDERR.puts "trace k:  #{k}"
        assert_equal 1.8476, k
    end

    it "Can get the minimum, median, maximum, and mode." do
        a = [1,2,3,4,5,6,7,8,9]
        localo = VectorOfContinuous.new(a)
        assert_equal localo.getCount, 9
        assert_equal 1, localo.genMin
        assert_equal 5, localo.genMedian
        assert_equal 9, localo.genMax
        assert_equal 1, localo.genMode # Question here:  should I return a sentinal when it is uniform?  NOTE
        a = [1,2,3,4,5,6,7,8,9,8,7,8]
        localo = VectorOfContinuous.new(a)
        min,max = localo.genRange
        assert_equal localo.getCount, 12
        assert_equal 1, min
        #puts "trace BEGIN median mmmm test"
        assert_equal 6.5, localo.genMedian
        #puts "trace END median mmmm"
        assert_equal 9, max
        assert_equal 8, localo.genMode # Question here:  should I return a sentinal when it is uniform?  NOTE
    end

    it "Has calculation for mean absolute error." do
        a = [1,2,3,4,5,6,7,8,9]
        localo = VectorOfContinuous.new(a)
        mae = localo.genMeanAbsoluteError
        assert_equal 2.2222, mae
    end

    it "Has a calculateQuartile method which returns the value for a designated quartile." do
        a  = [1,2,3,4,5]
        localo = VectorOfContinuous.new(a)
        qv = localo.calculateQuartile(0)
        assert_equal qv, 1
        #puts "trace BEGIN first quartile"
        qv = localo.calculateQuartile(1)
        #puts "trace END first quartile"
        assert_equal qv, 2
        qv = localo.calculateQuartile(2)
        assert_equal qv, 3
        qv = localo.calculateQuartile(3)
        assert_equal qv, 4
        qv = localo.calculateQuartile(4)
        assert_equal qv, 5

        a  = [0,1,2,3,4,5,6,7,8,9,8,9,9,9,9,9,8,7,8,7,8,7,6,5,4,3,2,1,0]
        sa = a.sort
        localo = VectorOfContinuous.new(a)
        #STDERR.puts "trace sa:  #{sa}, #{sa.size}"
        qv = localo.calculateQuartile(0)
        assert_equal qv, 0
        qv = localo.calculateQuartile(1)
        assert_equal qv, 3.0 # Wrong
        qv = localo.calculateQuartile(2)
        assert_equal qv, 7.0
        qv = localo.calculateQuartile(3)
        assert_equal qv, 8.0
        qv = localo.calculateQuartile(4)
        assert_equal qv, 9.0
    end

    it "Can calculate skewness." do
        a = [1,2,3,4,5,6,7,8,9]
        localo = VectorOfContinuous.new(a)
        sk = localo.genSkewness
        assert_equal 0, sk
        sk = localo.genSkewness(1)
        assert_equal 0, sk
        sk = localo.genSkewness(2)
        assert_equal 0, sk
        sk = localo.genSkewness(3)
        assert_equal 0, sk
        a = [1,2,2,3,3,3,4,4,4,4,4,4]
        localo = VectorOfContinuous.new(a)
        sk = localo.genSkewness
        assert_equal -0.9878, sk
        sk1 = localo.genSkewness(1)
        assert_equal -0.7545, sk1
        sk2 = localo.genSkewness(2)
        assert_equal -0.8597, sk2
        sk3 = localo.genSkewness(3)
        assert_equal sk3, sk
        a = [1,2,2,3,3,3,4,4,4,4,4,4]
        localo = VectorOfContinuous.new(a)
        STDERR.puts "trace sk:  #{sk}"
    end

    it "Has four standard deviation calculations." do
        a = [1,2,3]
        localo = VectorOfContinuous.new(a)
        sdsd = localo.genStandardDeviation
        localo.UseSumOfDiffs = false
        sdsx = localo.genStandardDeviation
        assert_equal sdsd, sdsx
        localo.Population = true
        sdsd = localo.genStandardDeviation
        localo.UseSumOfDiffs = false
        sdsx = localo.genStandardDeviation
        assert_equal sdsd, sdsx
    end

    it "Has an method to return the sum." do
        a = [1,2,2,3,3,3]
        localo = VectorOfContinuous.new(a)
        assert_equal localo.getCount, 6
        assert_equal 14, localo.genSum
    end

    it "Has two variance generation methods." do
        a = [1,2,2,3,3,3,99.336,5.9,0x259,1133.7,1234]
        localo = VectorOfContinuous.new(a)
        v = localo.genVarianceSumOfDifferencesFromMean
        assert_equal 231232.125543275, v
        v = localo.genVarianceXsSquaredMethod
        assert_equal 231232.12554327273, v
        v = localo.genVarianceSumOfDifferencesFromMean(true)
        assert_equal 210211.0232211591, v
        v = localo.genVarianceXsSquaredMethod(true)
        assert_equal 281851.50962308043, v
    end

end

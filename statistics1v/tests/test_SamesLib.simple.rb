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

HereDs=File.expand_path(".", __dir__)
SamesDs=File.expand_path("../..", __dir__)

require "#{SamesDs}/slib/SBinLib.rb"

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Tests for Global Support Routines

describe 'getFactorial' do

    it "Raises an ArgumentError if the argument passed is not an Integer." do
        assert_raise ArgumentError do
            generateModefromFrequencyAA(nil)
        end
        assert_raise ArgumentError do
            generateModefromFrequencyAA(333.33)
        end
        assert_raise ArgumentError do
            generateModefromFrequencyAA("a string")
        end
        assert_raise ArgumentError do
            generateModefromFrequencyAA(Array.new)
        end
    end

    it "Calculates factorial using Ruby's gamma function as per find in stackoverflow." do
        n = getFactorial(4)
        assert n = 24
        n   = getFactorial(0)
        assert_equal 1, n
        n   = getFactorial(1)
        assert_equal 1, n
        assert_raise ArgumentError do
            getFactorial(25.55)
        end
    end

end

describe 'generateModefromFrequencyAA(faaA)' do

    it "Raises an ArgumentError unless the argument passed is a Hash." do
        assert_raise ArgumentError do
            generateModefromFrequencyAA(nil)
        end
        assert_raise ArgumentError do
            generateModefromFrequencyAA(333)
        end
        assert_raise ArgumentError do
            generateModefromFrequencyAA("a string")
        end
        assert_raise ArgumentError do
            generateModefromFrequencyAA(Array.new)
        end
    end

    it "returns takes a frequency Associative Array, and returns a mode point statistic." do
        h = {'1234' => 528, 528 => 3, "A longer string" => 0, "x" => 55555 }
        result = generateModefromFrequencyAA(h)
        assert_equal "x", result
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

    it "Raises an ArgumentError unless the argument passed is an Array." do
        assert_raise ArgumentError do
            isNumericVector?(nil)
        end
        assert_raise ArgumentError do
            isNumericVector?(333)
        end
        assert_raise ArgumentError do
            isNumericVector?("a string")
        end
        assert_raise ArgumentError do
            isNumericVector?(Hash.new)
        end
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

    it "Raises an ArgumentError unless the argument passed is an Array." do
        assert_raise ArgumentError do
            isNumericVector?(nil)
        end
        assert_raise ArgumentError do
            isNumericVector?(333)
        end
        assert_raise ArgumentError do
            isNumericVector?("a string")
        end
        assert_raise ArgumentError do
            isNumericVector?(Hash.new)
        end
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
# Tests for HistogramOfX class

describe HistogramOfX do

    it "Simple Construction." do
        localo = HistogramOfX.new(1,5)
        assert_instance_of HistogramOfX, localo
        localo.setOccurrenceRange(1,3)
        localo.setOccurrenceRange(3,6)
        localo.addToCounts(1)
        localo.addToCounts(1)
        localo.addToCounts(2)
        localo.addToCounts(3)
        localo.addToCounts(3)
        localo.addToCounts(3)
        result = localo.generateCountCollection
        assert_equal result[0][0], 1
        assert_equal result[0][1], 3
        assert_equal result[0][2], 3
        assert_equal result[1][0], 3
        assert_equal result[1][1], 6
        assert_equal result[1][2], 3
    end

    it "Construction by Segment Size." do
        localo = HistogramOfX.newFromUniformSegmentSize(1,5,3)
        localo.addToCounts(1)
        localo.addToCounts(1)
        localo.addToCounts(2)
        localo.addToCounts(3)
        localo.addToCounts(3)
        localo.addToCounts(3)
        result = localo.generateCountCollection
        assert_equal result[0][0], 1
        assert_equal result[0][1], 4
        assert_equal result[0][2], 6
        assert_equal result[1][0], 4
        assert_equal result[1][1], 7
        assert_equal result[1][2], 0
    end

    it "Construction by Number of Segments." do
        localo = HistogramOfX.newFromDesiredSegmentCount(1,5,2)
        localo.addToCounts(1)
        localo.addToCounts(1)
        localo.addToCounts(2)
        localo.addToCounts(3)
        localo.addToCounts(3)
        localo.addToCounts(3)
        result = localo.generateCountCollection
        assert_equal result[0][0], 1
        assert_equal result[0][1], 3.5
        assert_equal result[0][2], 6
        assert_equal result[1][0], 3.5
        assert_equal result[1][1], 6
        assert_equal result[1][2], 0
    end

    it "Internal class RangeOccurrence." do
        localo = HistogramOfX::RangeOccurrence.new(1,2)
        assert_instance_of HistogramOfX::RangeOccurrence, localo
        assert_equal 0, localo.Count
        assert_equal 1, localo.StartNo
        assert_equal 2, localo.StopNo
        localo.addToCount
        assert_equal 1, localo.Count
        assert localo.hasOverlap?(1,2)
        assert_false localo.hasOverlap?(2,3)
        assert localo.isInRange?(1)
        assert localo.isInRange?(1.5)
        assert_false localo.isInRange?(2)
    end

    it "Internal validation against overlapping ranges." do
        localo = HistogramOfX.new(-128,128)
        localo.setOccurrenceRange(-128,-64)
        localo.setOccurrenceRange(-64,0)
        localo.setOccurrenceRange(0,64)
        localo.setOccurrenceRange(64,129)
        assert_raise ArgumentError do
            localo.setOccurrenceRange(25,99)
        end
    end

    it "Adding to counts." do
        localo = HistogramOfX.new(-5,0)
        localo.setOccurrenceRange(0,5)
        localo.addToCounts(1)
        localo.addToCounts(2)
        localo.addToCounts(-3)
        assert_raise ArgumentError do
            localo.addToCounts(8)
        end
    end

    it "Generating an ordered list of vectors of counts." do
        localo = HistogramOfX.new(-128,128)
        localo.setOccurrenceRange(-128,-64)
        localo.setOccurrenceRange(-64,0)
        localo.setOccurrenceRange(0,64)
        localo.setOccurrenceRange(64,129)
        localo.addToCounts(-99)
        localo.addToCounts(12)
        localo.addToCounts(53)
        localo.addToCounts(64)
        localo.addToCounts(3)
        localo.addToCounts(2)
        localo.addToCounts(22)
        localo.addToCounts(-22)
        result = localo.generateCountCollection
        assert_equal result[1][0], -64
        assert_equal result[1][1], 0
        assert_equal result[1][2], 1
        assert_equal result[3][0], 64
        assert_equal result[3][1], 129
        assert_equal result[3][2], 1
    end

    it "Validation that the Range is Complete." do
        localo = HistogramOfX.new(-128,128)
        localo.setOccurrenceRange(-128,-64)
        localo.setOccurrenceRange(-64,0)
        localo.setOccurrenceRange(0,64)
        localo.setOccurrenceRange(64,129)
        localo.validateRangesComplete
        localo.setOccurrenceRange(244,256)
        assert_raise RangeError do
            localo.validateRangesComplete
        end
    end
       
end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Tests for SumsOfPowers class

describe SumsOfPowers do

    it "Has just one native constructor." do
        localo = SumsOfPowers.new(false)
        assert_instance_of SumsOfPowers, localo
    end

    it "Generation of Pearson's First Skewness Coefficient with class method." do
        # Need data here for better knowledge.  For now just make sure a number comes out.
        a = SumsOfPowers.calculatePearsonsFirstSkewnessCoefficient(25,3,1.57)
        assert_equal 14.012738853503183, a
    end
       
    it "Generation of Pearson's Second Skewness Coefficient with class method." do
        # Need data here for better knowledge.  For now just make sure a number comes out.
        a = SumsOfPowers.calculatePearsonsSecondSkewnessCoefficient(25,3,1.57)
        assert_equal 14.012738853503183, a
        #STDERR.puts "trace a:  #{a}"
    end
       
    it "Generate second moment Subject Xs sum." do
        localo = SumsOfPowers.new(false)
        assert_respond_to localo, :_calculateSecondMomentSubjectXs
        a = localo._calculateSecondMomentSubjectXs
    end

    it "Generate third moment Subject Xs sum." do
        localo = SumsOfPowers.new(false)
        assert_respond_to localo, :_calculateThirdMomentSubjectXs
        a = localo._calculateThirdMomentSubjectXs
    end

    it "Generate fourth moment Subject Xs sum." do
        localo = SumsOfPowers.new(false)
        assert_respond_to localo, :_calculateFourthMomentSubjectXs
        a = localo._calculateFourthMomentSubjectXs
    end

    it "Adding to the sums.." do
        localo = SumsOfPowers.new(false)
        localo.addToSums(3)
        assert_equal 1, localo.N
        localo.addToSums(3)
        localo.addToSums(4)
        localo.addToSums(5)
    end

    it "Generating kurtosis." do
        a = [3,3,4,5]
        localo = SumsOfPowers.new(false)
        localo.setToDiffsFromMeanState(a.sum,a.size)
        localo.addToSums(a[0])
        assert_equal a.size, localo.N
        assert_equal 4, localo.N
        localo.addToSums(a[1])
        localo.addToSums(a[2])
        localo.addToSums(a[3])
        assert_equal 4, localo.N
        result = localo.requestKurtosis
        #STDERR.puts "trace Generating kurtosis:  #{result}"
        assert_equal -4.5, result
    end

    it "Generating skewness." do
        localo = SumsOfPowers.new(false)
        localo.addToSums(3)
        assert_equal 1, localo.N
        localo.addToSums(3)
        localo.addToSums(4)
        localo.addToSums(5)
        localo.addToSums(6)
        result = localo.requestSkewness
        assert_equal 56.25011459381775, result
    end

    it "Generating standard deviation." do
        localo = SumsOfPowers.new(false)
        localo.addToSums(3)
        assert_equal 1, localo.N
        localo.addToSums(3)
        localo.addToSums(4)
        localo.addToSums(4)
        result = localo.generateStandardDeviation
        assert_equal 0.5773502691896257, result
    end

    it "Generating variance." do
        localo = SumsOfPowers.new(false)
        localo.setToDiffsFromMeanState(15,4)
        localo.addToSums(3)
        localo.addToSums(3)
        localo.addToSums(4)
        localo.addToSums(5)
        result = localo.calculateVarianceUsingSubjectAsDiffs
        assert_equal 19.666666666666668, result
        localo = SumsOfPowers.new(false)
        localo.addToSums(3)
        localo.addToSums(3)
        localo.addToSums(4)
        localo.addToSums(5)
        result = localo.calculateVarianceUsingSubjectAsSumXs
        assert_equal 0.9166666666666666, result
        #assert_equal 19.666666666666668, result
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
        a = [3,2,1]
        localo = VectorOfX.new(a)
        assert_respond_to localo, :_assureSortedVectorOfX
        localo._assureSortedVectorOfX
        assert localo.SortedVectorOfX.size == 3
        assert localo.SortedVectorOfX[0] == 1
        assert localo.SortedVectorOfX[1] == 2
        assert localo.SortedVectorOfX[2] == 3
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

    it "Has a working getCount method." do
        localo = VectorOfX.new
        assert localo.getCount == 0
        a = [1.5,99,5876.1234,"String",String]
        localo = VectorOfX.new(a)
        assert localo.getCount == 5
    end

    it "Has a working getX method." do
        a = [1.5,99,5876.1234,"String",String]
        localo = VectorOfX.new(a)
        assert localo.getX(2) == 5876.1234
    end

    it "pushX method is pure virtual." do
        localo = VectorOfX.new
        assert_respond_to localo, :pushX
        assert_raise ArgumentError do
            localo.pushX("anything")
        end
    end

    it "requestResultAACSV(xFloat) method is pure virtual." do
        localo = VectorOfX.new
        assert_respond_to localo, :requestResultAACSV
    end

    it "requestResultAACSV(xFloat) method is pure virtual." do
        localo = VectorOfX.new
        assert_respond_to localo, :requestResultCSVLine
    end

    it "requestResultAACSV(xFloat) method is pure virtual." do
        localo = VectorOfX.new
        assert_respond_to localo, :requestResultJSON
    end

    it "Has tranformation method to output a line of CSV for the VectorOfX data." do
        a = [1.5,99,5876.1234,"String"]
        localo = VectorOfX.new(a)
        result = localo.transformToCSVLine
        assert "1.5,99,5876.1234,\"String\"", result
    end

    it "Has tranformation method to output a string of JSON for the VectorOfX data." do
        a = [1.5,99,5876.1234,"String",String]
        localo = VectorOfX.new(a)
        s = localo.transformToJSON
        assert s =~ /5876.1234/
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
        assert_equal 1.5, localo.getMin
        assert_equal 5876.1234, localo.getMax
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

    it "Calculates arithmetic mean in two places." do
        a = [1,2,3]
        localo  = VectorOfContinuous.new(a)
        vocoam  = localo.calculateArithmeticMean
        sopo    = localo._addUpXsToSumsOfPowers
        assert sopo.is_a? SumsOfPowers
        sopoam  = sopo.ArithmeticMean
        assert_equal vocoam, sopoam
    end

    it "Calculates geometric mean." do
        a = [1,2,3,4,5]
        localo  = VectorOfContinuous.new(a)
        gmean  = localo.calculateGeometricMean
        assert_equal 2.6052, gmean
        a           = [2,2,2,2]
        localo      = VectorOfContinuous.new(a)
        amean       = localo.calculateArithmeticMean
        gmean       = localo.calculateGeometricMean
        assert_equal amean, gmean
        a           = [1,2,3,4,5,6,7,8,9]
        localo      = VectorOfContinuous.new(a)
        amean       = localo.calculateArithmeticMean
        gmean       = localo.calculateGeometricMean
        assert amean > gmean
    end

    it "Calculates harmonic mean." do
        a = [1,2,3,4,5]
        localo  = VectorOfContinuous.new(a)
        hmean  = localo.calculateHarmonicMean
        assert_equal 2.1898, hmean
        a           = [2,2,2,2]
        localo      = VectorOfContinuous.new(a)
        amean       = localo.calculateArithmeticMean
        gmean       = localo.calculateGeometricMean
        hmean       = localo.calculateHarmonicMean
        assert hmean < amean
        assert hmean < gmean
        a           = [1,2,3,4,5,6,7,8,9]
        localo      = VectorOfContinuous.new(a)
        amean       = localo.calculateArithmeticMean
        gmean       = localo.calculateGeometricMean
        hmean       = localo.calculateHarmonicMean
        assert hmean < amean
        assert hmean < gmean
    end

    it "Has a calculateQuartile method which returns the value for a designated quartile." do
        a  = [0,1,2,3,4,5,6,7,8,9,8,9,9,9,9,9,8,7,8,7,8,7,6,5,4,3,2,1,0]
        sa = a.sort
        #puts "trace a:  #{a}, #{sa}, #{a.size}"
        localo = VectorOfContinuous.new(a)
        qv = localo.calculateQuartile(1)
        assert_equal qv, 3

        a       = [1,2,3,4,5]
        localo  = VectorOfContinuous.new(a)
        qv      = localo.calculateQuartile(0)
        assert_equal qv, 1
        #puts "trace BEGIN first quartile"
        qv      = localo.calculateQuartile(1)
        #puts "trace END first quartile"
        assert_equal qv, 2
        qv      = localo.calculateQuartile(2)
        assert_equal qv, 3
        qv      = localo.calculateQuartile(3)
        assert_equal qv, 4
        qv      = localo.calculateQuartile(4)
        assert_equal qv, 5

        a       = [0,1,2,3,4,5,6,7,8,9,8,9,9,9,9,9,8,7,8,7,8,7,6,5,4,3,2,1,0]
        sa      = a.sort
        localo  = VectorOfContinuous.new(a)
        qv      = localo.calculateQuartile(0)
        assert_equal qv, 0
        qv      = localo.calculateQuartile(1)
        assert_equal qv, 3.0
        qv      = localo.calculateQuartile(2)
        assert_equal qv, 7.0
        qv      = localo.calculateQuartile(3)
        assert_equal qv, 8.0
        qv      = localo.calculateQuartile(4)
        assert_equal qv, 9.0
    end

    it "Generates a Average Absolute Deviation for Arithmetic, Geometric, Harmonic Means, Median, Min, Max, Mode." do
        a           = [1,2,3,4,5,6,7,8.9]
        localo      = VectorOfContinuous.new(a)
        amaad1      = localo.generateAverageAbsoluteDeviation
        assert_equal 2.1125, amaad1
        amaad2      = localo.generateAverageAbsoluteDeviation(VectorOfContinuous::ArithmeticMeanId)
        assert_equal amaad1, amaad2
        gmaad       = localo.generateAverageAbsoluteDeviation(VectorOfContinuous::GeometricMeanId)
        assert_equal 2.1588, gmaad
        hmaad       = localo.generateAverageAbsoluteDeviation(VectorOfContinuous::HarmonicMeanId)
        assert_equal 2.3839, hmaad
        medianaad   = localo.generateAverageAbsoluteDeviation(VectorOfContinuous::MedianId)
        assert_equal 2.1125, medianaad
        minaad      = localo.generateAverageAbsoluteDeviation(VectorOfContinuous::MinId)
        assert_equal 3.6125, minaad
        maxaad      = localo.generateAverageAbsoluteDeviation(VectorOfContinuous::MaxId)
        assert_equal 4.2875, maxaad
        modeaad     = localo.generateAverageAbsoluteDeviation(VectorOfContinuous::ModeId)
        assert_equal 4.2875, modeaad
        a           = [0,1,2,3,4,5,6,7,8,9,8,9,9,9,9,9,8,7,8,7,8,7,6,5,4,3,2,1,0]
        localo      = VectorOfContinuous.new(a)
        aad         = localo.generateAverageAbsoluteDeviation
        assert_equal 2.6112, aad
        aad         = localo.generateAverageAbsoluteDeviation(VectorOfContinuous::MedianId)
        assert_equal 2.5172, aad
    end

    it "Generates a coefficient of variation." do
        a = [1,2,3,4,5,6,7,8.9]
        localo      = VectorOfContinuous.new(a)
        amean       = localo.calculateArithmeticMean
        stddev      = localo.requestStandardDeviation
        herecov     = ( stddev / amean ).round(localo.OutputDecimalPrecision)
        cov         = localo.generateCoefficientOfVariation
        assert_equal cov, herecov
    end

    it "Has two methods to Generate a matrix of histogram data." do
        a = [1,2,3,4,5,6,7,8,9]
        localo = VectorOfContinuous.new(a)
        hdaa = localo.generateHistogramAAbyNumberOfSegments(3,1)
        assert_equal 3, hdaa.size
        hdaa = localo.generateHistogramAAbyNumberOfSegments(3,0)
        assert_equal 3, hdaa.size
        hdaa = localo.generateHistogramAAbyNumberOfSegments(3,-1)
        assert_equal 3, hdaa.size
        hdaa = localo.generateHistogramAAbyNumberOfSegments(4,1)
        assert_equal 4, hdaa.size
        hdaa = localo.generateHistogramAAbyNumberOfSegments(5,0)
        assert_equal 5, hdaa.size
        hdaa = localo.generateHistogramAAbySegmentSize(2,1)
        diff0 = hdaa[0][1] - hdaa[0][0]
        #STDERR.puts "trace diff0 = hdaa[0][1] - hdaa[0][0]:  #{diff0} == #{hdaa[0][1]} - #{hdaa[0][0]}"
        assert_equal diff0, 2.0
        diff1 = hdaa[1][1] - hdaa[1][0]
        assert_equal diff1, 2
        hdaa = localo.generateHistogramAAbySegmentSize(3,0)
        diff2 = hdaa[2][1] - hdaa[2][0]
        assert_equal diff2, 3
    end

    it "Generates a Mean Absolute Difference." do
        a = [1,2,3,4,5,6,7,8.9]
        localo      = VectorOfContinuous.new(a)
        mad         = localo.generateMeanAbsoluteDifference
        assert_equal 3.225, mad
    end

    it "Can get the minimum, median, maximum, and mode." do
        a       = [1,2,3,4,5,6,7,8,9]
        localo  = VectorOfContinuous.new(a)
        assert_equal localo.getCount, 9
        assert_equal 1, localo.getMin
        assert_equal 5, localo.requestMedian
        assert_equal 9, localo.getMax
        assert_equal 1, localo.generateMode # Question here:  should I return a sentinal when it is uniform?  NOTE
        a       = [1,2,3,4,5,6,7,8,9,8,7,8]
        localo  = VectorOfContinuous.new(a)
        min,max = localo.requestRange
        assert_equal localo.getCount, 12
        assert_equal 1, min
        #puts "trace BEGIN median mmmm test"
        assert_equal 6.5, localo.requestMedian
        #puts "trace END median mmmm"
        assert_equal 9, max
        assert_equal 8, localo.generateMode # Question here:  should I return a sentinal when it is uniform?  NOTE
    end

    it "Has a method to test if the Vector Of X has an even N." do
        a = [1,2,3,4,5,6,7,8.9]
        localo      = VectorOfContinuous.new(a)
        assert localo.isEvenN?
        a = [1,2,3,4,5,6,7,8.9,11]
        localo      = VectorOfContinuous.new(a)
        assert ( not localo.isEvenN? )
    end

    it "Has an method to return (get, because it is direct call to language method) the sum." do
        a       = [1,2,2,3,3,3]
        localo  = VectorOfContinuous.new(a)
        assert_equal localo.getCount, 6
        assert_equal 14, localo.getSum
    end

    it "Can request calculation of kurtosis." do
        a = [1,2,3,4,5,6,7,8,9]
        localo  = VectorOfContinuous.new(a)
        ek      = localo.requestExcessKurtosis(2)
        #STDERR.puts "trace ek:  #{ek}"
        assert_equal -1.23, ek
        ek      = localo.requestExcessKurtosis
        assert_equal -1.2, ek
        k       = localo.requestKurtosis
        #STDERR.puts "trace k:  #{k}"
        assert_equal 1.8476, k

        localo.UseDiffFromMeanCalculations = false
        # NOTE:  These need to be implemented so the tests will change. TBD
        assert_raise ArgumentError do
            localo.requestExcessKurtosis(2)
        end
        assert_raise ArgumentError do
            localo.requestExcessKurtosis
        end
        k       = localo.requestKurtosis
        #STDERR.puts "trace k:  #{k}"
        assert_equal 1.8476, k
    end

    it "Can request a complete collection of all 5 quartiles in an array." do
        a       = [1,2,3,4,5]
        localo  = VectorOfContinuous.new(a)
        qa      = localo.requestQuartileCollection
        assert_equal 1, qa[0]
        assert_equal 2, qa[1]
        assert_equal 3, qa[2]
        assert_equal 4, qa[3]
        assert_equal 5, qa[4]
        a           = [0,1,2,3,4,5,6,7,8,9,8,9,9,9,9,9,8,7,8,7,8,7,6,5,4,3,2,1,0,1,2,2,3,3,3,99.336,5.9,0x259,1133.7,1234]
        localo  = VectorOfContinuous.new(a)
        qa      = localo.requestQuartileCollection
        assert_equal 0, qa[0]
        assert_equal 3.0, qa[1]
        assert_equal 6.0, qa[2]
        assert_equal 8.25, qa[3]
        assert_equal 1234, qa[4]
    end

    it "Has some formatted result methods." do
        a       = [1,2,3,4,5,6,7,8,9]
        localo  = VectorOfContinuous.new(a)
        assert_respond_to localo, :requestResultAACSV
        assert localo.requestResultAACSV.is_a?      String
        assert localo.requestResultCSVLine.is_a?    String
        assert localo.requestResultJSON.is_a?       String
    end

    it "Can request a calculation of skewness." do
        a       = [1,2,3,4,5,6,7,8,9]
        localo  = VectorOfContinuous.new(a)
        sk      = localo.requestSkewness
        assert_equal 0, sk
        sk      = localo.requestSkewness(1)
        assert_equal 0, sk
        sk      = localo.requestSkewness(2)
        assert_equal 0, sk
        sk      = localo.requestSkewness(3)
        assert_equal 0, sk
        a       = [1,2,2,3,3,3,4,4,4,4,4,4]
        localo  = VectorOfContinuous.new(a)
        sk      = localo.requestSkewness
        assert_equal -0.9878, sk
        sk1     = localo.requestSkewness(1)
        assert_equal -0.7545, sk1
        sk2     = localo.requestSkewness(2)
        assert_equal -0.8597, sk2
        sk3     = localo.requestSkewness(3)
        assert_equal sk3, sk
    end

    it "Has four standard deviation calculations corresponding to the four variance combinations." do
        a       = [1,2,3]
        localo  = VectorOfContinuous.new(a)
        sdsd    = localo.requestStandardDeviation
        localo.UseDiffFromMeanCalculations = false
        sdsx    = localo.requestStandardDeviation
        assert_equal sdsd, sdsx
        localo.Population = true
        sdsd    = localo.requestStandardDeviation
        localo.UseDiffFromMeanCalculations = false
        sdsx    = localo.requestStandardDeviation
        assert_equal sdsd, sdsx
    end

    it "Has two variance generation methods." do
        a = [1,2,2,3,3,3,99.336,5.9,0x259,1133.7,1234]
        localo = VectorOfContinuous.new(a)
        v = localo.requestVarianceSumOfDifferencesFromMean
        assert_equal 231232.125543275, v
        v = localo.requestVarianceXsSquaredMethod
        assert_equal 231232.12554327273, v
        v = localo.requestVarianceSumOfDifferencesFromMean(true)
        assert_equal 210211.0232211591, v
        v = localo.requestVarianceXsSquaredMethod(true)
        assert_equal 210211.02322115703, v
    end

    it "Input routine pushX validates arguments." do
        lvo = VectorOfContinuous.new
        assert_nothing_raised do
            lvo.pushX(123.456)
        end
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

    it "Fails differently according to special arguments to pushX." do
        # These are the pertinent identifiers:
        #BlankFieldOnBadData = 0
        #FailOnBadData       = 1
        #SkipRowOnBadData    = 2
        #ZeroFieldOnBadData  = 3
        localo = VectorOfContinuous.new
        assert_equal 0, localo.getCount
        assert_raise ArgumentError do
            localo.pushX("")
        end
        assert_equal 0, localo.getCount
        assert_raise ArgumentError do
            localo.pushX("",VectorOfX::BlankFieldOnBadData)
        end
        assert_equal 0, localo.getCount
        assert_raise ArgumentError do
            localo.pushX("",VectorOfX::FailOnBadData)
        end
        assert_equal 0, localo.getCount
        localo.pushX("",VectorOfX::SkipRowOnBadData)
        assert_equal 0, localo.getCount
        localo.pushX("",VectorOfX::ZeroFieldOnBadData)
        assert_equal 1, localo.getCount
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
        assert_equal 2, localo.getCount
    end

    it "Constructs with a Ruby Array." do
        assert_nothing_raised do
            VectorOfDiscrete.new([1.5,99,5876.1234,"some old string"])
        end
        localo = VectorOfDiscrete.new([1.5,99,5876.1234,"some old string"])
        assert_equal 4, localo.getCount
        assert localo.is_a? VectorOfDiscrete
        #assert localo.size == 4
    end

    it "Has a Binomial probability calculation." do
        a = [1,2,3,4,5,6,7,8,9,8]
        localo = VectorOfDiscrete.new(a)
        assert_equal 10, localo.getCount
        assert_respond_to localo, :calculateBinomialProbability
        #assert_equal 0.384, localo.calculateBinomialProbability(8,3,1) # The calculation returned at:  https://stattrek.com/online-calculator/binomial
        assert_equal 0.3840000000000001, localo.calculateBinomialProbability(8,3,1)
    end

    it "Has a method to get the Mode." do
        localo = VectorOfDiscrete.new
        assert_respond_to localo, :requestMode
        localo = VectorOfDiscrete.new([1.5,99,5876.1234,"some old string",99])
        assert_equal 5, localo.getCount
        result = localo.requestMode
        assert_equal 99, result
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

end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of test_SamesLib.simple.rb

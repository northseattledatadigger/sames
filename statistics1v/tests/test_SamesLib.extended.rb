#!/usr/bin/ruby
# test_SamesLib.extended.rb - Simple coverage for efficient first step sanity
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
    raise ArgumentError, "Sole argument must be valid test subtype of Ruby library."
end
require_relative RubyLibFs

require 'rspec/autorun'
require 'rspec/core'
require 'test/unit'

include Test::Unit::Assertions

HereDs=File.expand_path(".", __dir__)
SamesDs=File.expand_path("../..", __dir__)

TestDataDs="#{SamesDs}/testdata"

require "#{SamesDs}/slib/SBinLib.rb"

FirstTestFileFs=returnIfThere("#{TestDataDs}/sidewalkstreetratioupload.csv")

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Tests for Global Support Routines

describe 'getFactorial' do

    it "Can get factorial for a pretty large number." do
        n   = getFactorial(170)
        #x  = 7.257415615e+306 was the online calculation at:  https://www.calculatorsoup.com/calculators/discretemathematics/factorials.php
        x   = 7.257415615307999e+306
        assert_equal x, n
    end

end

describe 'generateModefromFrequencyAA(faaA)' do

    it "returns takes a frequency Associative Array, and returns a mode point statistic." do
        h = Hash.new
        key = nil
        128.times do
            key = rand
            h[key] = rand(1024)
        end
        assert_nothing_raised do
            result = generateModefromFrequencyAA(h)
        end
        assert h[key] >= 0
        assert h[key] <= 1024
    end

end

describe "isUsableNumberVector?" do

    it "It discerns whether all elements of a vector are good numbers for data." do
        assert isUsableNumberVector?([1,2,3,4,5]) == true
    end

end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Tests for HistogramOfX class

describe HistogramOfX do

    it "Construction with large number of ranges." do
        localo = HistogramOfX.new(1,5)
        assert_instance_of HistogramOfX, localo
        i = 0
        2048.times do
            assert_nothing_raised do
                localo.setOccurrenceRange(i,i+1)
            end
            i += 1
        end
        localo.setOccurrenceRange(i,i+1)
        2048.times do
            assert_nothing_raised do
                localo.addToCounts(rand(2048))
            end
        end
        result = nil
        assert_nothing_raised do
            result = localo.generateCountCollection
        end
        assert_equal 2049, result.size # This is large enough for my purposes,
                                        # I think.
    end

end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Tests for SumsOfPowers class

describe SumsOfPowers do

    it "Handles large N." do
        localo = SumsOfPowers.new
        2048.times do
            assert_nothing_raised do
                localo.addToSums(rand)
            end
        end
        result = nil
        assert_nothing_raised do
            result = localo.generateStandardDeviation
        end
       assert result > 0
        assert_nothing_raised do
            result = localo.requestSkewness
        end
        assert result > 0
    end
       
end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Tests for Base Class VectorOfX
#
# Most testing on these routines will be in the daughter classes where the
# behavior is manifest.  Note the initialize method was only defined to aid
# these tests.

describe VectorOfX do

    it "Methods do not fail with large N." do
        a = Array.new
        2048.times do
            2048.times do
                a.push(rand)
            end
        end
        localo = nil
        assert_nothing_raised do
            localo = VectorOfX.new(a)
        end
        assert_equal 4194304, localo.getCount
    end

end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Tests for VectorOfContinuous, and most base class methods inherited.

describe VectorOfContinuous do

    it "Methods do not fail with large N." do
        localo = VectorOfContinuous.new
        2048.times do
            2048.times do
                assert_nothing_raised do
                    localo.pushX(rand)
                end
            end
        end
        assert_equal 4194304, localo.getCount
        assert_nothing_raised do
            localo.calculateArithmeticMean
        end
        assert_nothing_raised do
            localo.calculateGeometricMean
        end
        assert_nothing_raised do
            localo.calculateHarmonicMean
        end
        assert localo.requestStandardDeviation > 0
        qa = nil
        assert_nothing_raised do
            qa = localo.requestQuartileCollection
        end
        assert qa[0].is_a? Numeric
        assert qa[1].is_a? Numeric
        assert qa[0] < qa[1]
        assert qa[2].is_a? Numeric
        assert qa[1] < qa[2]
        assert qa[3].is_a? Numeric
        assert qa[2] < qa[3]
        assert qa[4].is_a? Numeric
        assert qa[3] < qa[4]
    end

end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Tests for VectorOfDiscrete

describe VectorOfDiscrete do

    it "Methods do not fail with large N." do
        localo = VectorOfDiscrete.new
        2048.times do
            2048.times do
                assert_nothing_raised do
                    localo.pushX(rand(100))
                end
            end
        end
        mode = nil
        assert_nothing_raised do
            mode = localo.requestMode
        end
    end

end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Tests for VectorTable

describe VectorTable do

    it "Methods do not fail with large N." do
        vcsa    = [VectorOfContinuous,VectorOfContinuous,VectorOfDiscrete]
        localo  = VectorTable.new(vcsa)
        localv0 = localo.getVectorObject(0)
        localv1 = localo.getVectorObject(1)
        localv2 = localo.getVectorObject(2)
        2048.times do
            2048.times do
                assert_nothing_raised do
                    localv0.pushX(rand)
                end
                assert_nothing_raised do
                    localv1.pushX(rand)
                end
                assert_nothing_raised do
                    localv2.pushX("#{rand(32)}")
                end
                assert_nothing_raised do
                    localo.pushTableRow([rand,rand,"#{rand(32)}"])
                end
            end
        end
        assert_equal 8388608, localv0.getCount
        assert localv0.calculateArithmeticMean.is_a? Numeric
        assert localv0.requestSkewness.is_a? Numeric
        assert localv0.requestStandardDeviation.is_a? Numeric
        assert_equal 8388608, localv1.getCount
        assert localv1.calculateArithmeticMean.is_a? Numeric
        assert_equal 8388608, localv2.getCount
        assert localv2.requestMode.is_a? String
        result = localv2.calculateBinomialProbability("16",29,1)
        assert result > 0.3 # Pretty sure it will be.
        # This should always be pretty close to the same with such a large n.
        # Using p of success 0.03110527992248535, I confirmed this at:  https://stattrek.com/online-calculator/binomial 
    end

    it "Allows a user to load column values from a CSV file (and make all the calculations on vectors filled)." do
        vcsa    = [VectorOfDiscrete,VectorOfDiscrete,VectorOfContinuous,VectorOfContinuous,VectorOfContinuous]
        localo  = VectorTable.newFromCSV(vcsa,FirstTestFileFs,VectorOfX::DefaultFillOnBadData)
        lvi0o   = localo.getVectorObject(0)
        n       = lvi0o.getCount
        mode    = lvi0o.requestMode
        #STDERR.puts "trace n:  #{n}"
        #STDERR.puts "trace mode:  #{mode}"
        assert_equal 2103, n
        assert_equal "420030103001", mode
        lvi1o   = localo.getVectorObject(1)
        lvi2o   = localo.getVectorObject(2)
        lvi3o   = localo.getVectorObject(3)
        amean   = lvi3o.calculateArithmeticMean
        ssd     = lvi3o.requestStandardDeviation
        #STDERR.puts "trace amean:  #{amean}"
        #STDERR.puts "trace ssd:  #{ssd}"
        assert_equal 17134.3322, amean
        assert_equal 29010.7171, ssd
    end

end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of test_SamesLib.extended.rb

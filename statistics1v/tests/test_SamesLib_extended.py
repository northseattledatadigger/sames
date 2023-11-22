#!/usr/bin/ruby
# test_SamesLib_extended.py
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Constants and Includes

import os
import sys 
import unittest

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Tests for Global Support Routines

class Test_generateModeFromFrequencyAA(unittest.TestCase):

    def test_returns takes a frequency Associative Array, and returns a mode point statistic(self):
        h = {}
        key = None
        128.times do
            key = rand
            h[key] = rand(1024)
        assert_nothing_raised do
            result = generateModefromFrequencyAA(h)
        assert h[key] >= 0
        assert h[key] <= 1024


class Test_isUsableNumberVector(unittest.TestCase):

    def test_It_discerns_whether_all_elements_of_a_vector_are_good_numbers_for_data(self):
        self.assertTrue( isUsableNumberVector?([1,2,3,4,5]) )


#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Tests for HistogramOfX class

class Test_HistogramOfX(unittest.TestCase):

    def test_Construction_with_large_number_of_ranges(self):
        localo = HistogramOfX.new(1,5)
        assert_instance_of HistogramOfX, localo
        i = 0
        2048.times do
            assert_nothing_raised do
                localo.setOccurrenceRange(i,i+1)
            i += 1
        localo.setOccurrenceRange(i,i+1)
        2048.times do
            assert_nothing_raised do
                localo.addToCounts(rand(2048))
        result = nil
        assert_nothing_raised do
            result = localo.generateCountCollection
        self.assertEqual(  2049, result.size # This is large enough for my purposes,
                                        # I think.


#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Tests for SumsOfPowers class

class Test_SumsOfPowers(unittest.TestCase):

    def test_Handles large N(self):
        localo = SumsOfPowers.new
        2048.times do
            assert_nothing_raised do
                localo.addToSums(rand)
        result = nil
        assert_nothing_raised do
            result = localo.generateStandardDeviation
       assert result > 0
        assert_nothing_raised do
            result = localo.requestSkewness
        assert result > 0
       

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Tests for Base Class VectorOfX
#
# Most testing on these routines will be in the daughter classes where the
# behavior is manifest.  Note the initialize method was only defined to aid
# these tests.

class Test_VectorOfX(unittest.TestCase):

    def test_Methods do not fail with large N(self):
        a = Array.new
        2048.times do
            2048.times do
                a.push(rand)
        localo = nil
        assert_nothing_raised do
            localo = VectorOfX.new(a)
        self.assertEqual(  4194304, localo.getCount


#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Tests for VectorOfContinuous, and most base class methods inherited.

class Test_VectorOfContinuous(unittest.TestCase):

    def test_Methods do not fail with large N(self):
        localo = VectorOfContinuous.new
        2048.times do
            2048.times do
                assert_nothing_raised do
                    localo.pushX(rand)
        self.assertEqual(  4194304, localo.getCount
        assert_nothing_raised do
            localo.calculateArithmeticMean
        assert_nothing_raised do
            localo.calculateGeometricMean
        assert_nothing_raised do
            localo.calculateHarmonicMean
        assert localo.requestStandardDeviation > 0
        qa = nil
        assert_nothing_raised do
            qa = localo.requestQuartileCollection
        assert qa[0].is_a? Numeric
        assert qa[1].is_a? Numeric
        assert qa[0] < qa[1]
        assert qa[2].is_a? Numeric
        assert qa[1] < qa[2]
        assert qa[3].is_a? Numeric
        assert qa[2] < qa[3]
        assert qa[4].is_a? Numeric
        assert qa[3] < qa[4]


#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Tests for VectorOfDiscrete

class Test_VectorOfDiscrete(unittest.TestCase):

    def test_Methods do not fail with large N(self):
        localo = VectorOfDiscrete.new
        2048.times do
            2048.times do
                assert_nothing_raised do
                    localo.pushX(rand(100))
        mode = nil
        assert_nothing_raised do
            mode = localo.requestMode


#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Tests for VectorTable

class Test_VectorTable(unittest.TestCase):

    def test_Methods do not fail with large N(self):
        vcsa    = [VectorOfContinuous,VectorOfContinuous,VectorOfDiscrete]
        localo  = VectorTable.new(vcsa)
        localv0 = localo.getVectorObject(0)
        localv1 = localo.getVectorObject(1)
        localv2 = localo.getVectorObject(2)
        2048.times do
            2048.times do
                assert_nothing_raised do
                    localv0.pushX(rand)
                assert_nothing_raised do
                    localv1.pushX(rand)
                assert_nothing_raised do
                    localv2.pushX("#{rand(32)}")
                assert_nothing_raised do
                    localo.pushTableRow([rand,rand,"#{rand(32)}"])
        self.assertEqual(  8388608, localv0.getCount
        assert localv0.calculateArithmeticMean.is_a? Numeric
        assert localv0.requestSkewness.is_a? Numeric
        assert localv0.requestStandardDeviation.is_a? Numeric
        self.assertEqual(  8388608, localv1.getCount
        assert localv1.calculateArithmeticMean.is_a? Numeric
        self.assertEqual(  8388608, localv2.getCount
        assert localv2.requestMode.is_a? String
        result = localv2.calculateBinomialProbability("16",29,1)
        assert result > 0.3 # Pretty sure it will be.
        # This should always be pretty close to the same with such a large n.
        # Using p of success 0.03110527992248535, I confirmed this at:  https://stattrek.com/online-calculator/binomial 

    def test_Allows a user to load column values from a CSV file (and make all the calculations on vectors filled)(self):
        vcsa    = [VectorOfDiscrete,VectorOfDiscrete,VectorOfContinuous,VectorOfContinuous,VectorOfContinuous]
        localo  = VectorTable.newFromCSV(vcsa,FirstTestFileFs,VectorOfX::DefaultFillOnBadData)
        lvi0o   = localo.getVectorObject(0)
        n       = lvi0o.getCount
        mode    = lvi0o.requestMode
        #STDERR.puts "trace n:  #{n}"
        #STDERR.puts "trace mode:  #{mode}"
        self.assertEqual(  2103, n
        self.assertEqual(  "420030103001", mode
        lvi1o   = localo.getVectorObject(1)
        lvi2o   = localo.getVectorObject(2)
        lvi3o   = localo.getVectorObject(3)
        amean   = lvi3o.calculateArithmeticMean
        ssd     = lvi3o.requestStandardDeviation
        #STDERR.puts "trace amean:  #{amean}"
        #STDERR.puts "trace ssd:  #{ssd}"
        self.assertEqual(  17134.3322, amean
        self.assertEqual(  29010.7171, ssd


if __name__ == '__main__':

    if len(sys.argv) != 2:
        raise ValueError("Must provide test subset id as sole argument.")

    SubType = sys.argv.pop()

    #print(f"trace 1 {SubType}")
    ScriptPath      = os.path.realpath(__file__)
    #print(f"trace 2 {ScriptPath}")
    HERE            = os.path.dirname(__file__)
    HOME            = os.getenv('HOME') # None

    SAMESHOME       = os.path.abspath(os.path.join(HERE, '../..'))
    #print(f"trace 3 {SAMESHOME}")
    sys.path.append(SAMESHOME) # Not sure this is necessary.

    SamesProjectDs  = os.path.abspath(os.path.join(HERE, '..'))
    #print(f"trace 4 {SamesProjectDs}")
    sys.path.append(SamesProjectDs) # Not sure this is necessary.
    Python3LibFs    = f"{SamesProjectDs}/SamesLib_{SubType}.py"

    if os.path.isfile(Python3LibFs):
        match SubType:
            case "amateur":
                #import SamesLib_amateur as sames
                print("Not Yet Implemented.")
            case "enhanced":
                #import SamesLib_enhanced as sames
                print("Not Yet Implemented.")
            case "naive":
                #import SamesLib_naive as sames
                print("Not Yet Implemented.")
            case "native":
                import SamesLib_native as sames
            case "numpy":
                #import SamesLib_numpy as sames
                print("Not Yet Implemented.")
            case "pandas":
                #import SamesLib_pandas as sames
                print("Not Yet Implemented.")
            case "polars":
                print("Not Yet Implemented.")
            case "vernacular": # This might be one I'll refactor to comply more meticulously with Python mores, if I can ever stand to do it.
                #import SamesLib_vernacular as sames
                print("Not Yet Implemented.")
            case _:
                m = f"."
                raise ValueError(m)
                m = f"Library Under Test {Python3LibFs} NOT found."
                raise ValueError(m)

    unittest.main()

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of test_SamesLib_extended.py


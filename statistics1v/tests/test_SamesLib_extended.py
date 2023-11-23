#!/usr/bin/python3
# test_SamesLib_extended.py
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Constants and Includes

import numbers
import os
import random
import sys 
import unittest

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Tests for Global Support Routines

class Test_generateModeFromFrequencyAA(unittest.TestCase):

    def test_returns_takes_a_frequency_Associative_Array_and_returns_a_mode_point_statistic(self):
        h = {}
        key = None
        for _ in range(128):
            key = random.random()
            h[key] = random.randint(1,1024)
            result = sames.generateModefromFrequencyAA(h)
        self.assertTrue( h[key] >= 0 )
        self.assertTrue( h[key] <= 1024 )


class Test_isUsableNumberVector(unittest.TestCase):

    def test_It_discerns_whether_all_elements_of_a_vector_are_good_numbers_for_data(self):
        self.assertTrue( sames.isUsableNumberVector([1,2,3,4,5]) )


#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Tests for HistogramOfX class

class Test_HistogramOfX(unittest.TestCase):

    def test_Construction_with_large_number_of_ranges(self):
        localo  = sames.HistogramOfX(1,5)
        self.assertIsInstance( localo, sames.HistogramOfX )
        i       = 0
        for _ in range(2048):
            localo.setOccurrenceRange(i,i+1)
            i   += 1
        localo.setOccurrenceRange(i,i+1)
        for _ in range(2048):
            localo.addToCounts(random.randint(1,2048))
        result  = localo.generateCountCollection()
        rsize   = len(result)
        self.assertEqual(  2049, rsize ) # This is large enough for my purposes,
                                                # I think.


#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Tests for SumsOfPowers class

class Test_SumsOfPowers(unittest.TestCase):

    def test_Handles_large_N(self):
        localo = sames.SumsOfPowers()
        for _ in range(2048):
            localo.addToSums(random.random())
        result = localo.generateStandardDeviation()
        self.assertGreater( result, 0 )
        result = localo.requestSkewness()
        self.assertGreater( result, 0 )
       

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Tests for Base Class VectorOfX
#
# Most testing on these routines will be in the daughter classes where the
# behavior is manifest.  Note the initialize method was only defined to aid
# these tests.

class Test_VectorOfX(unittest.TestCase):

    def test_Methods_do_not_fail_with_large_N(self):
        a = []
        for _ in range(2048):
            for _ in range(2048):
                a.append(random.random())
        localo = sames.VectorOfX(a)
        self.assertEqual( 4194304, localo.getCount() )


#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Tests for VectorOfContinuous, and most base class methods inherited.

class Test_VectorOfContinuous(unittest.TestCase):

    def test_Methods_do_not_fail_with_large_N(self):
        localo = sames.VectorOfContinuous()
        for _ in range(2048):
            for _ in range(2048):
                xc = random.random() + 1.0
                #print(f"trace 5 test_Methods_do_not_fail_with_large_N{xc}")
                localo.pushX(xc)
        self.assertEqual( 4194304, localo.getCount() )
        localo.calculateArithmeticMean()
        localo.calculateGeometricMean()
        localo.calculateHarmonicMean()
        self.assertGreater( localo.requestStandardDeviation(), 0 )
        qa = localo.requestQuartileCollection()
        self.assertTrue( isinstance(qa[0],numbers.Number) )
        self.assertTrue( isinstance(qa[1],numbers.Number) )
        self.assertTrue( isinstance(qa[2],numbers.Number) )
        self.assertTrue( isinstance(qa[3],numbers.Number) )
        self.assertTrue( isinstance(qa[4],numbers.Number) )
        self.assertLess( qa[0],qa[1] )
        self.assertLess( qa[1],qa[2] )
        self.assertLess( qa[2],qa[3] )
        self.assertLess( qa[3],qa[4] )


#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Tests for VectorOfDiscrete

class Test_VectorOfDiscrete(unittest.TestCase):

    def test_Methods_do_not_fail_with_large_N(self):
        localo = sames.VectorOfDiscrete()
        for _ in range(2048):
            for _ in range(2048):
                localo.pushX(random.randint(1,100))
        mode = localo.requestMode()


#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Tests for VectorTable

class Test_VectorTable(unittest.TestCase):

    def test_Methods_do_not_fail_with_large_N(self):
        vcsa    = [sames.VectorOfContinuous,sames.VectorOfContinuous,sames.VectorOfDiscrete]
        localo  = sames.VectorTable(vcsa)
        localv0 = localo.getVectorObject(0)
        localv1 = localo.getVectorObject(1)
        localv2 = localo.getVectorObject(2)
        #print(f"trace 3 test_Methods_do_not_fail_with_large_N {localv0.getCount()}, {localv1.getCount()}, {localv2.getCount()}")
        for _ in range(2048):
            #print(f"trace 3a test_Methods_do_not_fail_with_large_N {localv0.getCount()}, {localv1.getCount()}, {localv2.getCount()}")
            for _ in range(2048):
                #print(f"trace 3b test_Methods_do_not_fail_with_large_N {localv0.getCount()}, {localv1.getCount()}, {localv2.getCount()}")
                localv0.pushX(random.random())
                localv1.pushX(random.random())
                localv2.pushX(f"{random.randint(1,32)}")
                #print(f"trace 3e test_Methods_do_not_fail_with_large_N {localv0.getCount()}, {localv1.getCount()}, {localv2.getCount()}")
                localo.pushTableRow([random.random(),random.random(),f"{random.randint(1,32)}"])
                #print(f"trace 3f test_Methods_do_not_fail_with_large_N {localv0.getCount()}, {localv1.getCount()}, {localv2.getCount()}")
        #print(f"trace 4 test_Methods_do_not_fail_with_large_N {localv0.getCount()}, {localv1.getCount()}, {localv2.getCount()}")
        self.assertEqual( 8388608, localv0.getCount() )
        self.assertTrue( isinstance(localv0.calculateArithmeticMean(),numbers.Number) )
        self.assertTrue( isinstance(localv0.requestSkewness(),numbers.Number) )
        self.assertTrue( isinstance(localv0.requestStandardDeviation(),numbers.Number) )
        self.assertEqual( 8388608, localv1.getCount() )
        self.assertTrue( isinstance( localv1.calculateArithmeticMean(),numbers.Number) )
        # AssertionError: 8388608 != 12582912 was a failure I got at 2023/11/22 16:30. xc
        self.assertEqual( 8388608, localv2.getCount() )
        self.assertTrue( isinstance(localv2.requestMode(),str) )
        result = localv2.calculateBinomialProbability("16",29,1)
        self.assertGreater( result, 0.3 ) # Pretty sure it will be.
        # This should always be pretty close to the same with such a large n.
        # Using p of success 0.03110527992248535, I confirmed this at:  https://stattrek.com/online-calculator/binomial 

    def test_Allows_a_user_to_load_column_values_from_a_CSV_file_and_make_all_the_calculations_on_vectors_filled(self):
        vcsa    = [sames.VectorOfDiscrete,sames.VectorOfDiscrete,sames.VectorOfContinuous,sames.VectorOfContinuous,sames.VectorOfContinuous]
        localo  = sames.VectorTable.newFromCSV(vcsa,FirstTestFileFs,sames.VectorOfX.DefaultFillOnBadData)
        lvi0o   = localo.getVectorObject(0)
        n       = lvi0o.getCount()
        mode    = lvi0o.requestMode()
        self.assertEqual(  2103, n )
        self.assertEqual(  "420030103001", mode )
        lvi1o   = localo.getVectorObject(1)
        lvi2o   = localo.getVectorObject(2)
        lvi3o   = localo.getVectorObject(3)
        amean   = lvi3o.calculateArithmeticMean()
        ssd     = lvi3o.requestStandardDeviation()
        self.assertEqual( 17134.3322, amean )
        self.assertEqual( 29010.7171, ssd )


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

    TestDataDs      = f"{SAMESHOME}/testdata"

    SAMESSLIB       = os.path.abspath(os.path.join(SAMESHOME, 'slib'))
    sys.path.append(SAMESSLIB)

    import SBinLib as sbl

    SamesProjectDs  = os.path.abspath(os.path.join(HERE, '..'))
    #print(f"trace 4 {SamesProjectDs}")
    sys.path.append(SamesProjectDs)
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

    FirstTestFileFs = sbl.returnIfThere(f"{TestDataDs}/sidewalkstreetratioupload.csv")

    unittest.main()

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of test_SamesLib_extended.py


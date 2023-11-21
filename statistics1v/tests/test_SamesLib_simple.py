#!/usr/bin/python3
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# test_SamesLib_simple.py

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Constants and Imports

import os
import sys 
import unittest

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Tests for Global Procedures

class Test_generateModefromFrequencyAA(unittest.TestCase):

    def test_Raises_ValueError_if_argument_not_dictionary(self):
        with self.assertRaises(ValueError) as context:
            sames.generateModefromFrequencyAA(None)
        self.assertTrue("Only argument must be frequency dictionary." in str(context.exception))
        with self.assertRaises(ValueError) as context:
            sames.generateModefromFrequencyAA(333)
        self.assertTrue("Only argument must be frequency dictionary." in str(context.exception))
        with self.assertRaises(ValueError) as context:
            sames.generateModefromFrequencyAA("a string")
        self.assertTrue("Only argument must be frequency dictionary." in str(context.exception))
        with self.assertRaises(ValueError) as context:
            sames.generateModefromFrequencyAA([])
        self.assertTrue("Only argument must be frequency dictionary." in str(context.exception))

    def test_anecdote_expected_results(self):
        d = {'1234': 528, 528: 3, "A longer string": 0, "x": 55555 }
        result = sames.generateModefromFrequencyAA(d)
        self.assertEqual("x", result)

class Test_isANumStr(unittest.TestCase):

    def test_sees_number_strings(self):
        self.assertTrue(sames.isANumStr('1234'))
        self.assertTrue(sames.isANumStr('1234.56789'))
        self.assertTrue(sames.isANumStr('.1234'))
        self.assertTrue(sames.isANumStr('1234.0'))
        self.assertFalse(sames.isANumStr('12 34'))
        self.assertFalse(sames.isANumStr('12x34'))
        self.assertFalse(sames.isANumStr('A'))
        self.assertFalse(sames.isANumStr('%'))
        self.assertFalse(sames.isANumStr(''))

    def test_rejects_non_strings(self):
        self.assertFalse(sames.isANumStr(1234))
        self.assertFalse(sames.isANumStr(15.993))
        self.assertFalse(sames.isANumStr(0.1234))

class Test_isNumericVector(unittest.TestCase):

    def test_vector_has_all_good_numbers(self):
        self.assertTrue(sames.isNumericVector([1,2,3,4,5]))
        self.assertFalse(sames.isNumericVector(['1',2,'33.33',"4"]))
        self.assertFalse(sames.isNumericVector(['1',2]))
        self.assertFalse(sames.isNumericVector([2,'33.33']))
        self.assertFalse(sames.isNumericVector([]))
        self.assertFalse(sames.isNumericVector(["4",5,6]))
        self.assertTrue(sames.isNumericVector([2,33.33,4,0x5,12341234123412341234]))
        self.assertFalse(sames.isNumericVector(['x',2,3,4,5]))
        self.assertFalse(sames.isNumericVector([' 1 1 ',2,3,4,5]))

    def test_Raises_ValueError_unless_vector_is_array(self):
        with self.assertRaises(ValueError) as context:
            sames.isNumericVector(None)
        with self.assertRaises(ValueError) as context:
            sames.isNumericVector(333)
        with self.assertRaises(ValueError) as context:
            sames.isNumericVector("a string")
        with self.assertRaises(ValueError) as context:
            sames.isNumericVector({})

class Test_isUsableNumber(unittest.TestCase):

    def test_Accepts_any_number_or_string_number(self):
        self.assertTrue(sames.isUsableNumber(1234))
        self.assertTrue(sames.isUsableNumber(15.993))
        self.assertTrue(sames.isUsableNumber(0.1234))
        self.assertTrue(sames.isUsableNumber('1234'))
        self.assertTrue(sames.isUsableNumber('1234.56789'))
        self.assertTrue(sames.isUsableNumber('.1234'))
        self.assertTrue(sames.isUsableNumber('1234.0'))

    def test_Rejects_non_numeric_stuff(self):
        self.assertFalse(sames.isUsableNumber('%'))
        self.assertFalse(sames.isUsableNumber('12 34'))
        self.assertFalse(sames.isUsableNumber('12x4'))
        self.assertFalse(sames.isUsableNumber('A'))
        self.assertFalse(sames.isUsableNumber(r"ABC"))
        self.assertFalse(sames.isUsableNumber({}))

class Test_isUsableNumberVector(unittest.TestCase):

    def test_discerns_whether_all_elements_vector_are_numbers(self):
        self.assertTrue(sames.isUsableNumberVector([1,2,3,4,5]))
        self.assertTrue(sames.isUsableNumberVector(['1',2,'33.33',"4"]))
        self.assertTrue(sames.isUsableNumberVector(['1',2]))
        self.assertTrue(sames.isUsableNumberVector([2,'33.33']))
        self.assertTrue(sames.isUsableNumberVector(["4",5,6]))
        self.assertTrue(sames.isUsableNumberVector([2,33.33,4,0x5,12341234123412341234]))
        self.assertFalse(sames.isUsableNumberVector(['x',2,3,4,5]))
        self.assertFalse(sames.isUsableNumberVector([' 1 1 ',2,3,4,5]))

    def tets_Raises_ValueError_unless_argument_is_Array(self):
        with self.assertRaises(ValueError) as context:
            sames.isUsableNumberVector(None)
        with self.assertRaises(ValueError) as context:
            sames.isUsableNumberVector(333)
        with self.assertRaises(ValueError) as context:
            sames.isUsableNumberVector("a string")
        with self.assertRaises(ValueError) as context:
            sames.isUsableNumberVector({})

class Test_validateStringNumberRange(unittest.TestCase):

    def test_Throws_RangeError_if_number_is_too_big(self):
        with self.assertRaises(ValueError) as context:
            sames.validateStringNumberRange(99)
        sames.validateStringNumberRange("1234.56789")
        sames.validateStringNumberRange("999999999999999999999999999999999999999999999999999999999999999999999999999999999999.999999999999999999999999999999999999999999999999999999")
        with self.assertRaises(IndexError) as context:
            sames.validateStringNumberRange("99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999.999999999999999999999999999999999999999999999999999999")

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Tests for HistogramOfX class

class Test_HistogramOfX_Class(unittest.TestCase):

    def test_Simple_Construction(self):
        localo = sames.HistogramOfX(1,5)
        self.assertIsInstance( localo, sames.HistogramOfX )
        localo.setOccurrenceRange(1,3)
        localo.setOccurrenceRange(3,6)
        tracecount = localo.FrequencyAA[1].Count
        localo.addToCounts(1)
        tracecount = localo.FrequencyAA[1].Count
        localo.addToCounts(1)
        localo.addToCounts(2)
        localo.addToCounts(3)
        localo.addToCounts(3)
        localo.addToCounts(3)
        result = localo.generateCountCollection()
        self.assertEqual( result[0][0], 1 )
        self.assertEqual( result[0][1], 3 )
        self.assertEqual( result[0][2], 3 )
        self.assertEqual( result[1][0], 3 )
        self.assertEqual( result[1][1], 6 )
        self.assertEqual( result[1][2], 3 )

    def test_Construction_by_Segment_Size(self):
        localo = sames.HistogramOfX.newFromUniformSegmentSize(1,5,3)
        localo.addToCounts(1)
        localo.addToCounts(1)
        localo.addToCounts(2)
        localo.addToCounts(3)
        localo.addToCounts(3)
        localo.addToCounts(3)
        result = localo.generateCountCollection()
        self.assertEqual( result[0][0], 1 )
        self.assertEqual( result[0][1], 4 )
        self.assertEqual( result[0][2], 6 )
        self.assertEqual( result[1][0], 4 )
        self.assertEqual( result[1][1], 7 )
        self.assertEqual( result[1][2], 0 )


    def test_Construction_by_Number_of_Segments(self):
        localo = sames.HistogramOfX.newFromDesiredSegmentCount(1,5,2)
        localo.addToCounts(1)
        localo.addToCounts(1)
        localo.addToCounts(2)
        localo.addToCounts(3)
        localo.addToCounts(3)
        localo.addToCounts(3)
        result = localo.generateCountCollection()
        self.assertEqual( result[0][0], 1 )
        self.assertEqual( result[0][1], 3.5 )
        self.assertEqual( result[0][2], 6 )
        self.assertEqual( result[1][0], 3.5 )
        self.assertEqual( result[1][1], 6 )
        self.assertEqual( result[1][2], 0 )

    def test_Internal_class_RangeOccurrence(self):
        localo = sames.RangeOccurrence(1,2)
        self.assertIsInstance( localo, sames.RangeOccurrence )
        self.assertEqual( 0, localo.Count )
        self.assertEqual( 1, localo.StartNo )
        self.assertEqual( 2, localo.StopNo )
        localo.addToCount()
        self.assertEqual( 1, localo.Count )
        self.assertTrue( localo.hasOverlap(1,2) )
        self.assertFalse( localo.hasOverlap(2,3) )
        self.assertTrue( localo.isInRange(1) )
        self.assertTrue( localo.isInRange(1.5) )
        self.assertFalse( localo.isInRange(2) )

    def test_Internal_validation_against_overlapping_ranges(self):
        localo = sames.HistogramOfX(-128,128)
        localo.setOccurrenceRange(-128,-64)
        localo.setOccurrenceRange(-64,0)
        localo.setOccurrenceRange(0,64)
        localo.setOccurrenceRange(64,129)
        with self.assertRaises(ValueError) as context:
            localo.setOccurrenceRange(25,99)

    def test_Adding_to_counts(self):
        localo = sames.HistogramOfX(-5,0)
        localo.setOccurrenceRange(0,5)
        localo.addToCounts(1)
        localo.addToCounts(2)
        localo.addToCounts(-3)
        with self.assertRaises(ValueError) as context:
            localo.addToCounts(8)

    def test_Generating_an_ordered_list_of_vectors_of_counts(self):
        localo = sames.HistogramOfX(-128,128)
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
        result = localo.generateCountCollection()
        self.assertEqual( result[1][0], -64 )
        self.assertEqual( result[1][1], 0 )
        self.assertEqual( result[1][2], 1 )
        self.assertEqual( result[3][0], 64 )
        self.assertEqual( result[3][1], 129 )
        self.assertEqual( result[3][2], 1 )

    def test_Validation_that_the_Range_is_Complete(self):
        localo = sames.HistogramOfX(-128,128)
        localo.setOccurrenceRange(-128,-64)
        localo.setOccurrenceRange(-64,0)
        localo.setOccurrenceRange(0,64)
        localo.setOccurrenceRange(64,129)
        localo.validateRangesComplete
        localo.setOccurrenceRange(244,256)
        with self.assertRaises(IndexError) as context:
            localo.validateRangesComplete()
       
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Tests for SumsOfPowers class

class Test_SumsOfPowers_Class(unittest.TestCase):

    def test_Has_just_one_native_constructor(self):
        localo = sames.SumsOfPowers(False)
        self.assertIsInstance( localo, sames.SumsOfPowers )

    def test_Generation_of_Pearsons_First_Skewness_Coefficient_with_class_method(self):
        # Need data here for better knowledge.  For now just make sure a number comes out.
        a = sames.SumsOfPowers.calculatePearsonsFirstSkewnessCoefficient(25,3,1.57)
        self.assertEqual( 14.012738853503183, a )
       
    def test_Generation_of_Pearsons_Second_Skewness_Coefficient_with_class_method(self):
        # Need data here for better knowledge.  For now just make sure a number comes out.
        a = sames.SumsOfPowers.calculatePearsonsSecondSkewnessCoefficient(25,3,1.57)
        self.assertEqual( 14.012738853503183, a )
        #STDERR.puts "trace a:  #{a}"
       
    def test_Generate_second_moment_Subject_Xs_sum(self):
        localo = sames.SumsOfPowers(False)
        self.assertTrue( hasattr(localo,'_calculateSecondMomentSubjectXs') )
        self.assertTrue( callable(localo._calculateSecondMomentSubjectXs) )
        with self.assertRaises( ZeroDivisionError ) as context:
            a = localo._calculateSecondMomentSubjectXs()
        localo.addToSums(3)
        localo.addToSums(4)
        localo.addToSums(5)
        a = localo._calculateSecondMomentSubjectXs()

    def test_Generate_third_moment_Subject_Xs_sum(self):
        localo = sames.SumsOfPowers(False)
        self.assertTrue( hasattr(localo,'_calculateThirdMomentSubjectXs') )
        self.assertTrue( callable(localo._calculateThirdMomentSubjectXs) )
        a = localo._calculateThirdMomentSubjectXs()

    def test_Generate_fourth_moment_Subject_Xs_sum(self):
        localo = sames.SumsOfPowers(False)
        self.assertTrue( hasattr(localo,'_calculateFourthMomentSubjectXs') )
        self.assertTrue( callable(localo._calculateFourthMomentSubjectXs) )
        a = localo._calculateFourthMomentSubjectXs()

    def test_Adding_to_the_sums(self):
        localo = sames.SumsOfPowers(False)
        localo.addToSums(3)
        self.assertEqual( 1, localo.N )
        localo.addToSums(3)
        localo.addToSums(4)
        localo.addToSums(5)

    def test_Generating_kurtosis(self):
        a = [3,3,4,5]
        localo  = sames.SumsOfPowers(False)
        sizeofa = len(a)
        sumofa  = sum(a)
        localo.setToDiffsFromMeanState(sumofa,sizeofa)
        localo.addToSums(a[0])
        self.assertEqual( sizeofa, localo.N )
        self.assertEqual( 4, localo.N )
        localo.addToSums(a[1])
        localo.addToSums(a[2])
        localo.addToSums(a[3])
        self.assertEqual( 4, localo.N )
        result  = localo.requestKurtosis()
        #STDERR.puts "trace Generating kurtosis:  #{result}"
        #self.assertEqual( -4.5, result )
        self.assertEqual( 4.48879632289572, result )

    def test_Generating_skewness(self):
        localo = sames.SumsOfPowers(False)
        localo.addToSums(3)
        self.assertEqual( 1, localo.N )
        localo.addToSums(3)
        localo.addToSums(4)
        localo.addToSums(5)
        localo.addToSums(6)
        result = localo.requestSkewness()
        self.assertEqual( 56.25011459381775, result )

    def test_Generating_standard_deviation(self):
        localo = sames.SumsOfPowers(False)
        localo.addToSums(3)
        self.assertEqual( 1, localo.N )
        localo.addToSums(3)
        localo.addToSums(4)
        localo.addToSums(4)
        result = localo.generateStandardDeviation()
        self.assertEqual( 0.5773502691896257, result )

    def test_Generating_variance(self):
        localo = sames.SumsOfPowers(False)
        localo.setToDiffsFromMeanState(15,4)
        localo.addToSums(3)
        localo.addToSums(3)
        localo.addToSums(4)
        localo.addToSums(5)
        result = localo.calculateVarianceUsingSubjectAsDiffs()
        self.assertEqual( 19.666666666666668, result )
        localo = sames.SumsOfPowers(False)
        localo.addToSums(3)
        localo.addToSums(3)
        localo.addToSums(4)
        localo.addToSums(5)
        result = localo.calculateVarianceUsingSubjectAsSumXs()
        self.assertEqual( 0.9166666666666666, result )

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Tests for Base Class VectorOfX
#
# Most testing on these routines will be in the daughter classes where the
# behavior is manifest.  Note the initialize method was only defined to aid
# these tests.

class Test_VectorOfX_Class(unittest.TestCase):

    def test_has_a__assureSortedVectorOfX_method_for_internal_updates_to_the_SortedVectorOfX_vector(self):
        a       = [3,2,1]
        localo  = sames.VectorOfX(a)
        self.assertTrue( hasattr(localo,'_assureSortedVectorOfX') )
        self.assertTrue( callable(localo._assureSortedVectorOfX) )
        localo._assureSortedVectorOfX()
        lsvx    = len(localo.SortedVectorOfX)
        self.assertEqual(lsvx, 3)
        self.assertEqual(localo.SortedVectorOfX[0], 1)
        self.assertEqual(localo.SortedVectorOfX[1], 2)
        self.assertEqual(localo.SortedVectorOfX[2], 3)

    def test_Constructs_with_no_argument_or_ruby_array(self):
        localo = sames.VectorOfX()
        a = [1.5,99,5876.1234,"String",""]
        localo = sames.VectorOfX(a)
        self.assertIsInstance( localo, sames.VectorOfX )

    def test_Has_a_working_getCount_method(self):
        localo = sames.VectorOfX()
        self.assertEqual( 0, localo.getCount() )
        a = [1.5,99,5876.1234,"String",""]
        localo = sames.VectorOfX(a)
        self.assertEqual( 5, localo.getCount() )

    def test_Has_a_working_getX_method(self):
        a = [1.5,99,5876.1234,"String",""]
        localo = sames.VectorOfX(a)
        self.assertEqual( localo.getX(2),5876.1234 )

    def test_pushX_method_is_pure_virtual(self):
        localo = sames.VectorOfX()
        self.assertTrue( hasattr(localo,'pushX') )
        self.assertTrue( callable(localo.pushX) )
        with self.assertRaises( ValueError ) as context:
            localo.pushX("anything",sames.VectorOfX.DefaultFillOnBadData)

    def test_requestResultAACSV_method_is_pure_virtual(self):
        localo = sames.VectorOfX()
        self.assertTrue( hasattr(localo,'requestResultAACSV') )
        self.assertTrue( callable(localo.requestResultAACSV) )

    def test_requestResultCSVLine_method_is_pure_virtual(self):
        localo = sames.VectorOfX()
        self.assertTrue( hasattr(localo,'requestResultCSVLine') )
        self.assertTrue( callable(localo.requestResultCSVLine) )

    def test_requestResultCSVJSON_method_is_pure_virtual(self):
        localo = sames.VectorOfX()
        self.assertTrue( hasattr(localo,'requestResultJSON') )
        self.assertTrue( callable(localo.requestResultJSON) )

    def test_Has_tranformation_method_to_output_a_line_of_CSV_for_the_VectorOfX_data(self):
        a = [1.5,99,5876.1234,"String"]
        localo = sames.VectorOfX(a)
        result = localo.transformToCSVLine()
        self.assertEqual( "1.5,99,5876.1234,\"String\"", result )

    def test_Has_tranformation_method_to_output_a_string_of_JSON_for_the_VectorOfX_data(self):
        a = [1.5,99,5876.1234,"String",""]
        localo = sames.VectorOfX(a)
        s = localo.transformToJSON()
        self.assertRegex(s, "5876.1234")

    def test_Has_read_handles_for_internal_data_arrays(self):
        a = [1.5,99,5876.1234,"String",""]
        localo = sames.VectorOfX(a)
        self.assertTrue( hasattr(localo,'VectorOfX') )
        self.assertTrue( hasattr(localo,'SortedVectorOfX') )


class Test_VectorOfContinuous_Class(unittest.TestCase):

    def test_argument_usage(self):
        pass

    def test_anecdote_expected_results(self):
        pass

class Test_VectorOfDiscrete_Class(unittest.TestCase):

    def test_argument_usage(self):
        pass

    def test_anecdote_expected_results(self):
        pass

class Test_VectorTable_Class(unittest.TestCase):

    def test_argument_usage(self):
        pass

    def test_anecdote_expected_results(self):
        pass

class TestMyModule(unittest.TestCase):

    def test_product(self):
        result = 6
        self.assertEqual(result, 6)

class Test2MyModule(unittest.TestCase):

    def test_product(self):
        result = 6
        self.assertEqual(result, 6)

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
# End of test_SamesLib_simple.py


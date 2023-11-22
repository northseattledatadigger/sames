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


#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Tests for sames.VectorOfContinuous, and most base class methods inherited.

class Test_VectorOfContinuous_Class(unittest.TestCase):

    def test_Constructs_with_no_argument(self):
        localo = sames.VectorOfContinuous()
        self.assertIsInstance( localo, sames.VectorOfContinuous )
        localo.pushX(5.333)

    def test_Constructs_with_a_Ruby_Array(self):
        sames.VectorOfContinuous([1.5,99,5876.1234])
        localo = sames.VectorOfContinuous([99.336,5.9,0x259,88441133.7,1234])
        self.assertIsInstance( localo, sames.VectorOfContinuous )

'''
    def test_Has_constructor_which_drops_bad_values(self):
        a = ["1.5","99","5876.1234","1234 ","asdf"]
        localo = nil
        assert_nothing_raised do
            localo = sames.VectorOfContinuousAfterInvalidatedDropped(a,false)
        assert_equal 4, localo.getCount
        assert_equal 1.5, localo.getMin
        assert_equal 5876.1234, localo.getMax

    def test_Has_internal_focused_method_to_construct_a_new_SumsOfPowers_object_for_moment_statistics(self):
        a = [1,2,3]
        localo  = sames.VectorOfContinuous(a)
        assert_equal localo.getCount, 3
        assert_respond_to localo, :_addUpXsToSumsOfPowers
        sopo    = localo._addUpXsToSumsOfPowers
        assert sopo.is_a? SumsOfPowers

    def test_Has_internal_focused_method_to_decide_startno_value_for_histogram(self):
        a = [1,2,3]
        localo = sames.VectorOfContinuous(a)
        assert_equal localo.getCount, 3
        startno = localo._decideHistogramStartNumber
        assert startno == 1
        startno = localo._decideHistogramStartNumber(0)
        assert startno == 0

    def test_Calculates_arithmetic_mean_in_two_places(self):
        a = [1,2,3]
        localo  = sames.VectorOfContinuous(a)
        vocoam  = localo.calculateArithmeticMean
        sopo    = localo._addUpXsToSumsOfPowers
        assert sopo.is_a? SumsOfPowers
        sopoam  = sopo.ArithmeticMean
        assert_equal vocoam, sopoam

    def test_Calculates_geometric_mean(self):
        a = [1,2,3,4,5]
        localo  = sames.VectorOfContinuous(a)
        gmean  = localo.calculateGeometricMean
        assert_equal 2.6052, gmean
        a           = [2,2,2,2]
        localo      = sames.VectorOfContinuous(a)
        amean       = localo.calculateArithmeticMean
        gmean       = localo.calculateGeometricMean
        assert_equal amean, gmean
        a           = [1,2,3,4,5,6,7,8,9]
        localo      = sames.VectorOfContinuous(a)
        amean       = localo.calculateArithmeticMean
        gmean       = localo.calculateGeometricMean
        assert amean > gmean

    def test_Calculates_harmonic_mean(self):
        a = [1,2,3,4,5]
        localo  = sames.VectorOfContinuous(a)
        hmean  = localo.calculateHarmonicMean
        assert_equal 2.1898, hmean
        a           = [2,2,2,2]
        localo      = sames.VectorOfContinuous(a)
        amean       = localo.calculateArithmeticMean
        gmean       = localo.calculateGeometricMean
        hmean       = localo.calculateHarmonicMean
        assert_equal amean, gmean
        assert_equal amean, hmean
        a           = [1,2,3,4,5,6,7,8,9]
        localo      = sames.VectorOfContinuous(a)
        amean       = localo.calculateArithmeticMean
        gmean       = localo.calculateGeometricMean
        hmean       = localo.calculateHarmonicMean
        assert amean > gmean
        assert gmean > hmean

    def test_Has_a_calculateQuartile_method_which_returns_the_value_for_a_designated_quartile(self):
        a  = [0,1,2,3,4,5,6,7,8,9,8,9,9,9,9,9,8,7,8,7,8,7,6,5,4,3,2,1,0]
        sa = a.sort
        #puts "trace a:  #{a}, #{sa}, #{a.size}"
        localo = sames.VectorOfContinuous(a)
        qv = localo.calculateQuartile(1)
        assert_equal qv, 3

        a       = [1,2,3,4,5]
        localo  = sames.VectorOfContinuous(a)
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
        localo  = sames.VectorOfContinuous(a)
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

    def test_Generates_a_Average_Absolute_Deviation_for_Arithmetic_Geometric_Harmonic_Means_Median_Min_Max_Mode(self):
        a           = [1,2,3,4,5,6,7,8.9]
        localo      = sames.VectorOfContinuous(a)
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
        localo      = sames.VectorOfContinuous(a)
        aad         = localo.generateAverageAbsoluteDeviation
        assert_equal 2.6112, aad
        aad         = localo.generateAverageAbsoluteDeviation(VectorOfContinuous::MedianId)
        assert_equal 2.5172, aad

    def test_Generates_a_coefficient_of_variation(self):
        a = [1,2,3,4,5,6,7,8.9]
        localo      = sames.VectorOfContinuous(a)
        amean       = localo.calculateArithmeticMean
        stddev      = localo.requestStandardDeviation
        herecov     = ( stddev / amean ).round(localo.OutputDecimalPrecision)
        cov         = localo.generateCoefficientOfVariation
        assert_equal cov, herecov

    def test_Has_two_methods_to_Generate_a_matrix_of_histogram_data(self):
        a = [1,2,3,4,5,6,7,8,9]
        localo = sames.VectorOfContinuous(a)
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

    def test_Generates_a_Mean_Absolute_Difference(self):
        a = [1,2,3,4,5,6,7,8.9]
        localo      = sames.VectorOfContinuous(a)
        mad         = localo.generateMeanAbsoluteDifference
        assert_equal 3.225, mad

    def test_Can_get_the_minimum_median_maximum_and_mode(self):
        a       = [1,2,3,4,5,6,7,8,9]
        localo  = sames.VectorOfContinuous(a)
        assert_equal localo.getCount, 9
        assert_equal 1, localo.getMin
        assert_equal 5, localo.requestMedian
        assert_equal 9, localo.getMax
        assert_equal 1, localo.generateMode # Question here:  should I return a sentinal when it is uniform?  NOTE
        a       = [1,2,3,4,5,6,7,8,9,8,7,8]
        localo  = sames.VectorOfContinuous(a)
        min,max = localo.requestRange
        assert_equal localo.getCount, 12
        assert_equal 1, min
        #puts "trace BEGIN median mmmm test"
        assert_equal 6.5, localo.requestMedian
        #puts "trace END median mmmm"
        assert_equal 9, max
        assert_equal 8, localo.generateMode # Question here:  should I return a sentinal when it is uniform?  NOTE

    def test_Has_a_method_to_test_if_the_Vector_Of_X_has_an_even_N(self):
        a = [1,2,3,4,5,6,7,8.9]
        localo      = sames.VectorOfContinuous(a)
        assert localo.isEvenN?
        a = [1,2,3,4,5,6,7,8.9,11]
        localo      = sames.VectorOfContinuous(a)
        assert ( not localo.isEvenN? )

    def test_Has_an_method_to_return_the_sum(self):
        a       = [1,2,2,3,3,3]
        localo  = sames.VectorOfContinuous(a)
        assert_equal localo.getCount, 6
        assert_equal 14, localo.getSum

    def test_Can_request_calculation_of_kurtosis(self):
        a = [1,2,3,4,5,6,7,8,9]
        localo  = sames.VectorOfContinuous(a)
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
        assert_raise ArgumentError do
            localo.requestExcessKurtosis
        k       = localo.requestKurtosis
        #STDERR.puts "trace k:  #{k}"
        assert_equal 1.8476, k

    def test_Can_request_a_complete_collection_of_all_5_quartiles_in_an_array(self):
        a       = [1,2,3,4,5]
        localo  = sames.VectorOfContinuous(a)
        qa      = localo.requestQuartileCollection
        assert_equal 1, qa[0]
        assert_equal 2, qa[1]
        assert_equal 3, qa[2]
        assert_equal 4, qa[3]
        assert_equal 5, qa[4]
        a           = [0,1,2,3,4,5,6,7,8,9,8,9,9,9,9,9,8,7,8,7,8,7,6,5,4,3,2,1,0,1,2,2,3,3,3,99.336,5.9,0x259,1133.7,1234]
        localo  = sames.VectorOfContinuous(a)
        qa      = localo.requestQuartileCollection
        assert_equal 0, qa[0]
        assert_equal 3.0, qa[1]
        assert_equal 6.0, qa[2]
        assert_equal 8.25, qa[3]
        assert_equal 1234, qa[4]

    def test_Has_some_formatted_result_methods(self):
        a       = [1,2,3,4,5,6,7,8,9]
        localo  = sames.VectorOfContinuous(a)
        assert_respond_to localo, :requestResultAACSV
        assert localo.requestResultAACSV.is_a?      String
        assert localo.requestResultCSVLine.is_a?    String
        assert localo.requestResultJSON.is_a?       String

    def test_Can_request_a_calculation_of_skewness(self):
        a       = [1,2,3,4,5,6,7,8,9]
        localo  = sames.VectorOfContinuous(a)
        sk      = localo.requestSkewness
        assert_equal 0, sk
        sk      = localo.requestSkewness(1)
        assert_equal 0, sk
        sk      = localo.requestSkewness(2)
        assert_equal 0, sk
        sk      = localo.requestSkewness(3)
        assert_equal 0, sk
        a       = [1,2,2,3,3,3,4,4,4,4,4,4]
        localo  = sames.VectorOfContinuous(a)
        sk      = localo.requestSkewness
        assert_equal -0.9878, sk
        sk1     = localo.requestSkewness(1)
        assert_equal -0.7545, sk1
        sk2     = localo.requestSkewness(2)
        assert_equal -0.8597, sk2
        sk3     = localo.requestSkewness(3)
        assert_equal sk3, sk

    def test_Has_four_standard_deviation_calculations_corresponding_to_the_four_variance_combinations(self):
        a       = [1,2,3]
        localo  = sames.VectorOfContinuous(a)
        sdsd    = localo.requestStandardDeviation
        localo.UseDiffFromMeanCalculations = false
        sdsx    = localo.requestStandardDeviation
        assert_equal sdsd, sdsx
        localo.Population = true
        sdsd    = localo.requestStandardDeviation
        localo.UseDiffFromMeanCalculations = false
        sdsx    = localo.requestStandardDeviation
        assert_equal sdsd, sdsx

    def test_Has_two_variance_generation_methods(self):
        a = [1,2,2,3,3,3,99.336,5.9,0x259,1133.7,1234]
        localo = sames.VectorOfContinuous(a)
        v = localo.requestVarianceSumOfDifferencesFromMean
        assert_equal 231232.125543275, v
        v = localo.requestVarianceXsSquaredMethod
        assert_equal 231232.12554327273, v
        v = localo.requestVarianceSumOfDifferencesFromMean(true)
        assert_equal 210211.0232211591, v
        v = localo.requestVarianceXsSquaredMethod(true)
        assert_equal 210211.02322115703, v

    def test_Input_routine_pushX_validates_arguments(self):
        lvo = sames.VectorOfContinuous
        assert_nothing_raised do
            lvo.pushX(123.456)
        assert_raise ArgumentError do
            lvo.pushX("asdf")
        assert_raise ArgumentError do
            lvo.pushX("0x9")
        assert_raise ArgumentError do
            lvo.pushX("1234..56")
        assert_raise ArgumentError do
            lvo.pushX("2 34")
        lvo.ValidateStringNumbers = true
        assert_raise RangeError do
            lvo.pushX("9999999999999999999999999999")

    def test_Fails_differently_according_to_special_arguments_to_pushX(self):
        # These are the pertinent identifiers:
        #BlankFieldOnBadData = 0
        #FailOnBadData       = 1
        #SkipRowOnBadData    = 2
        #ZeroFieldOnBadData  = 3
        localo = sames.VectorOfContinuous
        assert_equal 0, localo.getCount
        assert_raise ArgumentError do
            localo.pushX("")
        assert_equal 0, localo.getCount
        assert_raise ArgumentError do
            localo.pushX("",sames.VectorOfX::BlankFieldOnBadData)
        assert_equal 0, localo.getCount
        assert_raise ArgumentError do
            localo.pushX("",sames.VectorOfX::FailOnBadData)
        assert_equal 0, localo.getCount
        localo.pushX("",sames.VectorOfX::SkipRowOnBadData)
        assert_equal 0, localo.getCount
        localo.pushX("",sames.VectorOfX::ZeroFieldOnBadData)
        assert_equal 1, localo.getCount
'''

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


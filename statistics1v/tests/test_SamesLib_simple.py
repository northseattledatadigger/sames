#!/usr/bin/python3
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# test_SamesLib_simple.py

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Constants and Imports

import os
import sys 
import unittest

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

class Test_HistogramOfX_Class(unittest.TestCase):

    def test_argument_usage(self):
        pass

    def test_anecdote_expected_results(self):
        pass

class Test_SumsOfPowers_Class(unittest.TestCase):

    def test_argument_usage(self):
        pass

    def test_anecdote_expected_results(self):
        pass

class Test_VectorOfX_Class(unittest.TestCase):

    def test_argument_usage(self):
        pass

    def test_anecdote_expected_results(self):
        pass

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
    print(f"trace 4 {SamesProjectDs}")
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


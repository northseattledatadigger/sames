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

    def test_argument_usage(self):
        pass

'''
    def test_anecdote_expected_results(self):
        self.assertFalse(sames.isANumStr(1234))
        self.assertFalse(sames.isANumStr(""))
        self.assertTrue(sames.isANumStr("1234"))
        self.assertFalse(sames.isANumStr(15.993))
        self.assertTrue(sames.isANumStr("15.993"))
        self.assertFalse(sames.isANumStr(0.1234))
        self.assertTrue(sames.isANumStr("0.1234"))
'''

class Test_isNumericVector(unittest.TestCase):

    def test_argument_usage(self):
        pass

    def test_anecdote_expected_results(self):
        pass

class Test_isUsableNumber(unittest.TestCase):

    def test_argument_usage(self):
        pass

    def test_anecdote_expected_results(self):
        pass

class Test_isUsableNumberVector(unittest.TestCase):

    def test_argument_usage(self):
        pass

    def test_anecdote_expected_results(self):
        pass

class Test_validateStringNumberRange(unittest.TestCase):

    def test_argument_usage(self):
        pass

    def test_anecdote_expected_results(self):
        pass

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
    import SamesLib_native as sames
    unittest.main()

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of test_SamesLib_simple.py


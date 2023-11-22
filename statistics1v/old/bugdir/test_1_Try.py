#!/usr/bin/python3
# test_1_Try.py

import unittest

import Try as tr

class Test_Try(unittest.TestCase):

    def test_Constructs_with_no_argument(self):
        localo = tr.Try()
        self.assertIsInstance( localo, tr.Try )
        localo.pushX(5.333)

    def test_newAfter(self):
        localo = tr.Try.newAfter(["1.5"])
        self.assertEqual(1,localo.getCount())

if __name__ == '__main__':

    unittest.main()

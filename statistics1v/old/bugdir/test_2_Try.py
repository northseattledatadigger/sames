#!/usr/bin/python3
# test_2_Try.py

import unittest

import Try as tr

class Test_Try(unittest.TestCase):

    def test_newAfter(self):
        localo = tr.Try.newAfter(["1.5"])
        self.assertEqual(1,localo.getCount())

if __name__ == '__main__':

    unittest.main()

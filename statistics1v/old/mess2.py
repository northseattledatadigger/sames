#!/usr/bin/python3

import numbers
import re

#x=[]
x=[1,2,3]
if not type(x) is list:
    print("x is a list.")
if len(x) == 0:
    print("x is size zero.")
else:
    if ( all(isinstance(lve,numbers.Number) for lve in x) ):
        print("x has only numbers.")


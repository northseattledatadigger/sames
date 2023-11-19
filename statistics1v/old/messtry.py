#!/usr/bin/python3

import re

x = "1234"
#result = re.search(r'^-?\d*\.?\d+$',x)
result = re.match(r'^-?\d*\.?\d+$',x)
#result = re.search(r'^\d+$/',x)
#result = re.match(r'^\d+$',x)
#result = re.match("^\d+$/",x)
print(f"trade result:  {result}")

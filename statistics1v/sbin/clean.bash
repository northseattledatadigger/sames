#!/bin/bash
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# clean.bash

if [[ $1 = '-purge' ]]
then
    rm -rf bin
fi

rm -f mess*

rm -rf .pytest_cache
rm -rf ctree
rm -rf cpptree
rm -rf __pycache__
rm -rf extras/rusttree

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of clean.bash

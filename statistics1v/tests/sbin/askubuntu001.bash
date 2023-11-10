#!/bin/bash

declare -A a=()

b=4500
for ((c=1; c<$b; c++)); do
    (($RANDOM < 8192)) && ((a[if]++)) || ((a[else]++))
done

for d in if else; do
    LC_ALL=C printf "%4s ~ %0.2f%%\n" \
    $d $(bc -l <<< "100 / ($b / ${a[$d]})")
done


#!/bin/bash

lowdown() {
    echo "trace: $RANDOM"
}

nextup() {
    lowdown
}

nearertop() {
    nextup
}


top() {
    nearertop
}

b=4500
for ((c=1; c<$b; c++)); do
    top
done

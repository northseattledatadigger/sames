#!/usr/bin/env bats
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# test_SamesLib.acceptance.bats - Acceptance tests across all languages and
# versions.

# IMPORTANT NOTE:  This is designed to be run from the script:
#   ../acceptancetest.bash
# which accepts specification of which language and version is to be under
# test, and sets up the environment in general.
# >>>>>Running this test script directly WILL FAIL.

setup() {
    INDEX=$((${BATS_TEST_NUMBER} - 1))
    cat <<EOHDR >>$PrimaryOutputFSpec
AppUnderTest is:        $AppUnderTest
AppUnderTestFs is:      $AppUnderTestFs
LibraryUnderTestFs:     $LibraryUnderTestFs
FirstTestDataSubjectFs: $FirstTestDataSubjectFs
##### setup start at $(date)
BATS_TEST_NAME:         ${BATS_TEST_NAME}
BATS_TEST_FILENAME:     ${BATS_TEST_FILENAME}
BATS_TEST_DIRNAME:      ${BATS_TEST_DIRNAME}
BATS_TEST_NAMES:        ${BATS_TEST_NAMES[$INDEX]}
BATS_TEST_DESCRIPTION:  ${BATS_TEST_DESCRIPTION}
BATS_TEST_NUMBER:       ${BATS_TEST_NUMBER}
BATS_TMPDIR:            ${BATS_TMPDIR}

##### setup end at $(date)
EOHDR

    SWc3_AMean=$(sbin/requestSamplePointStatistics.bash     -B -i ../testdata/sidewalkstreetratioupload.csv -t -c3 -x       | grep '"ArithmeticMean"' | awk '{print $2}')
    SWc3_HMean=$(sbin/requestSamplePointStatistics.bash     -B -i ../testdata/sidewalkstreetratioupload.csv -t -c3 -x       | grep '"HarmonicMean"' | awk '{print $2}')
    SWc3_DKurtosis=$(sbin/requestSamplePointStatistics.bash -B -i ../testdata/sidewalkstreetratioupload.csv -t -c3 -x -d    | grep '"Kurtosis"' | awk '{print $2}')
    SWc3_GKurtosis=$(sbin/requestSamplePointStatistics.bash -B -i ../testdata/sidewalkstreetratioupload.csv -t -c3 -x -g    | grep '"Kurtosis"' | awk '{print $2}')
    SWc3_PKurtosis=$(sbin/requestSamplePointStatistics.bash -B -i ../testdata/sidewalkstreetratioupload.csv -t -c3 -x -p    | grep '"Kurtosis"' | awk '{print $2}')
    SWc3_Max=$(sbin/requestSamplePointStatistics.bash       -B -i ../testdata/sidewalkstreetratioupload.csv -t -c3 -x | grep '"Max"' | awk '{print $2}')
    SWc3_Median=$(sbin/requestSamplePointStatistics.bash    -B -i ../testdata/sidewalkstreetratioupload.csv -t -c3 -x | grep '"Median"' | awk '{print $2}' )
    SWc3_MedianAAD=$(sbin/requestSamplePointStatistics.bash -B -i ../testdata/sidewalkstreetratioupload.csv -t -c3 -x | grep '"MedianAAD"' | awk '{print $2}')
    SWc3_Min=$(sbin/requestSamplePointStatistics.bash       -B -i ../testdata/sidewalkstreetratioupload.csv -t -c3 -x | grep '"Min"' | awk '{print $2}')
    SWc3_Mode=$(sbin/requestSamplePointStatistics.bash      -B -i ../testdata/sidewalkstreetratioupload.csv -t -c3 -x | grep '"Mode"' | awk '{print $2}')
    SWc3_N=$(sbin/requestSamplePointStatistics.bash         -B -i ../testdata/sidewalkstreetratioupload.csv -t -c3 -x | grep '"N"' | awk '{print $2}')
    SWc3_Skewness=$(sbin/requestSamplePointStatistics.bash  -B -i ../testdata/sidewalkstreetratioupload.csv -t -c3 -x | grep '"Skewness"' | awk '{print $2}')
    SWc3_StdDev=$(sbin/requestSamplePointStatistics.bash    -B -i ../testdata/sidewalkstreetratioupload.csv -t -c3 -x | grep '"StandardDeviation"' | awk '{print $2}')
    SWc3_Sum=$(sbin/requestSamplePointStatistics.bash       -B -i ../testdata/sidewalkstreetratioupload.csv -t -c3 -x | grep '"Sum"' | awk '{print $2}')
}


teardown() {
    echo -e "##### teardown ${BATS_TEST_NAME} at $(date)\n" >>$PrimaryOutputFSpec

}

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# USAGE Basics

@test "$AppUnderTest simple run with no arguments." {
    run $AppUnderTestFs
    [ $status -eq 1 ]
    [[ -n $output ]]
}

@test "$AppUnderTest with one argument, but file not there." {
    run $AppUnderTestFs nonexistentfile.csv
    [ $status -eq 1 ]
    [[ -n $output ]]
}

@test "$AppUnderTest with one argument, but file not a valid format." {
    run $AppUnderTestFs nums.txt
    [ $status -eq 1 ]
    [[ -n $output ]]
}

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Test on primary data example ( FirstTestDataSubjectFs )

@test "$AppUnderTest calculate arithmetic mean for third column." {
    comparison=$(sbin/requestSamplePointStatistics.bash -B -i ../testdata/sidewalkstreetratioupload.csv -t -c3 -x | grep '"ArithmeticMean"' | awk '{print $2}')
    run $AppUnderTestFs $FirstTestDataSubjectFs 2:4 mean
    [ $status -eq 0 ]
    [[ -n $(echo $SWc3_AMean | grep $output) ]]
    #echo "# $SWc3_AMean versus $output" >&3
    run $AppUnderTestFs $FirstTestDataSubjectFs 2 arithmeticmean
    [ $status -eq 0 ]
    [[ -n $(echo $SWc3_AMean | grep $output) ]]
    #echo "# $SWc3_AMean versus $output" >&3
}

@test "$AppUnderTest calculate kurtosis for third column." {
    comparison=$(sbin/requestSamplePointStatistics.bash -B -i ../testdata/sidewalkstreetratioupload.csv -t -c3 -x | grep '"Kurtosis"' | awk '{print $2}')
    run $AppUnderTestFs $FirstTestDataSubjectFs 2:4 kurtosis
    [ $status -eq 0 ]
    #echo "# datamash $SWc3_DKurtosis versus $output" >&3
    #echo "# gnuplot  $SWc3_GKurtosis versus $output" >&3
    #echo "# pspp     $SWc3_PKurtosis versus $output" >&3
    (( $(echo "$SWc3_DKurtosis < $output" | bc -l) ))
    (( $(echo "$SWc3_GKurtosis > $output" | bc -l) ))
    (( $(echo "$SWc3_PKurtosis < $output" | bc -l) ))
}

@test "$AppUnderTest calculate maximum for third column." {
    comparison=$(sbin/requestSamplePointStatistics.bash -B -i ../testdata/sidewalkstreetratioupload.csv -t -c3 -x | grep '"Max"' | awk '{print $2}')
    run $AppUnderTestFs $FirstTestDataSubjectFs 2:4 max
    [ $status -eq 0 ]
    (( $(echo "$SWc3_Max == $output" | bc -l) ))
}

@test "$AppUnderTest calculate median for third column." {
    comparison=$(sbin/requestSamplePointStatistics.bash -B -i ../testdata/sidewalkstreetratioupload.csv -t -c3 -x | grep '"Median"' | awk '{print $2}')
    run $AppUnderTestFs $FirstTestDataSubjectFs 2:6 median
    [ $status -eq 0 ]
    #echo "# datamash $SWc3_Median versus $output" >&3
    [[ -n $(echo $SWc3_Median | grep $output) ]]
}

@test "$AppUnderTest calculate minimum for third column." {
    comparison=$(sbin/requestSamplePointStatistics.bash -B -i ../testdata/sidewalkstreetratioupload.csv -t -c3 -x | grep '"Min"' | awk '{print $2}')
    run $AppUnderTestFs $FirstTestDataSubjectFs 2:3 min
    [ $status -eq 0 ]
    choppedby1=${output::-1}
    #echo "# datamash $SWc3_Min versus $output / $choppedby1" >&3
    [[ -n $(echo $SWc3_Min | grep $choppedby1) ]]
}

@test "$AppUnderTest calculate n for third column." {
    comparison=$(sbin/requestSamplePointStatistics.bash -B -i ../testdata/sidewalkstreetratioupload.csv -t -c3 -x | grep '"N"' | awk '{print $2}')
    run $AppUnderTestFs $FirstTestDataSubjectFs 2:3 n
    [ $status -eq 0 ]
    #echo "# datamash $SWc3_N versus $output" >&3
    [[ -n $(echo $SWc3_N | grep $output) ]]
}

@test "$AppUnderTest calculate skewness for third column." {
    comparison=$(sbin/requestSamplePointStatistics.bash -B -i ../testdata/sidewalkstreetratioupload.csv -t -c3 -x | grep '"Skewness"' | awk '{print $2}')
    run $AppUnderTestFs $FirstTestDataSubjectFs 2:3 skewness
    [ $status -eq 0 ]
    #echo "# datamash $SWc3_Skewness versus $output" >&3
    [[ -n $(echo $SWc3_Skewness | grep $output) ]]
}

@test "$AppUnderTest calculate standard deviation for third column." {
    comparison=$(sbin/requestSamplePointStatistics.bash -B -i ../testdata/sidewalkstreetratioupload.csv -t -c3 -x | grep '"StandardDeviation"' | awk '{print $2}')
    run $AppUnderTestFs $FirstTestDataSubjectFs 2:3 stddev
    [ $status -eq 0 ]
    #echo "# datamash $SWc3_StdDev versus $output" >&3
    [[ -n $(echo $SWc3_StdDev | grep $output) ]]
}

@test "$AppUnderTest calculate sum for third column." {
    comparison=$(sbin/requestSamplePointStatistics.bash -B -i ../testdata/sidewalkstreetratioupload.csv -t -c3 -x | grep '"Sum"' | awk '{print $2}')
    run $AppUnderTestFs $FirstTestDataSubjectFs 2:3 sum
    [ $status -eq 0 ]
    choppedby3=${output::-3}
    #echo "# datamash $SWc3_Sum versus $output / $choppedby3" >&3
    [[ -n $(echo $SWc3_Sum | grep $choppedby3) ]]
}

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of test_SamesLib.acceptance.bats

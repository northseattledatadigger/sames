#!/usr/bin/env bats
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# test_SamesLib.acceptance.bats - Acceptance tests across all languages and
# versions.

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

    SWc3_AMean=$(sbin/requestSamplePointStatistics.bash -B -i ../testdata/sidewalkstreetratioupload.csv -t -c3 -x | grep '"ArithmeticMean"' | awk '{print $2}')
    SWc3_GMean=$(sbin/requestSamplePointStatistics.bash -B -i ../testdata/sidewalkstreetratioupload.csv -t -c3 -x | grep '"GeometricMean"' | awk '{print $2}')
    SWc3_HMean=$(sbin/requestSamplePointStatistics.bash -B -i ../testdata/sidewalkstreetratioupload.csv -t -c3 -x | grep '"HarmonicicMean"' | awk '{print $2}')
    SWc3_Kurtosis=$(sbin/requestSamplePointStatistics.bash -B -i ../testdata/sidewalkstreetratioupload.csv -t -c3 -x | grep '"Kurtosis"' | awk '{print $2}')
    SWc3_Max=$(sbin/requestSamplePointStatistics.bash -B -i ../testdata/sidewalkstreetratioupload.csv -t -c3 -x | grep '"Max"' | awk '{print $2}')
    SWc3_Median=$(sbin/requestSamplePointStatistics.bash -B -i ../testdata/sidewalkstreetratioupload.csv -t -c3 -x | grep '"Median"' | awk '{print $2}')
    SWc3_MedianAAD=$(sbin/requestSamplePointStatistics.bash -B -i ../testdata/sidewalkstreetratioupload.csv -t -c3 -x | grep '"MedianAAD"' | awk '{print $2}')
    SWc3_Min=$(sbin/requestSamplePointStatistics.bash -B -i ../testdata/sidewalkstreetratioupload.csv -t -c3 -x | grep '"Min"' | awk '{print $2}')
    SWc3_Mode=$(sbin/requestSamplePointStatistics.bash -B -i ../testdata/sidewalkstreetratioupload.csv -t -c3 -x | grep '"Mode"' | awk '{print $2}')
    SWc3_N=$(sbin/requestSamplePointStatistics.bash -B -i ../testdata/sidewalkstreetratioupload.csv -t -c3 -x | grep '"N"' | awk '{print $2}')
    SWc3_Skewness=$(sbin/requestSamplePointStatistics.bash -B -i ../testdata/sidewalkstreetratioupload.csv -t -c3 -x | grep '"Skewness"' | awk '{print $2}')
    SWc3_StdDev=$(sbin/requestSamplePointStatistics.bash -B -i ../testdata/sidewalkstreetratioupload.csv -t -c3 -x | grep '"StandardDeviation"' | awk '{print $2}')
    SWc3_Sum=$(sbin/requestSamplePointStatistics.bash -B -i ../testdata/sidewalkstreetratioupload.csv -t -c3 -x | grep '"Sum"' | awk '{print $2}')
}


teardown() {
    echo -e "##### teardown ${BATS_TEST_NAME} at $(date)\n" >>$PrimaryOutputFSpec

}

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# USAGE Basics

@test "$AppUnderTest simple run with no arguments." {
    run $AppUnderTestFs
    [ $status -eq 0 ]
    [ -n $output ]
}

@test "$AppUnderTest with one argument, but file not there." {
#    run $AppUnderTestFs nonexistentfile.csv
#    [ $status -eq 1 ]
#    [[ -n $output ]]
}

@test "$AppUnderTest with one argument, but file not a valid format." {
#    run $AppUnderTestFs nums.txt
#    [ $status -eq 1 ]
#    [[ -n $output ]]
}

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Test on primary data example ( FirstTestDataSubjectFs )

@test "$AppUnderTest calculate arithmetic mean for third column." {
#    run $AppUnderTestFs $FirstTestDataSubjectFs 2 mean
#    [ $status -eq 0 ]
#    [[ -n $output ]]
    #run $AppUnderTestFs $FirstTestDataSubjectFs 2 arithmeticmean
    #[ $status -eq 0 ]
    #[[ -n $output ]]
}

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of test_SamesLib.acceptance.bats

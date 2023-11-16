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
    run $AppUnderTestFs $FirstTestDataSubjectFs 2 mean
    [ $status -eq 0 ]
    [[ -n $output ]]
    #run $AppUnderTestFs $FirstTestDataSubjectFs 2 arithmeticmean
    #[ $status -eq 0 ]
    #[[ -n $output ]]
}

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of test_SamesLib.acceptance.bats

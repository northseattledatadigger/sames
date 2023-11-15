#!/usr/bin/env bats
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# test_SamesLib.acceptance.bats - Acceptance tests across all languages and
# versions.


@test "$AppUnderTest calculate arithmetic mean." {
    run $AppUnderTestFs >/dev/null 2>/dev/null
    [ $status -eq 1 ]
    [[ -n $output ]]
}


#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of test_SamesLib.acceptance.bats

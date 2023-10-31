#!/bin/bash
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# author_installs.ubuntu.bash

readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

source $SCRIPT_DIR/../slib/SBinLib.bashenv

catUsage() {
    cat <<EOU
USAGE:  $0 <options>
This is an install script for what the author uses with this "sames" suite he
is checking into his github accounts.  It involves a large amount Ubuntu of
additions, so should not be taken as the best combination that works for
everyone, and may be especially problematic for those with old Ubuntu installs,
but it is, he hopes, a helpful illustration and for some a functional "Ubuntu"
bash script.

Note there is NO 'quiet' option, so if you wish it so, please do your own I/O
redirects.

    -h  Display this help text without error.
    -n  Install packages to do NDarray and Numpy builds/runs.
    -p  Install packages to do Pandas and Polars builds/runs.
    -s  Install packages to do Spark builds/runs.
    Note that the present copy of the script defaults to Upgrade '$Upgrade'.
    -U  Do an Ubuntu apt-get -f dist-upgrade also.
    -u  Do NOT do an Ubuntu apt-get -f dist-upgrade.
EOU
}

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Init

if [[ $USER != 'root' ]]
then
    echoError "$USER is NOT root.  Script must have root priviledge to work."
    echoInfo "Exiting because operation could not execute."
    exit 9
fi

if [[ -z $(uname -a | grep -i ubuntu) ]]
then
    echoError "The OS appears to NOT be ubuntu."
    echoInfo "Exiting because operation could not execute."
    exit 8
fi

InstallNDArrayNumpySupport=false
InstallPandasPolarsSupport=true
InstallSparkSupport=false
#Upgrade=false # probably better for production draft.
Upgrade=true

if (( $# > 0 ))
then
    while getopts "hnpsUu" option
    do
        case "$option" in
        h)
            catUsage
            exit 0
            ;;
        n)
            InstallNDArrayNumpySupport=true
            ;;
        p)
            InstallPandasPolarsSupport=true
            ;;
        s)
            InstallSparkSupport=true
            ;;
        U)
            Upgrade=false
            ;;
        u)
            Upgrade=true
            ;;
        *)
            echoError 9 "'$option' NOT a programmed qualifier in this script."
            catUsage
            exit 1
            ;;
        esac
    done
fi

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Main

apt-get update
if $Upgrade
then
    apt-get -f dist-upgrade # Beware here:  I recommend using all the latest
                            # for the sake of security and not wasting time
                            # needlessly on legacy states, but this may not be
                            # the right choice for those testing on old
                            # installs with little experience with Ubuntu.
fi

# And these are what I have recently used.  You may find better combinations
# for yourself:
apt-get install build-essential
apt-get install golang
# Note Julia does not presently have an apt package.  Perhaps make procedure.
apt-get install perl
apt-get install python3
apt-get install nodejs
apt-get install ruby-all-dev
apt-get install rust-all

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of author_installs.ubuntu.bash

#!/bin/bash
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# see.ubuntu.bash

readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

source $SCRIPT_DIR/../slib/SBinLib.bashenv

catUsage() {
    cat <<EOU
USAGE:  $0 <options>
This script is mostly for me, but for anyone who wants to nose around without
a bunch of interactive cd stuff because you decide to read this script and are
actually as interested in this sames package, for some reason, as I am.

    -h  Display this help text without error.
    -b  list what is in the bin directory.
    -c  Exit cd-ing to the specified directory.
    -d  list what is in the test data directory.
    -e  list what is in the extras directory.
    -f  find list the entire tree of folders.
    -F  find list the entire tree.
    -n  list what is in the notes directory.
    -N  Pick something in the notes directory to read in view.  Yes view.  You
    can reprogram your copy if you like another reader.
    -p:<project> specify a project, like -p:statisticsv1, which was my first
    one.
    -s  list what is in the sbin directory.
    -t  list what is in the top directory.
EOU
}

listFilesInFolder() {
    local _folderNode="$1"
    local _projectNode="$2"

    if [[ -n $_projectNode ]]
    then
        ls $SAMES
    else
    fi
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
apt-get install bats
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

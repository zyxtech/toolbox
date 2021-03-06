#!/bin/sh
# clone from https://github.com/dmytro/sherlock_os/blob/master/bin/sherlock
#
# Script to detect UNIX/Linux OS and varios aspects of the
# OS. Especially for Linux: distribution type and derivarite (such as
# CentOS/RHEL or Debian/Ubuntu)
#
# Author: Dmytro Kovalov, 2013, March 12-13
#
# Used these sources to start:
# http://www.novell.com/coolsolutions/feature/11251.html
# http://serverfault.com/questions/3331/how-do-i-find-out-what-version-of-linux-is-running
# http://www.unix.com/slackware/23652-determine-linux-version.html
#
# Script outputs results in the format that can either be parsed or
# directly eval'ed in Bourne shell:
#
# Example
# -----------
# sherlock
# OS=Linux
# MACH=x86_64
# KERNEL=2.6.32-5-amd64
# DISTRIBUTION=debian
# FAMILY=debian
# DERIVATIVE=Debian
# RELEASE=6.0.6
# CODENAME=squeeze
#

PATH=/bin:/sbin:/usr/bin:/usr/sbin

####################################################################
# Functions
#

##
# Main function that call all others
#
detect_os () {

    OS=`uname -s`
    MACH=`uname -m`

    echo OS=$OS
    echo MACH=$MACH

    if [ "${OS}" = "SunOS" ] ; then
	    echo ARCH=`uname -p`
	    OSSTR="${OS} ${REV}(${ARCH} `uname -v`)"
        echo FAMILY=solaris
    elif [ "${OS}" = "AIX" ] ; then
	    echo OSSTR="${OS} `oslevel` (`oslevel -r`)"
        echo FAMILY=aix
    elif [ "${OS}" = "Darwin" ] ; then
        echo REV=`uname -r`
        echo FAMILY=macosx
    elif [ "${OS}" = "Linux" ] ; then
	    echo KERNEL="`uname -r`"
        linux_distro
    fi
}



## ------------------------------------------------------------
# Redhat derivatives distros
#
redhat_derivative () {

    local FILE=/etc/redhat-release

    grep -i 'red.*hat.*enterprise.*linux' $FILE 2>&1 > /dev/null && { echo  DERIVATIVE=rhel; return; }
    grep -i 'red.*hat.*linux' $FILE 2>&1 > /dev/null && { echo DERIVATIVE=rh; return; }
    grep -i 'cern.*e.*linux' $FILE 2>&1 > /dev/null && { echo DERIVATIVE=cel; return; }
    grep -i 'scientific linux cern' $FILE 2>&1 > /dev/null && { echo DERIVATIVE=slc; return; }
    grep -i 'centos' $FILE 2>&1 > /dev/null && { echo DERIVATIVE=centos; return; }

    echo DERIVATIVE=unknown
}


redhat_release () {
    echo RELEASE=`tr -d 'a-zA-Z [](){}' < /etc/redhat-release`
}

## ------------------------------------------------------------
# Debian derivatives
#
debian_derivative () {
    if which lsb_release 2>&1 > /dev/null ; then
        echo DERIVATIVE=`lsb_release --id --short 2> /dev/null`
        echo RELEASE=`lsb_release --release --short 2> /dev/null`
        echo CODENAME=`lsb_release --codename --short 2> /dev/null`
        return
    else
        echo DERIVATIVE=unknown
        echo RELEASE=`cat /etc/debian_version`
        echo CODENAME=unknown
        return
    fi
}

##
#
#
linux_distro () {

	if [ -f /etc/redhat-release ] ; then
		echo DISTRIBUTION=redhat
        echo FAMILY=rh
        redhat_derivative
        redhat_release
    elif [ -s /etc/slackware-version ]; then
        echo DISTRIBUTION="slackware"
	elif [ -f /etc/SUSE-release ] ; then
        # TODO - not tested
        echo DISTRIBUTION=suse
 		echo PSUEDONAME=`cat /etc/SUSE-release | tr "\n" ' '| sed s/VERSION.*//`
 		echo REV=`cat /etc/SUSE-release | tr "\n" ' ' | sed s/.*=\ //`
        echo VERSION=`cat /etc/SuSE-release | grep 'VERSION' | sed  -e 's#[^0-9]##g'`
	elif [ -f /etc/mandrake-release ] ; then
        # TODO - not tested
        echo DISTRIBUTION=mandrake
 		echo PSUEDONAME=`cat /etc/mandrake-release | sed s/.*\(// | sed s/\)//`
 		echo REV=`cat /etc/mandrake-release | sed s/.*release\ // | sed s/\ .*//`
        echo FAMILY=rh
	elif [ -f /etc/debian_version ] ; then
        echo DISTRIBUTION=debian
        echo FAMILY=debian
        debian_derivative
    elif [ -f /etc/UnitedLinux-release ]; then
        echo DISTRIBUTION="united"
        echo VERSION=`cat /etc/UnitedLinux-release`
    elif [ -r /etc/init.d/functions.sh ]; then
        # TODO - not tested
        source /etc/init.d/functions.sh
        [ zz`type -t ebegin 2>/dev/null` == "zzfunction" ] && echo DISTRIBUTION="gentoo"
	fi
}

# --------------------------------------------------------------------------------
# Do it!
#
detect_os
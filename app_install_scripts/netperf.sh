#! /bin/bash

### Header info ###
## template: 	V01
## Author: 	XiaoJun x00467495
## name:	netperf
## desc:	netperf source code build and install

### RULE
## 1. update Header info
## 2. use pr_err/pr_tip/pr_ok/pr_info as print API
## 3. use ${ass_rst ret exp log} as result assert code
## 4. implement each Interface Functions if you need

### VARIS ###

# Color Macro Start 
MCOLOR_RED="\033[31m"
MCOLOR_GREEN="\033[32m"
MCOLOR_YELLOW="\033[33m"
MCOLOR_END="\033[0m"
# Color Macro End

SRC_URL="https://github.com/HewlettPackard/netperf/archive/netperf-2.7.0.tar.gz"
PKG_URL=NULL
DISTRIBUTION=NULL
rst=0

## Selfdef Varis
MY_SRC_DIR="netperf-netperf-2.7.0"
MY_SRC_TAR="netperf-2.7.0.tar.gz"

### internal API ###

function pr_err()
{
	if [ "$1"x == ""x ] ; then
		echo -e $MCOLOR_RED "Error!" $MCOLOR_END
	else
		echo -e $MCOLOR_RED "$1" $MCOLOR_END
	fi
}

function pr_tip()
{
	if [ "$1"x != ""x ] ; then
		echo -e $MCOLOR_YELLOW "$1" $MCOLOR_END
	fi
}

function pr_ok()
{
	if [ "$1"x != ""x ] ; then
		echo -e $MCOLOR_GREEN "$1" $MCOLOR_END
	fi
}

function pr_info()
{
	if [ "$1"x != ""x ] ; then
		echo " $1"
	fi
}

# assert result [  $1: check value; $2: expect value; $3 fail log  ]
function ass_rst() 
{
	if [ "$#"x != "3"x ] ; then
		pr_err "ass_rst param faill, only $#, expected 3"
		return 1
	fi

	if [ "$1"x != "$2"x ] ; then
		pr_err "$3"
		exit 1
	fi

	return 0
}

### Interface Functions ###
## Interface list:
##	check_distribution()
##	clear_history()
##	install_depend()
##	download_src()
##		download src
##		untar & cd topdir
##	compile_and_install()
##		toggle to the right version
##		remove git info
##		configure & compile
##		install
##	selftest()
##  finish_install()
##		remove files

## Interface: get distribution
function check_distribution()
{
	if grep -Eqi "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
		DISTRIBUTION='CentOS'
	elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
		DISTRIBUTION='Debian'
	else
		DISTRIBUTION='unknown'
	fi

	pr_tip "Distribution : ${DISTRIBUTION}"

	return 0
}

## Interface: clear history files to prepare for reinstall files
function clear_history()
{
	pr_tip "[clear] skiped"
	return 0
}

## Interface: install dependency
function install_depend()
{
	pr_tip "[depend] skiped"
	return 0
}

## Interface: download_src
function download_src()
{
	wget -O ${MY_SRC_TAR} ${SRC_URL} --no-check-certificate
	ass_rst $? 0 "download ${SRC_URL} failed!"

	tar xvzf ${MY_SRC_TAR}
	ass_rst $? 0 "untar ${MY_SRC_TAR} failed"

	cd ${MY_SRC_DIR}

	pr_ok "[download] OK"
	return 0
}

## Interface: software self test
## example: print version number, run any simple example
function selftest()
{
	netperf -V
	ass_rst $? 0 "netperf install test failed!"	

	pr_ok "[selftest] OK"
	return 0
}

## Interface: compile_and_install
function compile_and_install()
{
	pr_tip "[install]<version> skiped"
	pr_tip "[install]<rm_git> skiped"

	./configure aarch64-unknown-linux-gnu
	ass_rst $? 0 "configure failed"
	
	make
	ass_rst $? 0 "make failed"

	make check
	ass_rst $? 0 "make check failed"

	make install
	ass_rst $? 0 "make install failed"

	if [ ! -f /usr/bin/netperf ] ; then
		cp src/netperf /usr/bin/ -f	
	fi

	pr_ok "[install]<compile> OK"

	if [ "$DISTRIBUTION"x == "Debian"x ] ; then
		pr_info ""
	elif [ "$DISTRIBUTION"x == "CentOS"x ] ; then
		pr_info ""
	fi

	pr_tip "[install]<install>"
	return 0
}

## Interface: rst_report
function rst_report()
{
	pr_err "[report]"
	return $rst
}

## Interface: finish install
function finish_install()
{
	cd ..
	rm -rf ${MY_SRC_DIR} ${MY_SRC_TAR}
	
	pr_tip "[finish]<clean> skiped"
	return 0
}

### Dependence ###

### Compile and Install ###

### selftest ###

### main code ###
function main()
{
	check_distribution
	ass_rst $? 0 "check_distribution failed!"
	
	clear_history
	ass_rst $? 0 "clear_history failed!"

	install_depend
	ass_rst $? 0 "install_depend failed!"
		
	download_src
	ass_rst $? 0 "download_src failed!"
	
	compile_and_install
	ass_rst $? 0 "compile_and_install failed!"
	
	selftest
	ass_rst $? 0 "selftest failed!"

	finish_install
	ass_rst $? 0 "finish_install failed"
}

pr_tip "-------- software compile and install start --------"
main
rst=$?

ass_rst $rst 0 "[FINAL] Software install,Fail!"

pr_ok " "
pr_ok "Software install OK!"

pr_tip "--------  software compile and install end  --------"

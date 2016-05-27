#!/bin/bash

file="$1"
arg_e="$2"
arg_n="$3"
arg_l="$4"

if [[ "${file}" =~ .*\.lastUpdated$ ]] && [ $arg_l ]; then
	echo "${file}"
	exit 0
fi

if [ ! -e "${file}.sha1" -a ! -e "${file}.md5" ] && [ $arg_n ]; then
	echo "${file}"
	exit 0
fi

#On Nexus Professional, there are some the checksum file format
#1st hash
## cat aa-1.0.0.jar.sha1
## b520042133e1cf4969aa269fe013468d0d176106
#2nd file-name hash
## cat aa-1.0.0.jar.sha1
## aa-1.0.0.jar b520042133e1cf4969aa269fe013468d0d176106
#3rd SHA1(file-name) hash
## cat aa-1.0.0.jar.sha1
## SHA1(aa-1.0.0.jar)= b520042133e1cf4969aa269fe013468d0d176106
if [ ! $arg_e ]; then
	exit 0
fi
if [ -e "${file}.sha1" ]; then
	local actual_checksum=`sha1sum "${file}"|awk '{print $1}'`
	cat "${file}.sha1"|grep ${actual_checksum} > /dev/null
	if [ $? -ne 0 ]; then
		echo "${file}"
		echo "${file}.sha1"
	fi
fi
if [ -e "${file}.md5" ]; then
	local actual_checksum=`md5sum "${file}"|awk '{print $1}'`
	cat "${file}.md5"|grep ${actual_checksum} > /dev/null
	if [ $? -ne 0 ]; then
		echo "${file}"
		echo "${file}.md5"
	fi
fi

exit 0

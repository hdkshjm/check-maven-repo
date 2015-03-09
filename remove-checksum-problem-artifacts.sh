#!/bin/bash

FILES=()
PROBLEM_FILES=()
TARGET_DIR="${HOME}/.m2/repository/"
PARALLEL=3

function sort_problem_files() {
	PROBLEM_FILES=($(for file in "${PROBLEM_FILES[@]}"; do echo "$file"; done|sort -n|uniq))
}

function confirm () {
	if [ $opt_f ]
	then
		echo "$@? [y/n] y"
		return 0
	fi

	echo
	read -p "$@? [y/n]" y
	if [ ! "x$y" = "xy" ];
		then
		echo "Not Confirmed.: $@"
		exit 0
	fi
	return 0
}

function check () {
	file="$1"
	if [ -e ${file}.sha1 ]; then
		actual_checksum=`sha1sum ${file}|awk '{print $1}'`
		expected_checksum=`cat  ${file}.sha1`
		if [ "${actual_checksum}" != "${expected_checksum}" ]; then
			PROBLEM_FILES=("${PROBLEM_FILES[@]}" "${file}" "${file}.sha1" )
		fi
	fi
	if [ -e ${file}.md5 ]; then
		actual_checksum=`md5sum ${file}|awk '{print $1}'`
		expected_checksum=`cat ${file}.md5|awk '{print $1}'`
		if [ "${actual_checksum}" != "${expected_checksum}" ]; then
			PROBLEM_FILES=("${PROBLEM_FILES[@]}" "${file}" "${file}.md5" )
		fi
	fi
	if [ ! -e ${file}.sha1 -a ! -e ${file}.md5 ]; then
		PROBLEM_FILES=("${PROBLEM_FILES[@]}" "${file}")
	fi
}

function check_files () {
	export -f check

	echo "$1"| xargs -P ${PARALLEL} -I@@@ bash -c "check @@@"
}

# check input 
while getopts "flhd:p:" flag
do
	case $flag in
		f) opt_f=true;;
		l) opt_l=true;;
		p) PARALLEL=$OPTARG;;
		d) TARGET_DIR=$OPTARG;;
		h|*) opt_h=true;;
    esac
done
if [ $opt_h ]
then
	echo "-h help"
	echo "-f never prompt"
	echo "-l list up files only(not remove files)"
	echo "-d directory(default ~/.m2/repository/)"
	echo "-p max-procs(default 3)"
	exit;
fi

FILES=`find ${TARGET_DIR} -type f -print|grep "\.war$\|\.jar$\|\.pom$"`

check_files "$FILES"
sort_problem_files

for (( i = 0; i < ${#PROBLEM_FILES[@]}; ++i ))
do
	echo ${PROBLEM_FILES[$i]}
done

if [ $opt_l ]
then
	exit 0
fi

confirm "remove files"

for (( i = 0; i < ${#PROBLEM_FILES[@]}; ++i ))
do
	rm ${PROBLEM_FILES[$i]}
done
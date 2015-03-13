#!/bin/bash

FILES=()
PROBLEM_FILES=()
TARGET_DIR="${HOME}/.m2/repository/"
PARALLELISM=3
REGEXP=""

function sort_problem_files() {
	PROBLEM_FILES=($(for file in "${PROBLEM_FILES[@]}"; do echo "$file"; done|sort -n|uniq))
}

function confirm() {
	if [ $opt_f ]; then
		echo "$@? [y/n] y"
		return 0
	fi

	echo
	read -p "$@? [y/n]" y
	if [ ! "x$y" = "xy" ]; then
		echo "Not Confirmed.: $@"
		exit 0
	fi
	return 0
}

function check() {
	file="$1"
	
	if [[ "${file}" =~ .*\.lastUpdated$ ]]; then
		echo "${file}"
		return 0
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
	if [ -e ${file}.sha1 ]; then
		actual_checksum=`sha1sum ${file}|awk '{print $1}'`
		cat ${file}.sha1|grep ${actual_checksum} > /dev/null
		if [ $? -ne 0 ]; then
			echo "${file}"
			echo "${file}.sha1"
		fi
	fi
	if [ -e ${file}.md5 ]; then
		actual_checksum=`md5sum ${file}|awk '{print $1}'`
		cat ${file}.md5|grep ${actual_checksum} > /dev/null
		if [ $? -ne 0 ]; then
			echo "${file}"
			echo "${file}.md5"
		fi
	fi
	if [ ! -e ${file}.sha1 -a ! -e ${file}.md5 ] && [ $opt_n ]; then
			echo "${file}"
	fi
}

function check_files() {
	export -f check

	PROBLEM_FILES=($(echo "$1"| xargs -P ${PARALLELISM} -I@@@ bash -c "check @@@"))
}

# check input 
while getopts "flani:d:p:h" flag
do
	case $flag in
		f) opt_f=true;;
		l) opt_l=true;;
		a) opt_a=true;;
		n) opt_n=true;;
		i) REGEXP=$OPTARG;;
		d) TARGET_DIR=$OPTARG;;
		p) PARALLELISM=$OPTARG;;
		h|*) opt_h=true;;
    esac
done
if [ $opt_h ]
then
	echo "-h help"
	echo "-f never prompt"
	echo "-l list up files only(not remove files)"
	echo "-a check *.jar, *.war, *.pom and *.lastUpdated (default: check *.jar, *.war, *.pom and *.lastUpdated except *-javadoc.jar and *-sources.jar)"
	echo "-n not check *.jar, *.war and *.pom which checksum(md5,sha1) file is not present"
	echo "-i ignore file/directory name pattern(grep regexp)"
	echo "-d directory(default ~/.m2/repository/)"
	echo "-p max-procs(default 3)"
	exit;
fi

FILES=`find ${TARGET_DIR} -type f -print|grep "\.war$\|\.jar$\|\.pom$\|\.lastUpdated$"`
if [ $opt_a ]; then
	FILES=`echo "$FILES"|grep -v "\-javadoc\.jar\|\-sources\.jar"`
fi
if [ -n "$REGEXP" ]; then
	FILES=`echo "$FILES"|grep -v "$REGEXP"`
fi


check_files "$FILES"
sort_problem_files

for (( i = 0; i < ${#PROBLEM_FILES[@]}; ++i ))
do
	echo ${PROBLEM_FILES[$i]}
done

if [ $opt_l ]; then
	exit 0
fi

confirm "remove files"

for (( i = 0; i < ${#PROBLEM_FILES[@]}; ++i ))
do
	rm ${PROBLEM_FILES[$i]}
done
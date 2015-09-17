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
	local file="$1"
	local arg_e="$2"
	local arg_n="$3"
	local arg_l="$4"

	if [[ "${file}" =~ .*\.lastUpdated$ ]] && [ $arg_l ]; then
		echo "${file}"
		return 0
	fi
	
	if [ ! -e ${file}.sha1 -a ! -e ${file}.md5 ] && [ $arg_n ]; then
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
	if [ ! $arg_e ]; then
		return 0
	fi
	if [ -e ${file}.sha1 ]; then
		local actual_checksum=`sha1sum ${file}|awk '{print $1}'`
		cat ${file}.sha1|grep ${actual_checksum} > /dev/null
		if [ $? -ne 0 ]; then
			echo "${file}"
			echo "${file}.sha1"
		fi
	fi
	if [ -e ${file}.md5 ]; then
		local actual_checksum=`md5sum ${file}|awk '{print $1}'`
		cat ${file}.md5|grep ${actual_checksum} > /dev/null
		if [ $? -ne 0 ]; then
			echo "${file}"
			echo "${file}.md5"
		fi
	fi


}

function check_files() {
	export -f check

	PROBLEM_FILES=($(echo "$1"| xargs -P ${PARALLELISM} -I@@@ bash -c "check @@@ ${opt_e:-''} ${opt_n:-''} ${op
t_l:-''}"))
}

# check input 
while getopts "fsenlai:d:p:h" flag
do
	case $flag in
		f) opt_f=true;;
		s) opt_s=true;;
		e) opt_e=true;;
		n) opt_n=true;;
		l) opt_l=true;;
		a) opt_e=true
		   opt_n=true
		   opt_l=true
		   ;;
		i) REGEXP=$OPTARG;;
		d) TARGET_DIR=$OPTARG;;
		p) PARALLELISM=$OPTARG;;
		h|*) opt_h=true;;
    esac
done

if [ ! $opt_e ] && [ ! $opt_l ] && [ ! $opt_n ] && [ ! $opt_o ]; then
	opt_h=true
fi

if [ $opt_h ]; then
	echo "remove-problematic-artifacts.sh -e|-n|-l|-a [-i|-d|-p]"
	echo ""
	echo "-h help"
	echo "-f never prompt"
	echo "-s show files only(not remove files)"
	echo "-e check *.jar, *.war and *.pom which checksum(md5,sha1) file exists"
	echo "-n check *.jar, *.war and *.pom which checksum(md5,sha1) file does not exists"
	echo "-l check *.lastUpdated"
	echo "-a same as -e, -n and -l"
	echo "-i ignore file/directory name pattern(grep regexp)"
	echo "-d directory(default ~/.m2/repository/)"
	echo "-p max-procs(default 3)"
	exit;
fi

FILES=`find ${TARGET_DIR} -type f -print|grep "\.war$\|\.jar$\|\.pom$\|\.lastUpdated$"`
if [ -n "$REGEXP" ]; then
	FILES=`echo "$FILES"|grep -v "$REGEXP"`
fi


check_files "$FILES"
sort_problem_files

for (( i = 0; i < ${#PROBLEM_FILES[@]}; ++i ))
do
	echo ${PROBLEM_FILES[$i]}
done

if [ $opt_s ]; then
	exit 0
fi

confirm "remove files"

for (( i = 0; i < ${#PROBLEM_FILES[@]}; ++i ))
do
	rm ${PROBLEM_FILES[$i]}
done

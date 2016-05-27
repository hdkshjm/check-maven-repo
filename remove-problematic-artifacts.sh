#!/bin/bash

FILES=()
PROBLEM_FILES=""
TARGET_DIR="${HOME}/.m2/repository/"
PARALLELISM=3
REGEXP=""
SCRIPT_DIR=`echo $(cd $(dirname $0);pwd)`

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

FILES=`find "${TARGET_DIR}" -type f -print|grep "\.war$\|\.jar$\|\.pom$\|\.lastUpdated$"| while read line ; do echo "$line" ;done`
if [ -n "$REGEXP" ]; then
	FILES=`echo "$FILES"|grep -v "$REGEXP"`
fi

cd "${SCRIPT_DIR}"
PROBLEM_FILES=`echo "$FILES"| xargs -P ${PARALLELISM} -I@@@ ./check_artifact.sh "@@@" "${opt_e:-''}" "${opt_n:-''}" "${opt_l:-''}"`
PROBLEM_FILES=`echo "${PROBLEM_FILES}"|sort -n|uniq`

echo "${PROBLEM_FILES}"

if [ $opt_s ]; then
	exit 0
fi

confirm "remove files"

echo "${PROBLEM_FILES}"|while read line ; do rm "$line" ;done

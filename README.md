# check-maven-repo
==================

maven repositoryにおいて、checksum error、checksumのないartifacts、download失敗したときのlastupdateを削除する

# 使い方
````
remove-problematic-artifacts.sh -e|-n|-l|-a [-i|-l|-p]
  -h help
  -f never prompt
  -s show files only(not remove files)
  -e check *.jar, *.war and *.pom which checksum(md5,sha1) file exists
  -n check *.jar, *.war and *.pom which checksum(md5,sha1) file does not exists
  -l check *.lastUpdated
  -a same as -e, -n and -l
  -i ignore file/directory name pattern(grep regexp)
  -d directory(default ~/.m2/repository/)
  -p max-procs(default 3)
````

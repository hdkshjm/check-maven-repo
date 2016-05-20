# check-maven-repo
==================

remove incorrect checksums and lastupdated files on your machine. or find the artifacts which doesn't have checksum files.

# How to use
## help
````
remove-problematic-artifacts.sh -e|-n|-l|-a [-i|-d|-p]
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


## On Sonatype Nexus, find the artifacts which checksum are incorrect, except Nexus meta dir /.nexus/attributes/
````
remove-problematic-artifacts.sh -e -s -i "/\.nexus/attributes/" -d ${NEXUS_HOME}
````

==================

maven repositoryにおいて、checksum error、checksumのないartifacts、download失敗したときのlastupdateを削除する

# 使い方
## help
````
remove-problematic-artifacts.sh -e|-n|-l|-a [-i|-d|-p]
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
## -javadoc.jar や -sources.jar をcheckしたくない場合
````
remove-problematic-artifacts.sh -e -i "\-javadoc\.jar\|\-sources\.jar"
````
## Sonatype Nexusにおいてrepositoryのmeta情報を格納する /.nexus/attributes/ をcheckしたくない場合
````
remove-problematic-artifacts.sh -e -i "/\.nexus/attributes/"
````


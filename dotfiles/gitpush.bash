#!/bin/bash
if [ $# -eq 0 ]; then
  echo "Usage: $0 <branch1> <branch2> <...>"
  echo "or"
  echo "Usage: $0 all"
  branches=`git branch -av`
  if [ $? -eq 0 ]; then
    echo "available branches:"
    branches=`git branch -av |awk 'BEGIN {FS=" "; result = ""} END {print result} $0 ~ /remotes\/origin/ {if (substr($1,16) != "HEAD"){result = result  substr($1,16) " ";}}'`
    echo $branches
  fi
  exit
fi
if [ "a$1" = "aall" ]; then
  branches=`git branch -av |awk 'BEGIN {FS=" "; result = ""} END {print result} $0 ~ /remotes\/origin/ {if (substr($1,16) != "HEAD"){result = result  substr($1,16) " ";}}'`
else
  branches=`echo $*`
fi
for i in $branches; do 
  echo "pushing changes to $i"
  isok=`git branch -r|egrep "$i\$"|wc -l`
  if [ $isok -eq 0 ]; then
    echo "branch origin/$i does not seem to exist -- ignoring"
    echo "."
  else
    git push origin HEAD:$i
    echo "."
  fi
done

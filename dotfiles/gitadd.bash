#!/bin/bash
foi=0
echo ""
git st
if [ $? -gt 0 ]; then
  echo 'Something went wrong...'
  exit $?
fi

read gmod gdel gadd <<HERE
$(git st|awk 'BEGIN {tot1=0; tot2=0; tot3=0} $1 ~ /M/ {tot1++} $1 ~ /D/ {tot2++} $1 ~ /\?\?/ {tot3++} END {print tot1 " " tot2 " " tot3}')
HERE

echo ""
if [ $gmod -gt 0 ]; then
  echo -n "Stage $gmod file modification(s)? (y/n) "
  read -t 5 go
  if [ "a$go" == "ay" ]; then
    git st | awk '$1 ~ /M/ {print $2}' | xargs git add
    foi=1
  fi
fi

echo ""
if [ $gdel -gt 0 ]; then
  echo -n "Stage $gdel file deletion(s)? (y/n) "
  read -t 5 go
  if [ "a$go" == "ay" ]; then
    git st | awk '$1 ~ /D/ {print $2}' | xargs git rm
    foi=1
  fi
fi

echo ""
if [ $gadd -gt 0 ]; then
  echo -n "Stage $gadd new file(s)? (y/n) "
  read -t 5 go
  if [ "a$go" == "ay" ]; then
    git st | awk '$1 ~ /\?\?/ {print $2}' | xargs git add
    foi=1
  fi
fi

echo ""
if [ $foi -gt 0 ]; then
  echo -n "Do you want to commit change(s) now? (y/n) "
  read -t 5 go
  if [ "a$go" == "ay" ]; then
    git ci
  fi
fi
echo "Done."

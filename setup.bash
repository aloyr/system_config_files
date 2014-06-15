#!/bin/bash

GITUSER=`finger $USER|awk '$0 ~ /Name:/'|sed 's/.*Name: //g'`
GITEMAIL=""

. ./config

if [ `id -u` -ne 0 ]; then
  echo "ERROR: You need root privileges to run this program."
  echo "Use 'sudo $0' instead"
  exit 1
fi

function getGitFile() {
  if [ -n $1 ]; then
    echo "Fetching $1"
    curl https://raw.githubusercontent.com/git/git/master/contrib/completion/$1 2> /dev/null > $DSTDIR$1
    chmod +x $DSTDIR$1
  fi
}

function getAloyrFile() {
  if [ -n $1 ]; then
    echo "Fetching $1"
    curl https://raw.githubusercontent.com/aloyr/system_config_files/master/$1 2> /dev/null > $DSTDIR$1
    chmod +x $DSTDIR$1
  fi
}

function checkProfile() {
  echo "Checking for /etc/profile.d"
  if [ `grep profile.d /etc/profile > /dev/null; echo $?` -ne 0 ]; then
    cat <<EOF >> /etc/profile
for PROFILE_SCRIPT in \$( ls /etc/profile.d/*.sh ); do
  . \$PROFILE_SCRIPT
done
EOF
  fi
}

DSTDIR="/usr/local/bin/"
for gitFile in git-completion.bash git-prompt.sh; do
  getGitFile $gitFile
done

for aloyrFile in gitadd.bash gitpush.bash set_prompt.bash; do
  getAloyrFile $aloyrFile
done

DSTDIR=$HOME
for aloyrFile in toprc vimrc gitconfig; do
  getAloyrFile $aloyrFile
  chown $USER $DSTDIR$aloyrFile
  chmod -x $DSTDIR$aloyrFile
  mv $DSTDIR{,.}$aloyrFile
done

checkProfile
echo "Done."

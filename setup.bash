#!/bin/bash

GITUSER=`finger $USER|awk '$0 ~ /Name:/'|sed 's/.*Name: //g'`
GITEMAIL=""
SHELL="/bin/bash"
DOPYTHON=false

if [ ! -f config ];then
  echo ""
  echo "ERROR: missing config file"
  echo "You should create a config text file to add your customizations"
  echo "At a minimum, you should set the GITEMAIL variable"
  echo "Example:"
  echo ""
  echo "cat 'GITEMAIL="yourname@gmail.com"' > config"
  echo ""
  exit 1
else
  . ./config
fi

if [ `id -u` -ne 0 ]; then
  echo "ERROR: You need root privileges to run this program."
  echo "Use 'sudo $0' instead"
  exit 1
fi

function getGitFile() {
  if [ -n $1 ]; then
    echo "Fetching $1"
    if [ -f $DSTDIR$1 ]; then
      echo "File already in place"
    else
      curl https://raw.githubusercontent.com/git/git/master/contrib/completion/$1 2> /dev/null > $DSTDIR$1
      chmod +x $DSTDIR$1
    fi
  fi
}

function getAloyrFile() {
  if [ -n $1 ]; then
    echo "Fetching $1"
    if [ -f $DSTDIR$1 ]; then
      echo "File already in place"
    else
      curl https://raw.githubusercontent.com/aloyr/system_config_files/master/$1 2> /dev/null > $DSTDIR$1
      chmod +x $DSTDIR$1
    fi
  fi
}

function getAloyrDotFile() {
  if [ -n $1 ]; then
    echo "Fetching $1"
    if [ -f $DSTDIR.$1 ]; then
      echo "File already in place"
    else
      curl https://raw.githubusercontent.com/aloyr/system_config_files/master/$1 2> /dev/null > $DSTDIR$1
      chmod +x $DSTDIR$1
      chown $USER $DSTDIR$aloyrFile
      chmod -x $DSTDIR$aloyrFile
      mv $DSTDIR{,.}$aloyrFile
    fi
  fi
}

function checkProfile() {
  echo "Checking for /etc/profile.d parsing"
  if [ ! -d /etc/profile.d ]; then
    mkdir /etc/profile.d
    touch /etc/profile.d/tmp.sh
  fi
  if [ `grep profile.d /etc/profile > /dev/null; echo $?` -ne 0 ]; then
    cat <<EOF >> /etc/profile
for PROFILE_SCRIPT in \$( ls /etc/profile.d/*.sh ); do
  . \$PROFILE_SCRIPT
done
EOF
  else
    echo "Profile.d already setup"
  fi
  echo "Checking for set_prompt"
  if [ `grep set_prompt.bash /etc/profile > /dev/null; echo $?` -ne 0 ]; then
    echo "" >> /etc/profile
    echo ". /usr/local/bin/set_prompt.bash" >> /etc/profile
  else
    echo "set_prompt already setup"
  fi
}

function changeShell() {
  chsh -s $SHELL $USER
  chsh -s $SHELL root
}

function setupPythonModule() {
  if [ `pip show $1 | wc -l` -eq 0 ]; then
    echo "Installing $1 module"
    pip install $1
  else
    echo "$1 module already installed"
  fi
}

function setupPython() {
  echo "Checking Python setup"
  if [ `which pip > /dev/null; echo $?` -ne 0 ]; then
    echo "Installing pip"
    easy_install pip
  else
    echo "pip is already installed"
  fi
  for module in requests pyquery; do
    setupPythonModule $module
  done
}

changeShell

DSTDIR="/usr/local/bin/"
for gitFile in git-completion.bash git-prompt.sh; do
  getGitFile $gitFile
done

for aloyrFile in gitadd.bash gitpush.bash set_prompt.bash; do
  getAloyrFile $aloyrFile
done

DSTDIR=$HOME
for aloyrDotFile in toprc vimrc gitconfig; do
  getAloyrFile $aloyrFile
done

checkProfile

if [ $DOPYTHON == true ]; then
  setupPython
else
  echo "Skipping python setup"
fi

echo "Done."

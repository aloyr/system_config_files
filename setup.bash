#!/bin/bash

# setup conservative defaults
GITUSER=`finger $SUDO_USER|awk '$0 ~ /Name:/'|sed 's/.*Name: //g'`
if [ -z $GITEMAIL ]; then
  GITEMAIL=""
fi
SHELL="/bin/bash"
DOPYTHON=false
DOVIM=false
DOPUPPET=false
DOPORTS=false

if [ `id -u` -ne 0 ]; then
  echo "ERROR: You need root privileges to run this program."
  echo "Use 'sudo $0' instead"
  exit 1
fi

if [ $(uname -v | grep ^Darwin > /dev/null ; echo $?) -eq 0 ];then
  for file in xcodebuild xcode-select; do
    if [ $(which $file | wc -l) -eq 0 ]; then
      echo "xcode is not installed."
      echo "please install xcode before continuing."
      exit 1
    fi
  done
fi

if [ $(xcode-select -p &> /dev/null; echo $?) -ne 0 ]; then
  echo "xcode tools are not installed, trying to install now"
  xcode-select --install
fi

if [ $(which pip > /dev/null; echo $?) -ne 0 ]; then
  easy_install pip
fi

function install() {
  echo "inside install - $1"
  ext=$(echo $1 | sed 's/.*[^\.]*\.\([^\.]*\)$/\1/g')
  case $ext in
  "pkg")
    echo "inside pkg"
    /usr/sbin/installer -pkg $1 -target /
    ;;
  "dmg")
    echo "inside dmg"
    volume=$(hdutil mount $1 | grep Volumes | sed 's/.*\/Volumes/\/Volumes/g')
    volume_queue="$volume_queue; $volume"
    if [ $(cp -a $volume/*.app /Applications/ &> /dev/null; echo $?) -ne 0 ]; then
      echo "inside if"
      for file in ls $volume/*.{dmg,pkg}; do
        echo "inside for"
        install $file
      done
    fi
    echo "about to unmount $volume"
    umount $(echo $volume_queue | awk 'function ltrim(s) { sub(/^[ \t\r\n]+/, "", s); return s } function rtrim(s) { sub(/[ \t\r\n]+$/, "", s); return s } function trim(s)  { return rtrim(ltrim(s)); } BEGIN {FS=";"} {for (i=1; i<NF; i++) {if (length(trim($i)) > 0) print $i}}' | tail -n 1)
    ;;
  esac
}

echo "about to check for MacPorts..."
if [ $(port help &> /dev/null; echo $?) -ne 0 ]; then
  echo "need to install..."
  portURL=$(curl -s https://www.macports.org/install.php | grep 'distfiles.macports.org/MacPorts' | grep $(sw_vers -productVersion) | sed 's/.*href="\([^"]*\)".*/\1/g' | uniq)
  portPKG=~/Downloads/$(echo $portURL | sed 's/.*\/\([^/]*\)$/\1/g')
  curl -o $portPKG $portURL
  if [ $(file $portPKG | grep HTML &> /dev/null; echo $?) -eq 0 ]; then
    echo "found redirect file, trying again"
    portURL=$(cat $portPKG | grep 'pkg' | grep $(sw_vers -productVersion) | sed 's/.*href="\([^"]*\)".*/\1/g' | uniq)
    curl -o $portPKG $portURL
  fi
  install $portPKG
fi

if [ $(port echo installed | grep ^libxml2 | wc -l) -ne 1 ]; then
  port install libxml2
fi

pip install -U requests pyquery fabric ansible

if [ ! -f config ] && [ ${#GITEMAIL} -lt 5 ] && ! grep "@" <<<$GITEMAIL; then
  echo ""
  echo "WARNING: missing config file"
  echo "You could create a config text file to add your customizations"
  echo "If you do that, at a minimum, you should set the GITEMAIL variable"
  echo "Example:"
  echo ""
  echo "echo 'GITEMAIL="yourname@gmail.com"' > config"
  echo ""
  echo "For more information about available customizations, refer to the"
  echo "online example file located at:"
  echo "https://github.com/aloyr/system_config_files/blob/master/example.config"
  echo ""
  echo "Alternatively, you can just enter your email below in the following 1-liner:"
  echo 'curl -s https://raw.githubusercontent.com/aloyr/system_config_files/master/setup.bash | sudo GITEMAIL="youremail@gmail.com" bash'
  if [ ${#GITEMAIL} -gt 5 ] && grep "@" <<<$GITEMAIL; then
    echo "Thank you, continuing with setup."
  else
    echo "Error detected with the email address, stopping process."
    exit 1
  fi
else
  . ./config 2> /dev/null
fi

function getGitFile() {
  if [ ! -d $DSTDIR ]; then mkdir -p $DSTDIR; fi
  if [ -n $1 ]; then
    echo "Fetching $1"
    if [ -f $DSTDIR$1 ]; then
      echo "File already in place"
    else
      curl -s https://raw.githubusercontent.com/git/git/master/contrib/completion/$1 > $DSTDIR$1
      chmod +x $DSTDIR$1
    fi
  fi
}

function getAloyrFile() {
  if [ ! -d $DSTDIR ]; then mkdir -p $DSTDIR; fi
  if [ -n $1 ]; then
    echo "Fetching $1"
    if [ -f $DSTDIR$1 ]; then
      echo "File already in place"
    else
      curl -s https://raw.githubusercontent.com/aloyr/system_config_files/master/dotfiles/$1 > $DSTDIR$1
      chmod +x $DSTDIR$1
    fi
  fi
}

function getAloyrDotFile() {
  if [ ! -d $DSTDIR ]; then mkdir -p $DSTDIR; fi
  if [ -n $1 ]; then
    echo "Fetching $1"
    if [ -f $DSTDIR.$1 ]; then
      echo "File already in place"
    else
      curl -s https://raw.githubusercontent.com/aloyr/system_config_files/master/dotfiles/$1 > $DSTDIR.$1
      chmod +x $DSTDIR.$1
      chown $SUDO_USER $DSTDIR.$1
      chmod -x $DSTDIR.$1
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

function setupVim() {
  getAloyrDotFile vimrc
  cd ~/
  git clone https://github.com/aloyr/vimrc.git .vim
  cd .vim
  git submodule init
  git submodule update --recursive
}

function getHelpers() {
  eval DOIT=\$$1
  if [ -n "$DOIT" ] && [ $DOIT == true ]; then
    curl -s https://raw.githubusercontent.com/aloyr/system_config_files/master/lib/get${1:2}.py | python
  else
    echo "Skipping $1 download"
  fi
}

echo "setting up xcode"
xcodebuild -license
xcode-select --install
echo "done setting up xcode"

if [ -d ~/Downloads ]; then
  echo "download folder already exists"
else
  echo "creating download folder"
  mkdir ~/Downloads
fi

changeShell

DSTDIR="/usr/local/bin/"
for gitFile in git-completion.bash git-prompt.sh; do
  getGitFile $gitFile
done

for aloyrFile in gitadd.bash gitpush.bash set_prompt.bash geoip drush.complete; do
  getAloyrFile $aloyrFile
done

DSTDIR="$HOME/"
for dotFile in toprc gitconfig; do
  getAloyrDotFile $dotFile
done
git config --global user.name "$GITUSER"
git config --global user.email $GITEMAIL

checkProfile

if [ $DOPYTHON == true ]; then
  setupPython
else
  echo "Skipping python setup"
fi

if [ $DOVIM == true ]; then
  setupVim
else
  echo "Skipping python setup"
fi

for i in DO{Ports}; do
  getHelpers $i
done

echo "Done."

HISTTIMEFORMAT="%Y-%m-%d %T "
# some more ls aliases
[[ $(uname -s) == 'Darwin' ]] && color="G" || color=" --color=auto"
alias ll="ls -l$color"
alias la="ls -A$color"
alias l="ls -CF$color"
alias pvenv3='python3.4 -m venv venv_${PWD##*/} && . venv_${PWD##*/}/bin/activate'
alias pvenv2='python2.7 -m virtualenv venv_${PWD##*/} && . venv_${PWD##*/}/bin/activate'

# setup php version if MAMPPro is found
if [ -f ~/Library/Preferences/de.appsolute.mamppro.plist ]; then
  PHPVER=$(/usr/libexec/PlistBuddy -c "print phpVersion" ~/Library/Preferences/de.appsolute.mamppro.plist)
  export PATH=/Applications/MAMP/bin/php/php${PHPVER}/bin:$PATH
fi

# Set prompt
TTYNAME=`tty|cut -b 6-`
USUARIO=`id -u`
if [ $USUARIO -eq 0 ]; then
  PS1="# \[\033[1;31m\]\u@\h\[\033[01;34m\]($TTYNAME) \[\033[1;34m\]\w\[\033[0m\]\n"
else
  PS1="# \[\e[32m\]\u@\h\[\033[01;34m\]($TTYNAME) \[\033[1;34m\]\w\[\033[0m\]\n"
fi

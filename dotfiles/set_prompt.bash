#!/bin/bash

# Setup lang
export LANG="en_US.UTF-8"
export EDITOR=vim

# Disable warning on new macs
export BASH_SILENCE_DEPRECATION_WARNING=1
# Fix ansible thread issue on apple silicon
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

# History adjustments
export HISTTIMEFORMAT="%Y-%m-%d %T "
export HISTSIZE=""
export HISTCONTROL=ignoreboth
export HISTIGNORE="history:clear:ls:ll"
shopt -s histappend
PROMPT_COMMAND="history -a;$PROMPT_COMMAND"

# some more ls aliases
[[ $(uname -s) == 'Darwin' ]] && color="G" || color=" --color=auto"
[[ $(which busybox 2> /dev/null) ]] && color=""
[[ $(which lsd 2> /dev/null) ]] && alias ls="lsd"
alias ll="ls -l$color"
alias la="ls -a$color"
alias lla="lls -al$color"
alias lt="ls --tree"
alias l="ls -CF$color"

# other convenience aliases
alias dignsa='dig +noall +short +answer'
alias path='echo $PATH | tr : "\n"'
alias paths='echo $PATH | tr : "\n" | sort'
alias pvenv2='python2 -m virtualenv venv2_${PWD##*/} && . venv2_${PWD##*/}/bin/activate'
alias pvenv3='python3 -m venv venv3_${PWD##*/} && . venv3_${PWD##*/}/bin/activate'
alias stripcolors="sed \"s,$(printf '\033')\\[[0-9;]*[a-zA-Z],,g\""
alias tmux='TERM=xterm-256color tmux'
alias brewupdate='brew update && kill -9 $(ps wax | awk "tolower(\$0) ~ /better/ && !/awk/ {print \$1}") && brew upgrade -g bettertouchtool && open /Applications/BetterTouchTool.app && brew outdated -g && brew reinstall --force spotify slack obs syntax-highlight librewolf chromium jetbrains-toolbox --no-quarantine && brew upgrade -g'
alias brewmonitor='watch -n 20 'out="$(brew outdated -g)"; echo "$out" | wc -l; echo "$out"''

# only setup composer alias if needed
if [[ -f /usr/local/bin/composer.phar && ! -f /usr/local/bin/composer ]]; then
  alias composer='php /usr/local/bin/composer.phar'
fi

# temp fix for bw cli
alias bw='NODE_OPTIONS="--no-deprecation" bw'


# Conditional functions
## Add dash app support to bash
if [ -d "/Applications/Dash.app" ]; then
  function dash() {
    open  "dash://$@"
  }
fi

# PATH settings
# setup php version if MAMPPro is present
#if [ -f ~/Library/Preferences/de.appsolute.mamppro.plist ]; then
#  PHPVER=$(/usr/libexec/PlistBuddy -c "print phpVersion" ~/Library/Preferences/de.appsolute.mamppro.plist)
#  export PATH="/Applications/MAMP/bin/php/php${PHPVER}/bin:$PATH"
#fi

# Conditional paths
# composer bin
[ -d ~/.composer/vendor/bin ] && export PATH="$HOME/.composer/vendor/bin:$PATH"
# symfony bin
[ -d ~/.symfony/bin ] && export PATH="$HOME/.symfony/bin:$PATH"
# symfony5 bin
[ -d ~/.symfony5/bin ] && export PATH="$HOME/.symfony5/bin:$PATH"
# yarn bin
[ -d ~/.yarn/bin ] && export PATH="$HOME/.yarn/bin:$PATH"
# android lib platform
[ -d ~/Library/Android/sdk/platform-tools ] && export PATH="$HOME/Library/Android/sdk/platform-tools:$PATH"
# android lib
[ -d ~/Library/Android/sdk/tools ] && export PATH="$HOME/Library/Android/sdk/tools:$PATH"

# update this file
function updatepromptfile() {
  PROMPTFILE="/usr/local/bin/set_prompt.bash"
  sudo curl -s https://raw.githubusercontent.com/aloyr/system_config_files/main/dotfiles/set_prompt.bash -o $PROMPTFILE
  sudo chmod +x $PROMPTFILE
  . $PROMPTFILE
}

# Helper functions
# check ssl expiration
function ssl_check() {
  if [ -z ${1+x} ] ; then
    echo "usage: ssl_check <domain:port>"
  else
    domain=$([[ $1 =~ [a-zA-Z.]*:[0-9]* ]] && echo "$1" || echo "$1:443")
    echo | openssl s_client -connect $domain 2>/dev/null | openssl x509 -noout -dates
  fi
}

# sets up xcode on macOS
function setupxcode() {
  if [ $(uname -s) == "Darwin" ]; then
    CLUFILE="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
    touch $CLUFILE
    CLU=$(softwareupdate -l | sed -n 's/.*\*.*\(Command Line.*\)$/\1/gp')
    if [ ! -z "$CLU" ]; then
      softwareupdate -i "$CLU" -v
    fi
    rm $CLUFILE
  else
    echo "this command only works on macOS."
  fi
}

# set port version auto-upgrade alias if on a mac
function portupgrade() {
  if [ $(uname -s) == "Darwin" ]; then
    OSVERSION=$(sw_vers -productVersion | sed 's/\..*//')
    PKGURL=$(curl -Ls https://www.macports.org/install.php | sed -n 's/.*"\([^"]*'$OSVERSION'[^"]*\.pkg\)".*/\1/gp' | head -n 1)
    if [ ! -z $PKGURL ]; then
      PKGFILE=$(echo $PKGURL | sed 's/.*\/\([^/]*\)$/\1/g')
      PKGNAME="/tmp/$PKGFILE"
      curl -s $PKGURL > $PKGNAME
      sudo installer -pkg $PKGNAME -target /
      rm $PKGNAME
      setupxcode
    fi
  else
    echo "this command only works on macOS."
  fi
}

# set port auto-update alias if on a mac
function portupdate() {
  if [ $(uname -s) == "Darwin" ]; then
    sudo port selfupdate
    sudo port upgrade outdated
    for action in clean uninstall; do 
      sudo port $action inactive
    done
    while [ $(port echo leaves | wc -l) -gt 0 ]; do
      for action in echo clean uninstall; do
        sudo port $action leaves
      done
    done
  else
    echo "this command only works on macOS."
  fi
}

# colorful man pages
# http://boredzo.org/blog/archives/2016-08-15/colorized-man-pages-understood-and-customized
man() {
    env \
        LESS_TERMCAP_mb=$(printf "\e[1;31m") \
        LESS_TERMCAP_md=$(printf "\e[1;31m") \
        LESS_TERMCAP_me=$(printf "\e[0m") \
        LESS_TERMCAP_se=$(printf "\e[0m") \
        LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
        LESS_TERMCAP_ue=$(printf "\e[0m") \
        LESS_TERMCAP_us=$(printf "\e[1;32m") \
            man "$@"
}

# color setup
# Attribute codes: 
# 00=none 01=bold 04=underscore 05=blink 07=reverse 08=concealed
# Text color codes:
# 30=black 31=red 32=green 33=yellow 34=blue 35=magenta 36=cyan 37=white
# Background color codes:
# 40=black 41=red 42=green 43=yellow 44=blue 45=magenta 46=cyan 47=white
BLACK_BOLD='\e[1;30m'
BLACK_NORMAL='\e[0;30m'
BLUE_BOLD='\e[1;34m'
BLUE_NORMAL='\e[0;34m'
GREEN_BOLD='\e[1;32m'
GREEN_NORMAL='\e[0;32m'
MAGENTA_BOLD='\e[1;35m'
MAGENTA_NORMAL='\e[0;35m'
RED_BOLD='\e[1;31m'
RED_NORMAL='\e[0;31m'
RESET='\e[0m'

# more colors
# Reset
Color_Off='\e[0m'       # Text Reset

# Regular Colors
Black='\e[0;30m'        # Black
Red='\e[0;31m'          # Red
Green='\e[0;32m'        # Green
Yellow='\e[0;33m'       # Yellow
Blue='\e[0;34m'         # Blue
Purple='\e[0;35m'       # Purple
Cyan='\e[0;36m'         # Cyan
White='\e[0;37m'        # White

# Bold
BBlack='\e[1;30m'       # Black
BRed='\e[1;31m'         # Red
BGreen='\e[1;32m'       # Green
BYellow='\e[1;33m'      # Yellow
BBlue='\e[1;34m'        # Blue
BPurple='\e[1;35m'      # Purple
BCyan='\e[1;36m'        # Cyan
BWhite='\e[1;37m'       # White

# Underline
UBlack='\e[4;30m'       # Black
URed='\e[4;31m'         # Red
UGreen='\e[4;32m'       # Green
UYellow='\e[4;33m'      # Yellow
UBlue='\e[4;34m'        # Blue
UPurple='\e[4;35m'      # Purple
UCyan='\e[4;36m'        # Cyan
UWhite='\e[4;37m'       # White

# Background
On_Black='\e[40m'       # Black
On_Red='\e[41m'         # Red
On_Green='\e[42m'       # Green
On_Yellow='\e[43m'      # Yellow
On_Blue='\e[44m'        # Blue
On_Purple='\e[45m'      # Purple
On_Cyan='\e[46m'        # Cyan
On_White='\e[47m'       # White

# High Intensity
IBlack='\e[0;90m'       # Black
IRed='\e[0;91m'         # Red
IGreen='\e[0;92m'       # Green
IYellow='\e[0;93m'      # Yellow
IBlue='\e[0;94m'        # Blue
IPurple='\e[0;95m'      # Purple
ICyan='\e[0;96m'        # Cyan
IWhite='\e[0;97m'       # White

# Bold High Intensity
BIBlack='\e[1;90m'      # Black
BIRed='\e[1;91m'        # Red
BIGreen='\e[1;92m'      # Green
BIYellow='\e[1;93m'     # Yellow
BIBlue='\e[1;94m'       # Blue
BIPurple='\e[1;95m'     # Purple
BICyan='\e[1;96m'       # Cyan
BIWhite='\e[1;97m'      # White

# High Intensity backgrounds
On_IBlack='\e[0;100m'   # Black
On_IRed='\e[0;101m'     # Red
On_IGreen='\e[0;102m'   # Green
On_IYellow='\e[0;103m'  # Yellow
On_IBlue='\e[0;104m'    # Blue
On_IPurple='\e[0;105m'  # Purple
On_ICyan='\e[0;106m'    # Cyan
On_IWhite='\e[0;107m'   # White

# error_codes prompt
#Good="$GREEN_BOLD""✔"
Good="✔"
#Bad="$RED_BOLD""✘"
Bad="✘"

function errCode() {
  if [[ $? == 0 ]]; then 
    echo -ne $Good
  else 
    echo -ne "$Bad [$?]"
  fi
}

function runThis() {
  if [ -f $1 ]; then
    . $1
  fi
}

# Set prompt
TTYNAME=`tty|cut -b 6-`
USUARIO=`id -u`

# prepping environment
# from https://github.com/git/git/raw/master/contrib/completion/git-completion.bash
runThis '/usr/local/bin/git-completion.bash'
# from https://github.com/git/git/raw/master/contrib/completion/git-prompt.sh
runThis '/usr/local/bin/git-prompt.sh'
# from https://trac.macports.org/wiki/howto/bash-completion
#. /opt/local/etc/bash_completion

GIT_PS1_SHOWDIRTYSTATE=true
GIT_PS1_SHOWSTASHSTATE=true
GIT_PS1_SHOWUNTRACKEDFILES=true
GIT_PS1_SHOWUPSTREAM="auto verbose"
GIT_PS1_SHOWCOLORHINTS=true #only available on PROMPT_COMMAND mode

if [ $USUARIO -eq 0 ]; then
  PS1="$RESET# \$(errCode) $RED_BOLD\u@\h$BLUE_BOLD($TTYNAME) \w $MAGENTA_NORMAL\$(__git_ps1 '(%s)')$RESET\n"
else
  PS1="$RESET# \$(errCode) $GREEN_BOLD\u@\h$BLUE_BOLD($TTYNAME) \w $MAGENTA_NORMAL\$(__git_ps1 '(%s)')$RESET\n"
fi


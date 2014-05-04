#!/bin/bash
# some more ls aliases
alias ll='ls -lG'
alias la='ls -AG'
alias l='ls -CFG'
alias speedtest='wget -O /dev/null http://speedtest.wdc01.softlayer.com/downloads/test10.zip'

#alias proxmoxlist='ssh itsbl006890i.olatheks.org pveca -l|awk '\''{print $3}'\''|grep -v CID|xargs -n 1 -i ssh {} vzlist -a -o ctid,numproc,status,ip,hostname,description | grep -v CTID|sort'
#alias opus-update='for i in training staging beta; do git checkout $i; git merge master; git push; done; git checkout master'
alias composer='php /usr/local/bin/composer.phar'

export EDITOR=vim

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
    echo -ne $Bad
  fi
}

# Set prompt
TTYNAME=`tty|cut -b 6-`
USUARIO=`id -u`

# prepping environment
# from https://github.com/git/git/raw/master/contrib/completion/git-completion.bash
. /usr/local/bin/git-completion.bash
# from https://github.com/git/git/raw/master/contrib/completion/git-prompt.sh
. /usr/local/bin/git-prompt.sh
GIT_PS1_SHOWDIRTYSTATE=true
GIT_PS1_SHOWSTASHSTATE=true
GIT_PS1_SHOWUNTRACKEDFILES=true
GIT_PS1_SHOWUPSTREAM="auto verbose"
GIT_PS1_SHOWCOLORHINTS=true #only available on PROMPT_COMMAND mode

function reset() {
  echo -ne $RESET
}

if [ $USUARIO -eq 0 ]; then
  PS1="$RESET# \$(errCode) $RED_BOLD\u@\h$BLUE_BOLD($TTYNAME) \w $MAGENTA_NORMAL\$(__git_ps1 '(%s)')$RESET\n"
else
  PS1="$RESET# \$(errCode) $GREEN_BOLD\u@\h$BLUE_BOLD($TTYNAME) \w $MAGENTA_NORMAL\$(__git_ps1 '(%s)')$RESET\n"
fi


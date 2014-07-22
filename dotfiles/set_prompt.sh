HISTTIMEFORMAT="%Y-%m-%d %T "
# some more ls aliases
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'

 # Set prompt
TTYNAME=`tty|cut -b 6-`
USUARIO=`id -u`
if [ $USUARIO -eq 0 ]; then
  PS1="# \[\033[1;31m\]\u@\h\[\033[01;34m\]($TTYNAME) \[\033[1;34m\]\w\[\033[0m\]\n"
else
  PS1="# \[\e[32m\]\u@\h\[\033[01;34m\]($TTYNAME) \[\033[1;34m\]\w\[\033[0m\]\n"
fi

echo "done"

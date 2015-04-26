#-----------------------------------------------------------------------------
#
#  shell environment
#
#-----------------------------------------------------------------------------

# Set the shell prompt.
export PS1='\h:\w\$ '

# List directories in color.
if [ $TERM != dumb -a -x /usr/bin/dircolors ]; then
    alias ls='ls --color'
    eval $(SHELL=${SHELL:-/bin/bash} TERM=xterm-256color /usr/bin/dircolors "$HOME/.dircolors")
fi

# Perform local configuration, if necessary.
if [ -f "$HOME/.bashrc.local" ]; then
    source "$HOME/.bashrc.local"
fi

# If the Cygwin X server is running locally, set DISPLAY accordingly.
if ps | grep /usr/X11R6/bin/XWin > /dev/null; then
    export DISPLAY=:0
fi

  
#-----------------------------------------------------------------------------
# aliases
#-----------------------------------------------------------------------------

alias +="less -S"


#-----------------------------------------------------------------------------
# functions
#-----------------------------------------------------------------------------

function rwin {
    host=$1
    ssh -f -X $host "bash --login -c win"
}

function set_title {
    title="$1"
    echo -ne "\033]0;${title}\007"
}


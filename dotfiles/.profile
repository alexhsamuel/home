########################################################################
#
#  login environment
#
########################################################################

# Who am I?
export EMAIL="alex@alexsamuel.net"

PATH="/usr/local/bin:${PATH}"
PATH="${PATH}:/usr/sbin:/sbin"
if [[ -d $HOME/local/bin ]]; then
    PATH="$HOME/local/bin:$PATH"
fi
export PATH

export LD_LIBRARY_PATH="/usr/local/lib:${LD_LIBRARY_PATH}"
export MAIL=$HOME/mail/inbox

# The one true program.
export EDITOR="emacs"

# Remote file access for rsync.
export RSYNC_RSH="ssh"

# Customize pager.
export PAGER="less"
export LESS="-SFX"

# Virtualenv is obnoxious.  Features should be opt-in.
export VIRTUAL_ENV_DISABLE_PROMPT=1

if [[ -f $HOME/.pythonstartup ]]; then
    export PYTHONSTARTUP=$HOME/.pythonstartup
fi

# Don't print whether we have mail.
unset MAILCHECK

# Perform local configuration, if necessary.
if [[ -f $HOME/.profile.local ]]; 
then
    source $HOME/.profile.local
fi

# Set up the shell environment.
source $HOME/.bashrc


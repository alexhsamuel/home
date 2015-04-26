########################################################################
#
#  login environment
#
########################################################################

export PATH="/usr/local/bin:${PATH}"
export PATH="${PATH}:/usr/sbin:/sbin"
export LD_LIBRARY_PATH="/usr/local/lib:${LD_LIBRARY_PATH}"

# The one true program.
export EDITOR="emacs"

# Remote file access for rsync.
export RSYNC_RSH="ssh"

# Virtualenv is obnoxious.  Features should be opt-in.
export VIRTUAL_ENV_DISABLE_PROMPT=1

# Don't print whether we have mail.
unset MAILCHECK

# Perform local configuration, if necessary.
if [ -f $HOME/.profile.local ]; 
then
    source $HOME/.profile.local
fi

# Set up the shell environment.
source $HOME/.bashrc


#-------------------------------------------------------------------------------
#
#  login environment
#
#-------------------------------------------------------------------------------

# Who am I?
export EMAIL="alex@alexsamuel.net"

PATH="/usr/local/bin:${PATH}"
PATH="${PATH}:/usr/sbin:/sbin"

if [[ -d $HOME/local/bin ]]; then
    PATH="$HOME/local/bin:$PATH"
fi

# Python setup.
if [[ -d $HOME/sw/conda/bin ]]; then
    PATH=$HOME/sw/conda/bin:$PATH
fi
if [[ -f $HOME/.pythonstartup ]]; then
    export PYTHONSTARTUP=$HOME/.pythonstartup
fi
# Virtualenv is obnoxious.  Features should be opt-in.
export VIRTUAL_ENV_DISABLE_PROMPT=1

# Rust setup.
if [[ -d $HOME/.cargo/bin ]]; then
    PATH="$PATH:$HOME/.cargo/bin"
fi

# Node setup.
if [[ -d $HOME/node ]]; then
    PATH="$HOME/sw/node/bin:$HOME/.npm-global/bin:$PATH"
    export NODE_PATH=$HOME/sw/node
fi

export MAIL=$HOME/mail/inbox

# The one true program.
export EDITOR="emacs"

# Remote file access for rsync.
export RSYNC_RSH="ssh"

# Customize pager.
export PAGER="less"
export LESS="-RSX"

# Don't print whether we have mail.
unset MAILCHECK

# Find some of our stuff.
export AHS_DEV_DIR=$HOME/dev
export AHS_GITHUB_DIR=$AHS_DEV_DIR/github

# Perform local configuration, if necessary.
if [[ -f $HOME/.profile.local ]]; then
    source $HOME/.profile.local
fi

# Set up the shell environment.
source $HOME/.bashrc


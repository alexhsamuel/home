#-------------------------------------------------------------------------------
#
#  login environment
#
#-------------------------------------------------------------------------------

if [[ $(uname -s) == "Darwin" ]]; then
    # I don't know WHY the fuck Apple things moronic shit like this is OK.
    export BASH_SILENCE_DEPRECATION_WARNING=1

    # Completely different from GNU.
    export LSCOLORS=GxExcxdxcxegedabagacad
fi

# Who am I?
export EMAIL="alex@alexsamuel.net"

if [[ -d $HOME/.local/bin ]]; then
    PATH="$HOME/.local/bin:$PATH"
fi

# Python setup.  

if [[ -f $HOME/.pythonstartup ]]; then
    export PYTHONSTARTUP=$HOME/.pythonstartup
fi

# Virtualenv is obnoxious.  Features should be opt-in.
export VIRTUAL_ENV_DISABLE_PROMPT=1

# Rust setup.
if [[ -f $HOME/.cargo/env ]]; then
    source $HOME/.cargo/env
    export RUST_SRC_PATH="$(rustc --print sysroot)/lib/rustlib/src/rust/src"
fi

# Set up Java.
if [[ -f $HOME/sw/java ]]; then
    export JAVA_HOME=$HOME/sw/java
    PATH="$JAVA_HOME/bin:$PATH"
fi

# Node setup.
if [[ -d $HOME/sw/node ]]; then
    PATH="$HOME/sw/node/bin:$HOME/.npm-global/bin:$PATH"
    export NODE_PATH=$HOME/sw/node
fi

# SBCL setup.
if [[ -d $HOME/sw/sbcl ]]; then
    PATH="$HOME/sw/sbcl/bin:$PATH"
    export SBCL_HOME=$HOME/sw/sbcl/lib/sbcl
fi

# Citrix setup.
if [[ -d $HOME/sw/icaclient ]]; then
    export ICAROOT=$HOME/sw/icaclient/linuxx64
fi

export MAIL=$HOME/mail/inbox

# Fix the ssh-agent socket path.
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

# Remote file access for rsync.
export RSYNC_RSH="ssh"

# Customize pager.
export PAGER="less"
export LESS="-RSX"

# Define LANGUAGE if LC_ALL isn't set.
if [[ -z "$LC_ALL" ]]; then
    export LANGUAGE=en_US.UTF-8
fi

# Don't print whether we have mail.
unset MAILCHECK

# Find some of our stuff.
export AHS_DEV_DIR=$HOME/dev
export AHS_GITHUB_DIR=$AHS_DEV_DIR/github

# Perform local configuration, if necessary.
if [[ -f $HOME/.profile.local ]]; then
    source $HOME/.profile.local
fi

# Set dircolors.
if [[ -x /usr/bin/dircolors && -f $HOME/.dircolors ]]; then
    eval $(/usr/bin/dircolors $HOME/.dircolors)
fi

# Set up the shell environment.
source $HOME/.bashrc


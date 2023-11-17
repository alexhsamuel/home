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

if [[ -d $HOME/dev/home/bin ]]; then
    PATH="$HOME/dev/home/bin:$PATH"
fi

if [[ -d $HOME/.local/bin ]]; then
    PATH="$HOME/.local/bin:$PATH"
fi

# SSH agent setup.
if [[ -z "$SSH_AUTH_SOCK" ]]; then
    export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
    if [[ ! -S $SSH_AUTH_SOCK ]]; then
	echo "missing ssh-agent socket: $SSH_AUTH_SOCK" >&2
    fi
fi

# Wayland stuff
# Enable Wayland in Firefox.
export MOZ_ENABLE_WAYLAND=1

# Python setup.
if [[ -f $HOME/.pythonstartup ]]; then
    export PYTHONSTARTUP=$HOME/.pythonstartup
fi

# Zig setup.
if [[ -f $HOME/sw/zig ]]; then
    PATH="$HOME/sw/zig:$PATH"
fi

# Ruby.  This is recommended per https://wiki.archlinux.org/title/ruby.
if [[ -x /usr/bin/ruby ]]; then
    _gem="$(ruby -e 'puts Gem.user_dir')"
    if [[ -d "$_gem" ]]; then
	export GEM_HOME="$_gem"
	export PATH="$PATH:$_gem/bin"
    fi
    unset _gem
fi

# Virtualenv is obnoxious.  Features should be opt-in.
export VIRTUAL_ENV_DISABLE_PROMPT=1

# Rust setup.
if [[ -f $HOME/.cargo/env ]]; then
    source $HOME/.cargo/env
    export RUST_SRC_PATH="$(rustc --print sysroot)/lib/rustlib/src/rust/src"
fi

# NVM setup.
if [[ -f /usr/share/nvm/init-nvm.sh ]]; then
    . /usr/share/nvm/init-nvm.sh
fi

# Citrix setup.
if [[ -d $HOME/sw/icaclient ]]; then
    export ICAROOT=$HOME/sw/icaclient/linuxx64
fi

export MAIL=$HOME/mail/inbox

# Remote file access for rsync.
export RSYNC_RSH="ssh"

# Customize pager.
export PAGER="less"
export LESS="-RSX"
export LESSCHARSET="utf-8"

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


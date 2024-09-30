#-------------------------------------------------------------------------------
#
#  shell environment
#
#-------------------------------------------------------------------------------

# Config.

# PiHole DNS service
vpn0=159.65.46.5

#-------------------------------------------------------------------------------

# Set the shell prompt.
export PS1='\h:\w\$ '

if [[ $BASH_VERSION =~ 3 ]]; then
    if [[ -f $HOME/dev/path/path-v3.sh ]]; then
        source $HOME/dev/path/path-v3.sh
    fi
else
    if [[ -f $HOME/dev/path/path.sh ]]; then
        source $HOME/dev/path/path.sh
    fi
fi

# List directories in color.
if [ $TERM != dumb -a -x /usr/bin/dircolors ]; then
    alias ls='ls --color'
    eval $(SHELL=${SHELL:-/bin/bash} TERM=xterm-256color /usr/bin/dircolors "$HOME/.dircolors")
fi

#-------------------------------------------------------------------------------

# Load the path library, if present.
if [[ -d $HOME/dev/path ]]; then
    if [[ $BASH_VERSION =~ 3 ]]; then
        . $HOME/dev/path/path-v3.sh
    else
        . $HOME/dev/path/path.sh
    fi
else
    echo "path library missing" >&2
fi

#-----------------------------------------------------------------------------
# functions
#-------------------------------------------------------------------------------

function abspath {
  echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}

function + { less "$@"; }
function lo { ls -G -oh "$@"; }
function ll { ls -G -al "$@"; }
function open { xdg-open "$@"; }
function utcdate { date -u +"%Y-%m-%dT%H:%M:%SZ"; }

function pyrg { rg -g '*.py' "$@"; }
function c++11 { c++ -std=c++11 -fdiagnostics-color=always "$@"; }
function c++14 { c++ -std=c++14 -fdiagnostics-color=always "$@"; }

function py { python3 -q "$@"; }
function activate {
    if [[ -z "$1" ]]; then
        if [[ -d "./.pyenv" ]]; then
            env=./.pyenv
        elif [[ -d "./env" ]]; then
            env=./env
        else
            echo "can't find env" >&2
            return 1
        fi
    else
        env=$1
    fi
    source "$env"/bin/activate;
}

function userctl { systemctl --user "$@"; }

# Use my emacs, if it's there.
if [[ -d $HOME/sw/emacs ]]; then
    function emacs { $HOME/sw/emacs/bin/emacs "$@"; }
    export EDITOR=$HOME/sw/emacs/bin/emacs
else
    export EDITOR=emacs
fi

#
# github-clone namespace/name
#
# clones a github repo into ~/github/NAMESPACE/NAME.
#
function github-clone {
    repo="$1"
    namespace=$(echo "$repo" | (IFS=/ read ns name; echo $ns))

    [[ -d $AHS_GITHUB_DIR ]] || (
        echo "$AHS_GITHUB_DIR doesn't exist" >&2
        exit 1
    )

    mkdir -p "$AHS_GITHUB_DIR/$namespace"
    git -C "$AHS_GITHUB_DIR/$namespace" clone "git@github.com:$repo.git"
}

function set_title {
    title="$1"
    echo -ne "\033]0;${title}\007"
}

function git-main-branch {
    if [[ -n "$(git branch --all --list '*main')" ]]; then
        echo main
    elif [[ -n "$(git branch --all --list '*master')" ]]; then
        echo master
    fi
}

function git-delete-merged {
    local main="$(git-main-branch)"
    if [[ -z "$main" ]]; then
        echo "unknown main branch" >&2
        return
    fi
    git branch --merged $main | grep -v "$main" | xargs -n 1 -r git branch -d
}

#-------------------------------------------------------------------------------
# MacOS

if [[ $(uname) == Darwin ]]; then
    function emacs {
        /Applications/Emacs.app/Contents/MacOS/Emacs "$@";
    }
fi

#-------------------------------------------------------------------------------

# Perform local configuration, if necessary.
if [ -f "$HOME/.bashrc.local" ]; then
    source "$HOME/.bashrc.local"
fi


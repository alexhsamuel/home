#-------------------------------------------------------------------------------
#
#  shell environment
#
#-------------------------------------------------------------------------------

# Set the shell prompt.
export PS1='\h:\w\$ '

if [[ -f $HOME/dev/path/path.sh ]]; then
    source $HOME/dev/path/path.sh
fi

# List directories in color.
if [ $TERM != dumb -a -x /usr/bin/dircolors ]; then
    alias ls='ls --color'
    eval $(SHELL=${SHELL:-/bin/bash} TERM=xterm-256color /usr/bin/dircolors "$HOME/.dircolors")
fi

# Set up the searchpath shell function.
_searchpath=$HOME/dev/home/dotfiles/searchpath.py
function searchpath {
    var=$1
    shift
    eval $var="$(/usr/bin/python -E "$_searchpath" "${!var}" $@)"
}
  
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

function c++11 { c++ -std=c++11 -fdiagnostics-color=always "$@"; }
function c++14 { c++ -std=c++14 -fdiagnostics-color=always "$@"; }

function py { python -q "$@"; }

#
# Compile a one-file C++14 progam to an executable, and run it.
#
function c++run {
  src=$1
  exe=$(abspath ${src%%.cc})
  (
    set -x
    c++ -std=c++14 -Wall $src -o $exe && $exe
  )
}

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

function rwin {
    host=$1
    ssh -f -X $host "bash --login -c win"
}

function set_title {
    title="$1"
    echo -ne "\033]0;${title}\007"
}

function utcdate { date -u +"%Y-%m-%dT%H:%M:%SZ"; }
function use-env { source activate "$@"; }
function use-root { source deactivate "$@"; }

function git-delete-merged {
    git branch --merged master | grep -v "\* master" | xargs -n 1 git branch -d
}

#-------------------------------------------------------------------------------

# Perform local configuration, if necessary.
if [ -f "$HOME/.bashrc.local" ]; then
    source "$HOME/.bashrc.local"
fi


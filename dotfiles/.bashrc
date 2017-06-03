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

# Set up the searchpath shell function.
_searchpath=$HOME/dev/home/dotfiles/searchpath.py
function searchpath {
    var=$1
    shift
    eval $var="$(/usr/bin/python -E "$_searchpath" "${!var}" $@)"
}
  
# Load the path library, if present.
if [[ -f $HOME/dev/path/path.sh ]]; then
    . $HOME/dev/path/path.sh
    PATH_VARNAME_ALIASES=(
        [CP]=CLASSPATH
        [LD]=LD_LIBRARY_PATH
        [MAN]=MANPATH
        [PY]=PYTHONPATH
        [P]=PATH
    )
else
    echo "path library missing" >&2
fi

#-----------------------------------------------------------------------------
# functions
#-----------------------------------------------------------------------------

function + { less "$@"; }

function c++11 { c++ -std=c++11 "$@"; }
function c++14 { c++ -std=c++14 "$@"; }

#
# github-clone NAMESPACE/NAME
#
# Clones a github repo into ~/github/NAMESPACE/NAME.
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

#-------------------------------------------------------------------------------

# Perform local configuration, if necessary.
if [ -f "$HOME/.bashrc.local" ]; then
    source "$HOME/.bashrc.local"
fi


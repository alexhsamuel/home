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
function open { xdg-open "$@"; }

function pyrg { rg -g '*.py' "$@"; }
function c++11 { c++ -std=c++11 -fdiagnostics-color=always "$@"; }
function c++14 { c++ -std=c++14 -fdiagnostics-color=always "$@"; }

function py { python3 -q "$@"; }
function activate { source "${1:-env}"/bin/activate; }

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

function rwin {
    host=$1
    ssh -f -X $host "bash --login -c win"
}

function set_title {
    title="$1"
    echo -ne "\033]0;${title}\007"
}

function utcdate { date -u +"%Y-%m-%dT%H:%M:%SZ"; }
function pyrg { rg -g '*.py' "$@"; }
function use-env { source activate "$@"; }
function use-root { source deactivate "$@"; }

function git-delete-merged {
    git branch --merged master | grep -v "\* master" | xargs -n 1 git branch -d
}

if [[ -f $HOME/sw/dropbox/dropbox.py ]]; then
    function dropbox {
        python $HOME/sw/dropbox/dropbox.py "$@";
    }
fi

function lock {
    i3lock -c 000000 -e
    $HOME/dev/home/dotfiles/dpms-off
}

# Activate or deactivate PiHole in WiFi DNS.
#
# Turn PiHole off if WiFi captive portals aren't detected properly.
#
#   pihole on -- Set PiHole as the DNS.
#   pihole off -- Reset DNS to network defaults.
#   pihole whitelist [IP] -- Whitelist IP in PiHole's firewall.
#   pihole unwhitelist [IP] -- Unwhitelist IP.
#
function pihole {
    if [[ $1 == "on" || $1 == "off" ]]; then
        if [[ $(uname) == Darwin ]]; then
            device=Wi-Fi
            if [[ $1 == "on" ]]; then
                dns="$vpn0 9.9.9.9"
            else
                dns=empty
            fi
            # Include a backup resolver.
            networksetup -setdnsservers $device $dns
            # Show current state.
            networksetup -getdnsservers $device

            # Flush DNS cache.
            sudo dscacheutil -flushcache
            sudo killall -HUP mDNSResponder
        else
            echo "on/off not implemented for $(uname)" >&2
            return
        fi

    elif [[ $1 == "whitelist" || $1 == "unwhitelist" ]]; then
        if [[ "$2" ]]; then
            ip=$2
        else
            ip=$(curl -s https://api.ipify.org)
        fi
        rule="allow from $ip"
        if [[ $1 == whitelist ]]; then
            echo "whitelisting $ip in PiHole UFW"
            ssh root@$vpn0 ufw $rule
        else
            echo "unwhitelisting $ip in PiHole UFW"
            ssh root@$vpn0 ufw delete $rule
        fi

    else
        echo "usage: pihole on|off" >&2
        return
    fi
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


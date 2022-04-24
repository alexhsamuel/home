#!/bin/bash

# dir=$(readlink -f $(dirname $0))
dir=$(cd $(dirname $0); pwd)
if [[ $dir != $HOME/dev/home/dotfiles ]]; then
    echo "please clone this repo to $HOME/dev/home"
fi

cd $HOME
for file in dev/home/dotfiles/.*; do
    if [[ -f $file ]]; then
	base=$(basename $file)
	if [[ -e $base ]]; then
            if [[ -L $base ]]; then
                target=$(readlink $base)
                if [[ $target = $file ]]; then
                    # Good.
                    :
                else
                    echo "already exists: $base → $target" >&2
                fi
            else
                echo "already exists: $base" >&2
            fi
	else
	    ln -s $file $base
	fi
    fi
done


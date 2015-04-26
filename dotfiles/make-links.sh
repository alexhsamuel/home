#!/bin/bash

dir=$(readlink -f $(dirname $0))
if [[ $dir != $HOME/dev/home/dotfiles ]]; then
    echo "please clone this repo to $HOME/dev/home"
fi

cd $HOME
for file in dev/home/dotfiles/.*; do
    if [[ -f $file ]]; then
	base=$(basename $file)
	if [[ -e $base ]]; then
	    echo "$base already exists"
	else
	    ln -s $file $base
	fi
    fi
done


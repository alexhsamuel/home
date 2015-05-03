#!/bin/bash

mail_file=$HOME/archive/mail/incoming/mail

if [[ ! -f $mail_file ]]; then
    echo "$mail_file doesn't exist" >&2
    exit 1
fi

date=$(date '+%Y%m%d')
archive_file=$mail_file.$date
if [[ -e $archive_file.bz2 ]]; then
    echo "$archive_file.bz2 already exists" >&2
    exit 1
fi

mv $mail_file $archive_file
bzip2 -9 $archive_file


#!/bin/bash
#---------------------------------------------------------------------------
#
# Retrieves archived mail files from the remote mail server.
#
# Uses a (passwordless) ssh key in "rsync" for authentication.  The
# corresponding public key "rsync.pub" must be added to the
# authorized_keys files on the server.
#
#---------------------------------------------------------------------------

ARCHIVE_DIR=archive/mail/incoming
SERVER=indetermi.net.
SSH_KEY=$HOME/$ARCHIVE_DIR/rsync

rsync -e "ssh -i $SSH_KEY" -ar --size-only \
    $SERVER:$ARCHIVE_DIR/mail.\* $HOME/$ARCHIVE_DIR

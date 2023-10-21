BASEDIR="$HOME/.config/Signal"
KEY=$(/usr/bin/jq -r '."key"' $BASEDIR/config.json)
DBPATH="$BASEDIR/sql/db.sqlite"
OUTPATH=$1

if [ -z "$OUTPATH" ]; then
    echo "usage: $0 OUTPATH" >&2
    exit 1
fi

/usr/bin/sqlcipher -list -noheader "$DBPATH" "PRAGMA key = \"x'"$KEY"'\";select json from messages;" > "$OUTPATH"


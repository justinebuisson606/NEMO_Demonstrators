#!/bin/bash
set -u

if [ $# -lt 1 ]; then
    echo "Usage: $0 /path/to/the/directory"
    exit 1
fi

DIR="$1"
DIR_PARENT="${DIR%/EXP*}"
SRC="$DIR_PARENT/MY_SRC/usrdef_istate.F90"
TMP="$DIR_PARENT/MY_SRC/usrdef_istate.F90.tmp"

if [ ! -f "$SRC" ]; then
    echo "Error : cannot find file : $SRC"
    exit 1
fi


awk '
/pts\(:,:,jk,jp_sal\).*EXP.*rn_lambda/ {next}
{print}
' \
"$SRC" > "$TMP"

diff "$SRC" "$TMP"

cp "$SRC" "$SRC.bak"
mv "$TMP" "$SRC"

echo "Changes applied. Saving : $SRC.bak"

DIR_NEMO="${DIR%/tests*}"
cd "$DIR_NEMO"
 
echo "Compiling"

./makenemo -r CANAL -n EXP42




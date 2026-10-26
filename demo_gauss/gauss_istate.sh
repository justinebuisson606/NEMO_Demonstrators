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

grep -q "pts(:,:,jpk,jp_sal).*=.*EXP.*rn_lambda" "$SRC" && SKIP_GAUSS=1 || SKIP_GAUSS=0

awk -v skip_gauss="$SKIP_GAUSS" '
/SUBROUTINE usr_def_istate/ { in_sub=1 }
in_sub && /END SUBROUTINE usr_def_istate/ { in_sub=0 }

in_sub && /SELECT CASE *\( *nn_initcase *\)/ { in_select=1 }
in_select && /END SELECT/ { in_select=0 }

in_sub && in_select && /CASE *\( *1 *\)/ { in_case=1 }
in_case && /END SELECT/ { in_case=0 }

{ 

# 1. Subbing saltblock or current salinity distribution for gaussian distribution
    if (in_sub && in_case && !skip_gauss && $0 ~ /WHERE.*\(.*ABS\(gphit.*\).*<= zsy.*/) {
	l1=$0; getline l2; getline l3; getline l4; getline l5;
	if (l2 ~ /pts\(:,:,jk,jp_sal\).*=.*/ && l3 ~ /ELSEWHERE/ && l4 ~ /pts\(:,:,jk,jp_sal\).*=.*/ && l5 ~ /END.*WHERE/) {
	     next;
	}
	print l1; print l2; print l3; print l4; print l5; next;
	}
    if (in_sub && in_case && !skip_gauss && !done_gauss && /DO jk=1, jpkm1/) {
	print 
	print "            pts(:,:,jk,jp_sal) = 30._wp+5._wp*EXP( -0.5_wp *glamt(:,:)**2 / rn_lambda**2 )"
	done_gauss=1
	next
	}
	
	print
}' \
"$SRC" > "$TMP"

diff "$SRC" "$TMP"


cp "$SRC" "$SRC.bak"
mv "$TMP" "$SRC"
echo "Changes applied. Saving : $SRC.bak"

DIR_NEMO="${DIR%/tests*}"
cd "$DIR_NEMO" || { echo "Error : impossible to enter $DIR_NEMO"; exit 1; }
echo "Compilation form : $(pwd)"

./makenemo -r CANAL -n EXP42

cd "$DIR" || { echo "Error : impossible to go back to $DIR"; exit 1; }
echo "Back to : $(pwd)"

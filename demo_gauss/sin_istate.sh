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

grep -q "pts(:,:,jk,jp_sal).*=.*SIN.*w0" "$SRC" && SKIP=1 || SKIP=0
grep -q "zjetx, zjety, zbeta.*w0" "$SRC" && SKIP_DECL=1 || SKIP_DECL=0
grep -q "w0 = rn_w" "$SRC" && SKIP_W0=1 || SKIP_W0=0



awk -v skip="$SKIP" -v skip_decl="$SKIP_DECL" -v skip_w0="$SKIP_W0" '

{

# Adding w0
   if (!skip_decl && !done_decl && /REAL\(wp\).*::.*zjetx, zjety, zbeta/) {
	sub(/REAL\(wp\).*::.*zjetx, zjety, zbeta/, "REAL(wp) :: zjetx, zjety, zbeta, domx, w0")
	done_decl=1
	print
	next
   }

# Insert w0 and domx, 

if (!skip_w0 && !done_w0 && /zjety *= *ABS\(rn_ujetszy\)\/2._wp/) {
	print 
	print "      !"
	print "      domx = rn_domszx/2._wp"
	print "      !"
	print "      w0 = rn_w"
	done_w0=1
	next
   }

}

/SUBROUTINE usr_def_istate/ { in_sub=1 }
in_sub && /END SUBROUTINE usr_def_istate/ { in_sub=0 }

in_sub && /SELECT CASE *\( *nn_initcase *\)/ { in_select=1 }
in_select && /END SELECT/ { in_select=0 }

in_sub && in_select && /CASE *\( *1 *\)/ { in_case=1 }
in_case && /END SELECT/ { in_case=0 }

{ 

# 1. Subbing saltblock or current salinity distribution for sinusoidal distribution
    if (in_sub && in_case && !skip && $0 ~ /WHERE.*\(.*ABS\(gphit.*\).*<= zsy.*/) {
	l1=$0; getline l2; getline l3; getline l4; getline l5;
	if (l2 ~ /pts\(:,:,jk,jp_sal\).*=.*/ && l3 ~ /ELSEWHERE/ && l4 ~ /pts\(:, :, jk, jp_sal\).*=.*/ && l5 ~ /END.*WHERE/) {
	     next;
	}
	print l1; print l2; print l3; print l4; print l5; next;
	}
    if (in_sub && in_case && !skip && !done && /DO jk=1, jpkm1/) {
	print 
	print "            pts(:, :, jk, jp_sal) = 30._wp +SIN(w0*2._wp*3.14159265358979323846_wp*glamt(:,:)/(domx) )"
	done=1
	next
	}
	
	print
}' \
"$SRC" > "$TMP"

diff "$SRC" "$TMP"


cp "$SRC" "$SRC.bak"
mv "$TMP" "$SRC"
echo "Changes applied. Saving : $SRC.bak"


SRC="$DIR_PARENT/MY_SRC/usrdef_nam.F90"
TMP="$DIR_PARENT/MY_SRC/usrdef_nam.F90.tmp"

grep -q "rn_vtmax, rn_uzonal, rn_ujetszx, rn_ujetszy,.*, rn_w" "$SRC" && SKIP_DECL=1 || SKIP_DECL=0
grep -q "frequency of the sinus salt distribution" "$SRC" && SKIP_W=1 ||SKIP_W=0

awk -v skip_decl="$SKIP_DECL" -v skip_w="$SKIP_W" '
{
#1. Declaring, rn_w as variable
   if (!done_decl && !skip_decl && /rn_vtxmax, rn_uzonal, rn_ujetszx, rn_ujetszy/) {
   sub(/rn_vtxmax, rn_uzonal, rn_ujetszx, rn_ujetszy/, "rn_vtxmax, rn_uzonal, rn_ujetszx, rn_ujetszy, rn_w")
   print
   done_decl=1
   next
   }

# Defininf rn_w 
   if (!done_w && !skip_w && /REAL\(wp\), PUBLIC :: * rn_ujetszy = */) {
 	print
	print "   REAL(wp), PUBLIC ::   rn_w        =   3.  ! frequency of the sinus salt distribution"
	done_w=1
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

NAME_TEST=$(basename "$(dirname "$DIR")")
echo "Name of the CANAL test compiled $NAME_TEST"

cd "$DIR_NEMO" || { echo "Error : impossible to enter $DIR_NEMO"; exit 1; }
echo "Compilation form : $(pwd)"

./makenemo -r CANAL -n $NAME_TEST 

cd "$DIR" || { echo "Error : impossible to go back to $DIR"; exit 1; }
echo "Back to : $(pwd)"

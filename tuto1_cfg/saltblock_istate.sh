#!/bin/bash

#set -x # Turn on debug
#set -v # Turn on Print shell input lines
#set -u #Turn on error if using unset variables

if [ $# -lt 1 ]; then
    echo "Usage: $0 /path/to/the/directory"
    exit 1
fi

DIR="$1"
DIR_PARENT="${DIR%/EXP*}"
SRC="$DIR_PARENT/MY_SRC/usrdef_istate.F90"
TMP="$DIR_PARENT/MY_SRC/usrdef_istate.F90.tmp"

if [ ! -f "$SRC" ]; then
    echo "Erreur : fichier introuvable : $SRC"
    exit 1
fi

# V??rifie si chaque modification a d??j?? ??t?? appliqu??e
grep -q "zjetx, zjety, zbeta, zsx, zsy" "$SRC" && SKIP_DECL=1 || SKIP_DECL=0
grep -q "zsx = ABS(rn_salszx)/2._wp" "$SRC" && SKIP_ZJETY=1 || SKIP_ZJETY=0
grep -q "! *WHERE( ABS(gphit) <= zjety )" "$SRC" && SKIP_WHERE=1 || SKIP_WHERE=0


awk -v skip_decl="$SKIP_DECL" -v skip_zjety="$SKIP_ZJETY" -v skip_where="$SKIP_WHERE" '
/SUBROUTINE usr_def_istate/ { in_sub=1 }
in_sub && /SELECT CASE *\( *nn_initcase *\)/ { in_select=1 }
in_sub && in_select && /CASE *\( *1 *\)/ { in_case1=1 }
in_case1 && /CASE *\(/ && !/CASE *\( *1 *\)/ { in_case1=0 }
in_case1 && /END SELECT/ { in_case1=0 }

{
    # 2. Ajout de zsx, zsy dans la d??claration
    if (!skip_decl && !done_decl && /REAL\(wp\) *:: *zjetx, zjety, zbeta/) {
        sub(/REAL\(wp\) *:: *zjetx, zjety, zbeta/, "REAL(wp) :: zjetx, zjety, zbeta, zsx, zsy")
        done_decl=1
	print
        next
    }

    # 3. Insertion apres le calcul de zjety
    if (!skip_zjety && !done_zjety && /zjety *= *ABS\(rn_ujetszy\)\/2\._wp/) {
        print
        print "      !"
        print "      zsx = ABS(rn_salszx)/2._wp"
        print "      zsy = ABS(rn_salszy)/2._wp"
        print "      !"
	done_zjety=1
        next
    }

    # 1. Commenter le WHERE cible + inserer le nouveau bloc (uniquement dans CASE(1))
    if (!skip_where && !done_where && in_case1 && /WHERE *\( *ABS\(gphit\) *<= *zjety *\)/) {
        sub(/WHERE *\( *ABS\(gphit\) *<= *zjety *\)/, "!WHERE( ABS(gphit) <= zjety )")
        print
        print "            WHERE( ABS(gphit) <= zsy*0.5 .AND. ABS(glamt) <= zsx*0.5)"
        print "               pts(:,:,jk,jp_sal) = 35._wp"
        print "            ELSEWHERE"
        print "               pts(:,:,jk,jp_sal) = 30._wp"
	done_where=1
	next
    }

    print
}' \
"$SRC"  > "$TMP"

diff "$SRC" "$TMP"


cp "$SRC" "$SRC.bak"
mv "$TMP" "$SRC"
echo "Changes applied. Saving : $SRC.bak"

SRC="$DIR_PARENT/MY_SRC/usrdef_nam.F90"
TMP="$DIR_PARENT/MY_SRC/usrdef_nam.F90.tmp"


# V??rifie si chaque modification a d??j?? ??t?? appliqu??e
grep -q "rn_vtxmax, rn_uzonal, rn_ujetszx, rn_ujetszy, rn_salszx, rn_salszy" "$SRC" && SKIP_DECL=1 || SKIP_DECL=0
grep -q "width of the square of salt" "$SRC" && SKIP_SALSZ=1 || SKIP_SALSZ=0

awk -v skip_decl="$SKIP_DECL" -v skip_salsz="$SKIP_SALSZ" '
{
    # 1. Declaring rn_ salszx, rn_salszy variables
    if (!done_decl && !skip_decl && /rn_vtxmax, rn_uzonal, rn_ujetszx, rn_ujetszy/) {
        sub(/rn_vtxmax, rn_uzonal, rn_ujetszx, rn_ujetszy/, "rn_vtxmax, rn_uzonal, rn_ujetszx, rn_ujetszy, rn_salszx, rn_salszy")
        print
	done_decl=1
        next
    }

    # 2. Defining rn_salszx, rn_salszy variables
    if (!done_salsz && !skip_salsz && /REAL\(wp\), PUBLIC :: * rn_ujetszy = */) {
        print
        print "   REAL(wp), PUBLIC ::   rn_salszx  =   50.   ! width of the square of salt [km]"
        print "   REAL(wp), PUBLIC ::   rn_salszy  =   50.   ! height of the square of salt[km]"
        done_salsz=1
	next
    }

    print
}' \
"$SRC"  > "$TMP"

diff "$SRC" "$TMP"

cp "$SRC" "$SRC.bak"
mv "$TMP" "$SRC"
echo "Changes applied. Saving : $SRC.bak"

DIR_NEMO="${DIR%/tests*}"
cd "$DIR_NEMO"

FILE = "${DIR%%tests/*}"
TEST = "${FILE%/*}"

./makenemo -r CANAL -n "$TEST"

cd "$DIR"

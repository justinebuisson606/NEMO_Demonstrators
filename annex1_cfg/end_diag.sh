#!/bin/bash

set -x
set -u 

if [ $# -lt 1 ]; then
    echo "Usage: $0 /path/to/the/directory"
    exit 1
fi

DIR="$1"
SRC="$DIR/namelist_cfg"

if [ ! -f "$SRC" ]; then
    echo "Erreur : fichier introuvable : $SRC"
    exit 1
fi


sed -i.bak \
-e 's/rn_domszx.*=.*\!/rn_domszx        =       1000.    !/' \
-e 's/rn_domszy.*=.*\!/rn_domszy        =       2000.   !/' \
-e 's/rn_domszz.*=.*\!/rn_domszz        =       1000.  !/' \
-e 's/rn_dx.*=.*\!/rn_dx        =       10.     !/' \
-e 's/rn_dy.*=.*\!/rn_dy        =       10.  !/' \
-e 's/rn_dz.*=.*\!/rn_dz        =       1000.  !/' \
-e 's/rn_0xratio.*=.*\!/rn_0xratio      =       0.5  !/' \
-e 's/rn_0yratio.*=.*\!/rn_0yratio      =       0.5  !/' \
-e 's/nn_fcase.*=.*\!/nn_fcase  =       0  !/' \
-e 's/rn_ppgphi0.*=.*\!/rn_ppgphi0      =       38.5  !/' \
-e 's/rn_u10.*=.*\!/rn_u10      =       0.  !/' \
-e 's/rn_uzonal.*=.*\!/rn_uzonal        =       0.5  !/' \
-e 's/rn_ujetszx.*=.*\!/rn_ujetszx              =       1000.  !/' \
-e 's/rn_ujetszy.*=.*\!/rn_ujetszy              =       2000.  !/' \
-e 's/nn_botcase.*=.*\!/nn_botcase      =       0  !/' \
-e 's/nn_initcase.*=.*\!/nn_initcase    =     1       !/' \
-e 's/ln_sshnoise.*=.*\!/ln_sshnoise    =       .false.   !/' \
-e 's/ln_Iperio.*=.*\!/ln_Iperio        =       .true.   !/' \
-e 's/ln_Jperio.*=.*\!/ln_Jperio        =       .false.   !/' \
-e "s/cn_exp.*=.*'.*'/cn_exp    =       'CANAL'/" \
-e 's/nn_it000.*=.*\!/nn_it000  =       0   !/' \
-e 's/nn_itend.*=.*\!/nn_itend  =       7680   !/' \
-e 's/nn_istate.*=.*\!/nn_istate      =       0   !/' \
-e 's/rn_Dt.*=.*\!/rn_Dt        =       900.   !/' \
-e 's/rn_atfp.*=.*\!/rn_atfp    =       0.   !/' \
"$SRC"

diff "$SRC" "$SRC.bak"


DIR_PARENT="${DIR%/EXP*}"
SRC="$DIR_PARENT/MY_SRC/usrdef_istate.F90"
TMP="$DIR_PARENT/MY_SRC/usrdef_istate.F90.tmp"

if [ ! -f "$SRC" ]; then
    echo "Erreur : fichier introuvable : $SRC"
    exit 1
fi


# Checking if the file has already been modified
grep -q "pssh(:,:) = - zf0 * rn_uzonal *( gphit(:,:)-glamt(:,:)) * 1.e3_wp / grav " "$SRC" && SKIP_SSH=1 || SKIP_SSH=0
grep -q "pssh(:,:) = - zf0 * rn_uzonal *( gphit(:,:)-glamt(:,:)) * 1.e3_wp / grav " "$SRC" && SKIP_PV=1 || SKIP_PV=0


awk -v skip_ssh="$SKIP_SSH" -v skip_pv="$SKIP_PV" '
/SUBROUTINE usr_def_istate/ { in_sub1=1 }
in_sub1 && /END SUBROUTINE usr_def_istate/ { in_sub1=0 }

in_sub1 && /SELECT CASE *\( *nn_initcase *\)/ { in_select1=1 }
in_select1 && /END SELECT/ { in_select1=0 }

in_sub1 && in_select1 && /CASE *\( *1 *\)/ { in_case1_a=1 }
in_case1_a && /CASE *\(/ && !/CASE *\( *1 *\)/ { in_case1_a=0 }
in_case1_a && /END SELECT/ { in_case1_a=0 }

{
    # 1. Removing current along the y-axis
    if (in_sub1 && in_case1_a && !done_pv && $0 ~ /DO jk=1, jpkm/) {
        l1=$0; getline l2; getline l3;
        if (l2 ~ /WHERE\(.*ABS\(glamt\).*<=.*zjetx.*\).*pv\(:,:,jk\).*=.*rn_uzonal/ && l3 ~ /END DO/) {
           done_pv=1; next;
        }
        print l1; print l2; print l3; next;
	}

}

/SUBROUTINE usr_def_istate_ssh/ { in_sub2=1 }
in_sub2 && /END SUBROUTINE usr_def_istate_ssh/ { in_sub2=0 }

in_sub2 && /SELECT CASE *\( *nn_initcase *\)/ { in_select2=1 }
in_select2 && /END SELECT/ { in_select2=0 }

in_sub2 && in_select2 && /CASE *\( *1 *\)/ { in_case1_b=1 }
in_case1_b && /CASE *\(/ && !/CASE *\( *1 *\)/ { in_case1_b=0 }
in_case1_b && /END SELECT/ { in_case1_b=0 }

in_sub2 && in_select2 && in_case1_b && /SELECT CASE *\( *nn_fcase *\)/ { in_fcase=1 }
in_fcase && /END SELECT/ { in_fcase=0 }

in_sub2 && in_select2 && in_case1_b && in_fcase &&  /CASE *\( *0 *\)/ { in_case0=1 }
in_case0 && /CASE *\(/ && !/CASE *\( *0 *\)/ { in_case0=0 }
in_case0 && /END SELECT/ { in_case0=0 }

{
    # 2. Removing y-coordinate to the ssh expression
    if (in_sub2 && !skip_ssh && !done_ssh && /pssh\(:,:\).*grav/) {
        sub(/pssh\(:,:\).*grav/, "pssh(:,:) = - zf0 * rn_uzonal *gphit(:,:)* 1e3_wp /grav ")
        print
        done_ssh=1
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
cd "$DIR_NEMO"|| { echo "Erreur : impossible d'aller dans $DIR_NEMO"; exit 1; }
echo "Compilation lanc??e depuis : $(pwd)"

FILE="${DIR#*tests/}"
TEST="${FILE%%/*}"


echo "Name of the executive : $TEST"


./makenemo -r CANAL -n "$TEST"


cd "$DIR"|| { echo "Erreur : impossible de revenir dans $DIR"; exit 1; }
echo "De retour dans : $(pwd)"


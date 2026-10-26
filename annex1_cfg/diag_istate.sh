#!/bin/bash

set -u
set -x


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
grep -q "pv\(:,:,jk\).*=.*rn_uzonal" "$SRC" && SKIP_PV=1 || SKIP_PV=0
grep -q "pssh\(:,:\).*=.*gphit\(:,:\)-glamt\(:,:\)" "$SRC" && SKIP_SSH=1 || SKIP_SSH=0



awk -v skip_pv="$SKIP_PV" -v skip_ssh="$SKIP_SSH" '
/SUBROUTINE usr_def_istate/ { in_sub=1 }
in_sub && /END SUBROUTINE usr_def_istate/ { in_sub=0 }

in_sub && /SELECT CASE *\( *nn_initcase *\)/ { in_select=1 }
in_select && /END SELECT/ { in_select=0 }

in_sub && in_select && /CASE *\( *1 *\)/ { in_case1=1 }
in_case1 && /CASE *\(/ && !/CASE *\( *1 *\)/ { in_case1=0 }
in_case1 && /END SELECT/ { in_case1=0 }

{
    # 1. Adding current in both directions
    if (in_sub && in_case1 && !skip_pv && !done_pv && /pv\(:,:,:\).*=.*0._wp/) {
        print
	print "        DO jk=1, jpkm1"
	print "           WHERE( ABS(glamt) <= zjetx ) pv(:,:,jk) = rn_uzonal"
	print "        END DO"
	done_pv=1
        next
    }

}

/SUBROUTINE usr_def_istate_ssh/ { in_sub=1 }
in_sub && /END SUBROUTINE usr_def_istate_ssh/ { in_sub=0 }

in_sub && /SELECT CASE *\( *nn_initcase *\)/ { in_select=1 }
in_select && /END SELECT/ { in_select=0 }

in_sub && in_select && /CASE *\( *1 *\)/ { in_case1=1 }
in_case1 && /CASE *\(/ && !/CASE *\( *1 *\)/ { in_case1=0 }
in_case1 && /END SELECT/ { in_case1=0 }

in_sub && in_select && in_case1 && /SELECT CASE *\( *nn_fcase *\)/ { in_fcase=1 }
in_fcase && /END SELECT/ { in_fcase=0 }

in_sub && in_select && in_case1 && in_fcase &&  /CASE *\( *0 *\)/ { in_case0=1 }
in_case0 && /CASE *\(/ && !/CASE *\( *0 *\)/ { in_case0=0 }
in_case0 && /END SELECT/ { in_case0=0 }


{
    # 2. Adding y-coordinate to the ssh expression
    if (!skip_ssh && !done_ssh && /pssh\(:,:\).*grav/) {
	sub(/pssh\(:,:\).*grav/, "pssh(:,:) = - zf0 * rn_uzonal *( gphit(:,:)-glamt(:,:)) * 1.e3_wp / grav ")
	print
	done_ssh=1
        next
    }

    print
}' \
"$SRC"  > "$TMP"

diff "$SRC" "$TMP"


cp "$SRC" "$SRC.bak"; mv "$TMP" "$SRC" && echo usrdef_istate.F90 modified

DIR_NEMO="${DIR%/tests*}"
cd "$DIR_NEMO"

./makenemo -r CANAL -n EXP42

cd "$DIR"



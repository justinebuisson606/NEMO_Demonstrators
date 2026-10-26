#!/bin/bash

set -x #Turn on debug
set -v #Turn on Print shell input lines
set -u #Turn on error if usinf unset variables


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


SED_EXPR=(
-e 's/rn_domszx.*=.*\!/rn_domszx	=	864.	!/'
-e 's/rn_domszy.*=.*\!/rn_domszy	=	1000.	!/'
-e 's/rn_domszz.*=.*\!/rn_domszz	=	1000.  !/'
-e 's/rn_dx.*=.*\!/rn_dx	=	10.	!/'
-e 's/rn_dy.*=.*\!/rn_dy	=	10.  !/'
-e 's/rn_dz.*=.*\!/rn_dz	=	1000.  !/'
-e 's/rn_0xratio.*=.*\!/rn_0xratio	=	0.5  !/'
-e 's/rn_0yratio.*=.*\!/rn_0yratio	=	0.5  !/'
-e 's/nn_fcase.*=.*\!/nn_fcase	=	0  !/'
-e 's/rn_ppgphi0.*=.*\!/rn_ppgphi0	=	38.5  !/'
-e 's/rn_u10.*=.*\!/rn_u10	=	0.  !/'
-e 's/rn_uzonal.*=.*\!/rn_uzonal	=	0.5  !/'
-e 's/rn_ujetszx.*=.*\!/rn_ujetszx		=	864.  !/'
-e 's/rn_ujetszy.*=.*\!/rn_ujetszy		=	1000.  !/'
-e 's/nn_botcase.*=.*\!/nn_botcase	=	0  !/'
-e 's/nn_initcase.*=.*\!/nn_initcase	=     1       !/'
-e 's/ln_sshnoise.*=.*\!/ln_sshnoise	=	.false.   !/'
-e 's/ln_Iperio.*=.*\!/ln_Iperio	=	.true.   !/'
-e 's/ln_Jperio.*=.*\!/ln_Jperio	=	.false.   !/'
-e "s/cn_exp.*=.*'.*'/cn_exp	=	'CANAL_saltblock'/"
-e 's/nn_it000.*=.*\!/nn_it000	=	0   !/'
-e 's/nn_itend.*=.*\!/nn_itend	=	7680   !/'
-e 's/nn_istate.*=.*\!/nn_istate      =       0   !/'
-e 's/rn_Dt.*=.*\!/rn_Dt	= 	900.   !/'
-e 's/rn_atfp.*=.*\!/rn_atfp    =       0.   !/'
-e 's/ln_seos.*=.*\!/ln_seos    =       .true.   !/'
-e 's/rn_a0.*=.*\!/rn_a0    =       0.28   !/'
-e 's/rn_b0.*=.*\!/rn_b0    =       0.   !/'


)

# On ajoute l'insertion seulement si elle n'est pas déjà présente
if ! grep -q "rn_salszx" "$SRC"; then
    SED_EXPR+=(-e '/rn_ujetszy/a\
   rn_salszx = 500.        ! width of the saltblock [km]\
   rn_salszy = 500.        ! height of the salt block [km]')
else
    echo "rn_salszx, rn_salszy already in the file, insertion ignored."
fi

sed -i.bak "${SED_EXPR[@]}" "$SRC"



diff "$SRC.bak" "$SRC"

#./run_nemo.sh


set +x #Turn off debug
set +v #Turn off Print shell input lines
set +u #Turn off error if usinf unset variables



















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


sed -i.bak \
-e 's/rn_domszx.*=.*\!/rn_domszx      =      	2000.    !/' \
-e 's/rn_domszy.*=.*\!/rn_domszy      =       1000.   !/' \
-e 's/rn_domszz.*=.*\!/rn_domszz      =       1000.  !/' \
-e 's/rn_dx.*=.*\!/rn_dx      =       10.     !/' \
-e 's/rn_dy.*=.*\!/rn_dy      =       10.  !/' \
-e 's/rn_dz.*=.*\!/rn_dz      =       1000.  !/' \
-e 's/rn_0xratio.*=.*\!/rn_0xratio    =       0.5  !/' \
-e 's/rn_0yratio.*=.*\!/rn_0yratio    =       0.5  !/' \
-e 's/nn_fcase.*=.*\!/nn_fcase        =       0  !/' \
-e 's/rn_ppgphi0.*=.*\!/rn_ppgphi0    =       38.5  !/' \
-e 's/rn_u10.*=.*\!/rn_u10    =       0.  !/' \
-e 's/rn_uzonal.*=.*\!/rn_uzonal      =       0.5  !/' \
-e 's/rn_ujetszx.*=.*\!/rn_ujetszx            =       2000.  !/' \
-e 's/rn_ujetszy.*=.*\!/rn_ujetszy            =       1000.  !/' \
-e 's/nn_botcase.*=.*\!/nn_botcase    =       0  !/' \
-e 's/nn_initcase.*=.*\!/nn_initcase    =     2       !/' \
-e 's/ln_sshnoise.*=.*\!/ln_sshnoise  =       .true.   !/' \
-e 's/ln_Iperio.*=.*\!/ln_Iperio      =       .true.   !/' \
-e 's/ln_Jperio.*=.*\!/ln_Jperio      =       .false.   !/' \
-e "s/cn_exp.*=.*'.*'/cn_exp    =       'CANAL_shear'/" \
-e 's/nn_it000.*=.*\!/nn_it000        =       0   !/' \
-e 's/nn_itend.*=.*\!/nn_itend        =       1920   !/' \
-e 's/nn_istate.*=.*\!/nn_istate      =       0   !/' \
-e 's/rn_Dt.*=.*\!/rn_Dt      =       900.   !/' \
-e 's/rn_atfp.*=.*\!/rn_atfp    =       0.   !/' \
-e 's/ln_dynadv_OFF.*=.*\!/ln_dynadv_OFF = .false. !/' \
-e 's/ln_dynadv_cen2.*=.*\!/ln_dynadv_cen2 = .false. !/' \
-e 's/ln_dynadv_up3.*=.*\!/ln_dynadv_up3  = .true.  !/' \
"$SRC"


diff "$SRC.bak" "$SRC"

#!/bin/bash

set -u

if [ $# -lt 2 ]; then
    echo "Usage; $0 /path/to/thr/directory & w list "
    exit 1
fi

DIR="$1"
W_LIST="$2"

FILE_DEF="$DIR/file_def_nemo-oce.xml"

sed -i 's/output_freq=".*"/output_freq="2h"/' "$FILE_DEF"

echo output_freq changed to 2 hours 

SRC="$DIR/namelist_cfg"

if [ ! -f "$SRC" ]; then
    echo "Error : cannot find file : $SRC"
    exit 1
fi 



for w  in $W_LIST; do 
    echo "Running simulation for rn_w = $w" 
    SED_EXPR=(
    # Running the UBS simulation
    -e "s/rn_w.*=.*\!.*frequency/rn_w	 =    ${w}.	! frequency/" \
    -e "s/cn_exp.*=.*'.*'/cn_exp	=	'CANAL_sin_ubs${w}'/" \
    -e 's/ln_traadv_ubs.*=.*\!/ln_traadv_ubs	=	.true.  !/' \
    -e 's/ln_traadv_OFF.*=.*\!/ln_traadv_OFF	=	.false.	!/' \
    -e 's/ln_traadv_fct.*=.*\!/ln_traadv_fct	=	.false.	!/' \
    -e 's/ln_traadv_cen.*=.*\!/ln_traadv_cen	=	.false.	!/' \
    -e 's/ln_traadv_mus.*=.*\!/ln_traadv_mus	=	.false.	!/' \
    -e 's/ln_traadv_qck.*=.*\!/ln_traadv_qck	=	.false.	!/' \
    
    )

    sed -i.bak "${SED_EXPR[@]}" "$SRC" 

    diff "$SRC.bak" "$SRC"

    ./run_nemo.sh || echo "run_nemo (UBS) failed for w=$w"

    # Running the CEN2 simulation 
SED_EXPR=(
    -e "s/cn_exp.*=.*'.*'/cn_exp	=	'CANAL_sin_cen2${w}'/" \
    -e 's/ln_traadv_cen.*=.*\!/ln_traadv_cen	=	.true.	!/' \
    -e 's/ln_traadv_ubs.*=.*\!/ln_traadv_ubs	=	.false.	!/' \
    -e 's/nn_cen_h.*=.*\!/nn_cen_h	=	2	!/' \
    -e 's/nn_cen_v.*=.*\!/nn_cen_v	=	2	!/' \

)


    sed -i.bak "${SED_EXPR[@]}" "$SRC"

    diff "$SRC.bak" "$SRC"    

    ./run_nemo.sh || echo "run_nemo (CEN2) failed for w=$w"

    # Running the CEN4 simulation
    SED_EXPR=(
    -e "s/cn_exp.*=.*'.*'/cn_exp	=	'CANAL_sin_cen4${w}'/" \
    -e 's/nn_cen_h.*=.*\!/nn_cen_h	=	4	!/' \
    -e 's/nn_cen_v.*=.*\!/nn_cen_v	=	4	!/' \

)


    sed -i.bak "${SED_EXPR[@]}" "$SRC"

    diff "$SRC.bak" "$SRC"

    ./run_nemo.sh || echo "run_nemo (CEN4) failed for w=$w"
    # Running the FCT2 simulation
    SED_EXPR=(
    -e "s/cn_exp.*=.*'.*'/cn_exp	=	'CANAL_sin_fct2${w}'/" \
    -e 's/ln_traadv_cen.*=.*\!/ln_traadv_cen	=	.false.	!/' \
    -e 's/ln_traadv_fct.*=.*\!/ln_traadv_fct	=	.true.	!/' \
    -e 's/nn_fct_h.*=.*\!/nn_fct_h	=	2	!/' \
    -e 's/nn_fct_v.*=.*\!/nn_fct_v	=	2	!/' \

    )


    sed -i.bak "${SED_EXPR[@]}" "$SRC"

    diff "$SRC.bak" "$SRC"

    ./run_nemo.sh || echo "run_nemo (FCT2) failed for w=$w"
    # Running the FCT4 simulation
    SED_EXPR=(
    -e "s/cn_exp.*=.*'.*'/cn_exp	=	'CANAL_sin_fct4${w}'/" \
    -e 's/nn_fct_h.*=.*\!/nn_fct_h	=	4	!/' \
    -e 's/nn_fct_v.*=.*\!/nn_fct_v	=	4	!/' \

    )

    sed -i.bak "${SED_EXPR[@]}" "$SRC"

    diff "$SRC.bak" "$SRC"

    ./run_nemo.sh || echo "run_nemo (FCT4) failed for w=$w"
    # Running the no advection scheme
    SED_EXPR=(
    -e "s/cn_exp.*=.*'.*'/cn_exp	=	'CANAL_sin_traadvOFF${w}'/" \
    -e 's/ln_traadv_fct.*=.*\!/ln_traadv_fct	=	.false.	!/' \
    -e 's/ln_traadv_OFF.*=.*\!/ln_traadv_OFF	=	.true.	!/' \

    )

    sed -i.bak "${SED_EXPR[@]}" "$SRC"

    diff "$SRC.bak" "$SRC"

    ./run_nemo.sh || echo " run_nemo (traadvOFF) failed for w=$w"

    echo "Runs completed for rn_w = $w"
   	
done



sed -i 's/output_freq=".*"/output_freq="1d"/' "$FILE_DEF"

echo output_freq changed back to 1 day

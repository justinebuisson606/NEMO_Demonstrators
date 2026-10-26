#!/bin/bash

set -u

if [ $# -lt 2 ]; then
    echo "Usage; $0 /path/to/thr/directory & lambda list "
    exit 1
fi

DIR="$1"
LAMBDA_LIST="$2"
SRC="$DIR/namelist_cfg"

if [ ! -f "$SRC" ]; then
    echo "Error : cannot find file : $SRC"
    exit 1
fi 



for lambda  in $LAMBDA_LIST; do 
    echo "Running simulation for rn_lambda = $lambda" 
    SED_EXPR=(
    # Running the UBS simulation
    -e "s/rn_lambda.*=.*\!.*gaussian.*lambda/rn_lambda   =    ${lambda}.   !  gaussian lambda/" \
    -e "s/cn_exp.*=.*'.*'/cn_exp	=	'CANAL_gauss_ubs.${lambda}'/" \
    -e 's/ln_traadv_ubs.*=.*\!/ln_traadv_ubs	=	.true.  !/' \
    -e 's/ln_traadv_OFF.*=.*\!/ln_traadv_OFF	=	.false.	!/' \
    -e 's/ln_traadv_fct.*=.*\!/ln_traadv_fct	=	.false.	!/' \
    -e 's/ln_traadv_cen.*=.*\!/ln_traadv_cen	=	.false.	!/' \
    -e 's/ln_traadv_mus.*=.*\!/ln_traadv_mus	=	.false.	!/' \
    -e 's/ln_traadv_qck.*=.*\!/ln_traadv_qck	=	.false.	!/' \
    
    )

    sed -i.bak "${SED_EXPR[@]}" "$SRC" 

    diff "$SRC.bak" "$SRC"

    ./run_nemo.sh || { echo "run_nemo (UBS) failed for lambda=$lambda"; continue; }
    
    # Running the FCT2 simulation
    SED_EXPR=(
    -e "s/cn_exp.*=.*'.*'/cn_exp	=	'CANAL_gauss_fct2.${lambda}'/" \
    -e 's/ln_traadv_ubs.*=.*\!/ln_traadv_ubs	=	.false.	!/' \
    -e 's/ln_traadv_fct.*=.*\!/ln_traadv_fct	=	.true.	!/' \
    -e 's/nn_fct_h.*=.*\!/nn_fct_h	=	2	!/' \
    -e 's/nn_fct_v.*=.*\!/nn_fct_v	=	2	!/' \

    )


    sed -i.bak "${SED_EXPR[@]}" "$SRC"

    diff "$SRC.bak" "$SRC"

    ./run_nemo.sh || { echo "run_nemo (FCT2) failed for lambda=$lambda"; continue; }

    # Running the FCT4 simulation
    SED_EXPR=(
    -e "s/cn_exp.*=.*'.*'/cn_exp	=	'CANAL_gauss_fct4.${lambda}'/" \
    -e 's/nn_fct_h.*=.*\!/nn_fct_h	=	4	!/' \
    -e 's/nn_fct_v.*=.*\!/nn_fct_v	=	4	!/' \

    )

    sed -i.bak "${SED_EXPR[@]}" "$SRC"

    diff "$SRC.bak" "$SRC"

    ./run_nemo.sh || { echo "run_nemo (FCT4) failed for lambda=$lambda"; continue; }

    # Running the no advection scheme
    SED_EXPR=(
    -e "s/cn_exp.*=.*'.*'/cn_exp	=	'CANAL_gauss_traadvOFF.${lambda}'/" \
    -e 's/ln_traadv_fct.*=.*\!/ln_traadv_fct	=	.false.	!/' \
    -e 's/ln_traadv_OFF.*=.*\!/ln_traadv_OFF	=	.true.	!/' \

    )

    sed -i.bak "${SED_EXPR[@]}" '$SRC"

    diff "$SRC.bak" "$SRC"

    ./run_nemo.sh || { echo " run_nemo (traadvOFF) failed for lambda=$lambda"; continue; }

    echo "Runs completed for rn_lambda = $lambda"
   	
done

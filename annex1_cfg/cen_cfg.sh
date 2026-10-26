set -x # Turn on debug
set -u #Turn on error if using unset variables

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
-e 's/ln_traadv_cen.*=.*\!/ln_traadv_cen	=	.true.	!/' \
-e 's/ln_traadv_OFF.*=.*\!/ln_traadv_OFF	=	.false.	!/' \
-e 's/ln_traadv_fct.*=.*\!/ln_traadv_fct	=	.false.	!/' \
-e 's/ln_traadv_mus.*=.*\!/ln_traadv_mus	=	.false.	!/' \
-e 's/ln_traadv_ubs.*=.*\!/ln_traadv_ubs	=	.false.	!/' \
-e 's/ln_traadv_qck.*=.*\!/ln_traadv_qck	=	.false.	!/' \
-e 's/nn_cen_h.*=.*\!/nn_cen_h	=	2		!/' \
-e 's/nn_cen_v.*=.*\!/nn_cen_v  =       2		!/' \
-e "s/cn_exp.*=.*'.*'/cn_exp =	'CANAL_saltblock_diag_cen2'	/" \
-e 's/ln_traldf_OFF.*=.*\!/ln_traldf_OFF        =       .true. !/' \
-e 's/ln_traldf_lap.*=.*\!/ln_traldf_lap        =       .false. !/' \
-e 's/ln_traldf_blp.*=.*\!/ln_traldf_blp        =       .false. !/' \

)

sed -i.bak "${SED_EXPR[@]}" "$SRC"

diff "$SRC" "$SRC.bak"

./run_nemo.sh && echo Run CANAL_saltblock_diag_cen2_all_grid.nc completed

SED_EXPR=(
-e 's/nn_cen_h.*=.*\!/nn_cen_h	=	4	!/' \
-e 's/nn_cen_v.*=.*\!/nn_cen_v	=	4	!/' \
-e "s/cn_exp.*=.*'.*'/cn_exp =	'CANAL_saltblock_diag_cen4'	/" \

)

sed -i.bak "${SED_EXPR[@]}" "$SRC"

diff "$SRC" "$SRC.bak"


./run_nemo.sh && echo Run CANAL_saltblock_diag_cen4_all_grid.nc completed

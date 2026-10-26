set -u #Turn on error if using unset variables

if [ $# -lt 1 ]; then
    echo "Usage: $0 /path/to/the/directory"
    exit 1
fi

DIR="$1"
SRC="$DIR/namelist_cfg"

if [ ! -f "$SRC" ]; then
    echo "Error : cannot find file : $SRC"
    exit 1
fi


sed -i.bak \
-e 's/ln_traadv_ubs.*=.*\!/ln_traadv_ubs        =       .true.  !/' \
-e 's/ln_traadv_OFF.*=.*\!/ln_traadv_OFF        =       .false. !/' \
-e 's/ln_traadv_fct.*=.*\!/ln_traadv_fct        =       .false. !/' \
-e 's/ln_traadv_mus.*=.*\!/ln_traadv_mus        =       .false. !/' \
-e 's/ln_traadv_cen.*=.*\!/ln_traadv_cen        =       .false. !/' \
-e 's/ln_traadv_qck.*=.*\!/ln_traadv_qck        =       .false. !/' \
-e 's/nn_ubs_v.*=.*\!/nn_ubs_v  =       2               !/' \
-e "s/cn_exp.*=.*'.*'/cn_exp =  'CANAL_saltblock_ubs'      /" \
-e 's/ln_traldf_OFF.*=.*\!/ln_traldf_OFF        =       .true. !/' \
-e 's/ln_traldf_lap.*=.*\!/ln_traldf_lap        =       .false. !/' \
-e 's/ln_traldf_blp.*=.*\!/ln_traldf_blp        =       .false. !/' \
"$SRC"

diff "$SRC" "$SRC.bak"

sh /"$DIR"/run_nemo.sh && echo Run CANAL_saltblock_ubs_all_grid.nc completed







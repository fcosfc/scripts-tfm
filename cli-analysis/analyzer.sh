#!/bin/bash
#
# --------------------------------------------------------------------------------------------
# analyzer.sh: script que extrae métricas de ficheros CSV resultado de ejecución de weka,
#              las analiza utilizando el Wilcoxon Signed-Rank Test y crea un tabla comparativa
#              para la memoria del TFM.
#
# author: Paco Saucedo.
# --------------------------------------------------------------------------------------------

# -----------------------
# Definición de variables
# -----------------------

USE="USE: analyzer.sh FOLDER example ~/Desarrollo/MasterIIUPO/TFM/ResultadosComparativas/ComparativaDatasetsWeka/CSV"

ARRAY_RF_ACCURACY=""
ARRAY_RFMSU_ACCURACY="" 
ARRAY_RF_FEATS="" 
ARRAY_RFMSU_FEATS="" 
ARRAY_RF_LEAVES="" 
ARRAY_RFMSU_LEAVES=""
IS_FIRST=1

# -------------------------------
# Análisis de la línea de comando
# -------------------------------

if [ $# != 2 ];
then
    echo -e $USE
    exit
fi

if [[ !(-d $1) ]];
then
    printf "Folder %s not found\n" $1
    exit
fi

# ------------------------------------------------
# Proceso de los ficheros de la carpeta de entrada
# ------------------------------------------------
printf ";acc;;#Feats;;#Leaves;\n" > $2
printf "Id.;RFMSU;RF;RFMSU;RF;RFMSU;RF\n" >> $2

CSV_FILES=($(ls $1))

for CSV_FILE in ${CSV_FILES[@]}
do
    read RF_ACCURACY RFMSU_ACCURACY RF_FEATS RFMSU_FEATS RF_LEAVES RFMSU_LEAVES < \
        <(awk -f data_extractor.awk $1/$CSV_FILE)

    RF_ACCURACY=$(echo $RF_ACCURACY | sed "s/\,/./")
    RFMSU_ACCURACY=$(echo $RFMSU_ACCURACY | sed "s/\,/./")
    RF_FEATS=$(echo $RF_FEATS | sed "s/\,/./")
    RFMSU_FEATS=$(echo $RFMSU_FEATS | sed "s/\,/./")
    RF_LEAVES=$(echo $RF_LEAVES | sed "s/\,/./")
    RFMSU_LEAVES=$(echo $RFMSU_LEAVES | sed "s/\,/./")

    printf "$CSV_FILE;$RFMSU_ACCURACY;$RF_ACCURACY;$RFMSU_FEATS;$RF_FEATS;$RFMSU_LEAVES;$RF_LEAVES\n" >> $2

    if [[ $IS_FIRST -eq 1 ]];
    then
        ARRAY_RF_ACCURACY=$(echo $ARRAY_RF_ACCURACY $RF_ACCURACY)
        ARRAY_RFMSU_ACCURACY=$(echo $ARRAY_RFMSU_ACCURACY $RFMSU_ACCURACY)
        ARRAY_RF_FEATS=$(echo $ARRAY_RF_FEATS $RF_FEATS)
        ARRAY_RFMSU_FEATS=$(echo $ARRAY_RFMSU_FEATS $RFMSU_FEATS)
        ARRAY_RF_LEAVES=$(echo $ARRAY_RF_LEAVES $RF_LEAVES)
        ARRAY_RFMSU_LEAVES=$(echo $ARRAY_RFMSU_LEAVES $RFMSU_LEAVES)
        IS_FIRST=0
    else
        ARRAY_RF_ACCURACY=$(echo $ARRAY_RF_ACCURACY "," $RF_ACCURACY)
        ARRAY_RFMSU_ACCURACY=$(echo $ARRAY_RFMSU_ACCURACY "," $RFMSU_ACCURACY)
        ARRAY_RF_FEATS=$(echo $ARRAY_RF_FEATS "," $RF_FEATS)
        ARRAY_RFMSU_FEATS=$(echo $ARRAY_RFMSU_FEATS "," $RFMSU_FEATS)
        ARRAY_RF_LEAVES=$(echo $ARRAY_RF_LEAVES "," $RF_LEAVES)
        ARRAY_RFMSU_LEAVES=$(echo $ARRAY_RFMSU_LEAVES "," $RFMSU_LEAVES)
    fi
done

# -------------------------------------
# Proceso del Wilcoxon signed rank test
# -------------------------------------

read WX_ACCURACY < \
    <(Rscript wilcoxon_signed_rank_test.R "$ARRAY_RF_ACCURACY" "$ARRAY_RFMSU_ACCURACY")

read WX_FEATS < \
    <(Rscript wilcoxon_signed_rank_test.R "$ARRAY_RF_FEATS" "$ARRAY_RFMSU_FEATS")

read WX_LEAVES < \
    <(Rscript wilcoxon_signed_rank_test.R "$ARRAY_RF_LEAVES" "$ARRAY_RFMSU_LEAVES")

printf "p-val;;$WX_ACCURACY;;$WX_FEATS;;$WX_LEAVES\n" >> $2
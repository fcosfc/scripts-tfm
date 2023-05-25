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

USE="USE: analyzer.sh FOLDER example ~/Desarrollo/MasterIIUPO/TFM/ResultadosComparativas/ComparativaDatasetsWeka/CSV RESULTS example /var/tmp/results.csv"

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

printf "Processing folder $1 ...\n"

# ------------------------------------------------
# Proceso de los ficheros de la carpeta de entrada
# ------------------------------------------------

printf ";acc;;#Feats;;#Leaves;\n" > $2
printf "Id.;RFMSU;RF;RFMSU;RF;RFMSU;RF\n" >> $2

CSV_FILES=($(ls $1))

for CSV_FILE in ${CSV_FILES[@]}
do
    printf "Processing file $CSV_FILE ...\n"

    # Extrae métricas desde el fichero CSV resultado de un procesamiento previo con Weka
    read RF_ACCURACY RFMSU_ACCURACY RF_FEATS RFMSU_FEATS RF_LEAVES RFMSU_LEAVES < \
        <(awk -f data_extractor.awk $1/$CSV_FILE)

    # Conversión de formato decimal y creación de arrays de datos para medias y tests
    RF_ACCURACY=$(echo $RF_ACCURACY | sed "s/\,/./")
    RFMSU_ACCURACY=$(echo $RFMSU_ACCURACY | sed "s/\,/./")

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

    # Conversión de vuelta para España y escritura de CSV, extrayendo el dataset origen del nombre del fichero
    RF_ACCURACY=$(echo $RF_ACCURACY | sed "s/\./,/")
    RFMSU_ACCURACY=$(echo $RFMSU_ACCURACY | sed "s/\./,/")

    DATASET=$(echo $CSV_FILE | sed "s/\.[0-9]*_[0-9]*.csv//g")

    printf "$DATASET;$RFMSU_ACCURACY;$RF_ACCURACY;$RFMSU_FEATS;$RF_FEATS;$RFMSU_LEAVES;$RF_LEAVES\n" >> $2
done

# -----------------------------
# Proceso de medias aritméticas
# -----------------------------

read MEAN_RF_ACCURACY < \
    <(Rscript mean.R "$ARRAY_RF_ACCURACY")

read MEAN_RFMSU_ACCURACY < \
    <(Rscript mean.R "$ARRAY_RFMSU_ACCURACY")

read MEAN_RF_FEATS < \
    <(Rscript mean.R "$ARRAY_RF_FEATS")

read MEAN_RFMSU_FEATS < \
    <(Rscript mean.R "$ARRAY_RFMSU_FEATS")

read MEAN_RF_LEAVES < \
    <(Rscript mean.R "$ARRAY_RF_LEAVES")

read MEAN_RFMSU_LEAVES < \
    <(Rscript mean.R "$ARRAY_RFMSU_LEAVES")

MEAN_RF_ACCURACY=$(echo $MEAN_RF_ACCURACY | sed "s/\./,/")
MEAN_RFMSU_ACCURACY=$(echo $MEAN_RFMSU_ACCURACY | sed "s/\./,/")
MEAN_RF_FEATS=$(echo $MEAN_RF_FEATS | sed "s/\./,/")
MEAN_RFMSU_FEATS=$(echo $MEAN_RFMSU_FEATS | sed "s/\./,/")
MEAN_RF_LEAVES=$(echo $MEAN_RF_LEAVES | sed "s/\./,/")
MEAN_RFMSU_LEAVES=$(echo $MEAN_RFMSU_LEAVES | sed "s/\./,/")

printf "mean;$MEAN_RFMSU_ACCURACY;$MEAN_RF_ACCURACY;$MEAN_RFMSU_FEATS;$MEAN_RF_FEATS;$MEAN_RFMSU_LEAVES;$MEAN_RF_LEAVES\n" >> $2 

# -------------------------------------
# Proceso del Wilcoxon signed rank test
# -------------------------------------

read WX_ACCURACY < \
    <(Rscript wilcoxon_signed_rank_test.R "$ARRAY_RF_ACCURACY" "$ARRAY_RFMSU_ACCURACY")

read WX_FEATS < \
    <(Rscript wilcoxon_signed_rank_test.R "$ARRAY_RF_FEATS" "$ARRAY_RFMSU_FEATS")

read WX_LEAVES < \
    <(Rscript wilcoxon_signed_rank_test.R "$ARRAY_RF_LEAVES" "$ARRAY_RFMSU_LEAVES")

WX_ACCURACY=$(echo $WX_ACCURACY | sed "s/\./,/")
WX_FEATS=$(echo $WX_FEATS | sed "s/\./,/")
WX_LEAVES=$(echo $WX_LEAVES | sed "s/\./,/")

printf "p-val;;$WX_ACCURACY;;$WX_FEATS;;$WX_LEAVES\n" >> $2

printf "Results saved on $2\n"
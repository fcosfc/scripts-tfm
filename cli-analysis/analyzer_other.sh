#!/bin/bash
#
# ---------------------------------------------------------------------------------------------------
# analyzer_other.sh: script que extrae métricas, de algoritmos distintos de Random Forests estándar, 
#                    de los ficheros CSV resultado de ejecución de weka,
#                    las analiza utilizando el Wilcoxon Signed-Rank Test y crea un tabla comparativa
#                    para la memoria del TFM.
#
# author: Paco Saucedo.
# ---------------------------------------------------------------------------------------------------

# -----------------------
# Definición de variables
# -----------------------

USE="USE: analyzer_other.sh FOLDER example ~/Desarrollo/MasterIIUPO/TFM/ResultadosComparativas/ComparativaDatasetsWeka/CSV RESULTS example /var/tmp/results.csv"

ARRAY_RFMSU_ACCURACY="" 
ARRAY_J48_ACCURACY="" 
ARRAY_NB_ACCURACY="" 
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

printf "Id.;RFMSU;J48;RFMSU;Naive Bayes\n" >> $2

CSV_FILES=($(ls $1))

for CSV_FILE in ${CSV_FILES[@]}
do
    printf "Processing file $CSV_FILE ...\n"

    # Extrae métricas desde el fichero CSV resultado de un procesamiento previo con Weka
    read RFMSU_ACCURACY J48_ACCURACY NB_ACCURACY < \
        <(awk -f data_extractor_other.awk $1/$CSV_FILE)

    # Conversión de formato decimal y creación de arrays de datos para medias y tests
    RFMSU_ACCURACY=$(echo $RFMSU_ACCURACY | sed "s/\,/./")
    J48_ACCURACY=$(echo $J48_ACCURACY | sed "s/\,/./")
    NB_ACCURACY=$(echo $NB_ACCURACY | sed "s/\,/./")

    if [[ $IS_FIRST -eq 1 ]];
    then
        ARRAY_RFMSU_ACCURACY=$(echo $ARRAY_RFMSU_ACCURACY $RFMSU_ACCURACY)
        ARRAY_J48_ACCURACY=$(echo $ARRAY_J48_ACCURACY $J48_ACCURACY)
        ARRAY_NB_ACCURACY=$(echo $ARRAY_NB_ACCURACY $NB_ACCURACY)
        IS_FIRST=0
    else
        ARRAY_RFMSU_ACCURACY=$(echo $ARRAY_RFMSU_ACCURACY "," $RFMSU_ACCURACY)
        ARRAY_J48_ACCURACY=$(echo $ARRAY_J48_ACCURACY "," $J48_ACCURACY)
        ARRAY_NB_ACCURACY=$(echo $ARRAY_NB_ACCURACY "," $NB_ACCURACY)
    fi

    # Conversión de vuelta para España y escritura de CSV, extrayendo el dataset origen del nombre del fichero
    RFMSU_ACCURACY=$(echo $RFMSU_ACCURACY | sed "s/\./,/")
    J48_ACCURACY=$(echo $J48_ACCURACY | sed "s/\./,/")
    NB_ACCURACY=$(echo $NB_ACCURACY | sed "s/\./,/")

    DATASET=$(echo $CSV_FILE | sed "s/\.[0-9]*_[0-9]*.csv//g")

    printf "$DATASET;$RFMSU_ACCURACY;$J48_ACCURACY;$RFMSU_ACCURACY;$NB_ACCURACY\n" >> $2
done

# -----------------------------
# Proceso de medias aritméticas
# -----------------------------

read MEAN_RFMSU_ACCURACY < \
    <(Rscript mean.R "$ARRAY_RFMSU_ACCURACY")

read MEAN_J48_ACCURACY < \
    <(Rscript mean.R "$ARRAY_J48_ACCURACY")

read MEAN_NB_ACCURACY < \
    <(Rscript mean.R "$ARRAY_NB_ACCURACY")

MEAN_RFMSU_ACCURACY=$(echo $MEAN_RFMSU_ACCURACY | sed "s/\./,/")
MEAN_J48_ACCURACY=$(echo $MEAN_J48_ACCURACY | sed "s/\./,/")
MEAN_NB_ACCURACY=$(echo $MEAN_NB_ACCURACY | sed "s/\./,/")

printf "mean;$MEAN_RFMSU_ACCURACY;$MEAN_J48_ACCURACY;$MEAN_RFMSU_ACCURACY;$MEAN_NB_ACCURACY\n" >> $2 

# -------------------------------------
# Proceso del Wilcoxon signed rank test
# -------------------------------------

read WX_J48_ACCURACY < \
    <(Rscript wilcoxon_signed_rank_test.R "$ARRAY_J48_ACCURACY" "$ARRAY_RFMSU_ACCURACY")

read WX_NB_ACCURACY < \
    <(Rscript wilcoxon_signed_rank_test.R "$ARRAY_NB_ACCURACY" "$ARRAY_RFMSU_ACCURACY")

WX_J48_ACCURACY=$(echo $WX_J48_ACCURACY | sed "s/\./,/")
WX_NB_ACCURACY=$(echo $WX_NB_ACCURACY | sed "s/\./,/")

printf "p-val;;$WX_J48_ACCURACY;;$WX_NB_ACCURACY\n" >> $2

printf "Results saved on $2\n"
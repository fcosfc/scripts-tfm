# ------------------------------------------------------------------------------------------------------------
# data_extractor_rf.awk: Extrae métricas de Random Forests de los ficheros CSV resultado de ejecución de weka,
#                        para tablas comparativas de la memoria del TFM. 
#
# author: Paco Saucedo.
# ------------------------------------------------------------------------------------------------------------

BEGIN {
    FS = ";"
}

{
    if ($1 == "Correctly classified instances percentaje") {
        RF_ACCURACY = $2
        RFMSU_ACCURACY = $3
    }

    if ($1 == "Distinct attributes average") {
        RF_FEATS = $2
        RFMSU_FEATS = $3
    }

    if ($1 == "Leaves number average") {
        RF_LEAVES = $2
        RFMSU_LEAVES = $3
    }
}

END {
    print RF_ACCURACY, RFMSU_ACCURACY, RF_FEATS, RFMSU_FEATS, RF_LEAVES, RFMSU_LEAVES
}
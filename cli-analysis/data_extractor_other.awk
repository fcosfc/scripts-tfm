# ------------------------------------------------------------------------------------------------------------
# data_extractor_other.awk: Extrae métricas, de algoritmos distintos de Random Forests estándar, 
#                           de los ficheros CSV resultado de ejecución de weka,
#                           para tablas comparativas de la memoria del TFM. 
#
# author: Paco Saucedo.
# ------------------------------------------------------------------------------------------------------------

BEGIN {
    FS = ";"
}

{
    if ($1 == "Correctly classified instances percentaje") {
        RFMSU_ACCURACY = $3
        J48_ACCURACY = $5
        NB_ACCURACY = $7
    }
}

END {
    print RFMSU_ACCURACY, J48_ACCURACY, NB_ACCURACY
}
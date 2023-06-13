
# Random Forests, medición alternativa de la importancia de los atributos

Trabajo Fin de Máster. \
Alumno [Francisco Saucedo](https://www.linkedin.com/in/franciscosaucedo/). \
[Máster Universitario en Ingeniería Informática](https://www.upo.es/postgrado/Master-Oficial-Ingenieria-Informatica/). \
[Universidad Pablo de Olavide](https://www.upo.es).

## Introducción

Scripts auxiliares para análisis de resultados durante la experimentación realizada en el Trabajo Fin de Máster.

## Requisito

[Fork del repositorio Weka creado durante el Trabajo Fin de Máster](https://github.com/fcosfc/weka)

## Uso

### Utilidad para comparativas

Permite comparar versiones estándar de Random Forest y Random Tree con las versiones de estudio creadas en el TFM, que utilizan MSU como medida de selección de atributos en la construcción de árboles de decisión.
La utilidad crea como salida un fichero CSV que contiene las distintas métricas, sus valores para los distintos algoritmos y la comparación de éstos.
Acciones:

* Obtener ayuda
```
cli-weka/msu.sh
```

* Ejemplo comparativa sobre un conjunto ejemplo de la instalación de Weka

```
cli-weka/msu.sh weather.nominal ../weka-stable-3-8/wekadocs/data
```

### Utilidad de análisis de datos de comparativas sobre Random Forests

Permite analizar las métricas que residen en los ficheros CSV generados con la utilidad anterior, con el objetivo de obtener conclusiones sobre si merece la pena la propuesta de uso de MSU realizada en el TFM.

* Obtener ayuda
```
cd cli-analysis

./analyzer_rf.sh 
```

* Ejemplo sobre una carpeta de resultados generados a partir de los ejemplos de la instalación de Weka
```
cd cli-analysis

./analyzer_rf.sh ~/Desarrollo/MasterIIUPO/TFM/ResultadosComparativas/ComparativaDatasetsWeka/CSV /var/tmp/results.CSV
```

### Utilidad de análisis de datos de comparativas Random Forests MSU - J48 - Naive Bayes

Permite analizar las métricas que residen en los ficheros CSV generados con la utilidad anterior, con el objetivo de obtener conclusiones sobre el rendimiento con otros algoritmos.

* Obtener ayuda
```
cd cli-analysis

./analyzer_other.sh 
```

* Ejemplo sobre una carpeta de resultados generados a partir de los ejemplos de la instalación de Weka
```
cd cli-analysis

./analyzer_other.sh ~/Desarrollo/MasterIIUPO/TFM/ResultadosComparativas/ComparativaDatasetsWeka/CSV /var/tmp/results.CSV
```
# Análisis y simulación de la dinámica poblacional de los hipopótamos en Colombia

## Descripción del proyecto

Este proyecto analiza la dinámica poblacional de los hipopótamos (*Hippopotamus amphibius*) introducidos en Colombia, una especie exótica invasora que representa desafíos para la conservación de la biodiversidad y la gestión ambiental.

Mediante herramientas de ciencia de datos en R, se desarrolla una simulación de la evolución poblacional entre 2026 y 2050, con el propósito de comparar los posibles efectos de diferentes estrategias de manejo.

## Objetivo

Simular y comparar la evolución de la población de hipopótamos en Colombia bajo cuatro escenarios hipotéticos de manejo, utilizando parámetros demográficos de supervivencia y reproducción.

## Metodología

Se utiliza un modelo poblacional estructurado por edad y sexo, con una población inicial hipotética de 200 individuos en 2026.

Se consideran cuatro escenarios:

1. **Sin intervención:** crecimiento poblacional sin medidas de control.
2. **Esterilización:** esterilización de hasta 20 hembras fértiles por año.
3. **Eutanasia:**  aplicación de eutanasia de hasta 20 individuos por año.
4. **Manejo combinado:** aplicación simultánea de esterilización y eutanasia.

Las proyecciones se realizan hasta el año 2050, bajo los supuestos establecidos en el informe.

Los resultados son proyecciones hipotéticas y no predicciones exactas de la población futura.

## Estructura del repositorio

- `cod/`: scripts de R para preparación de datos, simulación y visualización.
- `data/`: datos de entrada utilizados en el análisis.
- `info/`: documentación y referencias del proyecto.
- `config/`: parámetros demográficos utilizados por el modelo.
- `res/`: gráficos y animaciones generados mediante los scripts.
- `Individual_Jiménez_HerramientasDatosI_2026.qmd`: informe reproducible en Quarto.
- `Individual_Jiménez_HerramientasDatosI_2026.pdf`: versión PDF del informe.
- `README.md`: descripción del proyecto e instrucciones de ejecución.

Cada carpeta contiene un archivo `README.md` con información sobre su propósito.

## Herramientas utilizadas

- R y RStudio.
- Quarto para la elaboración del informe.
- Paquetes de R para manipulación de datos, visualización y animación.

## Cómo ejecutar el proyecto

1. Descargar o clonar este repositorio.
2. Abrir el proyecto en RStudio.
3. Instalar los paquetes de R necesarios, si aún no están instalados.
4. Abrir el archivo `Individual_Jimenez_HerramientasDatosI_2026.qmd`.
5. Ejecutar sus bloques de código o utilizar la opción **Render** para generar el informe.

Es importante mantener la estructura de carpetas para que las rutas relativas funcionen correctamente.

## Fuentes principales

El análisis utiliza información sobre la distribución y abundancia de los hipopótamos en Colombia, así como parámetros demográficos reportados en investigaciones científicas, particularmente los estudios de Moreno-Arias y colaboradores (2024) y Subalusky y colaboradores (2023).

Las referencias bibliográficas completas se encuentran en el informe.

## Consideraciones

El modelo mantiene constantes los parámetros demográficos y no incorpora explícitamente limitaciones de capacidad de carga, variación espacial ni cambios ambientales futuros. Por ello, los resultados deben interpretarse como una comparación de escenarios bajo supuestos determinados.

# Proyecto: Dinámica poblacional de los hipopótamos en Colombia
# Script: Parámetros del modelo
# Descripción: Organización de parámetros biológicos y supuestos de simulación
library(dplyr)
parametros_generales <- data.frame(
  parametro = c(
    "Año inicial",
    "Año final",
    "Población inicial",
    "Crecimiento anual de referencia"
  ),
  valor = c(2026, 2050, 200, 0.096),
  fuente = c(
    "Diseño del proyecto",
    "Diseño del proyecto",
    "Supuesto de simulación",
    "Subalusky et al. (2023)"
  )
)
parametros_generales
parametros_biologicos <- data.frame(
  etapa =  c(
    "Primer año",
    "De 1 a 2 años",
    "De 3 a 30 años"
  ),
  mortalidad = c(0.12, 0.06, 0.03)) |> 
  mutate(
    supervivencia = 1 - mortalidad
  )
edades <- 1:45
length(edades)

tabla_edades <- data.frame(
  edad = edades
)
tabla_edades <- tabla_edades |> 
  mutate(
    supervivencia_hembras = case_when(
      edad == 1 ~ 0.880,
      edad == 2 ~ 0.940,
      edad >= 3 & edad <= 10 ~ 0.970,
      edad >= 11 & edad <= 30 ~ 0.972,
      edad == 31 ~ 0.967,
      edad == 32 ~ 0.961,
      edad == 33 ~ 0.954,
      edad == 34 ~ 0.946,
      edad == 35 ~ 0.936,
      edad == 36 ~ 0.926,
      edad == 37 ~ 0.913,
      edad == 38 ~ 0.897,
      edad == 39 ~ 0.880,
      edad == 40 ~ 0.859,
      edad == 41 ~ 0.834,
      edad == 42 ~ 0.806,
      edad == 43 ~ 0.772,
      edad == 44 ~ 0.732,
      edad == 45 ~ 0.686,
      .default = NA_real_
    ),
    supervivencia_machos = case_when(
      edad == 1 ~ 0.880,
      edad == 2 ~ 0.940,
      edad >= 3 & edad <= 10 ~ 0.970,
      edad >= 11 & edad <= 30 ~ 0.969,
      edad == 31 ~ 0.963,
      edad == 32 ~ 0.957,
      edad == 33 ~ 0.949,
      edad == 34 ~ 0.940,
      edad == 35 ~ 0.930,
      edad == 36 ~ 0.918,
      edad == 37 ~ 0.904,
      edad == 38 ~ 0.887,
      edad == 39 ~ 0.867,
      edad == 40 ~ 0.844,
      edad == 41 ~ 0.817,
      edad == 42 ~ 0.785,
      edad == 43 ~ 0.748,
      edad == 44 ~ 0.704,
      edad == 45 ~ 0.653,
      .default = NA_real_
    ),
    fecundidad = case_when(
      edad >= 1 & edad <= 2 ~ 0.000,
      edad == 3 ~ 0.009,
      edad == 4 ~ 0.060,
      edad == 5 ~ 0.250,
      edad == 6 ~ 0.440,
      edad == 7 ~ 0.491,
      edad == 8 ~ 0.499,
      edad >= 9 & edad <= 25 ~ 0.500,
      edad == 26 ~ 0.495,
      edad == 27 ~ 0.490,
      edad == 28 ~ 0.485,
      edad == 29 ~ 0.480,
      edad == 30 ~ 0.475,
      edad == 31 ~ 0.470,
      edad == 32 ~ 0.465,
      edad == 33 ~ 0.460,
      edad == 34 ~ 0.455,
      edad == 35 ~ 0.450,
      edad == 36 ~ 0.445,
      edad == 37 ~ 0.440,
      edad == 38 ~ 0.435,
      edad == 39 ~ 0.430,
      edad == 40 ~ 0.425,
      edad == 41 ~ 0.420,
      edad == 42 ~ 0.415,
      edad == 43 ~ 0.410,
      edad == 44 ~ 0.405,
      edad == 45 ~ 0.400,
      .default = NA_real_
    ),
    mortalidad_hembras = 1 - supervivencia_hembras,
    mortalidad_machos = 1 - supervivencia_machos
  )

sum(is.na(tabla_edades$supervivencia_machos))
sum(is.na(tabla_edades$supervivencia_hembras))
sum(is.na(tabla_edades$fecundidad))

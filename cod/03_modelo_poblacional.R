# Proyecto: Dinámica poblacional de los hipopótamos en Colombia
# Script: Modelo poblacional
# Descripción: Cálculo del cambio poblacional de un año a otro mediante nacimientos, supervivencia y envejecimiento
library(dplyr)
library(ggplot2)
library(gganimate)
source("cod/02_parametros_modelo.R")

# Hacemos un modelo base sin intervención

cambio_poblacional <- function(poblacion){
  
  poblacion_actualizada <- left_join(poblacion, tabla_edades, by = "edad") |> 
    mutate(
      hembras_sobrevivientes = hembras * supervivencia_hembras,
      machos_sobrevivientes = machos * supervivencia_machos,
      edad_siguiente = edad + 1,
      nacimientos_esperados = hembras * fecundidad
    )
      total_nacimientos = sum(poblacion_actualizada$nacimientos_esperados)
      
      crias = data.frame(
        edad = 1,
        hembras = total_nacimientos * 0.5,
        machos = total_nacimientos * 0.5
      )
      poblacion_nueva <- select(
        poblacion_actualizada,
        edad = edad_siguiente,
        hembras = hembras_sobrevivientes,
        machos = machos_sobrevivientes
      ) |>
        bind_rows(crias) |>
        filter(edad <= 45) |>
        arrange(edad)
  return(poblacion_nueva)
}

poblacion_provisional = data.frame(
  edad = 1:45,
  hembras = rep(1, 45),
  machos = rep(1, 45)
)

for(i in 1:100){
  poblacion_provisional <- cambio_poblacional(poblacion_provisional)
}

total_provisional <- sum(poblacion_provisional$hembras + poblacion_provisional$machos)


poblacion_inicial <- poblacion_provisional |> 
  mutate(
    hembras = hembras / total_provisional * 200,
    machos = machos / total_provisional * 200
  )

poblacion_actual <- poblacion_inicial

historial <- data.frame(
  anio = 2026,
  poblacion_total = sum(poblacion_actual$hembras + poblacion_actual$machos)
)

for(i in 2027:2050){
  poblacion_actual = cambio_poblacional(poblacion_actual)
  registro_anual = data.frame(
    anio = i,
    poblacion_total = sum(poblacion_actual$hembras + poblacion_actual$machos))
    historial <- bind_rows(historial, registro_anual)
}
historial <- historial |>
  mutate(
    crecimiento_poblacional =
      (poblacion_total - lag(poblacion_total)) /
      lag(poblacion_total) * 100
  )

# Escenario de esterilización

poblacion_inicial_control <- poblacion_inicial |>
  rename(hembras_fertiles = hembras) |>
  mutate(hembras_esterilizadas = 0)

cambio_poblacional_control <- function(poblacion, parametros = tabla_edades){
  poblacion_actualizada <- left_join(poblacion, parametros, by = "edad") |> 
    mutate(
      fertiles_sobrevivientes = hembras_fertiles * supervivencia_hembras,
      esterilizadas_sobrevivientes = hembras_esterilizadas * supervivencia_hembras,
      machos_sobrevivientes = machos * supervivencia_machos,
      nacimientos_esperados = hembras_fertiles * fecundidad,
      edad_siguiente = edad + 1
    )
  total_nacimientos = sum(poblacion_actualizada$nacimientos_esperados)
  
  crias = data.frame(
    edad = 1,
    hembras_fertiles = total_nacimientos * 0.5,
    hembras_esterilizadas = 0,
    machos = total_nacimientos * 0.5
  )
  poblacion_nueva = select(
    poblacion_actualizada, 
    edad = edad_siguiente, 
    hembras_fertiles = fertiles_sobrevivientes,
    hembras_esterilizadas = esterilizadas_sobrevivientes,
    machos = machos_sobrevivientes
  )
  poblacion_nueva <- bind_rows(poblacion_nueva, crias) |> 
    filter(edad <= 45) |> 
    arrange(edad)
  return(poblacion_nueva)
  }


esterilizar_hembras <- function(poblacion, cantidad_anual){
  hembras_elegibles =filter(poblacion, edad >= 5 & edad <= 30)
  total_elegibles = sum(hembras_elegibles$hembras_fertiles)
  esterilizaciones_reales = min(cantidad_anual, total_elegibles)
  if (total_elegibles == 0) {
    return(poblacion)
  }
  poblacion <- poblacion |> 
    mutate(
    esterilizaciones_por_edad = if_else(
      edad >= 5 & edad <= 30,
      hembras_fertiles / total_elegibles * esterilizaciones_reales,
      0
    ),
    hembras_fertiles = hembras_fertiles - esterilizaciones_por_edad,
    hembras_esterilizadas = hembras_esterilizadas + esterilizaciones_por_edad
  )
  poblacion <- poblacion |> 
    select(-esterilizaciones_por_edad)
  
  return(poblacion)
}

poblacion_actual_control <- poblacion_inicial_control

historial_esterilizacion <- data.frame(
  anio = 2026,
  poblacion_total = sum(
    poblacion_actual_control$hembras_fertiles +
      poblacion_actual_control$hembras_esterilizadas +
      poblacion_actual_control$machos
  )
)

for(i in 2027:2050){
  poblacion_actual_control = 
    esterilizar_hembras(poblacion_actual_control, cantidad_anual = 10)
  poblacion_actual_control =
  cambio_poblacional_control(poblacion_actual_control)
  registro_anual <- data.frame(
    anio = i,
    poblacion_total = sum(
      poblacion_actual_control$hembras_fertiles +
        poblacion_actual_control$hembras_esterilizadas +
        poblacion_actual_control$machos)
    )
  historial_esterilizacion <- bind_rows(
    historial_esterilizacion,
    registro_anual
  )
}

# Escenario de extracción

extraer_hipopotamos <- function(poblacion, cantidad_anual){
  total_disponibles <- sum(
    poblacion$hembras_fertiles +
      poblacion$hembras_esterilizadas +
      poblacion$machos
  )
  extracciones_reales = min(cantidad_anual, total_disponibles)
  if (total_disponibles == 0) {
    return(poblacion)
  }
  poblacion <- poblacion |> 
    mutate(
      extracciones_fertiles = hembras_fertiles / total_disponibles * extracciones_reales,
      extracciones_esterilizadas = hembras_esterilizadas / total_disponibles * extracciones_reales,
      extracciones_machos = machos / total_disponibles * extracciones_reales,
      hembras_fertiles = hembras_fertiles - extracciones_fertiles,
      hembras_esterilizadas = hembras_esterilizadas - extracciones_esterilizadas,
      machos = machos - extracciones_machos,
      across(
        c(hembras_fertiles, hembras_esterilizadas, machos),
        ~ if_else(abs(.x) < 1e-10, 0, .x)
      )
    ) |> 
    select(
      -extracciones_fertiles,
      -extracciones_esterilizadas,
      -extracciones_machos
    )
  return(poblacion)
}

poblacion_actual_extraccion <- poblacion_inicial_control
historial_extraccion <- data.frame(
  anio = 2026,
  poblacion_total = 200
)

for(i in 2027:2050){
  poblacion_actual_extraccion = 
    extraer_hipopotamos(poblacion_actual_extraccion, cantidad_anual = 30)
  poblacion_actual_extraccion =
    cambio_poblacional_control(poblacion_actual_extraccion)
  registro_anual <- data.frame(
    anio = i,
    poblacion_total = sum(
      poblacion_actual_extraccion$hembras_fertiles +
        poblacion_actual_extraccion$hembras_esterilizadas +
        poblacion_actual_extraccion$machos)
  )
  historial_extraccion <- bind_rows(
    historial_extraccion,
    registro_anual
  )
}

# Escenario combinado: esterilización + extracción

poblacion_actual_combinado <- poblacion_inicial_control

historial_combinado <- data.frame(
  anio = 2026,
  poblacion_total = sum(
    poblacion_actual_combinado$hembras_fertiles +
      poblacion_actual_combinado$hembras_esterilizadas +
      poblacion_actual_combinado$machos
  )
)

for(i in 2027:2050){
  
  # Primero esterilizamos hasta 10 hembras por año
  poblacion_actual_combinado <- esterilizar_hembras(
    poblacion_actual_combinado,
    cantidad_anual = 10)
  
  # Después extraemos hasta 30 hipopótamos por año
  poblacion_actual_combinado <- extraer_hipopotamos(
    poblacion_actual_combinado,
    cantidad_anual = 30
  )
  
  # Calculamos nacimientos, supervivencia y envejecimiento
  poblacion_actual_combinado <- cambio_poblacional_control(
    poblacion_actual_combinado
  )
  
  # Registramos la población del año
  registro_anual <- data.frame(
    anio = i,
    poblacion_total = sum(
      poblacion_actual_combinado$hembras_fertiles +
        poblacion_actual_combinado$hembras_esterilizadas +
        poblacion_actual_combinado$machos
    )
  )
  
  historial_combinado <- bind_rows(
    historial_combinado,
    registro_anual
  )
}

comparacion_escenarios <- bind_rows(
  historial |> mutate(escenario = "Sin intervención"),
  historial_esterilizacion |> mutate(escenario = "Esterilización"),
  historial_extraccion |> mutate(escenario = "Extracción"),
  historial_combinado |> mutate(escenario = "Combinado")
) |>
  select(anio, escenario, poblacion_total)

# Tabla comparativa de resultados principales
tabla_resultados <- comparacion_escenarios |> 
  filter(anio %in% c(2026, 2030, 2040, 2050)) |> 
  mutate(poblacion_total = round(poblacion_total, 2)) |> 
  select(anio, escenario, poblacion_total) |> 
  tidyr::pivot_wider(
    names_from = escenario,
    values_from = poblacion_total
  ) |> 
  arrange(anio)

tabla_resultados

# Resultados de los años principales

# Gráfico comparativo de los cuatro escenarios

grafico_escenarios <- ggplot(
  comparacion_escenarios,
  aes(x = anio, y = poblacion_total, color = escenario)
) +
  geom_line(linewidth = 1.2) +
  scale_color_manual(
    values = c(
      "Sin intervención" = "#D95F02",
      "Esterilización" = "#7570B3",
      "Extracción" = "#1B9E77",
      "Combinado" = "#E7298A"
    ),
    breaks = c(
      "Sin intervención",
      "Esterilización",
      "Extracción",
      "Combinado"
    ),
    labels = c(
      "Sin intervención",
      "Esterilización (10 hembras/año)",
      "Extracción (30 individuos/año)",
      "Manejo combinado"
    )
  ) +
  scale_x_continuous(
    breaks = seq(2026, 2050, by = 4)
  ) +
  labs(
    title = "Proyección de hipopótamos en Colombia",
    subtitle = "Comparación de escenarios de manejo, 2026–2050",
    x = "Año",
    y = "Población esperada",
    color = NULL,
    caption = "Fuente: Elaboración propia mediante simulación poblacional."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "bottom",
    legend.text = element_text(size = 10),
    legend.title = element_blank(),
    plot.title = element_text(face = "bold"),
    plot.subtitle = element_text(color = "gray40")
  ) +
  guides(
    color = guide_legend(nrow = 2, byrow = TRUE)
  )

grafico_escenarios

# Animación de la evolución poblacional
# Solo se ejecuta al trabajar directamente en RStudio,
# no cuando Quarto genera el informe.

if (!isTRUE(getOption("knitr.in.progress"))) {
  
  grafico_animado <- grafico_escenarios +
    transition_reveal(along = anio)
  
  animacion <- animate(
    grafico_animado,
    nframes = 150,
    fps = 15,
    width = 1000,
    height = 650,
    renderer = gifski_renderer()
  )
  
  dir.create("figuras", showWarnings = FALSE)
  
  anim_save(
    "figuras/hipopotamos_escenarios.gif",
    animation = animacion
  )
}

# Análisis de sensibilidad

crear_poblacion_inicial <- function(total_inicial){
  poblacion_nueva <- poblacion_inicial |> 
  mutate(
    hembras = hembras/200 * total_inicial,
    machos = machos/200 * total_inicial)
  return(poblacion_nueva)
}

simular_sin_intervencion <- function(total_inicial){
  poblacion_actual <- crear_poblacion_inicial(total_inicial)
  historial <- data.frame(
    anio = 2026,
    poblacion_total = sum(
      poblacion_actual$hembras +
        poblacion_actual$machos
    )
  )
  for(i in 2027:2050){
    poblacion_actual = cambio_poblacional(poblacion_actual)
    registro_anual <- data.frame(
      anio = i,
      poblacion_total = sum(
        poblacion_actual$hembras +
          poblacion_actual$machos
      )
    )
  historial <- bind_rows(historial,registro_anual)
  }
  return(historial)
}

simulacion_200 <- simular_sin_intervencion(200)
simulacion_225 <- simular_sin_intervencion(225)
simulacion_250 <- simular_sin_intervencion(250)

bind_rows(
  simulacion_200 |> mutate(poblacion_inicial = 200),
  simulacion_225 |> mutate(poblacion_inicial = 225),
  simulacion_250 |> mutate(poblacion_inicial = 250)
) |>
  filter(anio %in% c(2026, 2030, 2040, 2050)) |>
  arrange(poblacion_inicial, anio)

# Vamos a automatizar los tres escenarios

simular_escenario <- function(total_inicial, esterilizaciones_anuales, 
                              extracciones_anuales, parametros = tabla_edades){
    poblacion_actual <- crear_poblacion_inicial(total_inicial) |> 
      rename(hembras_fertiles = hembras) |> 
      mutate(hembras_esterilizadas = 0)
  historial <- data.frame(
    anio = 2026,
    poblacion_total = sum(
      poblacion_actual$hembras_fertiles +
        poblacion_actual$hembras_esterilizadas +
        poblacion_actual$machos
    )
  )
  for (i in 2027:2050) {
    poblacion_actual = esterilizar_hembras(poblacion_actual,
                                                   cantidad_anual = esterilizaciones_anuales)
    poblacion_actual = extraer_hipopotamos(poblacion_actual,
                                               cantidad_anual = extracciones_anuales)
    poblacion_actual = cambio_poblacional_control(poblacion_actual, parametros = parametros)
    registro_anual <- data.frame(
      anio = i,
      poblacion_total = sum(
        poblacion_actual$hembras_fertiles +
          poblacion_actual$hembras_esterilizadas +
          poblacion_actual$machos
      )
    )
    historial <- bind_rows(historial,registro_anual)
  }
  return(historial)
}

# Sensibilidad a número de extracciones anuales

extraccion_10 <- simular_escenario(200, 0, 10)
extraccion_30 <- simular_escenario(200, 0, 30)
extraccion_33 <- simular_escenario(200, 0, 33)

sensibilidad_extraccion <- bind_rows(
  extraccion_10 |> mutate(escenario = "Extracción 10"),
  extraccion_30 |> mutate(escenario = "Extracción 30"),
  extraccion_33 |> mutate(escenario = "Extracción 33")
)

sensibilidad_extraccion |>
  filter(anio %in% c(2030, 2040, 2050)) |>
  select(anio, escenario, poblacion_total) |>
  arrange(anio, escenario)

# Sensibilidad a distintas tasas de fecundidad

tabla_edades_baja <- tabla_edades |> 
  mutate(
    fecundidad = fecundidad * 0.90
  )

tabla_edades_alta <- tabla_edades |> 
  mutate(
    fecundidad = fecundidad * 1.10
  )

simulacion_fecundidad_baja <- simular_escenario(
  200, 0, 0, parametros = tabla_edades_baja
)

simulacion_fecundidad_base <- simular_escenario(
  200, 0, 0, parametros = tabla_edades
)

simulacion_fecundidad_alta <- simular_escenario(
  200, 0, 0, parametros = tabla_edades_alta
)

comparacion_fecundidad <- bind_rows(
  simulacion_fecundidad_baja |>
    mutate(escenario = "Fecundidad baja"),
  
  simulacion_fecundidad_base |>
    mutate(escenario = "Fecundidad base"),
  
  simulacion_fecundidad_alta |>
    mutate(escenario = "Fecundidad alta")
)

comparacion_fecundidad |>
  filter(anio %in% c(2026, 2030, 2040, 2050)) |>
  select(anio, escenario, poblacion_total) |>
  arrange(anio, escenario)

# Sensibilidad a la cantidad de hembras esterilizadas

esterilizacion_5 <- simular_escenario(200, 5, 0)
esterilizacion_10 <- simular_escenario(200, 10, 0)
esterilizacion_15 <- simular_escenario(200, 15, 0)
esterilizacion_20 <- simular_escenario(200, 20, 0)

sensibilidad_esterilizacion <- bind_rows(
  esterilizacion_5 |> mutate(escenario = "Esterilización_5"),
  esterilizacion_10 |> mutate(escenario = "Esterilización_10"),
  esterilizacion_15 |> mutate(escenario = "Esterilización_15"),
  esterilizacion_20 |> mutate(escenario = "Esterilización_20")
  )
sensibilidad_esterilizacion |>
  filter(anio %in% c(2030, 2040, 2050)) |>
  select(anio, escenario, poblacion_total) |>
  arrange(anio, escenario)
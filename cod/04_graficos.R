library(ggplot2)
library(dplyr)

source("cod/01_preparacion_datos.R")

# Crear el gráfico del análisis exploratorio
grafico_grupos <- ggplot(
  grupos,
  aes(
    x = estimacion_central,
    y = reorder(grupo, estimacion_central)
  )
) +
  geom_col(fill = "skyblue4", width = 0.7) +
  geom_text(
    aes(label = estimacion_central),
    hjust = -0.2,
    size = 3.5
  ) +
  scale_x_continuous(
    breaks = seq(0, 140, by = 20),
    expand = expansion(mult = c(0, 0.12))
  ) +
  labs(
    title = "Distribución estimada de hipopótamos por grupo",
    x = "Número estimado de hipopótamos",
    y = NULL,
    caption = "Fuente: Moreno-Arias et al. (2024)."
  ) +
  theme_minimal(base_size = 14)

# Mostrar el gráfico
print(grafico_grupos)

# Guardarlo para Canva
dir.create("figuras", showWarnings = FALSE)

ggsave(
  "figuras/analisis_exploratorio.png",
  plot = grafico_grupos,
  width = 12,
  height = 7,
  dpi = 300,
  bg = "white"
)
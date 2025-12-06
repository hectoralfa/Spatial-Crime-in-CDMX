



#' Genera lixels para un municipio específico
#'
#' Esta función toma una red vial a nivel estatal o nacional y una tabla con el
#' tamaño promedio de lixel por municipio, y devuelve los lixels correspondientes
#' al polígono indicado por su clave.
#'
#' @param cve Character o numérico. Clave del municipio/polígono a procesar.
#' @param columna_clave Character. Nombre de la columna que contiene las claves municipales (por defecto, `"CVE_MUN"`).
#' @param columna_geometria Character. Nombre de la columna que contiene la geometría (por defecto, `"geometry"`).
#' @param red_poligonal Objeto `sf` que contiene la red vial completa. Debe incluir la clave del municipio y geometrías tipo `LINESTRING` o `MULTILINESTRING`.
#' @param lixel_size_poligono Data frame (o tibble) con al menos dos columnas:
#'   la clave del municipio (`columna_clave`) y `lixel_prom`, que es la longitud objetivo del lixel para ese municipio.
#'
#' @return
#' Un objeto `sf` con los lixels generados para el municipio solicitado, incluyendo una columna con la clave municipal.
#' Si no hay datos suficientes o hay un error, se devuelve `NULL`.
#'
#' @details
#' Internamente la función:
#' 1. Filtra la red vial por la clave dada.
#' 2. Se queda con geometrías de tipo `LINESTRING` o `MULTILINESTRING`.
#' 3. Castea a `LINESTRING` y asegura validez geométrica.
#' 4. Obtiene la longitud objetivo de lixel para esa clave.
#' 5. Aplica `lixelize_lines()` para generar los segmentos.
#'
#' @seealso
#' `sf::st_make_valid`, `sf::st_geometry_type`, `lixelize_lines`
#'
#' @examples
#' \dontrun{
#' lixels <- generar_lixels_municipio(
#'   cve = "002",
#'   red_poligonal = red_vial_estatal,
#'   lixel_size_poligono = tabla_lixel_municipal
#' )
#' }
generar_lixels_municipio <- function(cve,
                                     columna_clave = "CVE_MUN",
                                     columna_geometria = "geometry",
                                     red_poligonal,
                                     lixel_size_poligono) {
  
  tryCatch({
    
    # 1. Filtrar red vial del municipio y quedarse solo con líneas válidas
    red_mun_lineas <- red_poligonal |>
      dplyr::filter(.data[[columna_clave]] == cve) |>
      dplyr::select(all_of(columna_geometria)) |>
      dplyr::filter(sf::st_geometry_type(.data[[columna_geometria]]) %in%
                      c("LINESTRING", "MULTILINESTRING")) |>
      sf::st_cast("LINESTRING") |>
      sf::st_make_valid()
    
    # 2. Obtener longitud promedio de lixel para ese municipio
    lix_prom <- lixel_size_poligono |>
      dplyr::filter(.data[[columna_clave]] == cve) |>
      dplyr::pull("lixel_prom")
    
    # 3. Validaciones rápidas: sin red o sin longitud, salir con NULL
    if (nrow(red_mun_lineas) == 0 || length(lix_prom) == 0 || is.na(lix_prom)) {
      message(sprintf("Sin datos suficientes para generar lixels en polígono %s (red o lixel_prom faltante).", cve))
      return(NULL)
    }
    
    # 4. Lixelizar la red del municipio
    lixels_mun <- lixelize_lines(red_mun_lineas, lx_length = lix_prom)
    
    # 5. Agregar la clave del municipio
    lixels_mun[[columna_clave]] <- cve
    
    return(lixels_mun)
    
  }, error = function(e) {
    message(sprintf("Error al generar lixels en municipio %s: %s", cve, e$message))
    return(NULL)
  })
}

#----------------------------
#' KDE y análisis Gi* para un municipio/polígono específico
#'
#' Esta función realiza el análisis de densidad Kernel (KDE) sobre una red vial,
#' y aplica el estadístico local Gi* de Getis-Ord para identificar hotspots/coldspots.
#'
#' @param clave Character o numérico. Clave del municipio o polígono a procesar.
#' @param lix_pol_len_df Data frame con columnas `col_clave` y `col_interes`, que contiene
#'   el tamaño de lixel promedio por municipio/polígono.
#' @param col_clave Character. Nombre de la columna con la clave del municipio. Default: `"CVE_MUN"`.
#' @param col_interes Character. Nombre de la columna con el tamaño promedio del lixel. Default: `"lixel_prom"`.
#' @param bandaW Numeric. Factor multiplicativo para el ancho de banda (`bw = lixel * bandaW`). Default: `4`.
#' @param semilla Numeric. Semilla para la aleatoriedad (snap). Default: `123`.
#' @param lixel_df Data frame (opcional, no usado directamente en esta función).
#' @param lixel_df_completo Objeto `sf` con los lixels completos de toda la red.
#' @param poligono_df Objeto `sf` con los polígonos por municipio/polígono.
#' @param eventos_df Objeto `sf` con los eventos (puntos).
#' @param dis Numeric. Distancia entre puntos de muestreo en las líneas. Default: `20`.
#' @param kernel Character. Tipo de kernel a usar. Default: `"epanechnikov"`.
#' @param metodo Character. Método del KDE. Default: `"simple"`.
#'
#' @return
#' Un objeto `sf` con los lixels del municipio/polígono procesado, incluyendo:
#' - `kde`: valor de densidad kernel estimado.
#' - `gi`: estadístico Gi* de Getis-Ord.
#' - `gi_cat`: clasificación del Gi*.
#' Si no hay líneas válidas o el municipio no tiene datos suficientes, devuelve `NULL`.
#'
KDE_vial <- function(clave,
                     lix_pol_len_df,
                     col_clave = "CVE_MUN",
                     col_interes = "lixel_prom",
                     bandaW = 4,
                     semilla = 123,
                     lixel_df_completo,
                     poligono_df,
                     eventos_df,
                     dis = 20,
                     kernel = "epanechnikov",
                     metodo = "simple") {
  
  # Obtener tamaño de lixel
  lix_p <- lix_pol_len_df |>
    filter(.data[[col_clave]] == clave) |>
    pull(.data[[col_interes]])
  
  if (length(lix_p) == 0 || is.na(lix_p)) {
    message(sprintf("Clave %s sin lixel_prom definido.", clave))
    return(NULL)
  }
  
  bw <- lix_p * bandaW
  
  # Filtrar polígono
  muni_poly <- poligono_df[poligono_df[[col_clave]] == clave, ]
  lixels_muni <- st_intersection(lixel_df_completo, muni_poly)
  
  lixels_muni <- lixels_muni[st_geometry_type(lixels_muni) == "LINESTRING", ]
  
  if (nrow(lixels_muni) == 0) {
    message(sprintf("clave %s sin líneas válidas.", clave))
    return(NULL)
  }
  
  # Filtrar eventos
  puntos_muni <- eventos_df[st_within(eventos_df, muni_poly, sparse = FALSE), ]
  
  if (nrow(puntos_muni) > 0) {
    set.seed(semilla)
    eventos_snap <- snapPointsToLines2(puntos_muni, lixels_muni)
    puntos_muni$dist_to_snap <- st_distance(puntos_muni, eventos_snap, by_element = TRUE)
    
    samples_sf <- spNetwork::lines_points_along(lixels_muni, dist = dis)
    
    kde_result <- nkde(
      lines = lixels_muni,
      events = puntos_muni,
      w = rep(1, nrow(eventos_snap)),
      bw = bw,
      samples = samples_sf,
      kernel_name = kernel,
      method = metodo,
      sparse = TRUE,
      verbose = TRUE
    )
    
    samples_sf$kde2 <- kde_result
    samples_sf <- samples_sf |> rename(id = lineID)
    
    kde_lixels <- samples_sf |> 
      as.data.frame() |> 
      group_by(id) |>
      summarise(kde3 = mean(kde2, na.rm = TRUE), .groups = "drop")
    
    lixels_muni$kde <- kde_lixels$kde3[match(1:nrow(lixels_muni), kde_lixels$id)]
    lixels_muni$kde[is.na(lixels_muni$kde)] <- 0
    
    coords <- st_coordinates(st_centroid(lixels_muni))
    vecinos <- dnearneigh(coords, d1 = 0, d2 = bw * 4)
    pesos <- nb2listw(vecinos, style = "W", zero.policy = TRUE)
    
    lixels_muni$gi <- localG(lixels_muni$kde, pesos, zero.policy = TRUE)
  } else {
    message(sprintf("Clave %s sin eventos. kde = 0, gi = 0", clave))
    lixels_muni$kde <- 0
    lixels_muni$gi <- 0
  }
  
  # Clasificación de Gi*
  lixels_muni$gi_cat <- cut(
    lixels_muni$gi,
    breaks = c(-Inf, -1.96, -1.65, 1.65, 1.96, Inf),
    labels = c("Coldspot (99%)", "Coldspot (95%)", 
               "No significativo", 
               "Hotspot (95%)", "Hotspot (99%)")
  )
  
  lixels_muni[[col_clave]] <- clave
  return(lixels_muni)
}

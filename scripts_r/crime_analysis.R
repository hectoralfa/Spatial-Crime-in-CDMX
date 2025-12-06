# limpiar consola
rm(list = ls(all.names = TRUE))
gc()

options(scipen = 999)
source("funciones.r")
# Librerías
pacman::p_load(readxl,dplyr,tidyverse,sp,sf,spdep,igraph,lwgeom,
               tidygraph,readr, tmap, future,furrr,spNetwork)


# Datos
df_delitos <- read_csv("../input/Delitos/carpetasFGJ_2023.csv")
poligonos <-  st_read("../input/Poligonos/2023_1_09_MUN/2023_1_09_MUN.shp")
red_vial <- st_read("../input/Red_vial/09_CVE.json") 
agebs <-  st_read("../output/agebs.geojson")

# Preprocesamiento

# Verificar que el sistema de coordenadas sea el 4326
# Además si la geometria de tu red vial es tipo Multlilinestring 
# la transforma a tipo linestring 

if (st_crs(red_vial)$epsg==4326){
  red_vial <- red_vial[,c("geometry")] %>% 
    st_cast( "LINESTRING")
  
}else{
  red_vial <- st_set_crs(red_vial, 4326)
  
  red_vial <- red_vial[,c("geometry")] %>% 
    st_cast( "LINESTRING")
}
 
# Solo nos quedaremos con trozos de la red vial que pertenecen
# a los poligonos del área de estudio. Para que esto sea posible
# se cambia el sistema de coordenadas de los datos geograficos

 poligonos <- st_transform(agebs, 32614)
 red_vial <- st_transform(red_vial, 32614)
 
 # Intersecar red vial con los poligonos de estudio
 red_municipal <- st_intersection(red_vial, poligonos)
 
 # Calcular longitud promedio por poligono
 lixel_size_municipio <- red_municipal %>%
   mutate(long = st_length(geometry)) %>%
   group_by(ageb) %>%
   summarise(lixel_prom = round(mean(as.numeric(long)),-1))%>%
   st_drop_geometry() 
 
 # Unir la longitud promedio a la red vial 
 red_municipal <- red_municipal %>%
   left_join(lixel_size_municipio, by = "ageb")
 
 # Aplicar la función a cada poligono
 lista_lixels <- map(lixel_size_municipio$ageb, 
                     ~ generar_lixels_municipio(.x, columna_clave = "ageb",
                                                columna_geometria = "geometry", 
                                                red_poligonal =  red_municipal, 
                                                lixel_size_poligono =  lixel_size_municipio))
 
 # Unir todos los resultados (elimina los NULL)
 lixels_todos <- bind_rows(compact(lista_lixels)) 
 
 ### En este caso solo tomaremos los eventos donde el delito pertenece a robo a pasajero
 data_robo=df_delitos %>% 
   filter(categoria_delito %in% c("ROBO A PASAJERO A BORDO DE MICROBUS CON Y SIN VIOLENCIA", "ROBO A TRANSEUNTE EN VÍA PÚBLICA CON Y SIN VIOLENCIA","ROBO A NEGOCIO CON VIOLENCIA") )
 
 # Se crea un dataframe solo con las columnas de interés para no 
 # exponer datos sensibles
 eventos_df <- data_robo %>%
   mutate(id=row_number()) %>% 
   select(id, latitud, longitud) %>% 
   filter(!is.na(latitud), !is.na(longitud))
 
 # Cambio de sistema de coordenadas para que sea medible 
 eventos <- st_as_sf(eventos_df,
                     coords = c("longitud", "latitud"),
                     crs = 4326) %>%
   st_transform(32614) %>% 
   mutate(CVE_ENT="09")
 
 # # Inicializar lista para guardar resultados
 # lista_resultados <- list()
 # 
 # Obtener los códigos únicos de municipio
 codigos_mun <- unique(poligonos$ageb) 

 resultados_kde <- map(
   unique(poligonos$ageb),
   ~ KDE_vial(
     clave = .x,
     col_clave = "ageb",
     col_interes = "lixel_prom",
     lix_pol_len_df = lixel_size_municipio,
     lixel_df_completo = lixels_todos,
     poligono_df = poligonos,
     eventos_df = eventos
   )
 )
 
 # Convertir todas las columnas `gi` a numeric
 resultados_kde_limpio <- resultados_kde %>% 
   compact() %>% 
   map(~ {
     .x$gi <- as.numeric(.x$gi)
     return(.x)
   })
 
 # Ahora sí: unir
 kde_final <- bind_rows(resultados_kde_limpio) %>% 
   na.omit() %>%
   filter(gi_cat != "No significativo")
   
 
 # 
 df_robo <- data_robo %>% 
   select(delito, latitud, longitud) %>% 
   janitor::clean_names() %>% 
   mutate(longitud=as.numeric(longitud),
          latitud=as.numeric(latitud),
     coord_completa = ifelse(
       !is.na(latitud) & !is.na(longitud) & !(latitud < 1 & longitud < 1),
       "valida",
       "no valida"
     ),
     validador = ifelse(
       coord_completa == "valida" & latitud >= 14 & latitud <= 33 & longitud >= -118 & longitud <= -86,
       "en_rango",
       "fuera_rango"
     )
   ) 
 
 kde_final1=kde_final%>% 
   mutate(colores=case_when( gi_cat =="Coldspot (99%)" ~ "#207BF5",
                             gi_cat == "Coldspot (99%)" ~ "#77B2DB",
                             gi_cat == "Hotspot (95%)" ~ "#F58F7A",
                             gi_cat == "Hotspot (99%)" ~ "#F5011E",
                             TRUE ~ "#B0B0B0")) %>% 
   st_transform(crs=4326) %>% 
   mutate(CVE_ENT="09") %>% 
   select(CVE_ENT, geometry, colores)
 
 
 
 # leer archivos y transformar al sistema de coordenadas geográficas EPSG:4326 → WGS 84
 escuelas <- read_excel("../input/datos_coordenada/escuelas_cdmx.xlsx") %>% 
   select(nombre,latitud, longitud) %>% 
   mutate(latitud=as.numeric(latitud),
          longitud=as.numeric(longitud) ) %>% 
   na.omit()
   
 
 escuelas <- st_as_sf(escuelas, coords = c("longitud", "latitud"), crs = 4326) %>% 
   mutate(CVE_ENT="09")
 
 dend_poblacion=st_read("../input/datos_coordenada/municip_poblacion.geojson") %>% 
   st_transform(crs=4326)
  
 poligonos1 <- poligonos %>% 
   st_transform(crs=4326)
 
 # Leer archivo XYZ como tabla
 xyz_data <- read.table("../input/datos_coordenada/mex_pd_2020_1km_ASCII_XYZ.csv", 
                        header = TRUE,  sep = ",",)  # O TRUE si tiene encabezado
 # Ver las primeras filas
 xyz_sf <- st_as_sf(xyz_data, coords = c("X", "Y"), crs = 4326)
 
 puntos <- st_transform(xyz_sf, 4326)
 
 puntos_join <- st_join(puntos, poligonos1, join = st_within)
 
 # Calcular promedio por municipio
 promedios <- puntos_join %>%
   group_by(CVE_MUN, CVE_ENT) %>%  # usa el identificador del municipio
   summarise(prom_densidad_pob = mean(Z, na.rm = TRUE)) 
 
 poligono_sf=poligonos1 %>% 
   left_join(st_drop_geometry(promedios)[,c("CVE_MUN", "CVE_ENT", "prom_densidad_pob")], by=c("CVE_MUN", "CVE_ENT"))
 
 municipos_tablero <- st_transform(poligono_sf, 4326)
 
 eventos1 <- st_transform(eventos, 4326)%>%
   mutate(CVE_ENT="09")
 
 #json_municipios <- jsonlite::toJSON(municipos_tablero, pretty = TRUE)

 # escribir la información  en formatos json
st_write(eventos1,"../Aplicativo/output/delitos_robo.geojson", delete_dsn = TRUE )
 st_write(kde_final1, "../Aplicativo/output/calles09.geojson", delete_dsn = TRUE)
 
 st_write(escuelas, "../Aplicativo/output/escuelas.geojson", delete_dsn = TRUE)
 st_write(poligonos1,"../Aplicativo/output/poligono.geojson", delete_dsn = TRUE )
 st_write(municipos_tablero, "../Aplicativo/output/municip_poblacion.geojson", delete_dsn = TRUE)
 
 
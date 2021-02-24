
      # -- José Luis Losada Palenzuela -- #
                # -- 2021 -- #

### ------------------------------------------- ###
###         Código para el curso de             ###
###     tratamiento y visualización de datos    ###
### ------------------------------------------- ###

# -- 2_scripts_maps.R -- #
# -- Aquí solo se recoge el código de forma esquemática -- #  

rm(list = ls()) # Limpia los datos de la sesión

# ¿En otra sesión? Cargue las librerías y los datos

library(tidyverse)
bibliostylo = read.csv("stylometry_sample.csv", encoding = "UTF-8", stringsAsFactors=F)

## Lugares----

# Conocer la estructura de los datos: 
# Pipe %>%

lugares = bibliostylo %>%              # Asignamos la variable
  select(Place) %>%                    # Seleccionamos los lugares
  na_if("") %>%                        # Comprobamos si algunos están vacíos (¿revistas?)
  na.omit() %>%                        # Eliminamos los vacíos
  separate_rows(sep = "/", Place) %>%  # Separamos las observaciones que tengan
  separate_rows(sep = "&", Place) %>%
  separate_rows(sep = ";", Place) %>%  
  separate_rows(sep = "-", Place)


lugares[1:14,]

lugares = data.frame(lapply(lugares, str_trim)) # limpiar espacios.

lugares = dplyr::count(lugares, Place) # contamos. Atención a los namespaces

# Exportarlo fuera de R----

write.csv(lugares, file = "lugares_estilometria.csv") 

## Cargar lugares georreferenciados

geolugares = read.csv("geo_lugares_estilometria.csv")
geolugares[1:5,]


## Elaborar un mapa interactivo----

library(leaflet)

# mapa 1

leaflet() %>%
  addTiles() %>% # Representación del territorio
  addCircleMarkers(
    geolugares$lon, 
    geolugares$lat, 
    label = geolugares$Place) # Indicadores de posición.


# mapa 2
# Frecuencias.

leaflet() %>%
  addTiles() %>%
  addCircleMarkers(geolugares$lon, 
                   geolugares$lat, 
                   label = geolugares$Place, 
                   radius = geolugares$n*2)   %>%
  addControl("Lugares de publicación «Bibliography on Stylometry»")

# Mapa 3 con ggplot2

library(ggplot2)
# install.packages("maps")
library(maps)

ggplot() +
  borders("world", fill = "lightsteelblue") +
  geom_text(data = geolugares,
            aes(x = lon, y = lat),
            label = geolugares$Place)

ggplot(geolugares, aes(lon, lat)) +
  borders("world") +
  geom_point(aes(size = n, colour = n)) +
  coord_quickmap() +
  theme_void()

## Ejemplo de proyecto
# https://editio.github.io/mapping.literature

## Extra. Automatizar la geolocalización----

# install.packages("devtools")
# library(devtools)
# install_github("editio/georeference")

library(georeference)

typeof(lugares$Place)

# Buscar en el diccionario geográfico (Pelagios)
geolugares = georef(as.character(lugares$Place))

# Buscar en el diccionario geográfico (GeoNames)
# geolugares = georef(as.character(lugares$Place),  
#                source = "geonames", 
#                bounding.box ="43.7,-16.7,59.8,35.4", 
#                inject = "username=geonames_account_id")


leaflet() %>%
  addTiles() %>%
  addCircleMarkers(geolugares$lon, 
                   geolugares$lat, 
                   label = geolugares$name)

# Calcular las frecuencias
# geolugares_frq = plyr::count(geolugares)

leaflet() %>%
  addTiles() %>%
  addCircleMarkers(geolugares_frq$lon, 
                   geolugares_frq$lat, 
                   label = geolugares_frq$name,
                   radius = geolugares_frq$freq*2, 
                   popup = paste0("<b>",geolugares_frq$name,"</b>","<br>","gazetteer: ",geolugares_frq$url, "<br>", "freq of mention: ",geolugares_frq$freq)
  )

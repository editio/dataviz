
      # -- José Luis Losada Palenzuela -- #
                # -- 2020 -- #

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
lugares = count(lugares, Place) # contamos 

# Exportarlo fuera de R----

write.csv(lugares, file = "lugares_estilometria.csv") 

## Cargar lugares georreferenciados
library(georeference)

georef("Rome")

geolugares = read.csv("geo_lugares_estilometria.csv")
geolugares[1:5,]


## Elaborar un mapa interactivo----

library(leaflet)

# mapa 1

leaflet() %>%
  addTiles() %>% # Representación del territorio
  addCircleMarkers(geolugares$lon, geolugares$lat, label = geolugares$Place) # Indicadores de posición.


# mapa 2
# Frecuencias.

leaflet() %>%
  addTiles() %>%
  addCircleMarkers(geolugares$lon, 
                   geolugares$lat, 
                   label = geolugares$Place, 
                   radius = geolugares$n*2)   %>%
  addControl("Lugares de publicación «Bibliography on Stylometry»")


# https://editio.github.io/mapping.literature

## Extra. Automatizar la geolocalización----

# install.packages("devtools")
# library(devtools)
# install_github("editio/georeference")

library(georeference)

typeof(lugares$Place)

# Buscar en el diccionario geográfico (Pelagios)
geolugares = georef(as.character(lugares$Place))

leaflet() %>%
  addTiles() %>%
  addCircleMarkers(geolugares$lon, 
                   geolugares$lat, 
                   label = geolugares$name)

# Calcular las frecuencias
geolugares_frq = count(geolugares)

leaflet() %>%
  addTiles() %>%
  addCircleMarkers(geolugares_frq$lon, 
                   geolugares_frq$lat, 
                   label = geolugares_frq$name,
                   radius = geolugares_frq$freq*2, 
                   popup = paste0("<b>",geolugares_frq$name,"</b>","<br>","gazetteer: ",geolugares_frq$url, "<br>", "freq of mention: ",geolugares_frq$freq)
  )

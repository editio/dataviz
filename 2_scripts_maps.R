
      # -- José Luis Losada Palenzuela -- #
                # -- 2020 -- #

### ------------------------------------------- ###
###         Código para el curso de             ###
###     tratamiento y visualización de datos    ###
### ------------------------------------------- ###

# -- 2_scripts_maps.R -- #
# -- Aquí solo se recoge el código de forma esquemática -- #  

# rm(list = ls()) # Limpia los datos de la sesión

# ¿En otra sesión? Cargue las librerías y los datos

library(tidyverse)
bibliostylo = read.csv("stylometry_sample.csv", encoding = "UTF-8")

## Lugares----

bibliostylo$Place

lugares = bibliostylo %>%              # Asignamos la variable
  select(Place) %>%                    # Seleccionamos los lugares
  na_if("") %>%                        # Comprobamos si algunos están vacíos
  na.omit() %>%                        # Eliminamos los vacíos
  separate_rows(sep = "/", Place) %>%  # Separamos las observaciones que tengan
  separate_rows(sep = "&", Place) %>%
  separate_rows(sep = ";", Place) %>%  
  separate_rows(sep = "-", Place)

lugares[1:14,]

lugares = data.frame(lapply(lugares, str_trim))
lugares = count(lugares, Place)

# Exportarlo fuera de R----

write.csv(lugares, file = "lugares_estilometria.csv") 

## Cargar lugares georreferenciados

geolugares = read.csv("geo_lugares_estilometria.csv")
geolugares[1:5,]


## Elaborar un mapa interactivo----

library(leaflet)

# mapa 1

leaflet() %>%
  addTiles() %>%
  addCircleMarkers(geolugares$lon, geolugares$lat, label = geolugares$Place)


# mapa 2

leaflet() %>%
  addTiles() %>%
  addCircleMarkers(geolugares$lon, 
                   geolugares$lat, 
                   label = geolugares$Place, 
                   radius = geolugares$n*2)   %>%
  addControl("Lugares de publicación de Bibliography on Stylometry")


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

      # -- José Luis Losada Palenzuela -- #
                # -- 2021 -- #

### ------------------------------------------- ###
###         Código para el curso de             ###
###     tratamiento y visualización de datos    ###
### ------------------------------------------- ###

# -- 1_scripts_ggplot.R -- #
# -- Aquí solo se recoge el código de forma esquemática -- #  

## Instrucciones básicas en R----

x = 4         # Asignar un valor con "="

x             # Comprobar el valor

y <- 2        # asignar un valor con "<-"

y
y + 5         # sumarle 5.

y == x        # Comparar x con y. "==" (igualdad) "!=" (desigualdad)

y <- 2        # error.

miVariable = "En un lugar de La Mancha de cuyo nombre no quiero"

miVariable

# función que cuenta caracteres
nchar(miVariable)

# Dataframes


myBibl = data.frame(
  # autor = c("Góngora","Cervantes","Calderón","Cervantes"),
  título=c("Polifemo","Quijote","Príncipe constante","Persiles"), 
  año=c(1612,1605,1647,1617),
  etiqueta=c("poesía","novela","teatro","novela"),
  disponible=c(T,T,T,F)
)

# Función para visualizar la tabla en el panel source (no modificable)
library(tidyverse) # para la función view()
view(myBibl)

myBibl$autor = NULL
myBibl$etiqueta
myBibl$disponible

## Instalación y carga de paquetes----

# Solo es necesario instalarlos una vez. Usaremos los siguientes. 

#install.packages("tidyverse") # Contiene ggplot2
#install.packages("tokenizers")
#install.packages("stopwords") 
# install.packages("wordcloud")
# install.packages("treemapify")
# install.packages("leaflet")
# install.packages("ggalluvial")
# install.packages("igraph")

# Una vez instalados se deben cargar en cada sesión, p. ej. 
library(tidyverse)

# Explorar tibble() del paquete tidyverse, también para crear tablas.

## Crear y acceder al directorio de trabajo---- 

# Crear una carpeta manualmente (fuera de R) o crear directamente desde R con la función: dir.create("~/Documents/dataviz")
# Fijar el directorio de trabajo. Otras posibilidades en los menús de Rstudio.

# Session > Set Working Directory > to Source File Location

setwd("~/Documents/dataviz")

## Datos y codificación---- 

# Los datos para estos códigos están disponibles para su descarga en <https://github.com/editio/dataviz>

# Atención a la codificación. Importante que sea UFT-8 (comprobar con Sys.getlocale() o con l10n_info().) 

# Sys.getlocale()

# Para los OS Mac y Linux puede ser suficiente: Sys.setlocale(locale="UTF-8"). Para Windows deberá especificarse cada vez que se cargan los datos en la función correspondiente con: encoding = "UTF-8"

# Sys.setlocale(locale="UTF-8")

bibliostylo = read.csv("stylometry_sample.csv", encoding = "UTF-8", stringsAsFactors=F)

#bibliostylo = read.csv("zotero_estilometria.csv", encoding = "UTF-8")


# Funciones informativas sobre variables
bibliostylo$Author
dim(bibliostylo)
bibliostylo$Item.Type
class(bibliostylo)
colnames(bibliostylo)

## Primeras visualizaciones con ggplot2----

# geom_bar(). Visualiza el recuento.

ggplot(bibliostylo) +
  aes(Item.Type) +
  geom_bar()

# count(). Contar nosotros.

pub_type = count(bibliostylo, Item.Type) # Cuenta las observaciones
pub_type

# geom_col(), reorder()

ggplot(pub_type) +
  aes(x = reorder(Item.Type, n), y = n, fill = n) +
  geom_col() +
  labs(x = "recuento", y = "", title = "Tipos de publicación")

# Años: Publication.Year---- 

years = count(bibliostylo, Publication.Year) # Cuenta las observaciones de la variable

ggplot(years) +
  aes(x = reorder(Publication.Year, n), y = n, fill = n) +
  geom_col() +
  labs(x = "", y = "", title = "Publicaciones de DataViz") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) # Gira los años 45º y los ajusta horizontalmente.
# Probar n en reorder, angle.

# Autores: Author----
# Conocer los datos y su estructura: separador de nombres con ;

bibliostylo$Author

authors = separate_rows(bibliostylo, sep = ";", Author)
authors = count(authors, Author)

dim(authors) # ¿cuántos autores?

# authors[1:6,]  # una_tabla[filas,columnas]

authors = top_n(authors, 10, n) # Selecciona los 10 primeros según la frecuencia. Si empata añade.


ggplot(authors) +
  aes(x = reorder(Author, n), y = n, fill = n) +
  geom_col() +
  labs(x = "", y = "", title = "Autores") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Etiquetas: Manual.Tags----
bibliostylo$Manual.Tags
tags = separate_rows(bibliostylo, sep = ";", Manual.Tags) # Separa las observaciones
tags = data.frame(lapply(tags, str_trim)) # Limpia los espacios
tags = count(tags, Manual.Tags, sort = TRUE) # Cuenta las observaciones únicas

tags

# Seleccionar una frq de dos o más.
# subset

tags = subset(tags, tags$n > 2)  # Subconjunto de más de 2 etiquetas

ggplot(tags) +
  aes(x = reorder(Manual.Tags, n), y = n, fill = n) +
  geom_col() +
  labs(x = "", y = "", title = "Etiquetas") +
  coord_flip()

## Análisis textual de los títulos----

bibliostylo$Title

titulos = paste(bibliostylo$Title)  # Unir todas las observaciones de Title (cadena de caracteres)

# Componentes léxicos (tokens)

# Cargar las librerías (debe instalarse antes el paquete)
# Eliminar palabras vacías.
library(stopwords)

stopwords_en = stopwords("en")  # inglés
stopwords_de = stopwords("de")  # alemán
stopwords_es = stopwords("es")  # español
stopwords_nl = stopwords("nl")  # neerlandés
stopwords_fr = stopwords("fr")  # francés
stopwords_la = stopwords("latin", source = "stopwords-iso") # latín

stopwords_la 

# stopwords_es = stopwords("es") %>% # Spanish
#  append(c("ay", "aun", "si", "asi", "tan", "ser", "oh"))  # manualmente anadido
#
#  append(stopwords_es, c("ay", "aun", "si", "asi", "tan", "ser", "oh"))  # manualmente anadido


stopwords_la[2:8]  # Ver de la segunda a la octava

# ¿Variable idioma?

library(tokenizers)

list_tokens = tokenize_words(titulos, 
                             lowercase = T, 
                             strip_punct = T, 
                             strip_numeric = T, 
                             stopwords = c(stopwords_en, stopwords_de, stopwords_es, stopwords_la, stopwords_nl, stopwords_fr))



title_words = data.frame(palabras = unlist(list_tokens)) # Conversión en tabla.
title_words = count(title_words, palabras)  # contar las observaciones
title_words = top_n(title_words, 20, n)  

# updated_myData <- subset(title_words, palabras != "em")

ggplot(title_words) +
  aes(x = reorder(palabras, n), y = n, fill = n) +
  geom_col() +
  labs(x = "", y = "", title = "Palabras en títulos (selección con mayor frq)") +
  coord_flip()

## Nubes de palabras----
library(wordcloud) # no es ggplot

wordcloud(tags$Manual.Tags, tags$n)

#  wordcloud(tags$Manual.Tags, tags$n, scale =c(2,.2)) # Distintas resoluciones

wordcloud(title_words$palabras, title_words$n, colors=palette(), min.freq=5)

# wordcloud(title_words$palabras, title_words$n, min.freq=5, random.order=FALSE, rot.per=0.5, colors=brewer.pal(8, "Dark2"))


#  Nube de autores

authors = separate(authors, Author, into = c("apellido", "nombre"), sep = ",")
authors

wordcloud(authors$apellido, authors$n)

## Visualización jerárquica. Treemaps----

library(treemapify)

ggplot(tags) +
  aes(area = n, fill = n, label = Manual.Tags) +
  geom_treemap() +
  geom_treemap_text(fontface = "italic", colour = "white", place = "centre", grow = T) +
  theme(legend.position="none")




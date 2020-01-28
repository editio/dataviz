
      # -- José Luis Losada Palenzuela -- #
                # -- 2020 -- #

### ------------------------------------------- ###
###         Código para el curso de             ###
###     tratamiento y visualización de datos    ###
### ------------------------------------------- ###

# -- 3_scripts_redes.R -- #
# -- Aquí solo se recoge el código de forma esquemática -- #  

# rm(list = ls()) # Limpia los datos de la sesión

# ¿En otra sesión? Cargue las librerías y los datos

library(tidyverse)
bibliocurso = read.csv("asignatura_sample.csv", encoding = "UTF-8")

# Procesar los datos----

edgelist = select(bibliocurso, Author, Manual.Tags)
edgelist = separate_rows(edgelist, sep = ";", Manual.Tags)
edgelist = separate_rows(edgelist, sep = ";", Author)
edgelist = separate(edgelist, Author, into = c("apellido", "nombre"), sep = ",")
edgelist$nombre <- NULL
edgelist = na_if(edgelist, "")
edgelist = na.omit(edgelist)
edgelist = data.frame(lapply(edgelist, str_trim)) 

edgelist[1:3,]

# Visualizar con un diagrama de flujo----
# install.packages("ggalluvial")
library(ggalluvial)
ggplot(edgelist) +
  aes(axis1 = Manual.Tags, axis2 = apellido) +  # En el eje horizontal
  geom_alluvium(aes(fill = Manual.Tags)) +    # Conexiones y color
  geom_stratum() +                            # Columnas
  geom_text(stat = "stratum", label.strata = T) + # Texto y cálculo
  theme_void() +
  theme(legend.position = "none")

# New versions: geom_text(stat = "stratum", infer.label = T) 

## Crear un objeto de red----

# install.packages("igraph")
library(igraph)
graph <- graph.data.frame(edgelist, directed = F)

# Visualizar con plot----
plot(graph, 
     vertex.label = NA)

plot(graph,
     vertex.label.color="black",
     vertex.shape="none")

is.bipartite(graph)  # Comprobar si es un grafo bipartito

V(graph)$type <- V(graph)$name %in% edgelist[,2] # Crear un objeto bipartito
V(graph)$type

is.bipartite(graph)

plot(graph,
     vertex.label = NA,
     vertex.size = 7,
     # layout = layout_as_bipartite,
     vertex.color = ifelse(V(graph)$type, "tomato", "green")
)

# Calcular el grado de los nodos----

deg = degree(graph)

plot(graph,
     vertex.label = NA,
     vertex.size = deg*2,
     # layout = layout_as_bipartite,
     vertex.color = ifelse(V(graph)$type, "tomato", "green")
)

plot(graph,
     vertex.label = ifelse(deg > 4, V(graph)$name, NA),
     vertex.size = deg*2,
     vertex.color = ifelse(V(graph)$type, "tomato", "green"),
     vertex.label.cex = deg/4,
     vertex.label.color = "black"
)

## Exportar los datos fuera de R----

aristas = get.data.frame(graph, what = "edges")
nodos = get.data.frame(graph, what = "vertices")

write.csv(aristas, file = "aristas_biblio.csv") 
write.csv(nodos, file = "nodos_biblio.csv") 

write_graph(graph, "dataviz.gml", format = c("gml")) # Formato de Gephi
######################################################
# Grupo Trabajo Madrid (R-Hispano)
# Análisis de Redes Sociales (SNA)
# 
# Temática. Cómo hacer análisis de redes sociales con 
#           R-igraph y Gephi.
#         
# Datos.    Escándalo ENRON          
# Fecha.    04.04.2013 
# ----------------------------------------------------


getwd()
WORKING_DIR <- "~/R/RStats/R-Social Network Analysis"

# We're gonna need these later
#install.packages(c("igraph", "twitteR", "gplots"))
library(igraph)
library(twitteR)
library(gplots)


# Set your working directory to the full path of the R Social Network Analysis folder on your machine
setwd(WORKING_DIR)
getwd()
# Load data
#load("./data/TallerSNA-GrupoR-2013-04-04.Rdata")

load("./data/enron.Rdata")


summary(edges); nrow(edges)
# edges es dataframe que contiene los enlaces (4308, un pequeño subconjunto del total)
# es imprescindible para igraph tener dos primeras columnas con id's de nodos
# normalmente el primero es emisor y el segundo receptor -caso de enlace dirigido
# o más general, nodo A y nodo B
# este dataset contiene relativamente poca info. sobre enlace, sólo fecha, tipo (CC, BCC O TO) 
# y  número de comunicaciones

summary(nodes); nrow(nodes)
# nodes es dataframe contiene los datos de *todos* los nodos de la red (emisores y receptores)
# contiene Email_id -como dirección correo-e- lastName y muy interesante: status


# ========================================================================
# 1- CREACIÓN DE LA RED con graph.data.frame
# ========================================================================

# crear la red a partir de los dataframes de enlaces y nodos es realmente sencillo
# recalcar los requisitos de las dos primeras columnas de enlaces
# y de que nodos contenga los id's para absolutamente todos los nodos de tabla enlaces
# En la creación podemos decidir si la red es dirigida o no

# importante: para igraph V = vertex/vértice (=nodo). E = edge/enlace

network <- graph.data.frame(edges,
                            directed = TRUE,
                            vertices = nodes)

class(network);summary(network)

# Observamos que ha creado un objeto específico igraph, y el resumen nos dice nodos y enlaces
# automáticamente ha adjuntado *como propiedades de nodo* las columnas adicionales al id de nodo
# (name, lastName, status)
# y como *propiedades de enlace* las columnas adicionales a los id's de nodos en tabla enlaces
# (type, date, count)

# Podemos inspeccionar el formato interno con 

head(network)

# ========================================================================
# 2- MANEJANDO el objeto igraph y los componentes V y E
# ========================================================================

# La documentación mas práctica son el manual en línea
# http://igraph.sourceforge.net/doc/R/00Index.html
# http://igraph.sourceforge.net/documentation.html
# aunque aquí también ha un tutorial (inacabado)
# http://igraph.sourceforge.net/igraphbook/

# Se accede a las propiedades vértice y enlace mediante
# V(network) y E(network)
# http://igraph.sourceforge.net/doc/R/iterators.html

V(network)[1:10]
E(network)[1:10]

# Y también sus propiedades

table(V(network)$status)
table(E(network)$date)

# CAVEAT igraph no entiende bien el formato fecha
table(edges$date)
plot(table(edges$date))
plot(table(E(network)$date))

# ========================================================================
# 3- EXPORTAR el grafo a formatos externos para visualización etc 
# ========================================================================

# Cuidado con el formato de fechas -hay que pasarlo a character

write.graph(network,
            file = "network01.graphml",
            format = "graphml")


# Guardamos nuestro primer workspace

save.image(file ="enron_01.Rdata")


# ========================================================================
# VAMOS A REHACER EL GRAFO A PARTIR DE DATOS COMPLETOS -CON MENSAJE Y HORA
#
# 1- CREACIÓN DE LA RED con graph.data.frame
# ========================================================================

# Nuevo dataframe extraído del dump MySQL de amschulz
# Notad que ahora tenemos 61673 enlaces puesto que *no* hemos hecho group by

#load("edges_w_message.RData")

summary(edges.full); nrow(edges.full)

# Interesante notar cómo mantenemos la fecha (date) como texto
# PORQUE ESTE ES EL FORMATO QUE GEPHI ENTIENDE BIEN
# Pero vamos a crear un campo para tenerlo como fecha en R 

edges.full$date.R <- as.POSIXct(edges.full$date)

# crear la red a partir de los dataframes de enlaces y nodos es realmente sencillo
# recalcar los requisitos de las dos primeras columnas de enlaces
# y de que nodos contenga los id's para absolutamente todos los nodos de tabla enlaces
# En la creación podemos decidir si la red es dirigida o no

# importante: para igraph V = vertex/vértice (=nodo). E = edge/enlace

# AUNQUE debemos filtrar el contenido completo porque da problemas de xml


network.full <- graph.data.frame(edges.full[,c("sender",
                                               "receiver",
                                               "type",
                                               "date",
                                               "subject")],
                                 directed = TRUE,
                                 vertices = nodes)

class(network.full);summary(network.full)

# Observamos que ha creado un objeto específico igraph, y el resumen nos dice nodos y enlaces
# automáticamente ha adjuntado *como propiedades de nodo* las columnas adicionales al id de nodo
# (name, lastName, status)
# y como *propiedades de enlace* las columnas adicionales a los id's de nodos en tabla enlaces
# (type, date, count)

# ========================================================================
# 2- MANEJANDO el objeto igraph y los componentes V y E
# ========================================================================

# La documentación mas práctica son el manual en línea
# http://igraph.sourceforge.net/doc/R/00Index.html
# http://igraph.sourceforge.net/documentation.html
# aunque aquí también ha un tutorial (inacabado)
# http://igraph.sourceforge.net/igraphbook/

# Se accede a las propiedades vértice y enlace mediante
# V(network) y E(network)
# http://igraph.sourceforge.net/doc/R/iterators.html

V(network.full)[1:10]
E(network.full)[1:10]

# Y también sus propiedades

table(V(network.full)$status)
table(E(network.full)$date)


# Ya tenemos nuestro segundo workspace, mucho más completo que el anterior

save.image(file ="enron_02.Rdata")


# ========================================================================
# 3- EXPORTAR el grafo a formatos externos para visualización etc 
# ========================================================================

# Ahora si que tendremos bien el formato fecha -como cadena de caracteres

write.graph(network.full,
            file = "network02.graphml",
            format = "graphml")



# ========================================================================
# 4- METRICAS INDIVIDUALES 
# ========================================================================

# Gracias a notas en http://sigloxxi.fcie.uam.es/informatica/media/Grafos%20con%20R%20e%20Igraph.pdf
# Para obtener el camino mínimo entre un nodo i y un nodo j utilizamos la función
# get.shortest.paths y la ejecutamos mediante

get.shortest.paths(from = V(network.full)$lastName == "Pereira",
                   to = V(network.full)$lastName == "Horton",
                   graph = network.full)

nodes[c(138,11,132),]

# El diámetro de un grafo es la longitud de la mayor distancia geodésica entre nodos

diameter(network.full)

nodes[farthest.nodes(network.full),]


# Métricas individuales son se añaden directamente a tabla de propiedades de nodo
# o a la tabla original, como se desee
# La métrica individual más básica es el grado o número de contactos
# que pueden ser de entrada o de salida, y por supuesto el total

nodes$degree_total <- degree(network.full, 
                             v=V(network.full), 
                             mode = c("total"))
nodes$degree_in <- degree(network.full, 
                          v=V(network.full), 
                          mode = c("in"))
nodes$degree_out <- degree(network.full, 
                           v=V(network.full), 
                           mode = c("out"))


# Quienes son los top20 de cada uno

head(nodes[order(nodes$degree_total,
                 decreasing = TRUE),], n = 20L)

head(nodes[order(nodes$degree_in,
                 decreasing = TRUE),], n = 20L)

head(nodes[order(nodes$degree_out,
                 decreasing = TRUE),], n = 20L)


# reach is neighborhood.size
# es el alcance a n saltos (order)
# número total de gente (amigos de tus amigos) a los que llegas

nodes$reach_2_step <- 
  neighborhood.size(network.full, 
                    order = 2, # order = numeros de salto
                    nodes=V(network.full), 
                    mode = c("all"))

# Podemos observar que esta medida esta mucho mas relacionada con la conectividad real

head(nodes[order(nodes$reach_2_step,
                 decreasing = TRUE),], n = 30L)

# Hay más info sobre puesto concreto de cada nodo en
# http://www.inf.ed.ac.uk/teaching/courses/tts/assessed/roles.txt

# clustering coefficient and transitivity
# http://en.wikipedia.org/wiki/Clustering_coefficient
# "The clustering coefficient places more weight on the low degree nodes,
# while the transitivity ratio places more weight on the high degree nodes".
# Se mide la cohesion del grupo al que perteneces
# Y funciona a la inversa que el grado (hay que busar aquellos con mínima)

nodes$transitivity_ratio <- 
  transitivity(network.full, 
               vids=V(network.full), 
               type = "local")

# Ojo!! Relacion inversa
# A menor valor muy cohesionado y a mayor valor menos cohesionado
head(nodes[order(nodes$transitivity_ratio,
                 decreasing = FALSE),], n = 20L)

# Es buena idea incorporarlos a la tabla de nodos *dentro* del grafo

V(network.full)$outdegree <- degree(network.full, mode = "out")
V(network.full)$indegree <- degree(network.full, mode = "in")
V(network.full)$degree <- degree(network.full, mode = "all")
V(network.full)$reach_2_step <-   neighborhood.size(network.full, 
                                                    order = 2,
                                                    nodes=V(network.full), 
                                                    mode = c("all"))
V(network.full)$transitivity_ratio <- transitivity(network.full, 
                                                   vids=V(network.full), 
                                                   type = "local")


# ========================================================================
# 5- EXTRACCIÓN DE SUBGRAFOS
# ========================================================================

# Es facilísimo hacer subgrafos (grafos extraídos de un grafo más grande) con igraph
# para lo cual se proporcionan dos funciones básicas: 
# http://igraph.sourceforge.net/doc/R/subgraph.html


?induced.subgraph
?subgraph.edges



# Para extraer subgrafos de las personas más relevantes en el momento de la caída
# hemos extraído la información de aquí: http://es.wikipedia.org/wiki/Enron#Ca.C3.ADda_de_la_empresa

edges.full$day <- strftime(edges.full$date.R, "%Y-%m-%d")

network.august <- subgraph.edges(network.full,
                                 which(as.Date(E(network.full)$date) > "2001-02-12 00:00:00"),
                                 delete.vertices = TRUE)
summary(network.august)

write.graph(network.august,
            file = "network2001onwards.graphml",
            format = "graphml")


# Veamos los mensajes del presidente kenneth lay
# Ir a por un subgrafo 
mails.lay <- edges.full[(edges.full$sender == "kenneth.lay@enron.com" &
                           as.Date(edges.full$date.R) > "2001-07-01 00:00:00") |
                          (edges.full$receiver == "kenneth.lay@enron.com" &
                             as.Date(edges.full$date.R) > "2001-07-01 00:00:00") 
                        ,]
mails.lay <- mails.lay[order(as.Date(mails.lay$date.R)),]
nrow(mails.lay)

# Para que veáis un mensaje de un empleado (al CEO), porque se lo jugaban todo
mails.lay[rownames(mails.lay) == 3473,]
# Pero por supuesto esto dependía del puesto que se ocupaba
mails.lay[rownames(mails.lay) == 60469,]

# Estos son todos los nodos que hablan con kenneth lay
# Muestra que puede no ser tan sencillo extraer el subgrafo
# pero siempre será posible a partir de los datos originales

nodes.with.lay <- unique(c(mails.lay$sender,
                           mails.lay$receiver))

network.kenneth.lay <- graph.data.frame(mails.lay[,c("sender",
                                                     "receiver",
                                                     "type",
                                                     "date",
                                                     "subject")],
                                        directed = TRUE)

summary(network.kenneth.lay)

# y como anteriormente podemos exportar el grafo para visualizarlo

write.graph(network.kenneth.lay,
            file = "network_ken_lay.graphml",
            format = "graphml")


# Esto mismo se hace con las funciones neighborhood, pero con muchísimas más posibilidades

neighborhood.size(network.full, 
                  1, # el orden o cuántos vecinos se tienen en cuenta
                  V(network.full)$lastName == "Lay")

# Este señor era el CEO, así que le resultaba fácil llegar a toda la empresa en 2 saltos

neighborhood.size(network.full, 
                  2, # el orden o cuántos vecinos se tienen en cuenta
                  V(network.full)$lastName == "Lay")

# Podemos extraer los índices de los vecinos (salen 2 más que con el método manual:
# porque cuenta el orden 0 -el nodo central y porque puede haber algún nodo sin mensajes)

neighborhood(network.full, 
             1, # el orden o cuántos vecinos se tienen en cuenta
             V(network.full)$lastName == "Lay")

# y podemos volver a extraer el subgrafo con graph.neighborhood

network.kenneth.lay <- graph.neighborhood(network.full,
                                          1,
                                          V(network.full)$lastName == "Lay",
                                          mode = "all") # puedes también "in" o "out"

# por lo que sea summary(network.kenneth.lay) no funciona igual
# pero esto sí

print(network.kenneth.lay)

# OJO QUE AQUÍ NO HEMOS FILTRADO POR FECHAS! por eso salen muchos más enlaces


# ========================================================================
# 6- RECIPROCIDAD - DIADAS - GRAFO SOCIAL
# ========================================================================

# reciprocity function gives measure of reciprocity
# http://igraph.sourceforge.net/doc-0.5.1/R/reciprocity.html

# Para determinar la relacion social (distinta a la relacion de comunicación),
# para ello usamos la reciprocidad ( Usuario A escribe un correo electronico a Usuario B
# y Usuario B a Usuario B )
reciprocity(network.full)

# http://igraph.sourceforge.net/doc-0.5.1/R/dyad.census.html

dyad.census(network.full)

# gives back A named numeric vector with three elements:
# mut   The number of pairs with mutual connections.
# asym  The number of pairs with non-mutual connections.
# null   The number of pairs with no connection between them.

# Similar thing can be done with triplets (not done here)
# http://igraph.sourceforge.net/doc-0.5.1/R/triad.census.html

# El grafo social debiera contener pares recíprocos
# Esto es, nuestros pares dirigidos A->B requieren que también exista B->A
# Y de este modo tendremos una relación recíproca A<->B
# Convertimos el grafo *de comunicaciones* en el grafo *social*

# Para ello vamos a hacer un paso previo que es calcular el peso del enlace
# esto es, el número de comunicaciones entre dos nodos
# El número de comunicaciones *sin distinguir entre to, cc o bcc* es la medida más cruda
# del peso de la relación entre dos nodos

# Lo siguiente es un poco laborioso, quizá haya forma más elegante de hacerlo
# Extraemos los pares únicos y los ordenamos

pairs <- as.data.frame(unique(edges.full[c(1,2)]))
pairs <- pairs[order(pairs$sender, pairs$receiver),]


edges.ordered <- edges.full[order(edges.full$sender, edges.full$receiver),]

weight <- aggregate(edges.ordered[,3],
                    by = list(edges.ordered[,1],
                              edges.ordered[,2]),
                    length) 

weight <- weight[order(weight$Group.1, weight$Group.2),]

# Verifiquemos con head y tail

head(pairs, n = 10L)
head(weight, n = 10L)
tail(pairs, n = 10L)
tail(weight, n = 10L)
pairs[seq(236:248),]
weight[seq(236:248),]

# Así que ya podemos mezclar directamente pairs y weight

pairs$weight <- weight$x
head(pairs)

# Bien, por tanto hemos sustituido la tabla total de CORREOS por una tabla de ENLACES
# Vamos a comenzar a construir el grafo social, igual que antes pero con esta tabla

# Aqui tenemos 
network.sna <- graph.data.frame(pairs,
                                directed = TRUE,
                                vertices = nodes)

summary(network.sna)


reciprocity(network.sna)
dyad.census(network.sna)

# Y ahora podemos imponer requisitos para que un enlace sea "relación social" (p.ej. > 1 mens.)
# y muy importante que la relación entre los nodos SEA RECÍPROCA

# Gracias Carlos Gil Bellosta por sugerir esto
# http://stackoverflow.com/questions/13006656/igraph-nonreciprocal-edges-after-converting-to-undirected-graph-using-mutual

# http://igraph.sourceforge.net/doc/R/as.directed.html

network.social <- as.undirected(network.sna, 
                                mode = "collapse", #también estan "each" y "mutual"
                                edge.attr.comb="sum")

# La red de mr. Skilling
network.social[5]

# Lo pongo aquí únicamente como ilustración de lo poco interactivo que es dibujar grafo con igraph

plot(network.social, 
     main = "enron social network", 
     layout = layout.fruchterman.reingold(network.social),
     vertex.label = V(network.social)$lastName, 
     vertex.size = V(network.social)$degree, 
     edge.curved = T)

# Mucho más fácil con gephi

write.graph(network.social,
            file = "network_social.graphml",
            format = "graphml")



# ========================================================================
# 6- EXTRACCIÓN DE COMUNIDADES 
# ========================================================================

# CAVEAT sobre tipo de grafo (dirigido y no dirigido) y disponibilidad algoritmos
# documentación específica aquí: http://igraph.wikidot.com/community-detection-in-r
# Hay muchos algoritmos detección comunidades, es un área en continuo movimiento
# El algoritmo que implementa gephi es el de
# Vincent D Blondel, Jean-Loup Guillaume, Renaud Lambiotte, Etienne Lefebvre, 
# Fast unfolding of communities in large networks, 
# in Journal of Statistical Mechanics: Theory and Experiment 2008 (10), P1000

# Y está implementado en la siguiente función igraph
# http://igraph.sourceforge.net/doc/R/multilevel.community.html

communities <- multilevel.community(network.social)
str(communities)

comms.df <- data.frame(row.names = seq(1:149))
comms.df$Email_id <- communities$names
comms.df$community <- communities$membership

# Y ya sólo queda añadir la comunidad de cada nodo a la tabla original de nodos
str(nodes)

nodes.def <- merge(nodes, comms.df, 
                   by.x = "Email_id",
                   by.y = "Email_id")

str(nodes.def)
head(nodes.def)
plot(table(nodes.def$community))

# IMPORTANTE: GUARDAR LA COMUNIDAD COMO PROPIEDAD DE NODO EN EL GRAFO

V(network.social)$community <- communities$membership

save.image(file ="enron_06.Rdata")


# ========================================================================
# 7- VISUALIZACIÓN DE GRAFOS 
# ========================================================================

# There are currently three different functions in the igraph package which can draw graph in various ways:

# plot.igraph does simple non-interactive 2D plotting to R devices. 
# Actually it is an implementation of the plot generic function, so you can write plot(graph) 
# instead of plot.igraph(graph). As it used the standard R devices it supports every output 
# format for which R has an output device. 
# The list is quite impressing: PostScript, PDF files, XFig files, SVG files, JPG, PNG and of course 
# you can plot to the screen as well using the default devices, or the good-looking anti-aliased Cairo device. 
# See plot.igraph for some more information.

?plot.igraph

plot(network.social)
# Primera recomendación: intentar dibujar con igraph un grafo grande -y este de enron *no es enorme*
# es bastante inútil. Si tienes que hacerlo o es importante -> USA GEPHI
# Hay que hacer subgrafos.
# Extraigamos la comunidad "de los CEOs" (Lay y Skilling)

str(nodes.def)
nodes.def[nodes.def$lastName == "Lay",]
nodes.def[nodes.def$community == 8, c(2:9)]

com.ceos <- induced.subgraph(network.social,
                             V(network.social)$community == 8,
                             impl = "auto") # Ver ayuda

summary(com.ceos)

# Hago esto por comodidad para aprovechar el material de un tutorial

g <- com.ceos

# Intentemos otra vez
plot(g)


# By default (no layout), nodes are projected on random co-ordinates, with automatic labels 
# starting by 0, correlative numbers afterwards
# Sin opciones lo que tenemos son círculos con el número (el que asigna autom. igraph)
# Primero de todo: la disposición en plano es aleatoria, cambia cada vez que corremos el plot

# How to fix a layout in a plot: fix l

l <- layout.random(g)
plot(g,layout=l)

# Layout - Either a function or a numeric matrix. It specifies how the vertices will be placed on the plot.
# If it is a numeric matrix, then the matrix has to have one line for each vertex, 
# specifying its coordinates. The matrix should have at least two columns, for the x and y coordinates, 
# and it can also have third column, this will be the z coordinate for 3D plots and it is ignored for 2D plots.
# If a two column matrix is given for the 3D plotting function rglplot then the third column 
# is assumed to be 1 for each vertex.
# If layout is a function, this function will be called with the graph as the single parameter 
# to determine the actual coordinates. The function should return a matrix with two or three columns. 
# For the 2D plots the third column is ignored.

# Debemos mejorar la disposición en el plano con el layout
# y ya de paso introducimos tamaños de nodos y etiquetas

# Antes de nada, que nos salga el nombre en vez de una id arbitraria
# Userid's as node labels 

V(g)$label <- V(g)$lastName

plot(g, 
     layout=layout.fruchterman.reingold, 
     vertex.label.font = 1,
     vertex.label.cex = 0.8, 
     edge.arrow.size = 0.3,
     vertex.size = 12,
     vertex.color = "yellow")

plot(g,
     layout=layout.kamada.kawai)

# A partir de Schultz
# color the edges

par(bg = "#000000", mar = c(1,1,1,1), oma= c(1,1,1,1))

edge_col <- colorpanel(length(table(E(g)$weight)), 
                       low = "#2C7BB6", high = "#FFFFBF")  
E(g)$color <- edge_col[factor(E(g)$weight)]


plot(g, 
     main = "enron", 
     layout = layout.fruchterman.reingold(g, 
                                          params= list(niter = 1000, 
                                                       weights = E(g)$weight)),
     vertex.label = V(g)$label, 
     vertex.size = log10(as.numeric(V(g)$degree_total)),
     vertex.label.font = 1,
     vertex.label.color = "white",
     vertex.label.cex = 0.8, 
     edge.arrow.size = 0.3,
     vertex.color = "yellow",
     edge.arrow.size = E(g)$weight/150, 
     edge.width = 1.5*log10(E(g)$weight), 
     edge.curved = T, 
     edge.color = E(g)$color)

plot(g, 
     main = "enron", 
     layout = layout.kamada.kawai(g, 
                                  params= list(niter = 1000, 
                                               weights = E(g)$weight)),
     vertex.label = V(g)$label, 
     vertex.size = 12,
     vertex.label.font = 1,
     vertex.label.color = "black",
     vertex.label.cex = 0.8, 
     edge.arrow.size = 0.3,
     vertex.color = "yellow",
     edge.arrow.size = E(g)$weight/150, 
     edge.width = 1.5*log10(E(g)$weight), 
     edge.curved = T, 
     edge.color = E(g)$color)

# Other layouts

par(bg = "#FFFFFF", mar = c(1,1,1,1), oma= c(1,1,1,1))

plot(g, 
     main = "enron", 
     layout = layout.reingold.tilford,
     vertex.label = V(g)$label)

# Reingold.tilford produce un grafo jerárquico
# Aquí no tiene interés, pero sí es muy interesante para dibujar cascadas/flujos


plot(g, 
     main = "enron", 
     layout = layout.lgl,
     vertex.label = V(g)$label)

# lgl se supone que es para grafos muy grandes, yo no le veo diferencia aqui

# layout.circle produce gráficos de cuerdas o chord plots
# fijamos el layout

l <- layout.circle(g)

# usamos funciones de color de enlaces de antes
par(bg = "#000000", mar = c(1,1,1,1), oma= c(1,1,1,1))

edge_col <- colorpanel(length(table(E(g)$weight)), 
                       low = "#2C7BB6", high = "#FFFFBF")  
E(g)$color <- edge_col[factor(E(g)$weight)]

plot(g, 
     layout=l,
     vertex.label = V(g)$label,
     vertex.size=1,
     vertex.label.color = "white",
     edge.width = 1.5*log10(E(g)$weight), 
     edge.curved = F, 
     edge.color = E(g)$color)

# layout sphere
# rglplot is an experimental function to draw graphs in 3D using OpenGL. 

rglplot(g, layout=layout.sphere)


# tkplot does interactive 2D plotting using the tcltk package. 
# It can only handle graphs of moderate size, 
# a thousend vertices is probably already too many. 
# Some parameters of the plotted graph can be changed interactively 
# after issuing the tkplot command: 
# the position, color and size of the vertices and the color and width 
# of the edges. See tkplot for details.

tkplot(g)

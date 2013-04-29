# =====================================================================
# 
# Fuente: http://www.datanalytics.com/blog/2013/04/08/mapa-de-los-terremotos-en-la-peninsula-iberica/
install.packages("ggmap")
library(ggmap)

url <- "http://comcat.cr.usgs.gov/earthquakes/feed/search.php?maxEventLatitude=45&minEventLatitude=35&minEventLongitude=-10&maxEventLongitude=5&minEventTime=953683200000&maxEventTime=1364688000000&minEventMagnitude=-1.0&maxEventMagnitude=10&minEventDepth=0.0&maxEventDepth=800.0&format=csv"
terremotos <- read.csv(url)

# obtengo un mapa
pen.iber <- get_map( location = c(-9.5, 36, 3.5, 44),
                     color = "color",
                     maptype = "roadmap")

# le añado puntos
ggmap(pen.iber) +
  geom_point(aes(x = Longitude, y = Latitude,
                 size = Magnitude),
             data = terremotos, colour = 'red',
             alpha = 0.2)

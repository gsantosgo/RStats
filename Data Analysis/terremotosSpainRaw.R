# Terremotos en Peninsula Iberica 
getwd()
WORKING_DIR <- "~/R/RStats/Data Analysis/"
DATASET_FILE <- "./data/terremotosSpain.csv"
DATASET_FILERAW <- "./data/terremotosSpain.rda"
url <- "http://comcat.cr.usgs.gov/earthquakes/feed/search.php?maxEventLatitude=45&minEventLatitude=35&minEventLongitude=-10&maxEventLongitude=5&minEventTime=953683200000&maxEventTime=1364688000000&minEventMagnitude=-1.0&maxEventMagnitude=10&minEventDepth=0.0&maxEventDepth=800.0&format=csv"
download.file(url,destfile=DATASET_FILE)
dateDownloaded <- date()
dateDownloaded
terremotosSpainRaw <- read.csv(DATASET_FILE)
save(terremotosSpainRaw,dateDownloaded,file=DATASET_FILERAW)

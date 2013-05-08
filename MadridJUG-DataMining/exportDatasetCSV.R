# Export dataset 
getwd()
WORKING_DIR <- "~/R/RStats/MadridJUG-DataMining/" 
#WORKING_DIR <- "C:/Users/gsantos/R/RStats/MadridJUG-DataMining"
DATASET_DIR <- "./data/"
setwd(WORKING_DIR)
getwd()

# Predicting House Price  dataset
size <- c(80,90, 100, 110, 140, 140, 150, 160, 180, 200, 240, 250, 270, 320, 350)
price <- c(70, 83, 74, 93, 89, 58, 85, 114, 95, 100, 138, 111, 124, 161, 172)
housePrices <- data.frame(cbind(size, price))
write.csv(housePrices, file=paste0(DATASET_DIR,"housePrices.csv"), row.names=FALSE)

# Samsung predictive dataset 
#load(paste0(DATASET_DIR,"samsungData.rda")) 
#write.csv(samsungData, file=paste0(DATASET_DIR,"samsungData.csv"), row.names=FALSE)

# spam dataset
library(ElemStatLearn)
write.csv(spam, file=paste0(DATASET_DIR,"spambase.csv"), row.names=FALSE)

# zip.train dataset
zip.train <- as.data.frame(zip.train)
write.csv(zip.train, file=paste0(DATASET_DIR,"zip.train.csv"), row.names=FALSE)

# zip.test dataset 
zip.test <- as.data.frame(zip.test)
write.csv(zip.test, file=paste0(DATASET_DIR,"zip.test.csv"), row.names=FALSE)

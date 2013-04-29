# ================================================================
# MADRID JAVA USER GROUP: DATA MINING  
# 
# May 6, 2013
# 
# Jose María Gomez Hidalgo (@jmgomez) 
# Guillermo Santos García (@gsantosgo)
# 
# CLASSIFICATION PROBLEM
# Handwritten Digit Recognition. 
#
# The data from this example come from the handwritten ZIP codes on
# envelopes from U.S. postal mail. Each image is a segment from a five digit
# ZIP code, isolating a single digit. The images are 16×16 eight-bit grayscale
# maps, with each pixel ranging in intensity from 0 to 255.
# 
# 
# This script is licensed under the GPLv2 license 
# http://www.gnu.org/licenses/gpl.html
# ----------------------------------------------------------------
getwd()
WORKING_DIR <- "~/R/MadridJUG - DataMining/" 
setwd(WORKING_DIR)
getwd()


### Load Libraries 
#install.packages(c("ElemStatLearn","foreign","tree","rpart","maptree")) 
library(ElemStatLearn)
library(foreign)
library(tree)
library(rpart)
library(maptree)

# Dataset ZipCode (Dimensions)
# http://www-stat.stanford.edu/~tibs/ElemStatLearn/datasets/zip.info
 
DATASET.train <- as.data.frame(zip.train)
DATASET.test <- as.data.frame(zip.test)
head(DATASET.train)
dim(DATASET.train)
nrow(DATASET.train)
ncol(DATASET.train)
colnames(DATASET.train)
summary(DATASET.train)
sapply(DATASET.train[1,], class)

# Label, Class Label 
class(DATASET.train[,1])
levels(DATASET.train[,1])
summary(DATASET.train[,1])

# DataSet Train. Transform Label as Factor (Categorical)
DATASET.train[,1] <- as.factor(DATASET.train[,1])
class(DATASET.train[,1])
levels(DATASET.train[,1])
summary(DATASET.train[,1])

# DataSet Test. Transform Label as Factor (Categorical)
DATASET.test[,1] <- as.factor(DATASET.test[,1])
class(DATASET.test[,1])
levels(DATASET.test[,1])
summary(DATASET.test[,1])

# DataSet Train. Change Column Name 
colnames(DATASET.train) <- c("Y",paste("X.",1:256,sep=""))
# DataSet Test. Change Column Name
colnames(DATASET.test) <- c("Y",paste("X.",1:256,sep=""))

head(DATASET.train)
head(DATASET.test)
# ================================================================
# Exploratory Analysis 
# ----------------------------------------------------------------

### ==========================================
### Train
### ------------------------------------------
table(DATASET.train$class)

### ==========================================
### Test 
### ------------------------------------------
table(DATASET.test$class)


### =========================================
### Cart Model
### -----------------------------------------
pc <- proc.time()
model.rpart <- rpart(DATASET.train$Y ~ . ,method="class", data=DATASET.train)
proc.time() - pc
plotcp(model.rpart) # visualize cross-validation results
summary(model.rpart) # detailed summary of splits
printcp(model.rpart) # display the results
plot(model.rpart, uniform=TRUE, main="Classification Tree for Handwritten Digit Recognition")
text(model.rpart, all=TRUE ,cex=.75)
#text(model.rpart, all=TRUE,cex=0.75, splits=TRUE, use.n=TRUE, xpd=TRUE)


draw.tree(model.rpart, cex=0.5, nodeinfo=TRUE, col=gray(0:8 / 8))
prediction <- predict(model.rpart, newdata=DATASET.test, type='class')

# Confusion Matrix 
table("Actual Class"=DATASET.test$Y, "Predicted Class"=prediction)
error.rate <- sum(DATASET.test$Y != predict(model.rpart, newdata=DATASET.test, type='class')) / nrow(DATASET.test)
print (paste0("Handwritten Digit Recognition Cart Model: ", 1 - error.rate))


# ----------------------------------------------------------------
# WEKA 
# Writes data into Weka Attribute-Relation File Format (ARFF) files.
write.arff(DATASET.train, "./data/zip.train.arff")
write.arff(DATASET.test, "./data/zip.test.arff")
# ----------------------------------------------------------------
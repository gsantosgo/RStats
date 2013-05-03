# ================================================================
# MADRID JAVA USER GROUP: DATA MINING  
# 
# May 6, 2013
# 
# Jose Maria Gomez Hidalgo (@jmgomez) 
# Guillermo Santos Garcia (@gsantosgo)
# 
# CLASSIFICATION PROBLEM
# Handwritten Digit Recognition. 
#
# The data from this example come from the handwritten ZIP codes on
# envelopes from U.S. postal mail. Each image is a segment from a five digit
# ZIP code, isolating a single digit. The images are 16x16 eight-bit grayscale
# maps, with each pixel ranging in intensity from 0 to 255.
# 
# This script is licensed under the GPLv2 license 
# http://www.gnu.org/licenses/gpl.html
# ----------------------------------------------------------------
getwd()
WORKING_DIR <- "~/R/RStats/MadridJUG-DataMining/" 
#WORKING_DIR <- "C:/Users/gsantos/R/RStats/MadridJUG-DataMining"
DATASET_DIR <- "./data/"
FIGURES_DIR <- "./figures/"
COLORS <- c('white','black')
setwd(WORKING_DIR)
getwd()


### Load Libraries 
#install.packages(c("RColorBrewer","ElemStatLearn","foreign","tree""RWeka","rpart","maptree","e1071")) 
library(RColorBrewer)
library(ElemStatLearn)
library(foreign)
library(tree)
library(RWeka)
library(rpart)
library(maptree)
library(e1071)

#Set color 
CUSTOM_COLORS <- colorRampPalette(colors=COLORS)
CUSTOM_COLORS_PLOT <- colorRampPalette(brewer.pal(10,"Set3"))

# Dataset ZipCode (Dimensions)
# http://www-stat.stanford.edu/~tibs/ElemStatLearn/datasets/zip.info
 
DATASET.train <- as.data.frame(zip.train)
DATASET.test <- as.data.frame(zip.test)

# Train dataset 
head(DATASET.train)
dim(DATASET.train)
nrow(DATASET.train)
ncol(DATASET.train)
colnames(DATASET.train)
summary(DATASET.train)
sapply(DATASET.train[1,], class)

# Test data set 
head(DATASET.test)
dim(DATASET.test)
nrow(DATASET.test)
ncol(DATASET.test)
colnames(DATASET.test)
summary(DATASET.test)
sapply(DATASET.test[1,], class)

# Missing values
sum(is.na(DATASET.train))

# Missing values
sum(is.na(DATASET.test))

# Label, Class Label 
class(DATASET.train[,1])
levels(DATASET.train[,1])
summary(DATASET.train[,1])

# DataSet Train. Transform Label as Factor (Categorical)
DATASET.train[,1] <- as.factor(DATASET.train[,1]) # As Category
colnames(DATASET.train) <- c("Y",paste("X.",1:256,sep=""))
class(DATASET.train[,1])
levels(DATASET.train[,1])
sapply(DATASET.train[1,], class)

# DataSet Test. Transform Label as Factor (Categorical)
DATASET.test[,1] <- as.factor(DATASET.test[,1]) # As Category
colnames(DATASET.test) <- c("Y",paste("X.",1:256,sep=""))
class(DATASET.test[,1])
levels(DATASET.test[,1])
sapply(DATASET.test[1,], class)

head(DATASET.train)
head(DATASET.test)

# ----------------------------------------------------------------
# WEKA 
# Writes data into Weka Attribute-Relation File Format (ARFF) files.
#write.arff(DATASET.train, paste0(DATASET_DIR,"zip.train.arff"))
#write.arff(DATASET.test, paste0(DATASET_DIR,"zip.test.arff"))
# ----------------------------------------------------------------


# http://www.r-bloggers.com/the-essence-of-a-handwritten-digit/
## Plot the average image of each digit
par(mfrow=c(4,3),pty='s',mar=c(1,1,1,1),xaxt='n',yaxt='n')
images_digits_0_9 <- array(dim=c(10,16*16))
for(digit in 0:9)
{
  print(digit)
  images_digits_0_9[digit+1,] <- apply(DATASET.train[DATASET.train[,1]==digit,-1],2,sum)
  images_digits_0_9[digit+1,] <- images_digits_0_9[digit+1,]/max(images_digits_0_9[digit+1,])*255
  z <- array(images_digits_0_9[digit+1,], dim=c(16,16))
  z <- z[,16:1] ##right side up
  image(1:16,1:16,z,main=digit,col=CUSTOM_COLORS(256))
}

#pdf(file=paste0(FIGURES_DIR,"trainDigit.pdf"),)
#par(mfrow=c(4,4),pty='s',mar=c(3,3,3,3),xaxt='n',yaxt='n')
#for(i in 1:nrow(DATASET.train))
#{
#z <- array(as.vector(as.matrix(DATASET.train[i,-1])),dim=c(16,16))
#z <- z[,16:1] ##right side up
#image(1:16,1:16,z,main=DATASET.train[i,1],col=CUSTOM_COLORS(256))
#print(i)
#}

### ==========================================
### Training DataSet 
### ------------------------------------------

resTable <- table(DATASET.train$Y)
par(mfrow=c(1,1))
par(mar=c(5, 4, 4, 2) + 0.1) # increase y-axis margin.
plot <- plot(DATASET.train$Y,col=CUSTOM_COLORS_PLOT(10), main="Total Number of Digits (Training Set)", ylim=c(0,1500), ylab="Examples Number")
text(x=plot,y=resTable+50, labels=resTable, cex=0.75)
par(mfrow=c(1,1))
percentage <- round(resTable/sum(resTable)*100)
labels <- paste0 (row.names(resTable), " (", percentage ,"%) ") # add percents to labels
pie(resTable, labels=labels,col=CUSTOM_COLORS_PLOT(10),main="Total Number of Digits (Training Set)")

### ==========================================
### Testing DataSet 
### ------------------------------------------
resTable <- table(DATASET.test$Y)
par(mfrow=c(1,1))
par(mar=c(5, 4, 4, 2) + 0.1) # increase y-axis margin.
plot <- plot(DATASET.test$Y,col=CUSTOM_COLORS_PLOT(10), main="Total Number of Digits (Testing Set)", ylim=c(0,400), ylab="Examples Number")
text(x=plot,y=resTable+20, labels=resTable, cex=0.75)
par(mfrow=c(1,1))
percentage <- round(resTable/sum(resTable)*100)
labels <- paste0 (row.names(resTable), " (", percentage ,"%) ") # add percents to labels
pie(resTable, labels=labels,col=CUSTOM_COLORS_PLOT(10),main="Total Number of Digits (Testing Set)")


### =========================================
### RPart 
### -----------------------------------------
pc <- proc.time()
model.rpart <- rpart(DATASET.train$Y ~ . ,method="class", data=DATASET.train)
proc.time() - pc
printcp(model.rpart)

plot(model.rpart, uniform=TRUE, main="Classification (RPART). Tree of Handwritten Digit Recognition ")
text(model.rpart, all=TRUE ,cex=.75)
draw.tree(model.rpart, cex=0.5, nodeinfo=TRUE, col=gray(0:8 / 8))
# Confusion Matrix 
prediction.rpart <- predict(model.rpart, newdata=DATASET.test, type='class')
table("Actual Class"=DATASET.test$Y, "Predicted Class"=prediction.rpart)
error.rate.rpart <- sum(DATASET.test$Y != prediction.rpart) / nrow(DATASET.test)
print (paste0("Accuary (Precision): ", 1 - error.rate.rpart))

### =========================================
### k-Nearest Neighbors (kNN)
### -----------------------------------------
# Weka
pc <- proc.time()
model.knn <- IBk(DATASET.train$Y ~ . , data=DATASET.train)
proc.time() - pc
summary(model.knn)

prediction.knn <- predict(model.knn, newdata=DATASET.test, type='class')
table("Actual Class"=DATASET.test$Y, "Predicted Class"=prediction.knn)
error.rate.knn <- sum(DATASET.test$Y != prediction.knn) / nrow(DATASET.test)
print (paste0("Accuary (Precision): ", 1 - error.rate.knn))

### =========================================
### Naive Bayes 
### -----------------------------------------
pc <- proc.time()
model.naiveBayes <- naiveBayes(DATASET.train$Y ~ . , data=DATASET.train)
proc.time() - pc
summary(model.naiveBayes)

# Confusion Matrix 
prediction.naiveBayes <- predict(model.naiveBayes, newdata=DATASET.test, type='class')
table("Actual Class"=DATASET.test$Y, "Predicted Class"=prediction.naiveBayes)
error.rate.naiveBayes <- sum(DATASET.test$Y != prediction.naiveBayes) / nrow(DATASET.test)
print (paste0("Accuary (Precision): ", 1 - error.rate.naiveBayes))

### =========================================
### Support Vector Machine (SVM)
### -----------------------------------------
pc <- proc.time()
model.svm <- svm(DATASET.train$Y ~ . ,method="class", data=DATASET.train)
proc.time() - pc
summary(model.svm)
#plot(model.svm, DATASET.train, DATASET.train$Y ~z )

### Confusion Matrix (SVM)
```{r dependson="model_svm"}
prediction.svm <- predict(model.svm, newdata=DATASET.test, type='class')
table("Actual Class"=DATASET.test$Y, "Predicted Class"=prediction.svm)
error.rate.svm <- sum(DATASET.test$Y != prediction.svm) / nrow(DATASET.test)
print (paste0("Accuary (Precision): ", 1 - error.rate.svm))
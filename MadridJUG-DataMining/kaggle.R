
# Machine Learning Introduction 
# https://www.kaggle.com/c/digit-recognizer

#OJO!! Library VER FNN (Fast)
#https://www.kaggle.com/wiki/Tutorials
#https://www.kaggle.com/c/digit-recognizer/details/tutorial
#https://www.kaggle.com/c/digit-recognizer
#http://www.slideshare.net/wekacontent/wekathe-explorer

# makes the KNN submission
library(FNN)

train <- read.csv("../data/train.csv", header=TRUE)
test <- read.csv("../data/test.csv", header=TRUE)

labels <- train[,1]
train <- train[,-1]
results <- (0:9)[knn(train, test, labels, k = 10, algorithm="cover_tree")]
write(results, file="knn_benchmark.csv", ncolumns=1) 


# makes the random forest submission

library(randomForest)
train <- read.csv("../data/train.csv", header=TRUE)
test <- read.csv("../data/test.csv", header=TRUE)
labels <- as.factor(train[,1])
train <- train[,-1]
rf <- randomForest(train, labels, xtest=test, ntree=1000)
predictions <- levels(labels)[rf$test$predicted]
write(predictions, file="rf_benchmark.csv", ncolumns=1) 
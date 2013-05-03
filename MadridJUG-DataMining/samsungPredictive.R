######################################################
# 
# Autor. Guillermo Santos 
# Tematica. Samsung Predictive (coursera)
#         
# Fecha.    10.03.2013 
# ----------------------------------------------------

getwd()
WORKING_DIR <- "~/R/RStats/Data Analysis/"
setwd(WORKING_DIR)

## ==================================
## Libros
## R in nutshell
## ----------------------------------
## ==================================
## Enlaces 
## http://plantecology.syr.edu/fridley/bio793/cart.html
## ----------------------------------


### Load Libraries 
library(tree) 
library(rpart)

# Set your working directory to the full path of the R Social Network Analysis folder on your machine
setwd(WORKING_DIR)
getwd()

## 
#download.file("https://spark-public.s3.amazonaws.com/dataanalysis/samsungData.rda", destfile="./data/samsungData.rda")

# Load data
load("./data/samsungData.rda")

# Repeated Columns 
sum(names(samsungData) == "fBodyAccJerk-bandsEnergy()-1,16")
# Columnas incorrectas sintacticamente 
samsungData <- data.frame(samsungData)
#fBodyAccJerk-bandsEnergy()-1,16
#fBodyAccJerk-bandsEnergy()-1,16.1
#fBodyAccJerk-bandsEnergy()-1,16.2 

# 7352
dim(samsungData)
nrow(samsungData)
summary(samsungData)
sapply(samsungData[1,], class)
numericColumn <- sapply(samsungData[1,], class)
sum(numericColumn == "numeric")
names(samsungData)

# Subject number 
length(unique(samsungData$subject))

# samsungData$subject. Subject was performing the tasks
# samsungData$activity. Activity was performing 

### Find out about missing values
sum(is.na(samsungData))
## Columns 
apply(samsungData, 2, function(x) length(which(is.na(x))))

summary(samsungData$subject)

# laying, sitting, standing, walk, walkdown, walkup 
factor(samsungData$activity)
# Possible Transformation 
samsungData$activity <- as.factor(samsungData$activity)

# Field names with contains "mean" 
names(samsungData)[grepl(".*mean.*", names(samsungData))] 

#tBodyAcc.mean...X, tBodyAcc.mean...Y, tBodyAcc.mean...Z

tableResults <- table(samsungData$subject, samsungData$activity)
#aggdata <-aggregate(samsungData, by=list(samsungData$subject, samsungData$activity),
#                    FUN=mean, na.rm=TRUE)
#print(aggdata)


# Remove Column Subject 
#colSubject <- which(names(samsungData) == "subject")
#samsungDataTree <- samsungData[,-colSubject]

table(samsungData$activity)


### ==========================================
### Train 
### ------------------------------------------
samsungData.training <- samsungData[samsungData$subject == c(1, 3, 5, 6), ]
# Percentage
(nrow(samsungData.training) / nrow(samsungData)) * 100
table(samsungData.training$activity)

### ==========================================
### Test
### ------------------------------------------
# 371 observaciones
samsungData.test <- samsungData[samsungData$subject == c(27, 28, 29, 30), ]
# Percentage
(nrow(samsungData.test) / nrow(samsungData)) * 100
table(samsungData.test$activity)

### =========================================
### Tree Model 
### -----------------------------------------
set.seed(13)
modelSamsung.tree <- tree(activity ~ . - subject, data=samsungData.training)
plot(modelSamsung.tree)
text(modelSamsung.tree)
summary(modelSamsung.tree)

#Predict using the decision tree
#If type = "class":
  #(for a classification tree) a factor of classifications based on the responses. 
prediction <- predict(modelSamsung.tree, newdata=samsungData.test, type='class')
table("Actual Class"=samsungData.test$activity, "Predicted Class"=prediction)
error.rate <- sum(samsungData.test$activity != predict(modelSamsung.tree, newdata=samsungData.test, type='class')) / nrow(samsungData.test)
error.rate
print (paste0(" TreeModel: ", 1- error.rate))



# http://www.findnwrite.com/musings/visualizing-confusion-matrix-in-r/
#as.data.frame(table(samsungData$activity))
#trainActual <- as.data.frame(table(samsungData.training$activity))
#names(trainActual) <- c("Actividad","Activity Freq")
#testActual <- as.data.frame(table(samsungData.test$activity))

#build confusion matrix 
#confusion <- as.data.frame(table(samsungData.test$activity, prediction))
#names(confusion) <- c("Actividad","Prediction", "Freq")
#confusion <- merge(confusion, trainActual, by=c("Actividad"))
#confusion$Percent <- confusion$Freq/confusion$"Activity Freq"*100

# Predictive Analytics: Decision Tree and Ensembles
#http://horicky.blogspot.com.es/2012/06/predictive-analytics-decision-tree-and.html
### -----------------------------------------
### Fin Tree Model 
### -----------------------------------------


### =========================================
### Cart Model 
### -----------------------------------------
#### 
# http://www.statmethods.net/advstats/cart.html
# grow tree
set.seed(14)
modelSamsung.rpart <- rpart(activity ~ . - subject,method="class", data=samsungData.training)
plotcp(modelSamsung.rpart) # visualize cross-validation results
summary(modelSamsung.rpart) # detailed summary of splits
printcp(modelSamsung.rpart) # display the results
plot(modelSamsung.rpart, uniform=TRUE)
text(modelSamsung.rpart, all=TRUE,cex=0.75, splits=TRUE, use.n=TRUE, xpd=TRUE)

### =====================================================================
### Plotting Classifications Erros 
### ---------------------------------------------------------------------
#install.packages("maptree")
library(maptree)
draw.tree(modelSamsung.rpart, cex=0.5, nodeinfo=TRUE, col=gray(0:8 / 8))
prediction <- predict(modelSamsung.rpart, newdata=samsungData.test, type='class')

table("Actual Class"=samsungData.test$activity, "Predicted Class"=prediction)
error.rate <- sum(samsungData.test$activity != predict(modelSamsung.rpart, newdata=samsungData.test, type='class')) / nrow(samsungData.test)
print (paste0("Samsung Cart Model: ", 1- error.rate))
### -----------------------------------------
### Fin Cart Model 
### -----------------------------------------

### =========================================
### Bag Model
### -----------------------------------------
### =====================================================================
###  R in Nutshell
#install.packages("adabag")
library(adabag)


modelSamsung.bag <- bagging(formula=activity ~ .-subject, data=samsungData.training)
prediction <- predict(modelSamsung.bag, newdata=samsungData.test, type='class')
print(paste0(" Samsung Bag Model : ", 1- prediction$error))
print(prediction$confusion)

#install.packages("ipred")
library(ipred)
set.seed(15)
modelSamsung.bagging <- bagging(formula=activity ~ .-subject, data=samsungData.training,coob=TRUE)
prediction <- predict(modelSamsung.bagging, newdata=samsungData.test, type='class')
table("Actual Class"=samsungData.test$activity, "Predicted Class"=prediction)
error.rate <- sum(samsungData.test$activity != predict(modelSamsung.bagging, newdata=samsungData.test, type='class')) / nrow(samsungData.test)
print (paste0("Samsung Bagging Model: ", 1- error.rate))
### -----------------------------------------
### Fin Bag Model
### -----------------------------------------
      

### =========================================
### Random Forest 
### -----------------------------------------
#install.packages("randomForest")
library(randomForest)
set.seed(16)
modelSamsung.rf <- randomForest(formula=activity ~ . -subject, data=samsungData.training)    
prediction <- predict(modelSamsung.rf, newdata=samsungData.test, type='class')
table("Actual Class"=samsungData.test$activity, "Predicted Class"=prediction)
error.rate <- sum(samsungData.test$activity != predict(modelSamsung.rf, 
            newdata=samsungData.test, type='class')) / nrow(samsungData.test)
print (paste0("Samsung RandomForest Model: ", 1-error.rate))

### -----------------------------------------
### Fin Random Forest 
### -----------------------------------------



### =========================================
### SVM
### -----------------------------------------
library(e1071)
set.seed(17)
modelSamsung.svm <- randomForest(formula=activity ~ . - subject, data=samsungData.training)
prediction <- predict(modelSamsung.svm, newdata=samsungData.test, type='class')
table("Actual Class"=samsungData.test$activity, "Predicted Class"=prediction)
error.rate <- sum(samsungData.test$activity != predict(modelSamsung.svm, 
                newdata=samsungData.test, type='class')) / nrow(samsungData.test)
print (paste0("Samsung SVM Model: ", 1-error.rate))

plot (modelSamsung.svm, samsungData)

### -----------------------------------------
### Fin SVM 
### -----------------------------------------



## Importante. Solo BINARY RESPONSE 
### Boosting
#install.packages("ada")
#library("ada")
#modelSamsung.ada <- ada(formula=activity ~ . -subject, data=samsungData.training)






### -----------------------------------------
### Fin Random Forest 
### -----------------------------------------
fBodyAcc.mean...X
fBodyAcc.mean...Y
fBodyAcc.mean...Z

tBodyAcc.mean...X
tBodyAcc.mean...Y
tBodyAcc.mean...Z


samsungData.sitting <- samsungData[(samsungData$activity == 'sitting' & samsungData$subject == 21) ,]
plot (samsungData.sitting$tBodyAcc.mean...X, samsungData.sitting$fBodyAcc.mean...X) 
lines (samsungData.sitting$tBodyAcc.mean...X, samsungData.sitting$fBodyAcc.mean...X)


sqrt((samsungData.sitting$tBodyAcc.mean...X^2)+(samsungData.sitting$tBodyAcc.mean...Y^2)+(samsungData.sitting$tBodyAcc.mean...Z^2))

labelLegend <- c("X Axis", "Y Axis", "Z Axis")
colLegend <- c("black", "red", "blue")
id <- 1



FROM <- 0
TO <- 10000
BY <- 5000
YLIM <- c(-1.0,1.0)
LWD <- 2 
TOPRIGHT <- "topright"
INSET <- c(-0.2,0)
activities <- c("laying", "sitting", "standing", "walk", "walkdown", "walkup")
nActivities <- length(activities)
colorsActivities <- rainbow(nActivities)
position <- c("X","Y", "Z")
nPosition <- length(position)
colors <- rainbow(nPosition)


png(file="fig1.AccelerationX.png", units = "px", width=600, height=250)
#####################################################################
### samsungDataActivites$tBodyAcc.mean...X
### -----------------------------------------------------------------
par(mfrow = c(1, 6))
par(cex = 0.6)
par(mar = c(0, 0, 1, 0), oma = c(4, 4, 0.5, 0.5))
par(tcl = -0.25)
par(mgp = c(2, 0.6, 0))

for(i in 1:nActivities) {
  samsungDataActivites <- samsungData[(samsungData$activity == activities[i]) ,]  
  
  plot(seq(from=FROM, to=TO, length.out=length(samsungDataActivites$tBodyAcc.mean...X)),
           samsungDataActivites$tBodyAcc.mean...X, type="l", col=colorsActivities[i],
           ylim=YLIM, axes = FALSE) 
  
  mtext(activities[i], side = 3, line = -1, adj = 0.1, cex = 0.6)
  axis(1, at = seq(from=FROM, to=TO, by=BY))
  if (i == 1) {
    axis(2, at = seq(-1.0,1.0, 0.5))
  }
  
  box(col = "black")    
}

mtext("Time (s)", side = 1, outer = TRUE, cex = 0.7, line = 1.5)
mtext("Fig 1. Acceleration X", side = 1, outer = TRUE, cex = 0.7, line = 3.)
mtext("Acceleration", side = 2, outer = TRUE, cex = 0.7, line = 2.2)
dev.off()

#####################################################################
### samsungDataActivites$tBodyAcc.mean...Y
### -----------------------------------------------------------------
par(mfrow = c(1, 6))
par(cex = 0.6)
par(mar = c(0, 0, 1, 0), oma = c(4, 4, 0.5, 0.5))
par(tcl = -0.25)
par(mgp = c(2, 0.6, 0))

for(i in 1:nActivities) {
  samsungDataActivites <- samsungData[(samsungData$activity == activities[i]) ,]  
  
  plot(seq(from=FROM, to=TO, length.out=length(samsungDataActivites$tBodyAcc.mean...Y)),
       samsungDataActivites$tBodyAcc.mean...Y, type="l", col=colorsActivities[i],
       ylim=YLIM, axes = FALSE) 
  
  mtext(activities[i], side = 3, line = -1, adj = 0.1, cex = 0.6)
  axis(1, at = seq(from=FROM, to=TO, by=BY))
  if (i == 1) {
    axis(2, at = seq(-1.0,1.0, 0.5))
  }
  
  box(col = "black")    
}

mtext("Time (s)", side = 1, outer = TRUE, cex = 0.7, line = 1.5)
mtext("Fig 2. Acceleration Y", side = 1, outer = TRUE, cex = 0.7, line = 3.)
mtext("Acceleration", side = 2, outer = TRUE, cex = 0.7, line = 2.2)
# ---------------------------------------------------

#####################################################################
### samsungDataActivites$tBodyAcc.mean...Z
### -----------------------------------------------------------------
par(mfrow = c(1, 6))
par(cex = 0.6)
par(mar = c(0, 0, 1, 0), oma = c(4, 4, 0.5, 0.5))
par(tcl = -0.25)
par(mgp = c(2, 0.6, 0))

for(i in 1:nActivities) {
  samsungDataActivites <- samsungData[(samsungData$activity == activities[i]) ,]  
  
  plot(seq(from=FROM, to=TO, length.out=length(samsungDataActivites$tBodyAcc.mean...Z)),
       samsungDataActivites$tBodyAcc.mean...Z, type="l", col=colorsActivities[i],
       ylim=YLIM, axes = FALSE) 
  
  mtext(activities[i], side = 3, line = -1, adj = 0.1, cex = 0.6)
  axis(1, at = seq(from=FROM, to=TO, by=BY))
  if (i == 1) {
    axis(2, at = seq(-1.0,1.0, 0.5))
  }
  
  box(col = "black")    
}

mtext("Time (s)", side = 1, outer = TRUE, cex = 0.7, line = 1.5)
mtext("Fig 3. Acceleration Z", side = 1, outer = TRUE, cex = 0.7, line = 3.)
mtext("Acceleration", side = 2, outer = TRUE, cex = 0.7, line = 2.2)
# ---------------------------------------------------

par(mfrow=c(3,1))
par(mar=c(5.1, 4.1, 4.1, 8.1), xpd=TRUE)
FROM <- 0
TO <- 2.5
YLIM <- c(-1.0,1.0)
LWD <- 2 
TOPRIGHT <- "topright"
INSET <- c(-0.125,0)
activities <- c("laying", "sitting", "standing", "walk", "walkdown", "walkup")
nActivities <- length(activities)
colors <- rainbow(nActivities)

#####################################################################
### samsungDataActivites$tBodyAcc.mean...X
### -----------------------------------------------------------------

for(i in 1:nActivities) {
  samsungDataActivites <- samsungData[(samsungData$activity == activities[i]) ,]  
  
  if ( i == 1 ) { 
    plot(seq(from=FROM, to=TO, length.out=length(samsungDataActivites$tBodyAcc.mean...X)),
         samsungDataActivites$tBodyAcc.mean...X, type="n", 
         ylim=YLIM, 
         xlab="Time (s)", ylab="Acceleration Mean X") 
  }
  
  lines(seq(from=FROM, to=TO, length.out=length(samsungDataActivites$tBodyAcc.mean...X)), 
        samsungDataActivites$tBodyAcc.mean...X, lwd=LWD, col=colors[i])
  
}

# add a title and subtitle
title("Acceleration Mean X", "")

# add a legend

legend(TOPRIGHT, inset=INSET, activities, cex=0.8, col=colors,lty=1, title="Activities", lwd=2)
# ---------------------------------------------------


#####################################################################
### samsungDataActivites$tBodyAcc.mean...Y
### -----------------------------------------------------------------
for(i in 1:nActivities) {
  samsungDataActivites <- samsungData[(samsungData$activity == activities[i]) ,]  
  
  if ( i == 1 ) {   
    plot(seq(from=FROM, to=TO, length.out=length(samsungDataActivites$tBodyAcc.mean...Y)),
         samsungDataActivites$tBodyAcc.mean...Y, type="n", 
         ylim=YLIM, 
         xlab="Time (s)", ylab="Acceleration Mean Y") 
  }
  lines(seq(from=FROM, to=TO, length.out=length(samsungDataActivites$tBodyAcc.mean...Y)), 
        samsungDataActivites$tBodyAcc.mean...Y, lwd=LWD, col=colors[i])
  
}

# add a title and subtitle
title("Acceleration Mean Y", "")

# add a legend
legend(TOPRIGHT, inset=INSET, activities, cex=0.8, col=colors,lty=1, title="Activities", lwd=2)
# ---------------------------------------------------

#####################################################################
### samsungDataActivites$tBodyAcc.mean...Z
### -----------------------------------------------------------------

for(i in 1:nActivities) {
  samsungDataActivites <- samsungData[(samsungData$activity == activities[i]) ,]  
  
  if ( i == 1 ) { 
    
    plot(seq(from=FROM, to=TO, length.out=length(samsungDataActivites$tBodyAcc.mean...Z)),
         samsungDataActivites$tBodyAcc.mean...Z, type="n", 
         ylim=YLIM, 
         xlab="Time (s)", ylab="Acceleration Mean Z") 
  }
  
  lines(seq(from=FROM, to=TO, length.out=length(samsungDataActivites$tBodyAcc.mean...Z)), 
        samsungDataActivites$tBodyAcc.mean...Z, lwd=LWD, col=colors[i])
  
}

# add a title and subtitle
title("Acceleration Mean Z", "")

# add a legend
legend(TOPRIGHT, inset=INSET, activities, cex=0.8, col=colors,lty=1, title="Activities", lwd=2)
# ---------------------------------------------------

#####################################################################
### Magnitude Generation ()
### -----------------------------------------------------------------
FROM <- 0
TO <- 300
YLIM <- c(-1.5,1.5)
LWD <- 2 
activities <- c("laying", "sitting", "standing", "walk", "walkdown", "walkup")
nActivities <- length(activities)
colors <- rainbow(nActivities)

for(i in 1:nActivities) {
  samsungDataActivites <- samsungData[(samsungData$activity == activities[i]) ,]  

  if ( i == 1 ) { 
    plot(seq(from=FROM, to=TO, length.out=length(samsungDataActivites$tBodyAccMag.mean..)),
         samsungDataActivites$tBodyAccMag.mean.., type="n", 
         ylim=YLIM, 
        xlab="Time (s)", ylab="Acceleration") 
  }
  lines(seq(from=FROM, to=TO, length.out=length(samsungDataActivites$tBodyAccMag.mean..)), 
        samsungDataActivites$tBodyAccMag.mean.., lwd=LWD, col=colors[i])
  
}

# add a title and subtitle
title("Magnitude Acceleration", "")

# add a legend
legend(-0.2, 1.525, activities, cex=0.8, col=colors,lty=1, title="Activities",lwd=2)
# ---------------------------------------------------


par(mfrow=c(3,2))
# laying
samsungData.laying <- samsungData[(samsungData$activity == 'laying' & samsungData$subject == id) ,]
plot(seq(from=0, to=2.5, length.out=length(samsungData.laying$tBodyAcc.mean...X)), samsungData.laying$tBodyAcc.mean...X, type="l", ylim=c(-1,1), xlab="Time (s)", ylab="Acceleration", main="(a) Laying")
lines(seq(from=0, to=2.5, length.out=length(samsungData.laying$tBodyAcc.mean...Y)), samsungData.laying$tBodyAcc.mean...Y, type="l", col="red")
lines(seq(from=0, to=2.5, length.out=length(samsungData.laying$tBodyAcc.mean...Z)), samsungData.laying$tBodyAcc.mean...Z, type="l", col="blue")
legend(2.0, 1.0, legend = labelLegend, col = colLegend, pch = 19)

# sitting 
samsungData.sitting <- samsungData[(samsungData$activity == 'sitting' & samsungData$subject == id) ,]
plot(seq(from=0, to=2.5, length.out=length(samsungData.sitting$tBodyAcc.mean...X)), samsungData.sitting$tBodyAcc.mean...X, type="l", ylim=c(-1,1), xlab="Time (s)", ylab="Acceleration", main="(b) Sitting")
lines(seq(from=0, to=2.5, length.out=length(samsungData.sitting$tBodyAcc.mean...Y)), samsungData.sitting$tBodyAcc.mean...Y, type="l", col="red")
lines(seq(from=0, to=2.5, length.out=length(samsungData.sitting$tBodyAcc.mean...Z)), samsungData.sitting$tBodyAcc.mean...Z, type="l", col="blue")
legend(2.0, 1.0, legend = labelLegend, col = colLegend, pch = 19)

# standing 
samsungData.standing <- samsungData[(samsungData$activity == 'standing' & samsungData$subject == id) ,]
plot(seq(from=0, to=2.5, length.out=length(samsungData.standing$tBodyAcc.mean...X)), samsungData.standing$tBodyAcc.mean...X, type="l", ylim=c(-1,1), xlab="Time (s)", ylab="Acceleration", main="(c) standing")
lines(seq(from=0, to=2.5, length.out=length(samsungData.standing$tBodyAcc.mean...Y)), samsungData.standing$tBodyAcc.mean...Y, type="l", col="red")
lines(seq(from=0, to=2.5, length.out=length(samsungData.standing$tBodyAcc.mean...Z)), samsungData.standing$tBodyAcc.mean...Z, type="l", col="blue")
legend(2.0, 1.0, legend = labelLegend, col = colLegend, pch = 19)

# walk
samsungData.walk <- samsungData[(samsungData$activity == 'walk' & samsungData$subject == id) ,]
plot(seq(from=0, to=2.5, length.out=length(samsungData.walk$tBodyAcc.mean...X)), samsungData.walk$tBodyAcc.mean...X, type="l", ylim=c(-1,1), xlab="Time (s)", ylab="Acceleration", main="(d) Walk")
lines(seq(from=0, to=2.5, length.out=length(samsungData.walk$tBodyAcc.mean...Y)), samsungData.walk$tBodyAcc.mean...Y, type="l", col="red")
lines(seq(from=0, to=2.5, length.out=length(samsungData.walk$tBodyAcc.mean...Z)), samsungData.walk$tBodyAcc.mean...Z, type="l", col="blue")
legend(2.0, 1.0, legend = labelLegend, col = colLegend, pch = 19)

# walkdown
samsungData.walkdown <- samsungData[(samsungData$activity == 'walkdown' & samsungData$subject == id),]
plot(seq(from=0, to=2.5, length.out=length(samsungData.walkdown$tBodyAcc.mean...X)), samsungData.walkdown$tBodyAcc.mean...X, type="l", ylim=c(-1,1), xlab="Time (s)", ylab="Acceleration", , main="(e) Walk down")
lines(seq(from=0, to=2.5, length.out=length(samsungData.walkdown$tBodyAcc.mean...Y)), samsungData.walkdown$tBodyAcc.mean...Y, type="l", col="red")
lines(seq(from=0, to=2.5, length.out=length(samsungData.walkdown$tBodyAcc.mean...Z)), samsungData.walkdown$tBodyAcc.mean...Z, type="l", col="blue")
legend(2.0, 1.0, legend = labelLegend, col = colLegend, pch = 19)

# walkup
samsungData.walkup <- samsungData[(samsungData$activity == 'walkup' & samsungData$subject == id),]
plot(seq(from=0, to=2.5, length.out=length(samsungData.walkup$tBodyAcc.mean...X)), samsungData.walkup$tBodyAcc.mean...X, type="l", ylim=c(-1,1), xlab="Time (s)", ylab="Acceleration", main="(f) Walk Up")
lines(seq(from=0, to=2.5, length.out=length(samsungData.walkup$tBodyAcc.mean...Y)), samsungData.walkup$tBodyAcc.mean...Y, type="l", col="red")
lines(seq(from=0, to=2.5, length.out=length(samsungData.walkup$tBodyAcc.mean...Z)), samsungData.walkup$tBodyAcc.mean...Z, type="l", col="blue")
legend(2.0, 1.0, legend = labelLegend, col = colLegend, pch = 19)

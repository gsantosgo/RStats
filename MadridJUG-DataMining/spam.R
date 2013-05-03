# ================================================================
# MADRID JAVA USER GROUP: DATA MINING  
# 
# May 6, 2013
# 
# Jose Maria Gomez Hidalgo (@jmgomez) 
# Guillermo Santos Garcia (@gsantosgo)
# 
# CLASSIFICATION PROBLEM
# SPAM or NOT SPAM
#
#
# This script is licensed under the GPLv2 license 
# http://www.gnu.org/licenses/gpl.html
# ----------------------------------------------------------------
getwd()
WORKING_DIR <- "~/R/RStats/MadridJUG-DataMining"
#WORKING_DIR <- "C:/Users/gsantos/R/RStats/MadridJUG-DataMining"
setwd(WORKING_DIR)
getwd()

### Load Libraries 
#install.packages(c("RColorBrewer","gridBase",ElemStatLearn","foreign","tree","rpart","maptree","class","ROCR)) 
library(RColorBrewer)
library(gridbase)
library(ElemStatLearn)
library(foreign)
library(tree)
library(rpart)
library(maptree)
#install.packages("class") #not work in  2.15.2 
#library(class) #k Nearest Neighbors
library(e1071) # Support Vector Machine 
library(ROCR)

# Set color 
COLOR_SYSTEM <- "Set3"
COLORS <- brewer.pal(10,COLOR_SYSTEM)
PAL <- colorRampPalette(COLORS)


DATASET <- spam 

write.csv(DATASET)

head(DATASET)
dim(DATASET)
nrow(DATASET)
ncol(DATASET)
colnames(DATASET)
summary(DATASET)
sapply(DATASET[1,], class)

# Change Column Names 
newColNames <- c("word_freq_make",
"word_freq_address",
"word_freq_all",
"word_freq_3d",
"word_freq_our",
"word_freq_over",
"word_freq_remove",
"word_freq_internet",
"word_freq_order",
"word_freq_mail",
"word_freq_receive",
"word_freq_will",
"word_freq_people",
"word_freq_report",
"word_freq_addresses",
"word_freq_free",
"word_freq_business",
"word_freq_email",
"word_freq_you",
"word_freq_credit",
"word_freq_your",
"word_freq_font",
"word_freq_000",
"word_freq_money",
"word_freq_hp",
"word_freq_hpl", 
"word_freq_george",
"word_freq_650",
"word_freq_lab",
"word_freq_labs",
"word_freq_telnet",
"word_freq_857",
"word_freq_data",
"word_freq_415", 
"word_freq_85",
"word_freq_technology",
"word_freq_1999",
"word_freq_parts",
"word_freq_pm",
"word_freq_direct", 
"word_freq_cs",
"word_freq_meeting",
"word_freq_original",
"word_freq_project",
"word_freq_re",
"word_freq_edu",
"word_freq_table",
"word_freq_conference",
"char_freq_ch;",
"char_freq_ch(",
"char_freq_ch[",
"char_freq_ch!",
"char_freq_ch$",
"char_freq_ch#",
"capital_run_length_average",
"capital_run_length_longest",
"capital_run_length_total",
"spam")
length(newColNames)
colnames(DATASET) <- newColNames
colnames(DATASET)

class(DATASET$spam)
levels(DATASET$spam)

# ================================================================
# Exploratory Analysis 
# ----------------------------------------------------------------
result <- table(DATASET$spam)
numEmail <- result[["email"]]
numEmail
(numEmail/nrow(DATASET))*100
numSpam <- result[["spam"]]
numSpam
(numSpam/nrow(DATASET))*100
#table(email$spam, email$word_freq_george)
#table(spam$spam, spam$word_freq_george)

table <- table(DATASET$spam)
par(mfrow=c(1,2))
par(mar=c(5, 4, 4, 2) + 0.1) # increase y-axis margin.
plot <- plot(DATASET$spam,col=PAL(2), main="Email vs. Spam", ylim=c(0,4000), ylab="Examples Number")
text(x=plot,y=table+200, labels=table))
percentage <- round(table/sum(table)*100)
labels <- paste(row.names(table), percentage) # add percents to labels
labels <- paste(labels,"%",sep="") # ad % to labels
pie(table(DATASET$spam), labels=labels,col=PAL(2),main="Email vs. Spam")

# Average percentage of words or characters in an email message
# equal to the indicated word or character. We have chosen the words and characters
# showing the largest difference between spam and email.
dataset.email <- sapply(DATASET[which(DATASET$spam == "email"), 1:54], function(x)ifelse(is.numeric(x), round(mean(x),2), NA))
dataset.spam <- sapply(DATASET[which(DATASET$spam == "spam"), 1:54], function(x)ifelse(is.numeric(x), round(mean(x),2), NA))

dataset.email.order <- dataset.email[order(-dataset.email)[1:10]]
dataset.spam.order <- dataset.spam[order(-dataset.spam)[1:10]]

par(mfrow=c(1,2))
par(mar=c(8, 4, 4, 2) + 0.1) # increase y-axis margin.
plot <- barplot(dataset.email.order, col=PAL(10), main='Email: Average Percentage', names.arg="", ylab="Percentage Relative (%)") 
#text(x=plot,y=dataset.email.order-0.1, labels=dataset.email.order, cex=0.6)
vps <- baseViewports()
pushViewport(vps$inner, vps$figure, vps$plot)
grid.text(names(dataset.email.order),x = unit(plot, "native"), y=unit(-1, "lines"),just="right", rot=50)
popViewport(3)

plot <- barplot(dataset.spam.order, col=PAL(10), main='Spam: Average Percentage', names.arg="", ylab="Percentage Relative (%)") 
#text(x=plot,y=dataset.spam.order-0.1, labels=dataset.spam.order, cex=0.6)
vps <- baseViewports()
pushViewport(vps$inner, vps$figure, vps$plot)
grid.text(names(dataset.spam.order),x = unit(plot, "native"), y=unit(-1, "lines"),just="right", rot=50)
popViewport(3)


par(mar=c(5,8,4,2)) # increase y-axis margin.
barplot(dataset.spam[order(-dataset.spam)[1:10]], col=rainbow(6), main='Spam: Relative Frequencies', cex.names=0.5)
names(dataset.spam[order(-dataset.spam)[1:10]])

set.seed(1423)
index <- 1:nrow(DATASET)
trainindex <- sample(index, trunc(length(index)*0.6666666666666667))

### ==========================================
### Train
### ------------------------------------------
dataset.train <- DATASET[trainindex, ]
(nrow(dataset.train) / nrow(DATASET)) * 100
table(dataset.train$spam)

### ==========================================
### Test 
### ------------------------------------------
dataset.test <- DATASET[-trainindex, ]
(nrow(dataset.test) / nrow(DATASET)) * 100
table(dataset.test$spam)


### ===================================================================
### Classification. Recursive Partitioning and Regression Trees (RPART)
### -------------------------------------------------------------------
pc <- proc.time()
model.rpart <- rpart(spam ~ . ,method="class", data=dataset.train)
proc.time() - pc
plotcp(model.rpart) # visualize cross-validation results
summary(model.rpart) # detailed summary of splits
printcp(model.rpart) # display the results
plot(model.rpart, uniform=TRUE, main="Classification Tree for SPAM")
text(model.rpart, all=TRUE ,cex=.75)
#text(model.rpart, all=TRUE,cex=0.75, splits=TRUE, use.n=TRUE, xpd=TRUE)

draw.tree(model.rpart, cex=0.5, nodeinfo=TRUE, col=gray(0:8 / 8))
prediction <- predict(model.rpart, newdata=dataset.test, type='class')

# Confusion Matrix 
table("Actual Class"=dataset.test$spam, "Predicted Class"=prediction)
error.rate <- sum(dataset.test$spam != predict(model.rpart, newdata=dataset.test, type='class')) / nrow(dataset.test)
print (paste0("SPAM Cart Model: ", 1 - error.rate))

### =========================================
### Classification. k Nearest Neighbors
### -----------------------------------------
pc <- proc.time()
model.knn <- knn(train=dataset.train, test=dataset.test,cl=dataset.train$spam)
proc.time() - pc

summary(model.knn)
table("Actual Class"=dataset.test$spam, "Predicted Class"=model.knn)


### ============================================
### Classification. SVM (Support Vector Machine)
### --------------------------------------------
pc <- proc.time()
model.svm <- svm(train$spam~., data=dataset.train,)
proc.time() - pc
summary(model.svm)
predicted <- predict(model.svm, newdata=dataset.test, type="class")

### Curve ROC 
pred<-prediction(as.numeric(predicted), as.numeric(dataset.test$spam))
perf <- performance( pred, "tpr", "fpr")
par(mar=c(5,5,2,2),xaxs = "i",yaxs = "i",cex.axis=1.3,cex.lab=1.4)
# plotting the ROC curve
plot(perf,col="black",lty=3, lwd=3)
auc <- performance(pred,"auc")
# now converting S4 class to vector
auc <- unlist(slot(auc, "y.values"))
# adding min and max ROC AUC to the center of the plot
minauc<-min(round(auc, digits = 2))
maxauc<-max(round(auc, digits = 2))
minauct <- paste(c("min(AUC) = "),minauc,sep="")
maxauct <- paste(c("max(AUC) = "),maxauc,sep="")
legend(0.3,0.6,c(minauct,maxauct,"\n"),border="white",cex=1.7,box.col = "white")


performance(pred,"tpr","fpr")

# Confusion Matrix 
table("Actual Class"=dataset.test$spam, "Predicted Class"=predicted)

# ----------------------------------------------------------------
# WEKA 
# Writes data into Weka Attribute-Relation File Format (ARFF) files.
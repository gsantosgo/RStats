######################################################
# 
# Autor. Guillermo Santos 
# Temática. Loan Lending Club (coursera)
#         
# Fecha.    18.02.2013 
# ----------------------------------------------------

### ---------------------------------------------------------------------
### Load libraries
### ---------------------------------------------------------------------
library(car)
library(psych)
library(stringr)
library(RColorBrewer)
library(visreg)
  
### Processing

getwd()
WORKING_DIR <- "~/R/RStats/Data Analysis"
setwd(WORKING_DIR)
getwd()

## Download the data, read the data in and save dateDownloaded, the raw data as an RDA file 
urlFile <- "https://spark-public.s3.amazonaws.com/dataanalysis/loansData.csv"
download.file("https://spark-public.s3.amazonaws.com/dataanalysis/loansData.csv",destfile="./data/loansData.csv")
dateDownloaded <- date()
dateDownloaded
loansRaw <- read.csv("./data/loansData.csv")
save(loansRaw, dateDownloaded, file="loansData.rda")



### ---------------------------------------------------------------------
### Explore the data set 
### ---------------------------------------------------------------------
head(loansRaw)
summary(loansRaw)
sapply(loansRaw[1,], class)
## Summary 
sapply(loansRaw[,1:14], summary)

### ---------------------------------------------------------------------
### Variables - Factor to Numeric 
### ---------------------------------------------------------------------
loansRaw$Interest.Rate <- as.numeric(sub("[^0-9\\.]","",loansRaw$Interest.Rate))
#loansRaw$Loan.Length <- as.numeric(sub("months?","",loansRaw$Loan.Length))
loansRaw$Debt.To.Income.Ratio <- as.numeric(sub("[^0-9\\.]","",loansRaw$Debt.To.Income.Ratio))
# FICO.RANGE
#Fico.Range.Integer <- sapply(levels(loansRaw$FICO.Range), function(d) which(levels(loansRaw$FICO.Range) == d))
#loansRaw$FICO.Range <- as.numeric(Fico.Range.Integer[loansRaw$FICO.Range])

## Making numeric variables Employment.Length 
#loansRaw$Employment.Length <- as.character(loansRaw$Employment.Length)
#matchEmployment.Length <- str_match(loansRaw$Employment.Length, "(<? ?)(\\d{1,2})\\+? years?")
#for(i in 1:nrow(matchEmployment.Length)) {
#  if ( is.na(matchEmployment.Length[i,3]) ) loansRaw$Employment.Length[i] <- as.numeric("99")
#  else if ( (matchEmployment.Length[i,2] == "< " || matchEmployment.Length[i,2] == "<") && 
#              (matchEmployment.Length[i,3] == 1) )
#    loansRaw$Employment.Length[i] <- as.numeric("0")
#  else
#    loansRaw$Employment.Length[i] <- as.numeric(matchEmployment.Length[i,3])   
#}
#loansRaw$Employment.Length <- as.numeric(loansRaw$Employment.Length)

### ---------------------------------------------------------------------
### Missing Values (NA's)
### ---------------------------------------------------------------------
sum(is.na(loansRaw))
which(is.na(loansRaw), arr.ind=TRUE)
## Remove NA 
loansRaw <- loansRaw[complete.cases(loansRaw),]
dim(loansRaw)
levels(loansRaw$Employment.Length)
sum(loansRaw$Employment.Length == "n/a")
which(loansRaw == "n/a" , arr.ind=TRUE)


### ---------------------------------------------------------------------
### Exploratory analysis
### ---------------------------------------------------------------------

## Make some univariate plots/summary
hist(loansRaw$Amount.Requested, breaks=100)
hist(log10(loansRaw$Amount.Requested + 1), breaks=100)
summary(loansRaw$Amount.Requested)
quantile(loansRaw$Amount.Requested)
round(skew(loansRaw$Amount.Requested))
round(kurtosi(loansRaw$Amount.Requested))

hist(loansRaw$Amount.Funded.By.Investors, breaks=100)
summary(loansRaw$Amount.Funded.By.Investors)
quantile(loansRaw$Amount.Funded.By.Investors)
# Outliers. Negative o Zero Value
loansRaw$Amount.Funded.By.Investors[which(loansRaw$Amount.Funded.By.Investors < 1)]
loansRaw$Amount.Funded.By.Investors[which(loansRaw$Amount.Funded.By.Investors < 1)] <- loansRaw$Amount.Requested[which(loansRaw$Amount.Funded.By.Investors < 1)]
round(skew(loansRaw$Amount.Funded.By.Investors))
round(kurtosi(loansRaw$Amount.Funded.By.Investors))

hist(loansRaw$Interest.Rate, breaks=100)
boxplot(loansRaw$Interest.Rate)
summary(loansRaw$Interest.Rate)
quantile(loansRaw$Interest.Rate)
round(skew(loansRaw$Interest.Rate),2)
round(kurtosi(loansRaw$Interest.Rate),2)

hist(loansRaw$Debt.To.Income.Ratio, breaks=100)
boxplot(loansRaw$Debt.To.Income.Ratio)
summary(loansRaw$Debt.To.Income.Ratio)
quantile(loansRaw$Debt.To.Income.Ratio)
#Note. Debt To Income Ratio == 0 
loansRaw$Debt.To.Income.Ratio[(loansRaw$Debt.To.Income.Ratio == 0)]
round(skew(loansRaw$Debt.To.Income.Ratio),2)
round(kurtosi(loansRaw$Debt.To.Income.Ratio),2)

hist(loansRaw$Monthly.Income, breaks=100)
summary(loansRaw$Monthly.Income)
quantile(loansRaw$Monthly.Income)
round(skew(loansRaw$Monthly.Income),2)
round(kurtosi(loansRaw$Monthly.Income),2)

hist(loansRaw$Open.CREDIT.Lines, breaks=100)
summary(loansRaw$Open.CREDIT.Lines.Income)
quantile(loansRaw$Open.CREDIT.Lines)
round(skew(loansRaw$Open.CREDIT.Lines),2)
round(kurtosi(loansRaw$Open.CREDIT.Lines),2)

hist(loansRaw$Revolving.CREDIT.Balance, breaks=100)
summary(loansRaw$Revolving.CREDIT.Balance)
quantile(loansRaw$Revolving.CREDIT.Balance)
round(skew(loansRaw$Revolving.CREDIT.Balance),2) 
round(kurtosi(loansRaw$Revolving.CREDIT.Balance),2)
#Note. Revolving CREDIT Balance == 0 
boxplot(loansRaw$Revolving.CREDIT.Balance)
loansRaw$Revolving.CREDIT.Balance[which(loansRaw$Revolving.CREDIT.Balance == 0)]

hist(loansRaw$Inquiries.in.the.Last.6.Months, breaks=100)
summary(loansRaw$Inquiries.in.the.Last.6.Months)
quantile(loansRaw$Inquiries.in.the.Last.6.Months)
round(skew(loansRaw$Inquiries.in.the.Last.6.Months),2) 
round(kurtosi(loansRaw$Inquiries.in.the.Last.6.Months),2)

## Make some univariate tables/plot 
table(loansRaw$Loan.Length)
round(table(loansRaw$Loan.Length)/sum(table(loansRaw$Loan.Length)),2) * 100
plot(loansRaw$Loan.Length)
table(loansRaw$Loan.Purpose)
round(table(loansRaw$Loan.Purpose)/sum(table(loansRaw$Loan.Purpose)),2) * 100
plot(loansRaw$Loan.Purpose)
table(loansRaw$State)
round(table(loansRaw$State)/sum(table(loansRaw$State)),2) * 100
plot(loansRaw$State)
table(loansRaw$Home.Ownership)
round(table(loansRaw$Home.Ownership)/sum(table(loansRaw$Home.Ownership)),2) * 100
plot(loansRaw$Home.Ownership)
table(loansRaw$FICO.Range)
round(table(loansRaw$FICO.Range)/sum(table(loansRaw$FICO.Range)),2) * 100
plot(loansRaw$FICO.Range)
table(loansRaw$Employment.Length)
round(table(loansRaw$Employment.Length)/sum(table(loansRaw$Employment.Length)),2) * 100
plot(loansRaw$Employment.Length)

## Explotarions associations or relationships 
corLoansRaw.matrix <- cor(loansRaw[, c(3,1,2,6,9,11,12,13)])
round(corLoansRaw.matrix,2)
pairs(loansRaw[c(3,1,2,6,9,11,12,13)] )
plot(loansRaw$Amount.Requested, loansRaw$Interest.Rate, pch=19)
abline(lm(loansRaw$Interest.Rate ~ loansRaw$Amount.Requested), col="red", lwd=3)
plot(loansRaw$Amount.Funded.By.Investors, loansRaw$Interest.Rate, pch=19)
abline(lm(loansRaw$Interest.Rate ~ loansRaw$Amount.Funded.By.Investors), col="red", lwd=3)
plot(loansRaw$Debt.To.Income.Ratio, loansRaw$Interest.Rate, pch=19)
abline(lm(loansRaw$Interest.Rate ~ loansRaw$Debt.To.Income.Ratio), col="red", lwd=3)
#Note. There are outliers 
plot(loansRaw$Monthly.Income, loansRaw$Interest.Rate, pch=19)
abline(lm(loansRaw$Interest.Rate ~ loansRaw$Monthly.Income), col="red", lwd=3)
plot(loansRaw$Monthly.Income, loansRaw$Interest.Rate, pch=19)
abline(lm(loansRaw$Interest.Rate ~ loansRaw$Monthly.Income), col="red", lwd=3)
plot(loansRaw$Open.CREDIT.Lines, loansRaw$Interest.Rate, pch=19)
abline(lm(loansRaw$Interest.Rate ~ loansRaw$Open.CREDIT.Lines), col="red", lwd=3)
#Note. There are outliers
plot(loansRaw$Revolving.CREDIT.Balance, loansRaw$Interest.Rate, pch=19)
abline(lm(loansRaw$Interest.Rate ~ loansRaw$Revolving.CREDIT.Balance), col="red", lwd=3)
plot(loansRaw$Inquiries.in.the.Last.6.Months, loansRaw$Interest.Rate, pch=19)
abline(lm(loansRaw$Interest.Rate ~ loansRaw$Inquiries.in.the.Last.6.Months), col="red", lwd=3)

# Factor Variables Plots 
plot(loansRaw$Loan.Length, loansRaw$Interest.Rate)
plot(loansRaw$Loan.Purpose, loansRaw$Interest.Rate, xlab="Loan Purpose")
plot(loansRaw$State, loansRaw$Interest.Rate, xlab="State")
plot(loansRaw$Home.Ownership, loansRaw$Interest.Rate, xlab="Home Ownership")
plot(loansRaw$FICO.Range, loansRaw$Interest.Rate, xlab="FICO Range")
plot(loansRaw$Employment.Length, loansRaw$Interest.Rate, xlab="Employment Length")

## Outliers. Remove rows 
which(loansRaw$Monthly.Income > 35000)
loansRaw <- loansRaw[-which(loansRaw$Monthly.Income > 35000),]
plot(loansRaw$Monthly.Income, loansRaw$Interest.Rate, pch=19)
abline(lm(loansRaw$Interest.Rate ~ loansRaw$Monthly.Income), col="red", lwd=3)

which(loansRaw$Revolving.CREDIT.Balance > 150000)
loansRaw <- loansRaw[-which(loansRaw$Revolving.CREDIT.Balance > 150000),]
plot(loansRaw$Revolving.CREDIT.Balance, loansRaw$Interest.Rate, pch=19)
abline(lm(loansRaw$Interest.Rate ~ loansRaw$Revolving.CREDIT.Balance), col="red", lwd=3)

## Transform Variables 
summary(log10(loansRaw$Amount.Requested), useNA='ifany')
summary(log10(loansRaw$Amount.Requested+1))
loansRaw$log10Amount.Requested <- log10(loansRaw$Amount.Requested+1)
summary(log10(loansRaw$Amount.Funded.By.Investors), useNA='ifany')
summary(log10(loansRaw$Amount.Funded.By.Investors+1))
loansRaw$log10Amount.Funded.By.Investors <- log10(loansRaw$Amount.Funded.By.Investors+1)
summary(log10(loansRaw$Monthly.Income), useNA='ifany')
summary(log10(loansRaw$Monthly.Income+1))
loansRaw$log10Monthly.Income <- log10(loansRaw$Monthly.Income+1)
summary(log10(loansRaw$Open.CREDIT.Lines), useNA='ifany')
summary(log10(loansRaw$Open.CREDIT.Lines+1))
loansRaw$log10Open.CREDIT.Lines <- log10(loansRaw$Open.CREDIT.Lines+1)
summary(log10(loansRaw$Revolving.CREDIT.Balance), useNA='ifany')
summary(log10(loansRaw$Revolving.CREDIT.Balance+1))
loansRaw$log10Revolving.CREDIT.Balance <- log10(loansRaw$Revolving.CREDIT.Balance+1)
summary(sqrt(loansRaw$sqrtInquiries.in.the.Last.6.Months), useNA='ifany')
summary(sqrt(loansRaw$sqrtInquiries.in.the.Last.6.Months+1))
loansRaw$sqrtInquiries.in.the.Last.6.Months <- sqrt(loansRaw$Inquiries.in.the.Last.6.Months)

## Plot transform 
par(mfrow=c(1,2))
plot(loansRaw$Amount.Requested, loansRaw$Interest.Rate, pch=19)
abline(lm(loansRaw$Interest.Rate ~ loansRaw$Amount.Requested), col="red", lwd=3)
plot(loansRaw$log10Amount.Requested, loansRaw$Interest.Rate, pch=19)
abline(lm(loansRaw$Interest.Rate ~ loansRaw$log10Amount.Requested), col="red", lwd=3)

plot(loansRaw$Amount.Funded.By.Investors, loansRaw$Interest.Rate, pch=19)
abline(lm(loansRaw$Interest.Rate ~ loansRaw$Amount.Funded.By.Investors), col="red", lwd=3)
plot(loansRaw$log10Amount.Funded.By.Investors, loansRaw$Interest.Rate, pch=19)
abline(lm(loansRaw$Interest.Rate ~ loansRaw$log10Amount.Funded.By.Investors), col="red", lwd=3)

plot(loansRaw$Monthly.Income, loansRaw$Interest.Rate, pch=19)
abline(lm(loansRaw$Interest.Rate ~ loansRaw$Monthly.Income), col="red", lwd=3)
plot(loansRaw$log10Monthly.Income, loansRaw$Interest.Rate, pch=19)
abline(lm(loansRaw$Interest.Rate ~ loansRaw$log10Monthly.Income), col="red", lwd=3)

plot(loansRaw$Open.CREDIT.Lines, loansRaw$Interest.Rate, pch=19)
abline(lm(loansRaw$Interest.Rate ~ loansRaw$Open.CREDIT.Lines), col="red", lwd=3)
plot(loansRaw$log10Open.CREDIT.Lines, loansRaw$Interest.Rate, pch=19)
abline(lm(loansRaw$Interest.Rate ~ loansRaw$log10Open.CREDIT.Lines), col="red", lwd=3)

plot(loansRaw$Revolving.CREDIT.Balance, loansRaw$Interest.Rate, pch=19)
abline(lm(loansRaw$Interest.Rate ~ loansRaw$Revolving.CREDIT.Balance), col="red", lwd=3)
plot(loansRaw$log10Revolving.CREDIT.Balance, loansRaw$Interest.Rate, pch=19)
abline(lm(loansRaw$Interest.Rate ~ loansRaw$log10Revolving.CREDIT.Balance), col="red", lwd=3)

plot(loansRaw$Inquiries.in.the.Last.6.Months, loansRaw$Interest.Rate, pch=19)
abline(lm(loansRaw$Interest.Rate ~ loansRaw$Inquiries.in.the.Last.6.Months), col="red", lwd=3)
plot(loansRaw$sqrtInquiries.in.the.Last.6.Months, loansRaw$Interest.Rate, pch=19)
abline(lm(loansRaw$Interest.Rate ~ loansRaw$sqrtInquiries.in.the.Last.6.Months), col="red", lwd=3)


### ---------------------------------------------------------------------
### Modelling 
### ---------------------------------------------------------------------
lmFit1 <- lm(loansRaw$Interest.Rate ~ loansRaw$Amount.Requested)
plot(loansRaw$Amount.Requested, loansRaw$Interest.Rate, pch=19)
abline(lmFit1, col="red", lwd=3)
summary(lmFit1)

lmFit2 <- lm(loansRaw$Interest.Rate ~ loansRaw$log10Amount.Requested)
plot(loansRaw$log10Amount.Requested, loansRaw$Interest.Rate, pch=19)
abline(lmFit2, col="red", lwd=3)
summary(lmFit2)

# Fit model with no adjustment variable 
lmFitNoAdjust <- lm(Interest.Rate ~ FICO.Range, data=loansRaw) 
summary(lmFitNoAdjust)
plot(lmFitNoAdjust,which=1,col=as.factor(loansRaw$FICO.Range))

par(mfrow=c(1,3))
plot(loansRaw$FICO.Range,lmFitNoAdjust$residuals, pch=19) 


lmFitFinal <- lm(Interest.Rate ~ log10Amount.Requested +
              log10Amount.Funded.By.Investors + 
              Debt.To.Income.Ratio + 
              log10Open.CREDIT.Lines + 
              log10Revolving.CREDIT.Balance + 
              sqrtInquiries.in.the.Last.6.Months + 
              Loan.Length +               
              FICO.Range, data=loansRaw) 


### ---------------------------------------------------------------------
### Get the estimates and confidence intervals 
### ---------------------------------------------------------------------

## The estimate from summary 
summary(lmFitFinal)

## The confidence interval fron confint
confint(lmFit)
anova(lmFit)
plot(lmFit)
summary(lmFit)
library(car)
residualPlots(lmFit)



### ---------------------------------------------------------------------
### Figure makin 
### ---------------------------------------------------------------------


## Set up a function that makes colors prettier
mypar <- function(a=1,b=1,brewer.n=8,brewer.name="Dark2",...){
  par(mar=c(2.5,2.5,1.6,1.1),mgp=c(1.5,.5,0))
  par(mfrow=c(a,b),...)
  palette(brewer.pal(brewer.n,brewer.name))
}

## Set size of axes
cx <- 1
pch <- 19

## Save figure to pdf file
pdf(file="./figures/finalfigure.pdf", height=2*6, width=2*6)
mypar(mfrow=c(2,2))
#interestRate_FICORange_Means <- tapply(loansRaw$Interest.Rate, loansRaw$FICO.Range, mean, na.rm = TRUE)
#boxplot(interestRate_FICORange_Means ~ names(interestRate_FICORange_Means), xlab="FICO Score Range ", ylab="Interest Rate",main="")
#rug(interestRate_FICORange_Means)
#points(interestRate_FICORange_Means,col="red",pch=pch)
#lines(interestRate_FICORange_Means)

visreg(lmFitFinal, "log10Amount.Requested", xlab="log10 Amount Requested", ylab="Interest Rate")
mtext("(a)")

visreg(lmFitFinal, "FICO.Range", xlab="FICO Score Range", ylab="Interest Rate", col=as.factor(loansRaw$FICO.Range))
mtext("(b)")

visreg(lmFitFinal, "Debt.To.Income.Ratio", xlab="Debt To Income Ratio", ylab="Interest Rate")
mtext("(c)")

plot(lmFitFinal, which=1)
mtext("(d)")
dev.off()
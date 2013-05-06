![alt text](logo/logoMadridJUG.png) Madrid Java User Group (Madrid JUG)

Predicting House Price (REGRESSION PROBLEM) UNIVARIATE
========================================================
This a regression problem (machine learning). The Predict **House Price** depends **House Size**
******
#### May 9, 2013
#### Jose Maria Gomez Hidalgo [@jmgomez](http://twitter.com/jmgomez)
#### Guillermo Santos Garcia [@gsantosgo](http://twitter.com/gsantosgo)
#### This script is licensed under the GPLv2 license http://www.gnu.org/licenses/gpl.html

----------------------------------------------------------------

### Load libraries/data/create new variables


```r
library(knitr)  # Markdown

# Figures Label
opts_chunk$set(fig.path = "figures/plot-predicthouse-")
# opts_chunk$set(echo=FALSE, fig.path='figures/plot-predicthouse-',
# cache=TRUE)
```


### Data    

```r
size <- c(80, 90, 100, 110, 140, 140, 150, 160, 180, 200, 240, 250, 270, 320, 
    350)
price <- c(70, 83, 74, 93, 89, 58, 85, 114, 95, 100, 138, 111, 124, 161, 172)
housePrices <- data.frame(cbind(size, price))
```


Plot:

```r
plot(housePrices$size, housePrices$price, xlab = "Square meters", ylab = "$ Price (K)", 
    main = "Predict House Price", pch = 19)
```

![plot of chunk unnamed-chunk-2](figures/plot-predicthouse-unnamed-chunk-2.png) 


### Linear Regression Model 
 
### y = ax + b 
   

```r
model.regression <- lm(housePrices$price ~ housePrices$size)
model.regression
```

```
## 
## Call:
## lm(formula = housePrices$price ~ housePrices$size)
## 
## Coefficients:
##      (Intercept)  housePrices$size  
##           38.885             0.354
```



```r
predict(model.regression)
```

```
##      1      2      3      4      5      6      7      8      9     10 
##  67.19  70.73  74.27  77.81  88.43  88.43  91.96  95.50 102.58 109.66 
##     11     12     13     14     15 
## 123.81 127.35 134.43 152.12 162.74
```


Plot:

```r
plot(housePrices$size, housePrices$price, xlab = "Square meters", ylab = "$ Price (K)", 
    main = "Predict House Price", pch = 19)
abline(model.regression, col = 2, lwd = 3)
```

![plot of chunk unnamed-chunk-5](figures/plot-predicthouse-unnamed-chunk-5.png) 


### Predicting House Price of 120 squared meters?

```r
sizequery <- 120
# newdata <- data.frame(price=sizequery) predict.lm(model.regression,
# newdata, interval='confidence')
result <- model.regression$coefficients[1] + sizequery * model.regression$coefficients[2]
print(paste0("Predicting House Price of 120 squared meters: ", round(result, 
    2)))
```

```
## [1] "Predicting House Price of 120 squared meters: 81.35"
```

```r
plot(housePrices$size, housePrices$price, xlab = "Square meters", ylab = "$ Price (K)", 
    main = "Predict House Price", pch = 19)
abline(model.regression, col = 2, lwd = 3)
abline(h = result, v = sizequery, col = "blue", lty = "dotdash")
```

![plot of chunk unnamed-chunk-6](figures/plot-predicthouse-unnamed-chunk-6.png) 


### Predicting House Price of 300 squared meters?

```r
sizequery <- 300
result <- model.regression$coefficients[1] + sizequery * model.regression$coefficients[2]
print(paste0("Predicting House Price of 300 squared meters: ", round(result, 
    2)))
```

```
## [1] "Predicting House Price of 300 squared meters: 145.04"
```

```r
plot(housePrices$size, housePrices$price, xlab = "Square meters", ylab = "$ Price (K)", 
    main = "Predict House Price", pch = 19)
abline(model.regression, col = 2, lwd = 3)
abline(h = result, v = sizequery, col = "blue", lty = "dotdash")
```

![plot of chunk unnamed-chunk-7](figures/plot-predicthouse-unnamed-chunk-7.png) 


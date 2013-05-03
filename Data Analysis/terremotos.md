Analisis de Terremotos FINAL (Analisis de Datos)
========================== 

Descarga el conjunto del datos de los últimos terremotos (últimos 7 dias) producidos desde el sitio USGS. 

  http://earthquake.usgs.gov/earthquakes/catalogs/eqs7day-M1.txt	

Analisis de datos relacionando la magnitud de un terremoto con su profundidad
	
¿Que puedes inferir acerca de la relación entre estas dos cantidades? 

******
#### Enero 2013 Data Analysis Coursera 
#### Guillermo Santos Garcia [@gsantosgo](http://twitter.com/gsantosgo)
#### This script is licensed under the GPLv2 license http://www.gnu.org/licenses/gpl.html
----------------------------------------------------------------
Note: This analysis was created on a Ubuntu 12.0.4 (RStudio 2.5.13). 
------

## Preliminaries

#### Set Working Directory

```r
getwd()
```

```
## [1] "/home/gsantos/R/RStats/Data Analysis"
```

```r
WORKING_DIR <- "~/R/RStats/Data Analysis/"
DATASET_FILE <- "./data/quakesRaw.rda"
FIGURES_DIR <- "./figures/"
setwd(WORKING_DIR)
getwd()
```

```
## [1] "/home/gsantos/R/RStats/Data Analysis"
```

```r
# Figures Label
opts_chunk$set(echo = FALSE, fig.path = "figures/plot-te-", cache = TRUE)
```


### Load libraries/data/create new variables


```
## [1] "C"
```

```
## [1] "es_ES.UTF-8"
```



------

## Exploratory analysis

### Get minimum and maximum times and date downloaded (Methods/Data Collection)


```
## [1] "2013-01-24 20:24:10 CET"
```

```
## [1] "2013-01-31 20:19:09 CET"
```

```
## [1] "Thu Jan 31 15:28:41 2013"
```


### Find number of missing values/check ranges (Results paragraph 1)


```
## [1] 0
```

```
##       Src            Eqid        Version   
##  ak     :263   00400787:  1   2      :320  
##  nc     :243   00400795:  1   1      :190  
##  ci     :125   00400804:  1   0      :145  
##  us     : 98   00400807:  1   9      : 57  
##  nn     : 47   00400817:  1   3      : 53  
##  hv     : 30   00400828:  1   4      : 37  
##  (Other): 90   (Other) :890   (Other): 94  
##                                      Datetime        Lat       
##  Monday, January 28, 2013 20:37:09 UTC   :  2   Min.   :-58.8  
##  Saturday, January 26, 2013 12:46:43 UTC :  2   1st Qu.: 34.2  
##  Sunday, January 27, 2013 17:02:54 UTC   :  2   Median : 38.8  
##  Wednesday, January 30, 2013 16:36:59 UTC:  2   Mean   : 40.0  
##  Friday, January 25, 2013 00:06:25 UTC   :  1   3rd Qu.: 54.5  
##  Friday, January 25, 2013 00:10:02 UTC   :  1   Max.   : 66.0  
##  (Other)                                 :886                  
##       Lon         Magnitude        Depth            NST       
##  Min.   :-180   Min.   :1.00   Min.   :  0.0   Min.   :  0.0  
##  1st Qu.:-148   1st Qu.:1.30   1st Qu.:  3.9   1st Qu.: 11.0  
##  Median :-122   Median :1.70   Median :  9.2   Median : 18.0  
##  Mean   :-109   Mean   :2.04   Mean   : 23.8   Mean   : 31.9  
##  3rd Qu.:-117   3rd Qu.:2.30   3rd Qu.: 23.3   3rd Qu.: 33.0  
##  Max.   : 180   Max.   :6.80   Max.   :585.2   Max.   :598.0  
##                                                               
##                  Region             latCut            lonCut   
##  Northern California:157   [-58.8,33.8):180   [-180,-150):180  
##  Central Alaska     :108   [ 33.8,37.6):179   [-150,-123):180  
##  Central California : 81   [ 37.6,38.8):179   [-123,-120):178  
##  Southern California: 76   [ 38.8,60.2):179   [-120,-116):179  
##  Southern Alaska    : 69   [ 60.2,66.0]:179   [-116, 180]:179  
##  Nevada             : 32                                       
##  (Other)            :373                                       
##       nstCut      log10Depth        time                    
##  [ 0, 11):215   Min.   :0.00   Min.   :2013-01-24 20:24:10  
##  [11, 16):173   1st Qu.:0.69   1st Qu.:2013-01-26 03:39:40  
##  [16, 24):162   Median :1.01   Median :2013-01-27 16:23:43  
##  [24, 40):168   Mean   :1.05   Mean   :2013-01-28 00:06:33  
##  [40,598]:178   3rd Qu.:1.39   3rd Qu.:2013-01-29 20:31:49  
##                 Max.   :2.77   Max.   :2013-01-31 20:19:09  
## 
```

Latitude, longitude are within normal ranges. Magnitude has nothing above 7, depth is within the defined range. 


### Look at patterns over time (Results paragraph 1)
![plot of chunk unnamed-chunk-3](figures/plot-te-unnamed-chunk-31.png) ![plot of chunk unnamed-chunk-3](figures/plot-te-unnamed-chunk-32.png) 

There does not appear to be a time trend in either variable. 


### Look at distribution of magnitudes (Results paragraph 2)

```
## [1] 0.8549
```

```
## [1] 0.1071
```

Most earthquakes are small (< 3) or medium (>3 and < 5)

### Look at distribution of depths (Results paragraph 2)

![plot of chunk unnamed-chunk-5](figures/plot-te-unnamed-chunk-51.png) ![plot of chunk unnamed-chunk-5](figures/plot-te-unnamed-chunk-52.png) 


-------

## Modeling 

### Fit a model with no adjustment (results - paragraph 3)

![plot of chunk unnamed-chunk-6](figures/plot-te-unnamed-chunk-6.png) 

It appears there are some non-random patterns here.


### Now fit a model with factor adjustment for latitude, longitude, and number of sites (results - paragraph 3)

![plot of chunk lmFinalChunk](figures/plot-te-lmFinalChunk.png) 

Still some clumpiness of color, but much better than it was. 

## Get the estimates and confidence intervals


```
## 
## Call:
## lm(formula = quakes$Magnitude ~ quakes$log10Depth + quakes$latCut + 
##     quakes$lonCut + quakes$NST)
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -2.1780 -0.3977 -0.0632  0.3567  2.5521 
## 
## Coefficients:
##                            Estimate Std. Error t value Pr(>|t|)    
## (Intercept)                1.604386   0.108248   14.82  < 2e-16 ***
## quakes$log10Depth          0.406542   0.051430    7.90  8.0e-15 ***
## quakes$latCut[ 33.8,37.6) -0.349466   0.087473   -4.00  7.0e-05 ***
## quakes$latCut[ 37.6,38.8) -0.241225   0.091556   -2.63  0.00857 ** 
## quakes$latCut[ 38.8,60.2) -0.253899   0.081659   -3.11  0.00194 ** 
## quakes$latCut[ 60.2,66.0] -0.467433   0.098026   -4.77  2.2e-06 ***
## quakes$lonCut[-150,-123)  -0.119575   0.079336   -1.51  0.13212    
## quakes$lonCut[-123,-120)  -0.312672   0.094392   -3.31  0.00096 ***
## quakes$lonCut[-120,-116)  -0.576412   0.096162   -5.99  3.0e-09 ***
## quakes$lonCut[-116, 180]   0.837621   0.084815    9.88  < 2e-16 ***
## quakes$NST                 0.009701   0.000481   20.16  < 2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1 
## 
## Residual standard error: 0.686 on 885 degrees of freedom
## Multiple R-squared: 0.621,	Adjusted R-squared: 0.616 
## F-statistic:  145 on 10 and 885 DF,  p-value: <2e-16
```

```
##                               2.5 %   97.5 %
## (Intercept)                1.391933  1.81684
## quakes$log10Depth          0.305603  0.50748
## quakes$latCut[ 33.8,37.6) -0.521146 -0.17779
## quakes$latCut[ 37.6,38.8) -0.420916 -0.06153
## quakes$latCut[ 38.8,60.2) -0.414167 -0.09363
## quakes$latCut[ 60.2,66.0] -0.659823 -0.27504
## quakes$lonCut[-150,-123)  -0.275284  0.03613
## quakes$lonCut[-123,-120)  -0.497931 -0.12741
## quakes$lonCut[-120,-116)  -0.765144 -0.38768
## quakes$lonCut[-116, 180]   0.671159  1.00408
## quakes$NST                 0.008756  0.01065
```


-------

## Figure making



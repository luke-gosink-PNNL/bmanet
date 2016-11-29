library(glmnet)
library(randomForest)
library(MASS)
library(Boruta)
library(class)
library(MASS)
library(Hmisc)
library(klaR)
library(rpart)
library(mvtnorm)          
library(lars)
library(stats)
library(leaps)

setwd("/Users/gosi552/Documents/Papers/bma-solvation/")
t_data <- read.csv("data.csv", sep = ",")
X <- t_data[3:19]
y <- t_data[2]

# linear model...stepwise
fit <- lm(y~X138_SGenheden+X141_AndreasKlamt+X145_lhs_sampl4+X149_hwangseo+X153_kimasharp+X166_JoakimJ+X178_ChristopherFennell+X189_epurisima	+X196_rgc+X529_aemark+X544_gilsonlab+X548_jiafu+X561_ben+X562_biorga+X566_geballe+X575_weyang+X582_parsod,data=t_data)
step <- step(fit, direction="both", k = 2)
summary(step)
step$anova # display results 

#random forest
boruta.train <- Boruta(y~X138_SGenheden+X141_AndreasKlamt+X145_lhs_sampl4+X149_hwangseo+X153_kimasharp+X166_JoakimJ+X178_ChristopherFennell+X189_epurisima	+X196_rgc+X529_aemark+X544_gilsonlab+X548_jiafu+X561_ben+X562_biorga+X566_geballe+X575_weyang+X582_parsod, data = t_data,mcAdj=TRUE, doTrace = 0,pValue = 0.0001,maxRuns=19)
print(boruta.train)
getSelectedAttributes(boruta.train)

# lasso
cvfit <- glmnet::cv.glmnet(as.matrix(X),as.numeric(y[,1]))
coef(cvfit, s = "lambda.1se")



library(readr)
library(tidyverse)
library(mosaic)
library(FNN)

rmse = function(y, ypred) {
  sqrt(mean(data.matrix((y-ypred)^2)))
}

qb <- read.csv("Desktop/SDS_Project/data/qb.csv")


n = nrow(qb)
n_train = round(0.8*n)  # round to nearest integer
n_test = n - n_train
n_train = round(0.8*n)  # round to nearest integer
n_test = n - n_train



qb
drops <- c('position')
qb = qb[ , !(names(qb) %in% drops)]
qb[qb==0] <- NA
colMeans(qb, na.rm=TRUE)
qb$fortyyd[is.na(qb$fortyyd)] <- 4.842579
qb$twentyss[is.na(qb$twentyss)] <- 4.311045
qb$vertical[is.na(qb$vertical)] <- 31.010563
qb$broad[is.na(qb$broad)] <- 109.449275

# WR
# RB
# QB
# Offensive Linemen: OT, OG, C

# re-split into train and test cases with the same sample sizes
train_cases = sample.int(n, n_train, replace=FALSE)
test_cases = setdiff(1:n, train_cases)
qb_train = qb[train_cases,]
qb_test = qb[test_cases,]
Xtrain = model.matrix(~ . - picktotal - 1, data=qb_train)
Xtest = model.matrix(~ . - picktotal - 1, data=qb_test)

ytrain = qb_train$picktotal
ytest = qb_test$picktotal

scale_train = apply(Xtrain, 2, sd)
Xtilde_train = scale(Xtrain, scale = scale_train)
Xtilde_test = scale(Xtest, scale = scale_train)

head(Xtrain, 2)
head(Xtilde_train, 2) %>% round(3)
knn_model = knn.reg(Xtilde_train, Xtilde_test, ytrain, k=7)
knn_model$pred
rmse(ytest, knn_model$pred)



qb_test$knn = knn_model$pred
qb_test$knn_round = as.integer(knn_model$pred/51) + 1
qb_test$round = as.integer(qb_test$picktotal/51) + 1
qb_test
qb_test$idu <- as.numeric(row.names(qb_test))
qb_test
p_test = ggplot(data = qb_test) + 
  geom_point(mapping = aes(x = idu, y = round), color='lightgrey') + 
  theme_bw(base_size=18) 
p_test + geom_point(aes(x = idu, y = round), color='red')
p_test + geom_point(aes(x = idu, y = knn_round), color='red')


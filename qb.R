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



drops <- c('position')
qb = qb[ , !(names(qb) %in% drops)]
qb[qb==0] <- NA
avgs = colMeans(qb, na.rm=TRUE)
qb$fortyyd[is.na(qb$fortyyd)] <- avgs["fortyyd"]
qb$twentyss[is.na(qb$twentyss)] <- avgs["twentyss"]
qb$vertical[is.na(qb$vertical)] <- avgs["vertical"]
qb$broad[is.na(qb$broad)] <- avgs["broad"]

# WR
# RB
# QB
# Offensive Linemen: OT, OG, C

# get best K value
qb_k_percentages <- data.frame("K" = c(), "percentage" =c())
i <- 3
while(i <= 50){
  avg_cols = do(100)*{
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
    knn_model = knn.reg(Xtilde_train, Xtilde_test, ytrain, k=i)
    knn_model$pred
    rmse(ytest, knn_model$pred)
    
    qb_test$knn_round = as.integer(knn_model$pred/51) + 1
    qb_test$round = as.integer(qb_test$picktotal/51) + 1
    qb_test$idu <- as.numeric(row.names(qb_test))
    num_correct = qb_test$idu[qb_test$knn_round == qb_test$round]
    c(NROW(num_correct)/NROW(qb_test))
  }
  d = data.frame("K" = i, "percentage" = mean(avg_cols[["result"]]))
  qb_k_percentages = rbind(qb_k_percentages, d)
  i = i + 1
}

# graph of percentage correct per K value
qb_k_percentages_graph = ggplot(data = qb_k_percentages) + 
  geom_point(mapping = aes(x = K, y = percentage), color='lightgrey') + 
  theme_bw(base_size=18) + geom_path(aes(x = K, y = percentage), color='red') + 
  ylab("Guessed Round Correctly (%)")




# K = 3 is the best
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
knn_model = knn.reg(Xtilde_train, Xtilde_test, ytrain, k=3)

rmse(ytest, knn_model$pred)
qb_test$knn = knn_model$pred
qb_test$knn_round = as.integer(knn_model$pred/51) + 1
qb_test$round = as.integer(qb_test$picktotal/51) + 1
qb_test$idu <- as.numeric(row.names(qb_test))
num_correct = qb_test$idu[qb_test$knn_round == qb_test$round]

# scatter plot containing actual and predicted draft round. Red is our prediction. Idu
# is an arbitrary number meant to represent a unique player. K value is 3
qb_k_3 = ggplot(data = qb_test) + 
  geom_point(mapping = aes(x = idu, y = round), color='lightgrey') + 
  theme_bw(base_size=18) + geom_point(aes(x = idu, y = round), color='red') + geom_point(aes(x = idu, y = knn_round), color='red')


#3 without a doubt the best cause ti just falls off very quickly after that
average_compare = do(100)*{
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
  knn_model = knn.reg(Xtilde_train, Xtilde_test, ytrain, k=3)
  qb_test$knn = knn_model$pred
  qb_test$knn_round = as.integer(knn_model$pred/51) + 1
  qb_test$round = as.integer(qb_test$picktotal/51) + 1
  qb_test$rand = sample(1:5, size = nrow(qb_test), replace = TRUE)
  qb_test$rand
  qb_test$idu <- as.numeric(row.names(qb_test))
  num_correct = qb_test$idu[qb_test$knn_round == qb_test$round]
  rand_correct = qb_test$idu[qb_test$rand == qb_test$round]
  c(NROW(num_correct)/NROW(qb_test),
    NROW(rand_correct)/NROW(qb_test))
}
# print this out to show comparison between our model and null model over 100 runs
colMeans(average_compare)


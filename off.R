library(tidyverse)
library(mosaic)
library(FNN)
rmse = function(y, ypred) {
  sqrt(mean(data.matrix((y-ypred)^2)))
}

ol <- read.csv("Desktop/SDS_Project/data/of.csv")


n = nrow(ol)
n_train = round(0.8*n)  # round to nearest integer
n_test = n - n_train
n_train = round(0.8*n)  # round to nearest integer
n_test = n - n_train



ol
drops <- c('position')
ol = ol[ , !(names(ol) %in% drops)]
ol[ol==0] <- NA
avgs = colMeans(ol, na.rm=TRUE)
ol$fortyyd[is.na(ol$fortyyd)] <- avgs["fortyyd"] 
ol$twentyss[is.na(ol$twentyss)] <- avgs["twentyss"]
ol$vertical[is.na(ol$vertical)] <- avgs["vertical"]
ol$broad[is.na(ol$broad)] <- avgs["broad"]
ol$bench[is.na(ol$bench)] <- avgs["bench"]

# WR
# RB
# ol
# olfensive Linemen: OT, OG, C

# get best K value
kframe_s <- data.frame("K" = c(), "RMEAN_AVERAGE" =c())
i <- 3
while(i <= 50){
  avg_cols = do(100)*{
    train_cases = sample.int(n, n_train, replace=FALSE)
    test_cases = setdiff(1:n, train_cases)
    ol_train = ol[train_cases,]
    ol_test = ol[test_cases,]
    Xtrain = model.matrix(~ . - picktotal - 1, data=ol_train)
    Xtest = model.matrix(~ . - picktotal - 1, data=ol_test)
    
    ytrain = ol_train$picktotal
    ytest = ol_test$picktotal
    
    scale_train = apply(Xtrain, 2, sd)
    Xtilde_train = scale(Xtrain, scale = scale_train)
    Xtilde_test = scale(Xtest, scale = scale_train)
    
    head(Xtrain, 2)
    head(Xtilde_train, 2) %>% round(3)
    knn_model = knn.reg(Xtilde_train, Xtilde_test, ytrain, k=i)
    knn_model$pred
    rmse(ytest, knn_model$pred)
    
    ol_test$knn_round = as.integer(knn_model$pred/51) + 1
    ol_test$round = as.integer(ol_test$picktotal/51) + 1
    ol_test$idu <- as.numeric(row.names(ol_test))
    num_correct = ol_test$idu[ol_test$knn_round == ol_test$round]
    c(NROW(num_correct)/NROW(ol_test))
  }
  d = data.frame("K" = i, "percentage" = mean(avg_cols[["result"]]))
  kframe_s = rbind(kframe_s, d)
  i = i + 1
}


kmeanthing = ggplot(data = kframe_s) + 
  geom_point(mapping = aes(x = K, y = percentage), color='lightgrey') + 
  theme_bw(base_size=18) + geom_path(aes(x = K, y = percentage), color='red') + 
  ylab("Guessed Round Correctly (%)")
kmeanthing
kframe_s



# K = 12 is the best
train_cases = sample.int(n, n_train, replace=FALSE)
test_cases = setdiff(1:n, train_cases)
ol_train = ol[train_cases,]
ol_test = ol[test_cases,]
Xtrain = model.matrix(~ . - picktotal - 1, data=ol_train)
Xtest = model.matrix(~ . - picktotal - 1, data=ol_test)

ytrain = ol_train$picktotal
ytest = ol_test$picktotal

scale_train = apply(Xtrain, 2, sd)
Xtilde_train = scale(Xtrain, scale = scale_train)
Xtilde_test = scale(Xtest, scale = scale_train)

head(Xtrain, 2)
head(Xtilde_train, 2) %>% round(3)
knn_model = knn.reg(Xtilde_train, Xtilde_test, ytrain, k=3)
knn_model$pred
rmse(ytest, knn_model$pred)
ol_test$knn = knn_model$pred
ol_test$knn_round = as.integer(knn_model$pred/51) + 1
ol_test$round = as.integer(ol_test$picktotal/51) + 1
ol_test$idu <- as.numeric(row.names(ol_test))
num_correct = ol_test$idu[ol_test$knn_round == ol_test$round]
num_correct
p_test = ggplot(data = ol_test) + 
  geom_point(mapping = aes(x = idu, y = round), color='lightgrey') + 
  theme_bw(base_size=18) 
p_test + geom_point(aes(x = idu, y = round), color='red')
p_test + geom_point(aes(x = idu, y = knn_round), color='red')


average_compare = do(100)*{
  train_cases = sample.int(n, n_train, replace=FALSE)
  test_cases = setdiff(1:n, train_cases)
  ol_train = ol[train_cases,]
  ol_test = ol[test_cases,]
  Xtrain = model.matrix(~ . - picktotal - 1, data=ol_train)
  Xtest = model.matrix(~ . - picktotal - 1, data=ol_test)
  
  ytrain = ol_train$picktotal
  ytest = ol_test$picktotal
  
  scale_train = apply(Xtrain, 2, sd)
  Xtilde_train = scale(Xtrain, scale = scale_train)
  Xtilde_test = scale(Xtest, scale = scale_train)
  
  head(Xtrain, 2)
  head(Xtilde_train, 2) %>% round(3)
  knn_model = knn.reg(Xtilde_train, Xtilde_test, ytrain, k=3)
  ol_test$knn = knn_model$pred
  ol_test$knn_round = as.integer(knn_model$pred/51) + 1
  ol_test$round = as.integer(ol_test$picktotal/51) + 1
  ol_test$rand = sample(1:5, size = nrow(ol_test), replace = TRUE)
  ol_test$rand
  ol_test$idu <- as.numeric(row.names(ol_test))
  num_correct = ol_test$idu[ol_test$knn_round == ol_test$round]
  rand_correct = ol_test$idu[ol_test$rand == ol_test$round]
  c(NROW(num_correct)/NROW(ol_test),
    NROW(rand_correct)/NROW(ol_test))
}
colMeans(average_compare)

library(tidyverse)
library(mosaic)
library(FNN)
rmse = function(y, ypred) {
  sqrt(mean(data.matrix((y-ypred)^2)))
}

rb <- read.csv("Desktop/SDS_Project/data/rb.csv")


n = nrow(rb)
n_train = round(0.8*n)  # round to nearest integer
n_test = n - n_train
n_train = round(0.8*n)  # round to nearest integer
n_test = n - n_train


drops <- c('position')
rb = rb[ , !(names(rb) %in% drops)]
rb[rb==0] <- NA
avgs = colMeans(rb, na.rm=TRUE)
rb$fortyyd[is.na(rb$fortyyd)] <- avgs["fortyyd"]
rb$twentyss[is.na(rb$twentyss)] <- avgs["twentyss"]
rb$vertical[is.na(rb$vertical)] <- avgs["vertical"]
rb$broad[is.na(rb$broad)] <- avgs["broad"]

# WR
# RB
# rb
# Offensive Linemen: OT, OG, C

# get best K value
rb_k_percentages <- data.frame("K" = c(), "percentage" =c())
i <- 3
while(i <= 50){
  avg_cols = do(100)*{
    train_cases = sample.int(n, n_train, replace=FALSE)
    test_cases = setdiff(1:n, train_cases)
    rb_train = rb[train_cases,]
    rb_test = rb[test_cases,]
    Xtrain = model.matrix(~ . - picktotal - 1, data=rb_train)
    Xtest = model.matrix(~ . - picktotal - 1, data=rb_test)
    
    ytrain = rb_train$picktotal
    ytest = rb_test$picktotal
    
    scale_train = apply(Xtrain, 2, sd)
    Xtilde_train = scale(Xtrain, scale = scale_train)
    Xtilde_test = scale(Xtest, scale = scale_train)
    
    head(Xtrain, 2)
    head(Xtilde_train, 2) %>% round(3)
    knn_model = knn.reg(Xtilde_train, Xtilde_test, ytrain, k=i)
    knn_model$pred
    rmse(ytest, knn_model$pred)
    
    rb_test$knn_round = as.integer(knn_model$pred/51) + 1
    rb_test$round = as.integer(rb_test$picktotal/51) + 1
    rb_test$idu <- as.numeric(row.names(rb_test))
    num_correct = rb_test$idu[rb_test$knn_round == rb_test$round]
    c(NROW(num_correct)/NROW(rb_test))
  }
  d = data.frame("K" = i, "percentage" = mean(avg_cols[["result"]]))
  rb_k_percentages = rbind(rb_k_percentages, d)
  i = i + 1
  
}

# graph of percentage correct per K value
rb_k_percentages_graph = ggplot(data = rb_k_percentages) + 
  geom_point(mapping = aes(x = K, y = percentage), color='lightgrey') + 
  theme_bw(base_size=18) + geom_path(aes(x = K, y = percentage), color='red') + 
  ylab("Guessed Round Correctly (%)")

rb_k_percentages_graph


# K = 5ish is the best
train_cases = sample.int(n, n_train, replace=FALSE)
test_cases = setdiff(1:n, train_cases)
rb_train = rb[train_cases,]
rb_test = rb[test_cases,]
Xtrain = model.matrix(~ . - picktotal - 1, data=rb_train)
Xtest = model.matrix(~ . - picktotal - 1, data=rb_test)

ytrain = rb_train$picktotal
ytest = rb_test$picktotal

scale_train = apply(Xtrain, 2, sd)
Xtilde_train = scale(Xtrain, scale = scale_train)
Xtilde_test = scale(Xtest, scale = scale_train)

head(Xtrain, 2)
head(Xtilde_train, 2) %>% round(3)
knn_model = knn.reg(Xtilde_train, Xtilde_test, ytrain, k=5)
rmse(ytest, knn_model$pred)
rb_test$knn = knn_model$pred
rb_test$knn_round = as.integer(knn_model$pred/51) + 1
rb_test$round = as.integer(rb_test$picktotal/51) + 1
rb_test$idu <- as.numeric(row.names(rb_test))
num_correct = rb_test$idu[rb_test$knn_round == rb_test$round]
# scatter plot containing actual and predicted draft round. Red is our prediction. Idu
# is an arbitrary number meant to represent a unique player. K value is 5
rb_k_5 = ggplot(data = rb_test) + 
  geom_point(mapping = aes(x = idu, y = round), color='lightgrey') + 
  theme_bw(base_size=18) + geom_point(aes(x = idu, y = knn_round), color='red')


#compares with null value
average_compare = do(100)*{
  train_cases = sample.int(n, n_train, replace=FALSE)
  test_cases = setdiff(1:n, train_cases)
  rb_train = rb[train_cases,]
  rb_test = rb[test_cases,]
  Xtrain = model.matrix(~ . - picktotal - 1, data=rb_train)
  Xtest = model.matrix(~ . - picktotal - 1, data=rb_test)
  
  ytrain = rb_train$picktotal
  ytest = rb_test$picktotal
  
  scale_train = apply(Xtrain, 2, sd)
  Xtilde_train = scale(Xtrain, scale = scale_train)
  Xtilde_test = scale(Xtest, scale = scale_train)
  
  head(Xtrain, 2)
  head(Xtilde_train, 2) %>% round(3)
  knn_model = knn.reg(Xtilde_train, Xtilde_test, ytrain, k=5)
  rb_test$knn = knn_model$pred
  rb_test$knn_round = as.integer(knn_model$pred/51) + 1
  rb_test$round = as.integer(rb_test$picktotal/51) + 1
  rb_test$rand = sample(1:5, size = nrow(rb_test), replace = TRUE)
  rb_test$rand
  rb_test$idu <- as.numeric(row.names(rb_test))
  num_correct = rb_test$idu[rb_test$knn_round == rb_test$round]
  rand_correct = rb_test$idu[rb_test$rand == rb_test$round]
  c(NROW(num_correct)/NROW(rb_test),
    NROW(rand_correct)/NROW(rb_test))
}
# print this out to show comparison between our model and null model over 100 runs
colMeans(average_compare)




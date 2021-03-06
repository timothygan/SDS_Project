library(tidyverse)
library(mosaic)
library(FNN)
rmse = function(y, ypred) {
  sqrt(mean(data.matrix((y-ypred)^2)))
}

wr <- read.csv("Desktop/SDS_Project/data/wr.csv")


n = nrow(wr)
n_train = round(0.8*n)  # round to nearest integer
n_test = n - n_train
n_train = round(0.8*n)  # round to nearest integer
n_test = n - n_train


drops <- c('position')
wr = wr[ , !(names(wr) %in% drops)]
wr[wr==0] <- NA
avgs = colMeans(wr, na.rm=TRUE)
wr$fortyyd[is.na(wr$fortyyd)] <- avgs["fortyyd"]
wr$twentyss[is.na(wr$twentyss)] <- avgs["twentyss"]
wr$vertical[is.na(wr$vertical)] <- avgs["vertical"]
wr$broad[is.na(wr$broad)] <- avgs["broad"]
wr$threecone[is.na(wr$threecone)] <- avgs["threecone"]


# WR
# RB
# wr
# Offensive Linemen: OT, OG, C

# get best K value

wr_k_percentages <- data.frame("K" = c(), "percentage" =c())
i <- 3
while(i <= 50){
  avg_cols = do(100)*{
    train_cases = sample.int(n, n_train, replace=FALSE)
    test_cases = setdiff(1:n, train_cases)
    wr_train = wr[train_cases,]
    wr_test = wr[test_cases,]
    Xtrain = model.matrix(~ . - picktotal - 1, data=wr_train)
    Xtest = model.matrix(~ . - picktotal - 1, data=wr_test)
    
    ytrain = wr_train$picktotal
    ytest = wr_test$picktotal
    
    scale_train = apply(Xtrain, 2, sd)
    Xtilde_train = scale(Xtrain, scale = scale_train)
    Xtilde_test = scale(Xtest, scale = scale_train)
    
    head(Xtrain, 2)
    head(Xtilde_train, 2) %>% round(3)
    knn_model = knn.reg(Xtilde_train, Xtilde_test, ytrain, k=i)
    knn_model$pred
    rmse(ytest, knn_model$pred)
    
    wr_test$knn_round = as.integer(knn_model$pred/51) + 1
    wr_test$round = as.integer(wr_test$picktotal/51) + 1
    wr_test$idu <- as.numeric(row.names(wr_test))
    num_correct = wr_test$idu[wr_test$knn_round == wr_test$round]
    c(NROW(num_correct)/NROW(wr_test))
  }
  d = data.frame("K" = i, "percentage" = mean(avg_cols[["result"]]))
  wr_k_percentages = rbind(wr_k_percentages, d)
  i = i + 1
  
}

# graph of percentage correct per K value
wr_k_percentages_graph = ggplot(data = wr_k_percentages) + 
  geom_point(mapping = aes(x = K, y = percentage), color='lightgrey') + 
  theme_bw(base_size=18) + geom_path(aes(x = K, y = percentage), color='red') + 
  ylab("Guessed Round Correctly (%)")

wr_k_percentages_graph


# K = 4 is the best
train_cases = sample.int(n, n_train, replace=FALSE)
test_cases = setdiff(1:n, train_cases)
wr_train = wr[train_cases,]
wr_test = wr[test_cases,]
Xtrain = model.matrix(~ . - picktotal - 1, data=wr_train)
Xtest = model.matrix(~ . - picktotal - 1, data=wr_test)

ytrain = wr_train$picktotal
ytest = wr_test$picktotal

scale_train = apply(Xtrain, 2, sd)
Xtilde_train = scale(Xtrain, scale = scale_train)
Xtilde_test = scale(Xtest, scale = scale_train)

head(Xtrain, 2)
head(Xtilde_train, 2) %>% round(3)
knn_model = knn.reg(Xtilde_train, Xtilde_test, ytrain, k=4)
wr_test$knn = knn_model$pred
wr_test$knn_round = as.integer(knn_model$pred/51) + 1
wr_test$round = as.integer(wr_test$picktotal/51) + 1
wr_test$rand = sample(1:5, size = nrow(wr_test), replace = TRUE)
wr_test$idu <- as.numeric(row.names(wr_test))

# scatter plot containing actual and predicted draft round. Red is our prediction. Idu
# is an arbitrary number meant to represent a unique player. K value is 4
wr_k_4 = ggplot(data = wr_test) + 
  geom_point(mapping = aes(x = idu, y = round), color='lightgrey') + 
  theme_bw(base_size=18)  + geom_point(aes(x = idu, y = knn_round), color='red')
wr_k_4

#p_test = p_test + geom_point(aes(x = idu, y = rand), color='blue')
#p_test

#compares with null value
  average_compare = do(100)*{
    train_cases = sample.int(n, n_train, replace=FALSE)
    test_cases = setdiff(1:n, train_cases)
    wr_train = wr[train_cases,]
    wr_test = wr[test_cases,]
    Xtrain = model.matrix(~ . - picktotal - 1, data=wr_train)
    Xtest = model.matrix(~ . - picktotal - 1, data=wr_test)
    
    ytrain = wr_train$picktotal
    ytest = wr_test$picktotal
    
    scale_train = apply(Xtrain, 2, sd)
    Xtilde_train = scale(Xtrain, scale = scale_train)
    Xtilde_test = scale(Xtest, scale = scale_train)
    
    head(Xtrain, 2)
    head(Xtilde_train, 2) %>% round(3)
    knn_model = knn.reg(Xtilde_train, Xtilde_test, ytrain, k=4)
    wr_test$knn = knn_model$pred
    wr_test$knn_round = as.integer(knn_model$pred/51) + 1
    wr_test$round = as.integer(wr_test$picktotal/51) + 1
    wr_test$rand = sample(1:5, size = nrow(wr_test), replace = TRUE)
    wr_test$rand
    wr_test$idu <- as.numeric(row.names(wr_test))
    num_correct = wr_test$idu[wr_test$knn_round == wr_test$round]
    rand_correct = wr_test$idu[wr_test$rand == wr_test$round]
    c(NROW(num_correct)/NROW(wr_test),
      NROW(rand_correct)/NROW(wr_test))
  }
# print this out to show comparison between our model and null model over 100 runs
  
colMeans(average_compare)


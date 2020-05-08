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



rb
drops <- c('position')
rb = rb[ , !(names(rb) %in% drops)]
rb[rb==0] <- NA
colMeans(rb, na.rm=TRUE)
rb$fortyyd[is.na(rb$fortyyd)] <- 4.528723
rb$twentyss[is.na(rb$twentyss)] <- 4.237053
rb$vertical[is.na(rb$vertical)] <- 34.886719
rb$broad[is.na(rb$broad)] <- 119.119658

# WR
# RB
# rb
# Offensive Linemen: OT, OG, C

# get best K value
kframe_s <- data.frame("K" = c(), "RMEAN_AVERAGE" =c())
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
  kframe_s = rbind(kframe_s, d)
  i = i + 1
  
}


kmeanthing = ggplot(data = kframe_s) + 
  geom_point(mapping = aes(x = K, y = percentage), color='lightgrey') + 
  theme_bw(base_size=18) + geom_path(aes(x = K, y = percentage), color='red') + 
  ylab("Guessed Round Correctly (%)")
kmeanthing
kframe_s



# K = 14ish is the best
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
knn_model = knn.reg(Xtilde_train, Xtilde_test, ytrain, k=14)
knn_model$pred
rmse(ytest, knn_model$pred)
rb_test$knn = knn_model$pred
rb_test$knn_round = as.integer(knn_model$pred/51) + 1
rb_test$round = as.integer(rb_test$picktotal/51) + 1
rb_test$idu <- as.numeric(row.names(rb_test))
num_correct = rb_test$idu[rb_test$knn_round == rb_test$round]
num_correct
p_test = ggplot(data = rb_test) + 
  geom_point(mapping = aes(x = idu, y = round), color='lightgrey') + 
  theme_bw(base_size=18) 
p_test + geom_point(aes(x = idu, y = round), color='red')
p_test + geom_point(aes(x = idu, y = knn_round), color='red')




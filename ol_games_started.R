library(tidyverse)
library(mosaic)
library(FNN)
rmse = function(y, ypred) {
  sqrt(mean(data.matrix((y-ypred)^2)))
}

ol <- read.csv("Desktop/SDS_Project/data/ol_combined.csv")
ol
ol = subset(ol, year <= 2008)
ol
ol = subset(ol, select=c("position", "fortyyd", "twentyss", "vertical", "broad", "bench", "games_played"))
ol
ol = subset(ol, position == "OG" | position =="OT" | position=="C")
ol
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
# QB
# Offensive Linemen: OT, OG, C

# get best K value
kframe_s <- data.frame("K" = c(), "RMEAN_AVERAGE" =c())
i <- 3
while(i <= 30){
  avg_cols = do(100)*{
    train_cases = sample.int(n, n_train, replace=FALSE)
    test_cases = setdiff(1:n, train_cases)
    ol_train = ol[train_cases,]
    ol_test = ol[test_cases,]
    Xtrain = model.matrix(~ . - games_played - 1, data=ol_train)
    Xtest = model.matrix(~ . - games_played - 1, data=ol_test)
    
    ytrain = ol_train$games_played
    ytest = ol_test$games_played
    
    scale_train = apply(Xtrain, 2, sd)
    Xtilde_train = scale(Xtrain, scale = scale_train)
    Xtilde_test = scale(Xtest, scale = scale_train)
    
    head(Xtrain, 2)
    head(Xtilde_train, 2) %>% round(3)
    knn_model = knn.reg(Xtilde_train, Xtilde_test, ytrain, k=i)
    c(rmse(ytest, knn_model$pred))
  }
  d = data.frame("K" = i, "percentage" = mean(avg_cols[["result"]]))
  kframe_s = rbind(kframe_s, d)
  i = i + 1
}


kmeanthing = ggplot(data = kframe_s) + 
  geom_point(mapping = aes(x = K, y = percentage), color='lightgrey') + 
  theme_bw(base_size=18) + geom_path(aes(x = K, y = percentage), color='red') + 
  ylab("RMSE")
kmeanthing
kframe_s



# K = 11 is the best
train_cases = sample.int(n, n_train, replace=FALSE)
test_cases = setdiff(1:n, train_cases)
ol_train = ol[train_cases,]
ol_test = ol[test_cases,]
Xtrain = model.matrix(~ . - games_played - 1, data=ol_train)
Xtest = model.matrix(~ . - games_played - 1, data=ol_test)

ytrain = ol_train$games_played
ytest = ol_test$games_played

scale_train = apply(Xtrain, 2, sd)
Xtilde_train = scale(Xtrain, scale = scale_train)
Xtilde_test = scale(Xtest, scale = scale_train)

head(Xtrain, 2)
head(Xtilde_train, 2) %>% round(3)
knn_model = knn.reg(Xtilde_train, Xtilde_test, ytrain, k=11)
rmse(ytest, knn_model$pred)
ol_test$knn_games = as.integer(knn_model$pred) + 1
ol_test$idu <- as.numeric(row.names(ol_test))
knn_model$pred

p_test = ggplot(data = ol_test) + 
  geom_point(mapping = aes(x = idu, y = games_played), color='lightgrey') + 
  theme_bw(base_size=18) 
p_test + geom_point(aes(x = idu, y = games_played), color='lightgrey')
p_test + geom_point(aes(x = idu, y = knn_games), color='red')


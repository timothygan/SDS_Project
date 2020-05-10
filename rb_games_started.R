library(tidyverse)
library(mosaic)
library(FNN)
rmse = function(y, ypred) {
  sqrt(mean(data.matrix((y-ypred)^2)))
}

rb <- read.csv("Desktop/SDS_Project/data/rb_combined.csv")
rb = subset(rb, year <= 2008)
rb = subset(rb, select=c("position", "fortyyd", "twentyss", "vertical", "broad", "games_played"))
rb = subset(rb, position== "RB")
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
# QB
# Offensive Linemen: OT, OG, C

# get best K value
rb_games_k_rmse <- data.frame("K" = c(), "RMEAN_AVERAGE" =c())
i <- 3
while(i <= 30){
  avg_cols = do(100)*{
    train_cases = sample.int(n, n_train, replace=FALSE)
    test_cases = setdiff(1:n, train_cases)
    rb_train = rb[train_cases,]
    rb_test = rb[test_cases,]
    Xtrain = model.matrix(~ . - picktotal - games_played - 1, data=rb_train)
    Xtest = model.matrix(~ . - picktotal -  games_played - 1, data=rb_test)
    
    ytrain = rb_train$games_played
    ytest = rb_test$games_played
    
    scale_train = apply(Xtrain, 2, sd)
    Xtilde_train = scale(Xtrain, scale = scale_train)
    Xtilde_test = scale(Xtest, scale = scale_train)
    
    head(Xtrain, 2)
    head(Xtilde_train, 2) %>% round(3)
    knn_model = knn.reg(Xtilde_train, Xtilde_test, ytrain, k=i)
    c(rmse(ytest, knn_model$pred))
  }
  d = data.frame("K" = i, "RMEAN_AVERAGE" = mean(avg_cols[["result"]]))
  rb_games_k_rmse = rbind(rb_games_k_rmse, d)
  i = i + 1
}

# graph of RMSE vs K value
rb_games_k_rmse_graph = ggplot(data = rb_games_k_rmse) + 
  geom_point(mapping = aes(x = K, y = RMEAN_AVERAGE), color='lightgrey') + 
  theme_bw(base_size=18) + geom_path(aes(x = K, y = RMEAN_AVERAGE), color='red') + 
  ylab("RMSE")
rb_games_k_rmse_graph




# K = 7ish is best cause doesn't consider too many neighbors but is pretty low
train_cases = sample.int(n, n_train, replace=FALSE)
test_cases = setdiff(1:n, train_cases)
rb_train = rb[train_cases,]
rb_test = rb[test_cases,]
Xtrain = model.matrix(~ .  - games_played - 1, data=rb_train)
Xtest = model.matrix(~ . - games_played  - 1, data=rb_test)
ytrain = rb_train$games_played
ytest = rb_test$games_played
scale_train = apply(Xtrain, 2, sd)
Xtilde_train = scale(Xtrain, scale = scale_train)
Xtilde_test = scale(Xtest, scale = scale_train)

knn_model = knn.reg(Xtilde_train, Xtilde_test, ytrain, k=7)
rb_test$knn_games = as.integer(knn_model$pred)
rb_test$idu <- as.numeric(row.names(rb_test))
# scatter plot containing actual and predicted games_played. Red is our prediction. Idu
# is an arbitrary number meant to represent a unique player. K value is 7
rb_knn_games_started = ggplot(data = rb_test) + 
  geom_point(mapping = aes(x = idu, y = games_played), color='lightgrey') + 
  theme_bw(base_size=18) + geom_point(aes(x = idu, y = games_played), color='lightgrey') + geom_point(aes(x = idu, y = knn_games), color='red')
rb_knn_games_started



## run this to get picktotal vs gamesplayed
rb <- read.csv("Desktop/SDS_Project/data/rb_combined.csv")
rb = subset(rb, year <= 2008)
rb = subset(rb, select=c("position", "fortyyd", "twentyss", "vertical", "broad", "games_played"))
rb = subset(rb, position== "RB")
rb$picktotal[rb$picktotal == 0] = 255
rb_picktotal_gamesplayed = ggplot(data = rb) + 
  geom_point(mapping = aes(x = picktotal, y = games_played), color='red') + 
  theme_bw(base_size=18) 
##

## pick total vs stats
rb <- read.csv("Desktop/SDS_Project/data/rb_combined.csv")
rb = subset(rb, select=c("position", "picktotal", "fortyyd", "twentyss", "vertical", "broad", "games_played"))
rb = subset(rb, position== "RB")
drops <- c('position')
rb = rb[ , !(names(rb) %in% drops)]
rb[rb==0] <- NA

rb_fortyyd_picktotal = ggplot(data = rb) + 
  geom_point(mapping = aes(x = fortyyd, y = picktotal), color='red') + 
  theme_bw(base_size=18) 


rb_twentyss_picktotal = ggplot(data = rb) + 
  geom_point(mapping = aes(x = twentyss, y = picktotal), color='red') + 
  theme_bw(base_size=18) 


rb_vertical_picktotal = ggplot(data = rb) + 
  geom_point(mapping = aes(x = vertical, y = picktotal), color='red') + 
  theme_bw(base_size=18) 
vertical_picktotal

rb_broad_picktotal = ggplot(data = rb) + 
  geom_point(mapping = aes(x = broad, y = picktotal), color='red') + 
  theme_bw(base_size=18) 

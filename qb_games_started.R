library(tidyverse)
library(mosaic)
library(FNN)
rmse = function(y, ypred) {
  sqrt(mean(data.matrix((y-ypred)^2)))
}

qb <- read.csv("Desktop/SDS_Project/data/qb_combined.csv")
qb = subset(qb, year <= 2008)
qb = subset(qb, select=c("position", "fortyyd", "twentyss", "vertical", "broad", "games_played"))
qb = subset(qb, position== "QB")
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
qb_games_k_rmse <- data.frame("K" = c(), "RMEAN_AVERAGE" =c())
i <- 3
while(i <= 30){
  avg_cols = do(100)*{
    train_cases = sample.int(n, n_train, replace=FALSE)
    test_cases = setdiff(1:n, train_cases)
    qb_train = qb[train_cases,]
    qb_test = qb[test_cases,]
    Xtrain = model.matrix(~ . - games_played - 1, data=qb_train)
    Xtest = model.matrix(~ . - games_played - 1, data=qb_test)
    
    ytrain = qb_train$games_played
    ytest = qb_test$games_played
    
    scale_train = apply(Xtrain, 2, sd)
    Xtilde_train = scale(Xtrain, scale = scale_train)
    Xtilde_test = scale(Xtest, scale = scale_train)
    
    head(Xtrain, 2)
    head(Xtilde_train, 2) %>% round(3)
    knn_model = knn.reg(Xtilde_train, Xtilde_test, ytrain, k=i)
    c(rmse(ytest, knn_model$pred))
  }
  d = data.frame("K" = i, "RMEAN_AVERAGE" = mean(avg_cols[["result"]]))
  qb_games_k_rmse = rbind(qb_games_k_rmse, d)
  i = i + 1
}


qb_games_k_rmse_graph = ggplot(data = qb_games_k_rmse) + 
  geom_point(mapping = aes(x = K, y = RMEAN_AVERAGE), color='lightgrey') + 
  theme_bw(base_size=18) + geom_path(aes(x = K, y = RMEAN_AVERAGE), color='red') + 
  ylab("RMSE")




# K = 6ish is the best
train_cases = sample.int(n, n_train, replace=FALSE)
test_cases = setdiff(1:n, train_cases)
qb_train = qb[train_cases,]
qb_test = qb[test_cases,]
Xtrain = model.matrix(~ . - games_played - 1, data=qb_train)
Xtest = model.matrix(~ . - games_played - 1, data=qb_test)

ytrain = qb_train$games_played
ytest = qb_test$games_played

scale_train = apply(Xtrain, 2, sd)
Xtilde_train = scale(Xtrain, scale = scale_train)
Xtilde_test = scale(Xtest, scale = scale_train)

head(Xtrain, 2)
head(Xtilde_train, 2) %>% round(3)
knn_model = knn.reg(Xtilde_train, Xtilde_test, ytrain, k=6)
qb_test$knn_games = as.integer(knn_model$pred) + 1
qb_test$idu <- as.numeric(row.names(qb_test))
# scatter plot containing actual and predicted games_played. Red is our prediction. Idu
# is an arbitrary number meant to represent a unique player. K value is 6
qb_knn_games_started = ggplot(data = qb_test) + 
  geom_point(mapping = aes(x = idu, y = games_played), color='lightgrey') + 
  theme_bw(base_size=18) + geom_point(aes(x = idu, y = games_played), color='lightgrey') + geom_point(aes(x = idu, y = knn_games), color='red')

qb <- read.csv("Desktop/SDS_Project/data/qb_combined.csv")
qb = subset(qb, year <= 2008)
qb = subset(qb, select=c("position", "picktotal", "fortyyd", "twentyss", "vertical", "broad", "games_played"))
qb = subset(qb, position== "QB")
qb$picktotal[qb$picktotal == 0] = 255
qb_picktotal_gamesplayed = ggplot(data = qb) + 
  geom_point(mapping = aes(x = picktotal, y = games_played), color='red') + 
  theme_bw(base_size=18) 


qb <- read.csv("Desktop/SDS_Project/data/qb_combined.csv")
qb = subset(qb, select=c("position", "fortyyd", "twentyss", "vertical", "broad", "picktotal", "games_played"))
qb = subset(qb, position== "QB")
drops <- c('position')
qb = qb[ , !(names(qb) %in% drops)]
qb[qb==0] <- NA

qb_fortyyd_picktotal = ggplot(data = qb) + 
  geom_point(mapping = aes(x = fortyyd, y = picktotal), color='red') + 
  theme_bw(base_size=18) 

qb_twentyss_picktotal = ggplot(data = qb) + 
  geom_point(mapping = aes(x = twentyss, y = picktotal), color='red') + 
  theme_bw(base_size=18) 

qb_vertical_picktotal = ggplot(data = qb) + 
  geom_point(mapping = aes(x = vertical, y = picktotal), color='red') + 
  theme_bw(base_size=18) 

qb_broad_picktotal = ggplot(data = qb) + 
  geom_point(mapping = aes(x = broad, y = picktotal), color='red') + 
  theme_bw(base_size=18) 



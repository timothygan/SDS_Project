library(tidyverse)
library(mosaic)
library(FNN)
rmse = function(y, ypred) {
  sqrt(mean(data.matrix((y-ypred)^2)))
}

ol <- read.csv("Desktop/SDS_Project/data/ol_combined.csv")
ol = subset(ol, year <= 2008)
ol = subset(ol, select=c("position", "fortyyd", "twentyss", "vertical", "broad", "bench", "games_played"))
ol = subset(ol, position == "OG" | position =="OT" | position=="C")
n = nrow(ol)
n_train = round(0.8*n)  # round to nearest integer
n_test = n - n_train
n_train = round(0.8*n)  # round to nearest integer
n_test = n - n_train


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
ol_games_k_rmse <- data.frame("K" = c(), "RMEAN_AVERAGE" =c())
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
  d = data.frame("K" = i, "RMEAN_AVERAGE" = mean(avg_cols[["result"]]))
  ol_games_k_rmse = rbind(ol_games_k_rmse, d)
  i = i + 1
}

# graph of RMSE vs K value
ol_games_k_rmse_graph = ggplot(data = ol_games_k_rmse) + 
  geom_point(mapping = aes(x = K, y = RMEAN_AVERAGE), color='lightgrey') + 
  theme_bw(base_size=18) + geom_path(aes(x = K, y = RMEAN_AVERAGE), color='red') + 
  ylab("RMSE")




# K = 9 is the best
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
knn_model = knn.reg(Xtilde_train, Xtilde_test, ytrain, k=9)
ol_test$knn_games = as.integer(knn_model$pred) + 1
ol_test$idu <- as.numeric(row.names(ol_test))
# scatter plot containing actual and predicted games_played. Red is our prediction. Idu
# is an arbitrary number meant to represent a unique player. K value is 9
ol_knn_games_started = ggplot(data = ol_test) + 
  geom_point(mapping = aes(x = idu, y = games_played), color='lightgrey') + 
  theme_bw(base_size=18) + geom_point(aes(x = idu, y = games_played), color='lightgrey') + geom_point(aes(x = idu, y = knn_games), color='red')


ol <- read.csv("Desktop/SDS_Project/data/ol_combined.csv")
ol = subset(ol, year <= 2008)
ol = subset(ol, select=c("position", "picktotal", "fortyyd", "twentyss", "vertical", "broad", "bench", "games_played"))
ol = subset(ol, position == "OG" | position =="OT" | position=="C")
ol$picktotal[ol$picktotal == 0] = 255
ol_picktotal_gamesplayed = ggplot(data = ol) + 
  geom_point(mapping = aes(x = picktotal, y = games_played), color='red') + 
  theme_bw(base_size=18) 



ol <- read.csv("Desktop/SDS_Project/data/ol_combined.csv")
ol = subset(ol, select=c("position", "picktotal", "fortyyd", "twentyss", "vertical", "broad", "bench", "games_played"))
ol = subset(ol, position == "OG" | position =="OT" | position=="C")
drops <- c('position')
ol = ol[ , !(names(ol) %in% drops)]
ol[ol==0] <- NA
ol_fortyyd_picktotal = ggplot(data = ol) + 
  geom_point(mapping = aes(x = fortyyd, y = picktotal), color='red') + 
  theme_bw(base_size=18) 

ol_twentyss_picktotal = ggplot(data = ol) + 
  geom_point(mapping = aes(x = twentyss, y = picktotal), color='red') + 
  theme_bw(base_size=18) 

ol_vertical_picktotal = ggplot(data = ol) + 
  geom_point(mapping = aes(x = vertical, y = picktotal), color='red') + 
  theme_bw(base_size=18) 

ol_broad_picktotal = ggplot(data = ol) + 
  geom_point(mapping = aes(x = broad, y = picktotal), color='red') + 
  theme_bw(base_size=18) 

ol_bench_picktotal = ggplot(data = ol) + 
  geom_point(mapping = aes(x = bench, y = picktotal), color='red') + 
  theme_bw(base_size=18) 
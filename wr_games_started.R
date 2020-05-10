library(tidyverse)
library(mosaic)
library(FNN)
rmse = function(y, ypred) {
  sqrt(mean(data.matrix((y-ypred)^2)))
}

wr <- read.csv("Desktop/SDS_Project/data/wr_combined.csv")
wr = subset(wr, year <= 2008)
wr = subset(wr, select=c("position", "threecone",  "fortyyd", "twentyss", "vertical", "broad", "games_played"))
wr = subset(wr, position== "WR")
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
# QB
# Offensive Linemen: OT, OG, C

# get best K value
wr_games_k_rmse <- data.frame("K" = c(), "RMEAN_AVERAGE" =c())
i <- 3
while(i <= 30){
  avg_cols = do(100)*{
    train_cases = sample.int(n, n_train, replace=FALSE)
    test_cases = setdiff(1:n, train_cases)
    wr_train = wr[train_cases,]
    wr_test = wr[test_cases,]
    Xtrain = model.matrix(~ . - games_played - 1, data=wr_train)
    Xtest = model.matrix(~ . - games_played - 1, data=wr_test)
    
    ytrain = wr_train$games_played
    ytest = wr_test$games_played
    
    scale_train = apply(Xtrain, 2, sd)
    Xtilde_train = scale(Xtrain, scale = scale_train)
    Xtilde_test = scale(Xtest, scale = scale_train)
    
    head(Xtrain, 2)
    head(Xtilde_train, 2) %>% round(3)
    knn_model = knn.reg(Xtilde_train, Xtilde_test, ytrain, k=i)
    c(rmse(ytest, knn_model$pred))
  }
  d = data.frame("K" = i, "RMEAN_AVERAGE" = mean(avg_cols[["result"]]))
  wr_games_k_rmse = rbind(wr_games_k_rmse, d)
  i = i + 1
}

# graph of RMSE vs K value
wr_games_k_rmse_graph = ggplot(data = wr_games_k_rmse) + 
  geom_point(mapping = aes(x = K, y = RMEAN_AVERAGE), color='lightgrey') + 
  theme_bw(base_size=18) + geom_path(aes(x = K, y = RMEAN_AVERAGE), color='red') + 
  ylab("RMSE")




# K = 8 is the best
train_cases = sample.int(n, n_train, replace=FALSE)
test_cases = setdiff(1:n, train_cases)
wr_train = wr[train_cases,]
wr_test = wr[test_cases,]
Xtrain = model.matrix(~ . - games_played - 1, data=wr_train)
Xtest = model.matrix(~ . - games_played - 1, data=wr_test)
ytrain = wr_train$games_played
ytest = wr_test$games_played
scale_train = apply(Xtrain, 2, sd)
Xtilde_train = scale(Xtrain, scale = scale_train)
Xtilde_test = scale(Xtest, scale = scale_train)
knn_model = knn.reg(Xtilde_train, Xtilde_test, ytrain, k=8)
wr_test$knn_games = as.integer(knn_model$pred) + 1
wr_test$idu <- as.numeric(row.names(wr_test))
# scatter plot containing actual and predicted games_played. Red is our prediction. Idu
# is an arbitrary number meant to represent a unique player. K value is 8
wr_knn_games_started = ggplot(data = wr_test) + 
  geom_point(mapping = aes(x = idu, y = games_played), color='lightgrey') + 
  theme_bw(base_size=18) + geom_point(aes(x = idu, y = games_played), color='lightgrey') + geom_point(aes(x = idu, y = knn_games), color='red')


## run this to get picktotal vs gamesplayed
wr = read.csv("Desktop/SDS_Project/data/wr_combined.csv")
wr = subset(wr, year <= 2008)
wr = subset(wr, select=c("position","picktotal", "threecone",  "fortyyd", "twentyss", "vertical", "broad", "games_played"))
wr = subset(wr, position== "WR")
wr$picktotal[wr$picktotal == 0] = 255
wr_picktotal_gamesplayed = ggplot(data = wr) + 
  geom_point(mapping = aes(x = picktotal, y = games_played), color='red') + 
  theme_bw(base_size=18) 
wr_picktotal_gamesplayed
##

## pick total vs stats
wr = read.csv("Desktop/SDS_Project/data/wr_combined.csv")
wr = subset(wr, select=c("position", "threecone", "picktotal", "fortyyd", "twentyss", "vertical", "broad", "games_played"))
wr = subset(wr, position== "WR")
drops <- c('position')
wr = wr[ , !(names(wr) %in% drops)]
wr[wr==0] <- NA

wr_fortyyd_picktotal = ggplot(data = wr) + 
  geom_point(mapping = aes(x = fortyyd, y = picktotal), color='red') + 
  theme_bw(base_size=18) 

wr_twentyss_picktotal = ggplot(data = wr) + 
  geom_point(mapping = aes(x = twentyss, y = picktotal), color='red') + 
  theme_bw(base_size=18) 

wr_vertical_picktotal = ggplot(data = wr) + 
  geom_point(mapping = aes(x = vertical, y = picktotal), color='red') + 
  theme_bw(base_size=18) 

wr_broad_picktotal = ggplot(data = wr) + 
  geom_point(mapping = aes(x = broad, y = picktotal), color='red') + 
  theme_bw(base_size=18) 

wr_threecone_picktotal = ggplot(data = wr) + 
  geom_point(mapping = aes(x = threecone, y = picktotal), color='red') + 
  theme_bw(base_size=18) 

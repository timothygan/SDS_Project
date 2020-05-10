library(tidyverse)
library(mosaic)
library(FNN)
rmse = function(y, ypred) {
  sqrt(mean(data.matrix((y-ypred)^2)))
}

rb <- read.csv("Desktop/SDS_Project/data/rb_combined.csv")
rb
rb = subset(rb, year <= 2008)
rb
rb = subset(rb, select=c("position", "picktotal", "fortyyd", "twentyss", "vertical", "broad", "games_played"))
rb
rb = subset(rb, position== "RB")
rb
n = nrow(rb)
n_train = round(0.8*n)  # round to nearest integer
n_test = n - n_train
n_train = round(0.8*n)  # round to nearest integer
n_test = n - n_train



rb
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
kframe_s <- data.frame("K" = c(), "RMEAN_AVERAGE" =c())
i <- 3
while(i <= 30){
  avg_cols = do(100)*{
    train_cases = sample.int(n, n_train, replace=FALSE)
    test_cases = setdiff(1:n, train_cases)
    rb_train = rb[train_cases,]
    rb_test = rb[test_cases,]
    Xtrain = model.matrix(~ . - games_played - 1, data=rb_train)
    Xtest = model.matrix(~ . - games_played - 1, data=rb_test)
    
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
rb_train = rb[train_cases,]
rb_test = rb[test_cases,]
Xtrain = model.matrix(~ . - games_played - 1, data=rb_train)
Xtest = model.matrix(~ . - games_played - 1, data=rb_test)

ytrain = rb_train$games_played
ytest = rb_test$games_played

scale_train = apply(Xtrain, 2, sd)
Xtilde_train = scale(Xtrain, scale = scale_train)
Xtilde_test = scale(Xtest, scale = scale_train)

head(Xtrain, 2)
head(Xtilde_train, 2) %>% round(3)
knn_model = knn.reg(Xtilde_train, Xtilde_test, ytrain, k=3)
rmse(ytest, knn_model$pred)
rb_test$knn_games = as.integer(knn_model$pred)
rb_test$idu <- as.numeric(row.names(rb_test))
knn_model$pred

p_test = ggplot(data = rb_test) + 
  geom_point(mapping = aes(x = idu, y = games_played), color='lightgrey') + 
  theme_bw(base_size=18) 
p_test + geom_point(aes(x = idu, y = games_played), color='lightgrey')
p_test + geom_point(aes(x = idu, y = knn_games), color='red')
rb$picktotal[rb$picktotal == 0] = 255

picktotal_gamesplayed = ggplot(data = rb) + 
  geom_point(mapping = aes(x = picktotal, y = games_played), color='red') + 
  theme_bw(base_size=18) 
picktotal_gamesplayed

rb <- read.csv("Desktop/SDS_Project/data/rb_combined.csv")
rb = subset(rb, select=c("position", "picktotal", "fortyyd", "twentyss", "vertical", "broad", "games_played"))
rb = subset(rb, position== "RB")
drops <- c('position')
rb = rb[ , !(names(rb) %in% drops)]
rb[rb==0] <- NA

fortyyd_picktotal = ggplot(data = rb) + 
  geom_point(mapping = aes(x = fortyyd, y = picktotal), color='red') + 
  theme_bw(base_size=18) 
fortyyd_picktotal

twentyss_picktotal = ggplot(data = rb) + 
  geom_point(mapping = aes(x = twentyss, y = picktotal), color='red') + 
  theme_bw(base_size=18) 
twentyss_picktotal

vertical_picktotal = ggplot(data = rb) + 
  geom_point(mapping = aes(x = vertical, y = picktotal), color='red') + 
  theme_bw(base_size=18) 
vertical_picktotal

broad_picktotal = ggplot(data = rb) + 
  geom_point(mapping = aes(x = broad, y = picktotal), color='red') + 
  theme_bw(base_size=18) 
broad_picktotal
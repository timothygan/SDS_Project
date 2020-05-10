library(tidyverse)
library(mosaic)
library(FNN)
rmse = function(y, ypred) {
  sqrt(mean(data.matrix((y-ypred)^2)))
}

of <- read.csv("Desktop/SDS_Project/data/of.csv")


n = nrow(of)
n_train = round(0.8*n)  # round to nearest integer
n_test = n - n_train
n_train = round(0.8*n)  # round to nearest integer
n_test = n - n_train



of
drops <- c('position')
of = of[ , !(names(of) %in% drops)]
of[of==0] <- NA
avgs = colMeans(of, na.rm=TRUE)
of$fortyyd[is.na(of$fortyyd)] <- avgs["fortyyd"] 
of$twentyss[is.na(of$twentyss)] <- avgs["twentyss"]
of$vertical[is.na(of$vertical)] <- avgs["vertical"]
of$broad[is.na(of$broad)] <- avgs["broad"]
of$bench[is.na(of$bench)] <- avgs["bench"]

# WR
# RB
# of
# Offensive Linemen: OT, OG, C

# get best K value
kframe_s <- data.frame("K" = c(), "RMEAN_AVERAGE" =c())
i <- 3
while(i <= 50){
  avg_cols = do(100)*{
    train_cases = sample.int(n, n_train, replace=FALSE)
    test_cases = setdiff(1:n, train_cases)
    of_train = of[train_cases,]
    of_test = of[test_cases,]
    Xtrain = model.matrix(~ . - picktotal - 1, data=of_train)
    Xtest = model.matrix(~ . - picktotal - 1, data=of_test)
    
    ytrain = of_train$picktotal
    ytest = of_test$picktotal
    
    scale_train = apply(Xtrain, 2, sd)
    Xtilde_train = scale(Xtrain, scale = scale_train)
    Xtilde_test = scale(Xtest, scale = scale_train)
    
    head(Xtrain, 2)
    head(Xtilde_train, 2) %>% round(3)
    knn_model = knn.reg(Xtilde_train, Xtilde_test, ytrain, k=i)
    knn_model$pred
    rmse(ytest, knn_model$pred)
    
    of_test$knn_round = as.integer(knn_model$pred/51) + 1
    of_test$round = as.integer(of_test$picktotal/51) + 1
    of_test$idu <- as.numeric(row.names(of_test))
    num_correct = of_test$idu[of_test$knn_round == of_test$round]
    c(NROW(num_correct)/NROW(of_test))
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
of_train = of[train_cases,]
of_test = of[test_cases,]
Xtrain = model.matrix(~ . - picktotal - 1, data=of_train)
Xtest = model.matrix(~ . - picktotal - 1, data=of_test)

ytrain = of_train$picktotal
ytest = of_test$picktotal

scale_train = apply(Xtrain, 2, sd)
Xtilde_train = scale(Xtrain, scale = scale_train)
Xtilde_test = scale(Xtest, scale = scale_train)

head(Xtrain, 2)
head(Xtilde_train, 2) %>% round(3)
knn_model = knn.reg(Xtilde_train, Xtilde_test, ytrain, k=3)
knn_model$pred
rmse(ytest, knn_model$pred)
of_test$knn = knn_model$pred
of_test$knn_round = as.integer(knn_model$pred/51) + 1
of_test$round = as.integer(of_test$picktotal/51) + 1
of_test$idu <- as.numeric(row.names(of_test))
num_correct = of_test$idu[of_test$knn_round == of_test$round]
num_correct
p_test = ggplot(data = of_test) + 
  geom_point(mapping = aes(x = idu, y = round), color='lightgrey') + 
  theme_bw(base_size=18) 
p_test + geom_point(aes(x = idu, y = round), color='red')
p_test + geom_point(aes(x = idu, y = knn_round), color='red')


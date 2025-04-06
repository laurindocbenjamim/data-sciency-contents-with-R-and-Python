# Installing the libraries
#install.packages(e1071)
#install.packages("FNN")
#install.packages("dplyr")

# importing the libraries
library(caret)
library(readxl)
library(yardstick)
library(rpart)
library(pROC)
library(FNN)
library(dplyr)

# Loading the dataset
setwd("~/Documents/RProjects/data-sciency-contents-with-R-and-Python/data-mining/datasets")
data <- read_excel("Classify_risk_dataset.xlsx")

# converting the dataset as dataframe
df <- as.data.frame(data)

# Classifying the dependente variable
df$RISK <- trimws(df$RISK)
df$RISK <- as.factor(df$RISK)
levels(df$RISK) <- c("1", "0") # bad loss=1, good risk = 0
df$RISK <- relevel(df$RISK, ref = "0")

# Removing categorical variables (e.g, characters or factor columns except target)
categorical_vars <- sapply(df, is.factor) | sapply(df, is.character)
categorical_vars["RISK"] <- FALSE # Keep target
df_numeric <- df[, !categorical_vars]

# Normalize the numerical features using min-max normalization
normalize_min_max <- function(x){
  return((x - min(x)) / (max(x) - min(x)))
}

df_numeric_norm <- as.data.frame(lapply(df_numeric[, -ncol(df_numeric)], normalize_min_max)) # Include target
df_norm <- cbind(df_numeric_norm, RISK = df_numeric$RISK)

# set seed for reproducibility
set.seed(123)

# create 10-folds for cross validation
fold_indexes <- createFolds(df_norm$RISK, k = 10)

# Initialize an empty list to store accuracy
accuracy_list <- c()
prob_positive_class <- c()
accuracy_score_vec <- c()
precision_score_vec <- c()
recall_score_vec <- c()
f1_score_vec <- c()
# store AUC values
auc_values <- c()

# ROC Plot setup
plot.new()
plot.window(xlim = c(0, 1), ylim = c(0, 1))
axis(1); axis(2); box()
title(main = "ROC Curves (10-Fold CV)", xlab = "False Positive Rate", ylab = "True Positive Rate")


for(i in 1:10){
  # Split the normalized data into train_set and test_set
  test_indexes <- fold_indexes[[i]]
  train_set <- df_norm[-test_indexes, ]
  test_set <- df_norm[test_indexes, ]
  
  # K-NN with k = 2
  knn_pred <- knn(train = train_set[, -ncol(train_set)],
                  test = test_set[, -ncol(test_set)],
                  cl = train_set$RISK,
                  k = 2,
                  prob = TRUE)
  # Extract probability of being positive (RISK = "1")
  attr_prob <- attr(knn_pred, "prob")
  # If the prediceted class is "1" (Positive), keep the proportion 
  prob_positive <- ifelse(knn_pred == "1", attr_prob, 1 - attr_prob)
  
  # Comput AUC
  roc_curve <- roc(response = test_set$RISK, 
                   predictor = prob_positive, 
                   levels = c("0", "1"), 
                   direction = "<")
  auc_values[i] <- auc(roc_curve)
  cat(sprintf("Fold %d AUC : %.3f\n", i, auc_values[i]))
  
  accuracy_score_vec[i] <- accuracy_vec(test_set$RISK, prob_positive)
}

# Final average AUC
cat(sprintf("\nMean AUC across 10 folds: %.3f\n", mean(auc_values)))

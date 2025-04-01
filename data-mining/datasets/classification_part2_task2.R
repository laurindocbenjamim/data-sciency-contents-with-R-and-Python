
# Installing the libraries
#install.packages("e1071")

# importing the libraries
library(caret)
library(readxl)
library(yardstick)
library(rpart)
library(pROC)
library(e1071)

# Loading the dataset
setwd("~/Documents/RProjects/data-sciency-contents-with-R-and-Python/data-mining/datasets")
dataset <- read_excel("Classify_risk_dataset.xlsx")

# Converting the dataset into dataframe
df <- data.frame(dataset)

# Classifying the dependent variable/attribute
df$RISK <- as.factor(df$RISK)
levels(df$RISK) <- c("1", "0")
df$RISK <- relevel(df$RISK, ref = "0")

# Set seed for reproducibility
set.seed(123)

# Creating the 10-Cross validation to evaluate the performance of a model to predict the
# type of risk, using Naïve Bayes
folder_indexes <- createFolds(df$RISK, k = 10)

# Display the structure of the dataset
str(df)

# Initialize an empty list to store accuracy
accuracy_score <- c()

for(i in 1:10){
  # creating training and testing sets
  test_indexes <- folder_indexes[[i]]
  train_set <- df[-test_indexes, ]
  test_set <- df[test_indexes, ]
  
  # Train Naive Bayes model with the train set
  model <- naiveBayes(RISK ~., data = train_set)
  
}




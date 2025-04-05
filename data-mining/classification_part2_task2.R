
# Importing libraries
library(readxl)
library(caret)
library(yardstick)
library(rpart)
library(pROC)

# Loading the dataset
setwd("~/Documents/RProjects/data-sciency-contents-with-R-and-Python/data-mining/datasets")
data <- read_excel("Classify_risk_dataset.xlsx")
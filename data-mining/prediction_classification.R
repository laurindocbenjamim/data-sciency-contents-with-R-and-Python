## Load the dataset

setwd("/home/feti/Documents/RProjects/data-sciency-contents-with-R-and-Python/data-mining/datasets/")

# installing the package
install.packages("readxl", dependencies = TRUE)
install.packages("caret", dependencies = TRUE)
install.packages("dplyr", dependencies = TRUE)

#load the libray
library(caret)
library(dplyr)
library(readxl)


#Load the dataset
data <- read_excel("Classify_risk_dataset.xlsx")

# First mutation
data <- mutate(data,
               ID = as.character(ID),
               AGE = as.numeric(AGE),
               INCOME = as.numeric(INCOME),
               GENDER = factor(GENDER),
               MARITAL = factor(MARITAL),
               NUMKIDS = as.numeric(NUMKIDS),
               NUMCARDS = as.numeric(NUMCARDS),
               HOWPAID = factor(HOWPAID),
               MORTGAGE = factor(MORTGAGE),
               STORECAR = as.numeric(STORECAR),
               LOANS = as.numeric(LOANS),
               RISK = relevel(factor(RISK), ref = "good risk")
)

# Second mutation for binary conversion
data <- mutate(data,
               RISK = ifelse(RISK == "bad loss", 1, 0)
)

# Set seed for reproducibility
set.seed(123)

#Describe the dataset
?data

#get the dimension of the dataset
dim(data)

# (Display the names of the variables
names(data)

# print the the target attribute
data$RISK

# Converting categorical variable to factors
data$GENDER <- as.factor(data$GENDER)
data$MARITAL <- as.factor(data$MARITAL)
data$HOWPAID <- as.factor(data$HOWPAID)
data$MORTGAGE <- as.factor(data$MORTGAGE)
data$RISK <- as.factor(data$RISK)

cat("Data Structure:\n")
str(data)

# Analysing the data by using the summary function
summary(data)
# Transforming dependent variable into 1 and 0
# Checking levels first
# Transform dependent variable into binary
levels(data$RISK) <- c("good risk", "bad loss")
data$RISK <- relevel(data$RISK, ref = "good risk")

# Create 10 folds
folds <- createFolds(data$RISK, k=10, list=TRUE, returnTrain=FALSE)

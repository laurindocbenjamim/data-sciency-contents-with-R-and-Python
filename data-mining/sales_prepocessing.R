
# Uncomment install.packages lines if you don't have these packages installed
# install.packages("readxl")
# install.packages("caTools")
# install.packages("caret")
 install.packages("randomForest")
#install.packages("readODS")

#library(readODS)
library(readxl)         # For reading Excel files (not used here since we load a CSV)
library(caTools)        # For splitting the dataset
library(caret)          # For evaluation tools like confusionMatrix
library(randomForest)   # For the Random Forest classifier
 
# Loading dataset
dataset <- read.csv("datasets/sales_dataset.csv")

# Taking care of the missing data for column Age
dataset$Age <- ifelse(is.na(dataset$Age), 
                      ave(dataset$Age, FUN = function(x) mean(x, na.rm = TRUE)),
                      dataset$Age
                      )

# Taking care of the missing data for Salary
dataset$Salary <- ifelse(is.na(dataset$Salary), ave(dataset$Salary, FUN = function(x) mean(x, na.rm = TRUE)),
                         dataset$Salary
                          )


# Encoding category variables
# means that converting its  value into numeric value
# We convert column by column

# 1.First Way
# This way is impratical for large amounts of data
#dataset$Country <- factor(dataset$Country,
#                          levels = c('France', 'Angola', 'Brasil'),
#                          labels = c(1, 2, 3))

# Or
#country_levels <- c("France", "Angola", "Brasil")
#country_labels <- seq_along(country_levels) # Generates 1,2,3 dinamically

#dataset$Country <- factor(dataset$Country, levels = country_levels, labels = country_labels)
# Instead of using Factor for huge and critical dataset use Match
#dataset$Country <- match(dataset$Country, country_levels)

# 2. Second way: Optimized Approach for Large Datasets
# Instead of manually defining levels, extract them directly from the dataset:

# Get all unique country names from the dataset
country_levels <- unique(dataset$Country)

# Assigne numerical labels automatically
dataset$Country <- factor(dataset$Country, levels = country_levels, 
                          labels = seq_along(country_levels))
# converting the Purchase values into binnary values
dataset$Purchased <- factor(dataset$Purchased, levels = c('No', 'Yes'),
                            labels = c(1, 0))

# Splitting the datasets into training set and test set

# We define this to generate random numbers
set.seed(123)
split <- sample.split(dataset$Purchased, SplitRatio = 0.8)

training_set <- subset(dataset, split == TRUE)
test_set <- subset(dataset, split == FALSE)

# Features Scaling. 
# Is the process to standardizing or normalizing the values
# transforming thems to be in same scale
# Runnig this code it can raise the error: 'Error in colMeans(x, na.rm = TRUE) : 'x' must be numeric'
# because when we use factor to convert categorical attributo into numeric
# the values remains categorical like "'1' or '0'"
#training_set <- scale(training_set)
#test_set <- scale(test_set)

# in this case we transform only the real numeric attributes
training_set[, 2:3] <- scale(training_set[, 2:3])
test_set[,2:3] <- scale(test_set[, 2:3])

# -------------------------------
# 6. Classification Model: Logistic Regression
# -------------------------------
# Train a logistic regression classifier using all predictors
classifier <- glm(Purchased~ ., family = binomial, data = training_set)

# Predict probabilities in test set
probabilities <- predict(classifier, newdata = test_set, type = "response")

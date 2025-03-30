
#install.packages("readODS")
#library(readODS)

# Loading dataset
dataset <- read.csv("datasets/sales_dataset.csv")
# If need to select specific columns
# dataset <- dataset[, 2:3]


# Splitting the datasets into training set and test set
#install.packages("caTools")
library(caTools)
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
# training_set[, 2:3] <- scale(training_set[, 2:3])
# test_set[,2:3] <- scale(test_set[, 2:3])

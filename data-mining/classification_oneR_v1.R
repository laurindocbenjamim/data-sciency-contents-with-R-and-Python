

# Installing the libraries
# install.package("readxl")
#install.packages("OneR")
# Importing the libraries
library(readxl)
library(OneR)
library(caret)

# Set working directory and load dataset
setwd("~/Documents/RProjects/data-sciency-contents-with-R-and-Python/data-mining/datasets/")
dataset <- read_excel("Classify_risk_dataset.xlsx")

# Convert to data frame
df <- as.data.frame(dataset)

# Classify variables
df$AGE <- as.integer(df$AGE)
df$INCOME <- as.numeric(df$INCOME)
df$GENDER <- as.factor(df$GENDER)
df$MARITAL <- as.factor(df$MARITAL)
df$NUMKIDS <- as.integer(df$NUMKIDS)
df$NUMCARDS <- as.integer(df$NUMCARDS)
df$HOWPAID <- as.factor(df$HOWPAID)
df$MORTGAGE <- as.factor(df$MORTGAGE)
df$STORECAR <- as.integer(df$STORECAR)
df$LOANS <- as.integer(df$LOANS)
df$RISK <- as.factor(df$RISK)

# Display the structure of the dataframe
str(df)

# Check for missing values
cat("Missing values in dataset:\n")
print(colSums(is.na(df)))

# Remove rows with missing values (if any)
df <- na.omit(df)

# Ensure the correct levels for RISK
levels(df$RISK) <- c("1", "0")
df$RISK <- relevel(df$RISK, ref = "0")

# Split data into training and testing sets
set.seed(123)
train_index <- createDataPartition(df$RISK, p = 0.8, list = FALSE)
train_data <- df[train_index, ]
test_data <- df[-train_index, ]

# Check lengths of train and test data
cat("Training data rows:", nrow(train_data), "\n")
cat("Testing data rows:", nrow(test_data), "\n")

# Build the OneR model, excluding ID
oneR_model <- OneR(RISK ~ AGE + INCOME + GENDER + MARITAL + NUMKIDS + NUMCARDS + 
                     HOWPAID + MORTGAGE + STORECAR + LOANS, data = train_data)

# Display the model
print(oneR_model)

# Make predictions on the test data
predictions <- predict(oneR_model, test_data)

# Check lengths of predictions and actual values
cat("Length of predictions:", length(predictions), "\n")
cat("Length of test_data$RISK:", length(test_data$RISK), "\n")

# Calculate accuracy
accuracy_score <- mean(predictions == test_data$RISK, na.rm = TRUE)
cat("Accuracy of the OneR model: ", round(accuracy_score * 100, 2), "%\n")

# Generate confusion matrix
conf_matrix <- table(Predicted = predictions, Actual = test_data$RISK)
print("Confusion Matrix:")
print(conf_matrix)

# Optional: Additional metrics
confusionMatrix(conf_matrix)


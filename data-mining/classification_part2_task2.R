
# Installing the libraries
#install.packages(e1071)

# importing the libraries
library(caret)
library(readxl)
library(yardstick)
library(rpart)
library(pROC)
library(e1071)

# Loading the dataset
setwd("~/Documents/RProjects/data-sciency-contents-with-R-and-Python/data-mining/datasets")
data <- read_excel("Classify_risk_dataset.xlsx")

# Converting the dataset into a dataframe

df <- as.data.frame(data)

# Classifying the dependent variable/attribute
df$RISK <- trimws(df$RISK)
df$RISK <- as.factor(df$RISK)
levels(df$RISK) <- c("1", "0") # bad loss=1, good risk = 0
df$RISK <- relevel(df$RISK, ref = "0")

# Set seed for reproducibility
set.seed(123)

# Checking for missing values in dataset
cat("Checking for missing values in dataset: \n")
print(colSums(is.na(df)))
na.omit(df)

# Creating the 10-Cross validation to evaluate the performance of a model to predict the
# type of risk, using Naïve Bayes
folder_indexes <- createFolds(df$RISK, k = 10)

# Display the structure of the dataset
str(df)

# Initialize an empty list to store accuracy
accuracy_list <- c()
prob_positive_class <- c()
accuracy_score_vec <- c()
precision_score_vec <- c()
recall_score_vec <- c()
f1_score_vec <- c()
auc_values <- c()

# ROC curve plotting setup
plot(NULL, xlim = c(0, 1), ylim = c(0, 1), xlab = "False Positive Rate (FPR)", 
     ylab = "True Positive Rate (TPR)", main = "ROC Curves for 10-Fold Cross-Validation")
abline(a = 0, b = 1, lty = 2, col = "gray")  # Diagonal reference line


for(i in 1:10){
  # creating training and testing sets
  test_indexes <- folder_indexes[[i]]
  train_set <- df[-test_indexes, ]
  test_set <- df[test_indexes, ]
  
  # Train Naive Bayes model with the train set
  model <- naiveBayes(RISK ~., data = train_set)
  # Predict probabilities (type = "raw" gives probabilities for each class)
  probs <- predict(model, test_set, type = "raw")
  
  # Predict classes
  predicted_classes <- predict(model, test_set)
  
  # Calculte accuracy 
  accuracy_score <- mean(predicted_classes == test_set$RISK)
  accuracy_list <- c(accuracy_list, accuracy_score)
  
  # Focus on positive class probabilities (Assuming positive 
  # class is 'bad loss' or 'Positive')
  
  if ("1" %in% colnames(probs)) {
    prob_positive_class <- probs[, "1"]
  } else {
    stop("Positive class '1' not found. Check column names in 'probs'.")
  }
  
  #accuracy_score_vec[i] <- accuracy_vec(test_set$RISK, predicted_classes)
  accuracy_score_vec[i] <- accuracy_vec(truth = test_set$RISK, estimate = predicted_classes)
  
  precision_score_vec[i] <- precision_vec(test_set$RISK, predicted_classes)
  recall_score_vec[i] <- recall_vec(test_set$RISK, predicted_classes)
  f1_score_vec[i] <- f_meas_vec(test_set$RISK, predicted_classes, beta = 1)
  
  # Computing the ROK curve and AUC for each attribute
  roc_curve <- roc(test_set$RISK, prob_positive_class, levels = c("1", "0"), direction = "<")
  auc_values[i] <- auc(roc_curve)
  
  # Plot roc curve for this fold 
  plot.roc(roc_curve, col = rgb(0.2, 0.6, 0.8, alpha = 0.5), add = TRUE)
  
}

# Compute meac auc
mean_auc <- mean(auc_values)

# Calc decision-tree
d_tree_model <- rpart(RISK ~ ., data = df, method = "class")

# Accuracy
cat("Average accuracy accross 10 folds: ", mean(accuracy_list), "\n")

# Summary of positive class probabilities
cat("Mean Probability of positive class: ", mean(prob_positive_class), "\n")

cat("Accuracy score: ", mean(accuracy_score_vec), "\n")
cat("Precision score: ", mean(precision_score_vec), "\n")
cat("Recall score: ", mean(recall_score_vec), "\n")
cat("F-1 Score: ", mean(f1_score_vec), "\n")
cat("Mean AUC: ", mean_auc)

# plot the decision tree
plot(d_tree_model)
text(d_tree_model, use.n = TRUE, cex = 0.8)





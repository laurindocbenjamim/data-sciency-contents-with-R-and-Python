# Importing libraries
library(readxl)
library(caret)
library(yardstick)
library(rpart)
library(pROC)

# Loading the dataset
setwd("~/Documents/RProjects/data-sciency-contents-with-R-and-Python/data-mining/datasets")
data <- read_excel("Classify_risk_dataset.xlsx")

# Converting the dataset into a dataframe
df <- data.frame(data)

# Ensuring RISK is a factor
df$RISK <- as.factor(df$RISK)
levels(df$RISK) <- c("1", "0")  # Ensure correct factor levels
df$RISK <- relevel(df$RISK, ref = "0")  # Set "0" as the reference level

# Creating 10-fold cross-validation
folds_indices <- createFolds(df$RISK, k = 10)

# Display the structure of the dataframe
str(df)

# Initializing performance metrics storage
accuracy <- c()
precision <- c()
recall <- c()
f1_score <- c()
auc_values <- c()  # Store AUC values

# ROC curve plotting setup
plot(NULL, xlim = c(0, 1), ylim = c(0, 1), xlab = "False Positive Rate (FPR)", 
     ylab = "True Positive Rate (TPR)", main = "ROC Curves for 10-Fold Cross-Validation")
abline(a = 0, b = 1, lty = 2, col = "gray")  # Diagonal reference line


for (i in 1:10) {
  # Splitting data into training and testing sets
  train_set <- df[-folds_indices[[i]],]
  test_set <- df[folds_indices[[i]],]
  
  # Logistic Regression Model
  model <- glm(RISK ~ ., data = train_set, family = binomial("logit"))
  
  # Predictions
  pred_probs <- predict(model, test_set, type = "response")
  predicted_classes <- factor(ifelse(pred_probs >= 0.5, "1", "0"), levels = c("0", "1"))  # Convert to factor
  
  # Evaluating model performance
  accuracy[i] <- accuracy_vec(test_set$RISK, predicted_classes)
  precision[i] <- precision_vec(test_set$RISK, predicted_classes)
  recall[i] <- recall_vec(test_set$RISK, predicted_classes)
  f1_score[i] <- f_meas_vec(test_set$RISK, predicted_classes, beta = 1)

  # Compute ROC curve and AUC
  roc_curve <- roc(test_set$RISK, pred_probs, levels = c("0", "1"), direction = "<")
  auc_values[i] <- auc(roc_curve)
  
  # Plot ROC curve for this fold
  plot.roc(roc_curve, col = rgb(0.2, 0.6, 0.8, alpha = 0.5), add = TRUE)
}

# Compute mean AUC
mean_auc <- mean(auc_values)

# Decision Tree Model
tree_model <- rpart(RISK ~ ., data = df, method = "class")

# Displaying results
cat("Mean Accuracy: ", mean(accuracy), "\n")
cat("Mean Precision: ", mean(precision), "\n")
cat("Mean Recall: ", mean(recall), "\n")
cat("Mean F1-score: ", mean(f1_score), "\n")
cat("Mean AUC: ", mean_auc, "\n")

# Plot the decision tree
plot(tree_model)
text(tree_model, use.n = TRUE, cex = 0.8)


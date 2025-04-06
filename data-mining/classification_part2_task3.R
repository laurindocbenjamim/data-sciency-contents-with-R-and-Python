# Load required libraries
library(readxl)
library(caret)
library(FNN)
library(pROC)
library(yardstick)
library(dplyr)

# Load and prepare data
df <- read_excel("Classify_risk_dataset.xlsx")
df <- as.data.frame(df)

# Clean and encode RISK variable
df$RISK <- trimws(df$RISK)
df$RISK <- as.factor(df$RISK)
levels(df$RISK) <- c("1", "0")  # 1 = bad loss (positive), 0 = good risk (negative)
df$RISK <- relevel(df$RISK, ref = "0")

# Remove categorical variables (except target)
categorical_vars <- sapply(df, is.factor) | sapply(df, is.character)
categorical_vars["RISK"] <- FALSE
df_numeric <- df[, !categorical_vars]

# Normalize with Min-Max scaling
normalize_min_max <- function(x) {
  return((x - min(x)) / (max(x) - min(x)))
}
df_numeric_norm <- as.data.frame(lapply(df_numeric[, -ncol(df_numeric)], normalize_min_max))
df_norm <- cbind(df_numeric_norm, RISK = df_numeric$RISK)

# Set seed and create folds
set.seed(123)
folds <- createFolds(df_norm$RISK, k = 10)

# Initialize vectors to store metrics
auc_values <- c()
accuracy_vals <- c()
precision_vals <- c()
recall_vals <- c()
f1_vals <- c()

# ROC Plot setup
plot.new()
plot.window(xlim = c(0, 1), ylim = c(0, 1))
axis(1); axis(2); box()
title(main = "ROC Curves (10-Fold CV)", xlab = "False Positive Rate", ylab = "True Positive Rate")

# Loop over each fold
for (i in 1:10) {
  test_idx <- folds[[i]]
  train_data <- df_norm[-test_idx, ]
  test_data <- df_norm[test_idx, ]
  
  # Train kNN model (k=2)
  knn_pred <- knn(train = train_data[, -ncol(train_data)],
                  test = test_data[, -ncol(test_data)],
                  cl = train_data$RISK,
                  k = 2,
                  prob = TRUE)
  
  # Get probability of positive class (RISK = 1)
  attr_prob <- attr(knn_pred, "prob")
  prob_positive <- ifelse(knn_pred == "1", attr_prob, 1 - attr_prob)
  
  # Convert probabilities to class labels using threshold = 0.5
  pred_class <- ifelse(prob_positive >= 0.5, "1", "0")
  pred_class <- factor(pred_class, levels = c("0", "1"))
  truth <- factor(test_data$RISK, levels = c("0", "1"))
  
  # Compute metrics using yardstick
  accuracy_vals[i] <- accuracy_vec(truth = truth, estimate = pred_class)
  precision_vals[i] <- precision_vec(truth = truth, estimate = pred_class)
  recall_vals[i] <- recall_vec(truth = truth, estimate = pred_class)
  f1_vals[i] <- f_meas_vec(truth = truth, estimate = pred_class, beta = 1)
  
  # Compute AUC
  roc_curve <- roc(truth, prob_positive, levels = c("0", "1"), direction = "<")
  auc_values[i] <- auc(roc_curve)
  
  # Plot ROC curve
  plot.roc(roc_curve, col = rgb(0.3, 0.3, 1, alpha = 0.3), add = TRUE)
}

# Final summaries
cat(sprintf("Mean Accuracy: %.3f\n", mean(accuracy_vals)))
cat(sprintf("Mean Precision: %.3f\n", mean(precision_vals)))
cat(sprintf("Mean Recall: %.3f\n", mean(recall_vals)))
cat(sprintf("Mean F1 Score: %.3f\n", mean(f1_vals)))
cat(sprintf("Mean AUC: %.3f\n", mean(auc_values)))


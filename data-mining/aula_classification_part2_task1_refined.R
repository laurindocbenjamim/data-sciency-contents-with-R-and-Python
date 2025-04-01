# Installing libraries
#install.packages("randomForest")
#install.packages("dplyr")

# Importing libraries
library(readxl)
library(caret)
library(yardstick)
library(rpart)
library(pROC)
library(ROSE)      # For handling class imbalance
library(randomForest)  # For random forest model
library(dplyr)     # For data manipulation

# Loading the dataset
setwd("~/Documents/RProjects/data-sciency-contents-with-R-and-Python/data-mining/datasets")
data <- read_excel("Classify_risk_dataset.xlsx")
df <- data.frame(data)

# Ensuring RISK is a factor
df$RISK <- as.factor(df$RISK)
levels(df$RISK) <- c("1", "0")
df$RISK <- relevel(df$RISK, ref = "0")

# Check class distribution
cat("Class Distribution:\n")
print(table(df$RISK))

# Inspect variable types
cat("\nVariable Types Before Conversion:\n")
str(df)

# Convert all predictors to appropriate types
df <- df %>% mutate_if(is.character, as.factor) %>%  # Convert character to factor
  mutate_if(is.logical, as.numeric) %>%   # Convert logical to numeric
  mutate_if(is.integer, as.numeric)      # Ensure integers are numeric

# Check variable types after conversion
cat("\nVariable Types After Conversion:\n")
str(df)

# Balance the dataset using ROSE
set.seed(123)  # For reproducibility
balanced_df <- ROSE(RISK ~ ., data = df, seed = 123)$data

# Verify the balanced dataset
cat("\nClass Distribution After ROSE:\n")
print(table(balanced_df$RISK))

# Creating 10-fold cross-validation
folds_indices <- createFolds(balanced_df$RISK, k = 10)

# Initialize performance metrics storage
metrics <- data.frame(Fold = 1:10, Accuracy = NA, Precision = NA, Recall = NA, F1 = NA, AUC = NA)

# ROC curve plotting setup
plot(NULL, xlim = c(0, 1), ylim = c(0, 1), xlab = "False Positive Rate (FPR)", 
     ylab = "True Positive Rate (TPR)", main = "ROC Curves for 10-Fold Cross-Validation (Logistic Regression)")
abline(a = 0, b = 1, lty = 2, col = "gray")

# Logistic Regression with Threshold Tuning
for (i in 1:10) {
  train_set <- balanced_df[-folds_indices[[i]],]
  test_set <- balanced_df[folds_indices[[i]],]
  
  # Logistic Regression Model
  model <- glm(RISK ~ ., data = train_set, family = binomial("logit"))
  
  # Predictions (probabilities)
  pred_probs <- predict(model, test_set, type = "response")
  
  # Optimize threshold based on F1-score
  thresholds <- seq(0.1, 0.9, by = 0.05)
  f1_scores <- sapply(thresholds, function(th) {
    preds <- factor(ifelse(pred_probs >= th, "1", "0"), levels = c("1", "0"))  # Match RISK levels
    f_meas_vec(test_set$RISK, preds, beta = 1)
  })
  optimal_threshold <- thresholds[which.max(f1_scores)]
  
  # Apply optimal threshold
  predicted_classes <- factor(ifelse(pred_probs >= optimal_threshold, "1", "0"), levels = c("1", "0"))  # Match RISK levels
  
  # Evaluate performance
  metrics$Accuracy[i] <- accuracy_vec(test_set$RISK, predicted_classes)
  metrics$Precision[i] <- precision_vec(test_set$RISK, predicted_classes)
  metrics$Recall[i] <- recall_vec(test_set$RISK, predicted_classes)
  metrics$F1[i] <- f_meas_vec(test_set$RISK, predicted_classes, beta = 1)
  
  # ROC and AUC
  roc_curve <- roc(test_set$RISK, pred_probs, levels = c("0", "1"), direction = "<")
  metrics$AUC[i] <- auc(roc_curve)
  plot.roc(roc_curve, col = rgb(0.2, 0.6, 0.8, alpha = 0.5), add = TRUE)
}

# Summarize logistic regression results
logistic_summary <- metrics %>% summarise_all(mean, na.rm = TRUE) %>% select(-Fold)
cat("\nLogistic Regression Results (Balanced Data, Optimized Threshold):\n")
print(logistic_summary)

# Decision Tree with Tuning
set.seed(123)
tree_control <- trainControl(method = "cv", number = 10)
tree_grid <- expand.grid(cp = seq(0.01, 0.1, by = 0.01))  # Tune complexity parameter
tree_model <- train(RISK ~ ., data = balanced_df, method = "rpart", 
                    trControl = tree_control, tuneGrid = tree_grid)
cat("\nOptimized Decision Tree Results:\n")
print(tree_model$results[tree_model$results$cp == tree_model$bestTune$cp, ])

# Random Forest Model
set.seed(123)
rf_model <- randomForest(RISK ~ ., data = balanced_df, ntree = 100, importance = TRUE)
rf_pred <- predict(rf_model, balanced_df)
rf_metrics <- data.frame(
  Accuracy = accuracy_vec(balanced_df$RISK, rf_pred),
  Precision = precision_vec(balanced_df$RISK, rf_pred),
  Recall = recall_vec(balanced_df$RISK, rf_pred),
  F1 = f_meas_vec(balanced_df$RISK, rf_pred, beta = 1)
)
cat("\nRandom Forest Results (Full Data):\n")
print(rf_metrics)

# Plot the optimized decision tree
plot(tree_model$finalModel)
text(tree_model$finalModel, use.n = TRUE, cex = 0.8)


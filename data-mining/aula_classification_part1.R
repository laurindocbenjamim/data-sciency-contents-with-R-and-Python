
# importing the libraries
library(readxl)
library(caret)

# Loading the dataset
setwd("~/Documents/RProjects/data-sciency-contents-with-R-and-Python/data-mining/datasets")
data <- read_excel("Classify_risk_dataset.xlsx")

# Converting the datase into a dataframe
df <- data.frame(data)

df$RISK <- as.factor(df$RISK)

levels(df$RISK) <- c(1,0)

df$RISK <- relevel((df$RISK), ref = "0")

folds_indices <- createFolds(df$RISK, k=10)
accuracy <- c()

for(i in 1:10){
  trainset <- df[-folds_indices[[i]]]
  testset <- df[folds_indices[[i]],]
  
  model <- glm(df$RISK ~., trainset[,-1], family = binomial("logit"))
  
  pred_probs <- predict(model, testset[,-1], type="response")
  
  predict_classes <- ifelse(pred_probs >= 0.5, 1, 0)
  accuracy[i] <- sum(predict_classes==testset$RISK)/nrow(testset)
}

mean_accuracy <- mean(accuracy)

cat("Mean accuracy: ", mean_accuracy, "\n")

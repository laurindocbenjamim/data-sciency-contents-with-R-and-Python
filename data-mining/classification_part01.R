

# Installing the libraries
# install.package("readxl")
#install.packages("OneR")
# Importing the libraries
library(readxl)
# Load required package
library(OneR)


#_________________________________________________________________
# PERFORMING THE TASK 01
# importing the datasets
setwd("~/Documents/RProjects/data-sciency-contents-with-R-and-Python/data-mining/datasets/")
dataset <- read_excel("Classify_risk_dataset.xlsx")

# change the object to a data frame
df <- as.data.frame(dataset)

# Display the structure of the dataframe
str(df)

# Classify each attribute and
df_classifier <- sapply(df, class)

print(df_classifier)

#_________________________________________________________________
# PERFORMING THE TASK 01

# Converting the categorical variable if needed
risk_data <- as.data.frame(lapply(df_classifier, as.factor))
##construct a One R model (think on the dependent and independent variables) – function
# OneR of package OneR
# Defining dependent (target) variable and independent variables
# Assuming the target variable is named "RISK"
risk_model <- OneR(RISK ~., data = risk_data)

# print the model summary
print(risk_model)

# predict using the model
predictions <- predict(risk_model, risk_data)

# create confusion-matrix
conf_matrix <- table(Actual=risk_data$RISK, Predicted = predictions)
print(conf_matrix)

# Estimate accuracy
accuracy <- sum(diag(conf_matrix)) / sum(conf_matrix)
print(paste("Models accuracy: ", round(accuracy * 100, 2), "%"))  
  
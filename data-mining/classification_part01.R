

# Installing the libraries
# install.package("readxl")

# Importing the libraries
library(readxl)

# importing the datasets
setwd("~/Documents/RProjects/data-sciency-contents-with-R-and-Python/data-mining/datasets/")
dataset <- read_excel("Classify_risk_dataset.xlsx")

# change the object to a data frame
df <- as.data.frame(dataset)

# Display the structure of the dataframe
str(df)

# Classify each attribute
df_classifier <- sapply(df, class)

print(df_classifier)

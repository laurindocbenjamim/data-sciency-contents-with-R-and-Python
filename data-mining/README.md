
# Build a Classification model Using the OneR package

[CODE FONT](https://github.com/laurindocbenjamim/data-sciency-contents-with-R-and-Python/blob/oneR-package/data-mining/classification_oneR_v1.R) 


📢 **Data Pre-Processing** 
- **Lesson 02.v2**:

# Heart Disease Dataset Merging and Preprocessing Script

## Objective
This script consolidates four heart disease datasets (Cleveland, Hungary, Long Beach VA, and Switzerland) into a unified dataset. It performs data cleaning, standardization, missing value handling, and preliminary analysis.

## Workflow

### 1. Set Working Directory
```R
setwd("/home/feti/Documents/RProjects/data-mining/datasets")
```
- Sets the working directory containing datasets

### 2. Load Datasets
```R
clevelanda_data <- read.csv('cleveland_data.txt', header = TRUE, sep = ",", dec = ".")
hungary_data <- read.csv('hungary_data.txt', header = TRUE, sep = ",", dec = ".")
long_beach_va_data <- read.csv('long-beach-va_data.txt', header = TRUE, sep = ",", dec = ".")
switzerland_data <- read.csv('switzerland_data.txt', header = TRUE, sep = ",", dec = ".")
```
- Reads four datasets from text files

### 3. Add Dataset Origin Identifier
```R
clevelanda_data$origin <- 'cl'  # Cleveland
hungary_data$origin <- 'hu'     # Hungary
long_beach_va_data$origin <- 'lb'  # Long Beach VA
switzerland_data$origin <- 'sw'  # Switzerland
```
- Adds source tracking column

### 4. Standardize Column Names
```R
colnames(switzerland_data)[4] <- "age"
```
- Aligns Swiss dataset's age column

### 5. Clean Hungary Dataset
```R
hungary_data$num <- substr(hungary_data$num, 2, 2)
```
- Extracts relevant diagnostic digit

### 6. Merge Datasets
```R
merged_data <- rbind(clevelanda_data, long_beach_va_data, hungary_data, switzerland_data)
merged_data$ID <- 1:nrow(merged_data)
```
- Combines datasets and adds unique ID

### 7. Preliminary Analysis
```R
summary(merged_data)
sd(merged_data$age, na.rm = TRUE)
mean(merged_data$age, na.rm = TRUE)
min(merged_data$age, na.rm = TRUE)
max(merged_data$age, na.rm = TRUE)
```
- Generates initial statistics

### 8. Handle Missing Values
```R
merged_data[merged_data == "?"] <- NA
```
- Converts placeholders to NA

### 9. Fix Cleveland Thal Variable
```R
merged_data[merged_data$origin == "cl", "thal"] <- substr(
  merged_data[merged_data$origin == "cl", "thal"], 1, 1
)
merged_data$thal <- as.factor(merged_data$thal)
```
- Processes blood flow data

### 10. Encode Categorical Variables
```R
categorical_variable_list <- c("origin", "sex", "cp", "fbs", "restecg", "exang", "slope", "num")
merged_data[, categorical_variable_list] <- lapply(
  merged_data[, categorical_variable_list], as.factor
)
```
- Converts specified variables to factors

### 11. Remove Excessive Missing Data
```R
aux <- apply(merged_data, 1, function(i) sum(is.na(i)))
merged_data <- merged_data[aux <= 3, ]
```
- Filters incomplete records

## Key Improvements
1. Removed redundant ID column assignment
2. Fixed factor conversion implementation
3. Added proper NA handling in calculations
4. Improved column renaming robustness

## Output
Final cleaned dataset (`merged_data`) features:
- Standardized column names
- Factor-encoded categorical variables
- Missing value handling
- Source tracking
- Unique identifiers

Ready for advanced analysis of heart disease predictors.

## Requirements
- Input files must have consistent column structures
- Numeric columns should use compatible formatting
- R version 3.6+ recommended

> **Note**: Original script assumes compatible dataset structures. For production use:
> - Validate column names/orders before merging
> - Consider using column name references instead of indices
> - Add additional data quality checks

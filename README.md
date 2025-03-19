# data-sciency-contents
A collection of data science resources, including tutorials, code snippets, and project ideas. Covers topics like machine learning, data visualization, big data, and AI. Perfect for learners and professionals looking to enhance their data science skills. 🚀📊

# Data Sciency Contents  

🚀 Welcome to **Data Sciency Contents**!  

This repository contains valuable resources on **Data Engineering, Data Science, Data Mining, and Data Analytics**. You'll find tutorials, code snippets, best practices, and project ideas to enhance your data skills.  

## 📌 Topics Covered  
- **Data Engineering**: ETL processes, data pipelines, databases, and cloud data solutions.  
- **Data Science**: Machine learning, deep learning, and statistical analysis.  
- **Data Mining**: Pattern discovery, clustering, and predictive modeling.  
- **Data Analytics**: Data visualization, business intelligence, and insights generation.  

## 📂 How to Use  
Feel free to explore the content, contribute, or suggest improvements. Whether you're a beginner or an experienced data professional, this repository aims to be a valuable learning resource.  

## 🤝 Contributing  
Contributions are welcome! If you have interesting insights, code, or tutorials, feel free to submit a pull request.  

📢 **Stay curious and keep exploring the world of data!**  


## 📌 DATA MINING

📢 **Data Pre-Processing** 
- **Lesson 02**:




Here’s a breakdown of the key functions and parameters used:

**setwd("path")**

Purpose: Sets the working directory where the data files are stored.
Parameter:
"path" → String specifying the directory path.

**read.csv(file, header, sep, dec)**

Purpose: Reads a CSV file into an R data frame.
Parameters:
file → File name.
header = TRUE → Uses the first row as column names.
sep = "," → Defines comma as the column separator.
dec = "." → Specifies decimal point notation.

**summary(dataframe)**

Purpose: Provides a summary of statistics for each column in the data frame.

**substr(x, start, stop)**

Purpose: Extracts substrings from a character vector.
Example:
r
Copy
Edit
hungary_data$num <- substr(hungary_data$num, 2, 2)
Extracts the second character from "num".

**rbind(data1, data2, ...)**

Purpose: Combines multiple data frames by rows.

**seq_len(n)**

Purpose: Creates a sequence of numbers from 1 to n.

**sd(x), mean(x), min(x), max(x)**

Purpose: Compute standard deviation, mean, min, and max.

**str(dataframe)**

Purpose: Displays the structure of the dataset.
**merged_data[merged_data == "?"] <- NA
Purpose: Replaces "?" values with NA.

**as.factor(x)**

Purpose: Converts a variable to a categorical factor.

**lapply(dataframe[, columns], as.factor)**

Purpose: Applies as.factor() to multiple columns at once.

**apply(X, MARGIN, FUN)**

Purpose: Applies a function across rows or columns.
Example:
r
Copy
Edit
aux <- apply(merged_data, 1, function(i) sum(is.na(i)))
1 → Row-wise operation.
sum(is.na(i)) → Counts missing values in each row.

***Merged_data[condition, ]**

Purpose: Filters rows that meet a condition.
Final Thoughts
This script efficiently prepares, cleans, and processes datasets for a data mining project. It ensures data consistency, removes missing values, and converts necessary variables to categorical factors for further analysis.

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

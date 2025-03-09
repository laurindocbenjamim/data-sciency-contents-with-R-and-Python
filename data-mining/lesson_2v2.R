###############################################################################
# Heart Disease Data Merging and Preprocessing Script
# 
# Purpose: Merge and clean heart disease datasets from multiple sources 
#          (Cleveland, Hungary, Switzerland, Long Beach VA) for unified analysis
#
# Input Files (expected in working directory):
# - cleveland_data.txt
# - hungary_data.txt
# - long-beach-va_data.txt
# - switzerland_data.txt
#
# Output File:
# - cleaned_heart_data.csv
#
# Author: Laurindo C. Benjamim
# Date: 09/03/2025
# Version: 1.0
###############################################################################

# Set Working Directory --------------------------------------------------------
# Set this to your actual data directory path
setwd("/home/feti/Documents/RProjects/data-sciency-contents-with-R-and-Python/data-mining/datasets")

# Load Libraries ---------------------------------------------------------------
# (None required - uses base R functionality)

# Data Loading ----------------------------------------------------------------
# Read all datasets with consistent parameters
cleveland_data <- read.csv('cleveland_data.txt', header = TRUE, 
                           sep = ",", dec = ".", na.strings = c("?", "NA"))
hungary_data <- read.csv('hungary_data.txt', header = TRUE, 
                         sep = ",", dec = ".", na.strings = c("?", "NA"))
long_beach_va_data <- read.csv('long-beach-va_data.txt', header = TRUE, 
                               sep = ",", dec = ".", na.strings = c("?", "NA"))
switzerland_data <- read.csv('switzerland_data.txt', header = TRUE, 
                             sep = ",", dec = ".", na.strings = c("?", "NA"))

# Add Data Source Identifiers --------------------------------------------------
cleveland_data$origin <- 'cl'
hungary_data$origin <- 'hu'
long_beach_va_data$origin <- 'lb'
switzerland_data$origin <- 'sw'

# Column Standardization ------------------------------------------------------
# Ensure consistent column names across datasets
colnames(switzerland_data)[colnames(switzerland_data) == "AGE"] <- "age"

# Data Cleaning: Hungary Dataset ----------------------------------------------
# Clean numeric classification column
hungary_data$num <- substr(hungary_data$num, 2, 2)

# Merge Datasets --------------------------------------------------------------
# Verify column compatibility before merging
stopifnot(
  all.equal(
    colnames(cleveland_data),
    colnames(hungary_data),
    colnames(long_beach_va_data),
    colnames(switzerland_data)
  )
)

merged_data <- rbind(
  cleveland_data,
  hungary_data,
  long_beach_va_data,
  switzerland_data
)

# Add Unique Identifier --------------------------------------------------------
merged_data$ID <- seq_len(nrow(merged_data))

# Initial Data Exploration ----------------------------------------------------
cat("\nInitial Data Summary:\n")
print(summary(merged_data))

cat("\nAge Statistics:")
cat("\nMean age:", mean(merged_data$age, na.rm = TRUE))
cat("\nSD age:", sd(merged_data$age, na.rm = TRUE))
cat("\nAge range:", range(merged_data$age, na.rm = TRUE), "\n")

# Data Quality Fixes ----------------------------------------------------------
# Clean thal column for Cleveland data
merged_data[merged_data$origin == "cl", "thal"] <- substr(
  merged_data[merged_data$origin == "cl", "thal"], 1, 1
)

# Factor Conversion ------------------------------------------------------------
categorical_vars <- c("origin", "sex", "cp", "fbs", 
                      "restecg", "exang", "slope", "num", "thal")

merged_data[categorical_vars] <- lapply(
  merged_data[categorical_vars], 
  function(x) factor(x, exclude = c("", " ", NA))
)

# Missing Data Handling -------------------------------------------------------
# Remove rows with >3 missing values
missing_counts <- apply(merged_data, 1, function(x) sum(is.na(x)))
merged_data <- merged_data[missing_counts <= 3, ]

# Display categorical variables to verify changes.
merged_data[, categorical_vars]

# Final Data Structure Check --------------------------------------------------
cat("\nFinal Data Structure:\n")
str(merged_data)

cat("\nMissing Values per Column:")
print(colSums(is.na(merged_data)))

# Export Cleaned Data ---------------------------------------------------------
write.csv(merged_data, "cleaned_heart_data.csv", row.names = FALSE)
cat("\nCleaned data saved as 'cleaned_heart_data.csv'")


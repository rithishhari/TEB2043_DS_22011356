age <- c(55,57,56,52,51,59,58,53,59,55,60,60,60,60,52,55,56,51,60,
         52,54,56,52,57,54,56,58,53,53,50,55,51,57,60,57,55,51,50,57,58)

# TABLE 1: Individual Age Count

age_table <- as.data.frame(table(age))
colnames(age_table) <- c("Staff_Age", "Total_Number_of_Staff")

print(age_table)

# TABLE 2: Age Ranges (5 groups)

age_range <- cut(age,
                 breaks = c(50, 52, 54, 56, 58, 60),
                 include.lowest = TRUE,
                 right = TRUE)

range_table <- as.data.frame(table(age_range))
colnames(range_table) <- c("Age_Range", "Total_Number_of_Staff")

print(range_table)

# Insight

cat("Most staff retire between ages:",
    range_table$Age_Range[which.max(range_table$Total_Number_of_Staff)],
    "\n")

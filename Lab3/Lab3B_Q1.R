scores <- c(33, 24, 54, 94, 16, 89, 60, 6, 77, 61,
            13, 44, 26, 24, 73, 73, 90, 39, 90, 54)

grade_counts <- c(
  sum(scores >= 90 & scores <= 100),  # A
  sum(scores >= 80 & scores <= 89),   # B
  sum(scores >= 70 & scores <= 79),   # C
  sum(scores >= 60 & scores <= 69),   # D
  sum(scores >= 50 & scores <= 59),   # E
  sum(scores <= 49)                   # F
)

grade_table <- data.frame(
  Score = c("90-100", "80-89", "70-79", "60-69", "50-59", "<=49"),
  Grade = c("A", "B", "C", "D", "E", "F"),
  Number_of_Students = grade_counts
)

print(grade_table)

pass_status <- scores > 49
cat("Number Passed:", sum(pass_status), "\n")
cat("Number Failed:", sum(!pass_status), "\n")

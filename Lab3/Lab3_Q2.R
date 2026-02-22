students <- list(
  Robert = 59,
  Hemsworth = 71,
  Scarlett = 83,
  Evans = 68,
  Pratt = 65,
  Larson = 57,
  Holland = 62,
  Paul = 92,
  Simu = 92,
  Renner = 59
)

scores2 <- unlist(students)

highest <- max(scores2)
lowest <- min(scores2)
average <- mean(scores2)

student_highest <- names(scores2)[which(scores2 == highest)]
student_lowest <- names(scores2)[which(scores2 == lowest)]

cat("Highest Score:", highest, "\n")
cat("Lowest Score:", lowest, "\n")
cat("Average Score:", average, "\n")
cat("Student with Highest Score:", student_highest, "\n")
cat("Student with Lowest Score:", student_lowest, "\n")

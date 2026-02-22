weight <- as.numeric(readline("Enter your weight (kg): "))
height <- as.numeric(readline("Enter your height (m): "))

bmi <- weight / (height^2)

cat("Your BMI is:", bmi, "\n")

if (bmi < 18.5) {
  cat("Status: Underweight")
} else if (bmi >= 18.5 && bmi < 25) {
  cat("Status: Normal")
} else if (bmi >= 25 && bmi < 30) {
  cat("Status: Overweight")
} else {
  cat("Status: Obese")
}

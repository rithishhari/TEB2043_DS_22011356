weight <- as.numeric(readline("Enter weight: "))
height <- as.numeric(readline("Enter height: "))

bmi <- weight/(height^2)

underweight <- bmi <= 18.4
normal <- bmi >= 18.5 & bmi <= 24.9
overweight <- bmi >= 25.0 & bmi <= 39.9
obese <- bmi >= 40.0

cat("Underweight:", underweight, "\n")
cat("Normal:", normal, "\n")
cat("Overweight:", overweight, "\n")
cat("Obese:", obese)

cat("Check whether an n digits number is Armstrong or not:\n")
cat("-----------------------------------------------------------\n")

num <- as.integer(readline("Input an integer: "))
original <- num
sum <- 0
digits <- nchar(as.character(num))

while (num > 0) {
  digit <- num %% 10
  sum <- sum + digit^digits
  num <- num %/% 10
}

if (sum == original) {
  cat(original, "is an Armstrong number.\n")
} else {
  cat(original, "is not an Armstrong number.\n")
}

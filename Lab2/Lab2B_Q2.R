str1 <- readline("Enter first string: ")
str2 <- readline("Enter second string: ")

str1_lower <- tolower(str1)
str2_lower <- tolower(str2)

if (str1_lower == str2_lower) {
  cat("The strings are the same")
} else {
  cat("The strings are different")
}

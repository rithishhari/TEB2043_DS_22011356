Array1 <- array(1:24, dim = c(2, 4, 3))

cat("Array1\n")
print(Array1)

Array2 <- array(25:54, dim = c(3, 2, 5))

cat("\nArray2\n")
print(Array2)

cat("\nThe second row of the second matrix of the array:\n")
print(Array1[2, , 2])

cat("\nThe element in the 3rd row and 2nd column of the 1st matrix:\n")
print(Array2[3, 2, 1])

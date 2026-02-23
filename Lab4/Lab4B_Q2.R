V1 <- c(2,3,1,5,4,6,8,7,9)

Matrix1 <- matrix(V1, nrow = 3, ncol = 3)

rownames(Matrix1) <- c("R1","R2","R3")
colnames(Matrix1) <- c("C1","C2","C3")

Matrix2 <- t(Matrix1)

Add <- Matrix1 + Matrix2
Subtract <- Matrix1 - Matrix2
Multiply <- Matrix1 * Matrix2
Divide <- Matrix1 / Matrix2

Matrix1
Matrix2
Add
Subtract
Multiply
Divide

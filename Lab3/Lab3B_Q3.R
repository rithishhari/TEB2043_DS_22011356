students_df <- data.frame(
  Name = c("Robert","Hemsworth","Scarlett","Evans","Pratt",
           "Larson","Holland","Paul","Simu","Renner"),
  Chemistry = c(59,71,83,68,65,57,62,92,92,59),
  Physics = c(89,86,65,52,60,67,40,77,90,61)
)

chem_fail <- sum(students_df$Chemistry <= 49)
phys_fail <- sum(students_df$Physics <= 49)

best_chem <- students_df$Name[which(students_df$Chemistry == max(students_df$Chemistry))]
best_phys <- students_df$Name[which(students_df$Physics == max(students_df$Physics))]

cat("Chemistry Fails:", chem_fail, "\n")
cat("Physics Fails:", phys_fail, "\n")
cat("Best Chemistry Student:", best_chem, "\n")
cat("Best Physics Student:", best_phys, "\n")

name <- readline("Enter your name: ")
phone <- readline("Enter your phone number: ")

name_upper <- toupper(name)

first3 <- substr(phone, 1, 3)
last4 <- substr(phone, nchar(phone)-3, nchar(phone))

cat("Name:", name_upper, "\n")
cat("Phone:", first3, "XXXX", last4)

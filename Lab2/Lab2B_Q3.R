name <- readline("Enter name: ")
phone <- readline("Enter phone number: ")

name2 <- toupper(name)

first3 <- substr(phone,1,3)
last4 <- substr(phone,nchar(phone)-3,nchar(phone))

cat("Hi,",name2,". A verification code has been sent to",
    first3,"-xxxxx",last4)

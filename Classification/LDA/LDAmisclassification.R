#Finds misclassified subjects, as well as estimates the total and group accuracies 
#for the Final Model


cat("\f")
rm(list = ls())

setwd('~/R/LDA/')
source('LDACrossValidation.R')
setwd('~/R/Data/')
data <- cbind(read.table('CC_Beta.txt'),
              read.table('CC_Delta.txt'),
              read.table('CC_High_Alpha.txt'),
              read.table('CC_Low_Alpha.txt'),
              read.table('CC_Theta.txt'))

#Number of trials
n <- 500
accuracies <- matrix(0,nrow = 3)

#Misclassification array
misc <- matrix(0,nrow = 115, ncol = 3)
colnames(misc) <- c("# times misclassified","# times tested","Rate")


###Start trials
for (i in 1:n){
  
  #randomly remove 3 controls and 2 patients to have even # in each group and then shuffle
  #(70 controls and 40 patients)
  data2 <- data[-c(sample(1:73,3),sample(74:115,2)),]
  data2 <- data2[c(sample(1:70,70,replace=F),sample(71:110,40,replace=F)),]
  
  #Record which subjects are being tested
  for (j in 1:110){
    x <- as.integer(rownames(data2[j,]))
    misc[x,2] <- misc[x,2] + 1
  }
  
  #Randomly arranges the 70 controls and the 40 patients
  data2 <- data2[c(sample(1:70,70,replace=F),sample(71:110,40,replace=F)),]
  
  #Uses 6 pc's according to final best model
  LDAoutput <- LDACrossValidation(data2,6,T)
  
  #add accuracies to the vector.  Will be averaged after the loop
  accuracies <- accuracies + LDAoutput[[1]]
  
  #Record which subjects were misclassified
  y <- as.integer(unlist(LDAoutput[[2]]))
  for (j in 1:length(y)){
    misc[y[j],1] <- misc[y[j],1] + 1
  }
}
#Average accuracies across n
accuracies <- accuracies/n

#Calculate misclassification rates
misc[,3] <- round(misc[,1] / misc[,2], digits = 4)

#Add ID numbers in
ids <- read.table('IDs.txt')
colnames(ids) <- "ID"

misc <- cbind(ids,misc)

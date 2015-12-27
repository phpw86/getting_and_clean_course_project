
getwd()
setwd("~/RProgramming/")
library(reshape2)
library(dplyr)

filename <- "getdata_dataset.zip"

## Download and unzip the dataset:
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

# Load activity labels and features
actLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
actLabels[,2] <- as.character(actLabels[,2])
feat <- read.table("UCI HAR Dataset/features.txt")
feat[,2] <- as.character(feat[,2])

# Extracting data on mean and standard deviation
targetfeat <- grep(".*mean.*|.*std.*", feat[,2])
targetfeat_names <- feat[targetfeat,2]
targetfeat_names = gsub('-mean', 'Mean', targetfeat_names)
targetfeat_names = gsub('-std', 'Std', targetfeat_names)
targetfeat_names <- gsub('[-()]', '', targetfeat_names)


# Load datasets
traindat <- read.table("UCI HAR Dataset/train/X_train.txt")[targetfeat]
trainact <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainsub <- read.table("UCI HAR Dataset/train/subject_train.txt")
traindat <- cbind(trainsub, trainact, traindat)

testdat <- read.table("UCI HAR Dataset/test/X_test.txt")[targetfeat]
testact <- read.table("UCI HAR Dataset/test/Y_test.txt")
testsub <- read.table("UCI HAR Dataset/test/subject_test.txt")
testdat <- cbind(testsub, testact, testdat)

# merge and add labels
fin_dat <- rbind(traindat, testdat)
colnames(fin_dat) <- c("subject", "activity", targetfeat_names)

# convert activities & subjects into factors
fin_dat$activity <- factor(fin_dat$activity, levels = actLabels[,1], labels = actLabels[,2])
fin_dat$subject <- as.factor(fin_dat$subject)

fin_dat_melt <- melt(fin_dat, id = c("subject", "activity"))
mean_fin_dat <- dcast(fin_dat_melt, subject + activity ~ variable, mean)

write.table(mean_fin_dat, file="~/RProgramming/clean.txt", row.names = FALSE, quote = FALSE)

getwd()
setwd("~/RProgramming/UCI HAR Dataset/")

library(plyr)
library(dplyr)

#Write Inertial Signals contents to new test and train folders
file_listInert1 <- list.files('~/RProgramming/UCI HAR Dataset/test/Inertial Signals')
file_listInert2 <- list.files('~/RProgramming/UCI HAR Dataset/train/Inertial Signals')
targetdirtest <- c('~/RProgramming/UCI HAR Dataset/test')
origindirtest <- c('~/test/Inertial Signals')
file.copy(from='~/RProgramming/UCI HAR Dataset/test/Inertial Signals', to='~/RProgramming/UCI HAR Dataset/test', recursive=TRUE ,copy.mode=TRUE)

lapply(file_listInert1, function(x) file.copy(paste (origindirtest, x , sep = "/"),  
                                          paste (targetdirtest,x, sep = "/"), recursive = FALSE,  copy.mode = TRUE))

file.copy(from='~/RProgramming/UCI HAR Dataset/test/Inertial Signals', to=)
file_listInert1

file_listfinal1 <- c(file_list1, file_listInert1, file_listInert2)
file_listfinal1 
targetfiles <- c('test','train')

file_list <- list.files(targetfiles, pattern='*.txt')



full_data <- do.call(
  'rbind', lapply(file_listfinal1, FUN=function(files){
    read.table(files, header=TRUE, sep='/')
  }))

library(reshape2)

filename <- "getdata_dataset.zip"

## Download and unzip the dataset:
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

# Load activity labels + features
actLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
actLabels[,2] <- as.character(actLabels[,2])
feat <- read.table("UCI HAR Dataset/features.txt")
feat[,2] <- as.character(feat[,2])

# Extract only the data on mean and standard deviation
targetfeat <- grep(".*mean.*|.*std.*", feat[,2])
targetfeat_names <- feat[targetfeat,2]
targetfeat_names = gsub('-mean', 'Mean', targetfeat_names)
targetfeat_names = gsub('-std', 'Std', targetfeat_names)
targetfeat_names <- gsub('[-()]', '', targetfeat_names)


# Load the datasets
traindat <- read.table("UCI HAR Dataset/train/X_train.txt")[targetfeat]
trainact <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainsub <- read.table("UCI HAR Dataset/train/subject_train.txt")
traindat <- cbind(trainsub, trainact, traindat)

testdat <- read.table("UCI HAR Dataset/test/X_test.txt")[targetfeat]
testact <- read.table("UCI HAR Dataset/test/Y_test.txt")
testsub <- read.table("UCI HAR Dataset/test/subject_test.txt")
testdat <- cbind(testsub, testact, testdat)

# merge datasets and add labels
allData <- rbind(train, test)
colnames(allData) <- c("subject", "activity", featuresWanted.names)

# turn activities & subjects into factors
allData$activity <- factor(allData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
allData$subject <- as.factor(allData$subject)

allData.melted <- melt(allData, id = c("subject", "activity"))
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)

write.table(allData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)

library(data.table)
library(dplyr)

## Download and unzip the dataset:
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
download.file(fileURL,"downloaded_dataset.zip",mode="wb")
unzip(filename) 

# Load activity labels + features & Extracts only the measurements on #the mean and standard deviation for each measurement.

actLabel <- read.table("UCI HAR Dataset/activity_labels.txt",col.names=c("activityId", "activityLabel"))
actFeatures <- read.table("UCI HAR Dataset/features.txt",col.names=c("featureId", "featureLabel"))
actLabel$activityLabel <-gsub("_", "", as.character(actLabel$activityLabel))
reqFeatures <- grep(".*mean.*|.*std.*", actFeatures$featureLabel)

# Load the datasets with mean and standard deviation only
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")
x_train <- read.table("UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("UCI HAR Dataset/train/Y_train.txt")
x_test <- read.table("UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("UCI HAR Dataset/test/Y_test.txt")

#merge 

newSubject <- rbind(subject_train,subject_test)
newX <- rbind(x_train,x_test)
newX <- newX[,reqFeatures]
tempY <- rbind(y_train,y_test)
colnames(tempY) <- c("activityId")
newY <- inner_join(tempY,actLabel)

#Uses descriptive activity names to name the activities in the data set
#Appropriately labels the data set with descriptive variable names.

names(newSubject) <- "subject"
names(newY) <- "activityLabel"

newReqFeatures <- actFeatures[reqFeatures,2]
newReqFeatures <- gsub('-mean', 'Mean', newReqFeatures)
newReqFeatures <- gsub('-std', 'Std', newReqFeatures)
newReqFeatures <- gsub('[-()]', '', newReqFeatures)

names(newX)<- newReqFeatures

data <- cbind(newSubject, newY$activityLabel, newX)

finalTable <- data.table(data)

#5. Independent tidy data set with the average of each variable for each #activity and each subject.
calcData<- finalTable[, lapply(.SD, mean), by=c("subject", "newY$activityLabel")]
write.table(calcData, "tidy.txt", row.name=FALSE)


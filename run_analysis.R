## Melanie D Young
## Getting and Cleaning Data
## 12/24/2015
## source data set: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
##  'features.txt': List of all features.
##  'activity_labels.txt': Links the class labels with their activity name.
##  subject_test.txt:Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30. 
##  subject_train.txt:Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30. 
## 'train/X_train.txt': Training set.
## 'train/y_train.txt': Training labels.
## 'test/X_test.txt': Test set.
## 'test/y_test.txt': Test labels.

# This code will do the following:
# Merge the training and the test sets to create one data set.
# Extract only the measurements on the mean and standard deviation for each measurement. 
# Use descriptive activity names to name the activities in the data set
# Appropriately label the data set with descriptive variable names. 
# Create a second, independent tidy data set with the average of each variable for each activity and each subject.

## check first if the needed packages are installed and loaded
if (!require("data.table")) {
  install.packages("data.table")
}
if (!require("reshape2")) {
  install.packages("reshape2")
}
library('data.table')
library('reshape2')

## load the data
activityLabels <- read.table("./data2/UCI HAR Dataset/activity_labels.txt")[,2]
features <- read.table("./data2/UCI HAR Dataset/features.txt")[,2]

features_logical <- grepl("mean|std", features)

## extract the measurements and mean and standard deviations
X_test <- read.table("./data2/UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./data2/UCI HAR Dataset/test/y_test.txt")

subject_test <- read.table("./data2/UCI HAR Dataset/test/subject_test.txt")
names(X_test) = features

X_test = X_test[,features_logical]
## rename the activities with descriptive activity names
## label the data set with descriptive variable names
y_test[,2] = activityLabels[y_test[,1]]

names(y_test) = c("Activity_ID", "Activity_Label")
names(subject_test) = "subject"

testData <- cbind(as.data.table(subject_test), y_test, X_test)

## now do the same for the training data set
## extract the measurements and mean and standard deviations
X_train <- read.table("./data2/UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./data2/UCI HAR Dataset/train/y_train.txt")

subject_train <- read.table("./data2/UCI HAR Dataset/train/subject_train.txt")
names(X_train) = features

X_train = X_train[,features_logical]
## rename the activities with descriptive activity names
## label the data set with descriptive variable names
y_train[,2] = activityLabels[y_train[,1]]

names(y_train) = c("Activity_ID", "Activity_Label")
names(subject_train) = "subject"

trainData <- cbind(as.data.table(subject_train), y_train, X_train)
## merge the training and test data sets
data = rbind(testData, trainData)
idLabels   = c("subject", "Activity_ID", "Activity_Label")
dataLabels = setdiff(colnames(data), idLabels)
dataFinal     = melt(data, id = idLabels, measure.vars = dataLabels)
# Apply mean function to dataset using dcast function
tidyData   = dcast(dataFinal, subject + Activity_Label ~ variable, mean)
## write out the final, tidy data set
write.table(tidyData, file = "tidy_data_final.txt",row.names = FALSE)

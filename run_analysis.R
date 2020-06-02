library("data.table")
library("dplyr")
library("reshape2")

# To Download Data --> "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
# Make sure to put the dataset in your working Directory

data_dir <- getwd()

# 1- Merging the training and the test sets to create one data set.

# Reading files and checking dimensions
X_train <- read.table(paste0(data_dir, "/UCI HAR Dataset/train/X_train.txt"))
dim(X_train)

Y_train <- read.table(paste0(data_dir, "/UCI HAR Dataset/train/y_train.txt"))
dim(Y_train)

S_train <- read.table(paste0(data_dir, "/UCI HAR Dataset/train/subject_train.txt"))
dim(S_train)

X_test <- read.table(paste0(data_dir, "/UCI HAR Dataset/test/X_test.txt"))
dim(X_test)

Y_test <- read.table(paste0(data_dir, "/UCI HAR Dataset/test/y_test.txt"))
dim(Y_test)

S_test <- read.table(paste0(data_dir, "/UCI HAR Dataset/test/subject_test.txt"))
dim(S_test)

# Merging Step 
X_data <- rbind(X_train, X_test)
dim(X_data)

Y_data <- rbind(Y_train, Y_test)
dim(Y_data)

S_data <- rbind(S_train, S_test)
dim(S_data)

# 2- Extracting only the measurements on the mean and standard deviation for each measurement.

# Getting Feature names 
features <- read.table(paste0(data_dir,"/UCI HAR Dataset/features.txt"))

# Selecting columns which contains 'mean()' or 'std()'
selectedCols <- grep("-(mean|std).*", as.character(features[,2]))
X_data <- X_data[selectedCols]
dim(X_data) # 79/561 columns contains 'mean()' or 'std()'

# 3- Uses descriptive activity names to name the activities in the data set

labels <- read.table(paste0(data_dir, "/UCI HAR Dataset/activity_labels.txt"))
labels[,2] <- as.character(labels[,2])
labels[,2]
allData <- cbind(S_data, Y_data, X_data)
colnames(allData) <- c("Subject", "Activity", selectedColNames)

# Descriptive Activity Names
allData$Activity <- factor(allData$Activity, levels = labels[,1], labels = labels[,2])
allData$Subject <- as.factor(allData$Subject)

# 4- Appropriately labels the data set with descriptive variable names.

selectedColNames <- features[selectedCols, 2]
selectedColNames <- gsub("-mean", "Mean", selectedColNames)
selectedColNames <- gsub("-std", "Std", selectedColNames)
selectedColNames <- gsub("[-()]", "", selectedColNames)

dim(allData)

# 5- From the data set in step 4, creates a second, independent tidy data set 
#    with the average of each variable for each activity and each subject.

meltedData <- melt(allData, id = c("Subject", "Activity"), measure.vars = selectedColNames)
tidyData <- dcast(meltedData, Subject + Activity ~ variable, mean)
dim(tidyData)
write.table(tidyData, "./tidy_dataset.txt", row.names = FALSE, quote = FALSE)

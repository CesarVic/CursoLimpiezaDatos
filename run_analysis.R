## You should create one R script called run_analysis.R that does the following. 
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive activity names.
## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

if (!require("data.table")) {
  install.packages("data.table")
}

if (!require("reshape2")) {
  install.packages("reshape2")
}

require("data.table")

require("reshape2")


## 1. Merges the training and the test sets to create one data set

# read data into data frames
subject_train <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")
subject_test <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")
X_train <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
X_test <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
y_train <- read.table("./data/UCI HAR Dataset/train/y_train.txt")
y_test <- read.table("./data/UCI HAR Dataset/test/y_test.txt")

# add column name for subject files
names(subject_train) <- "subjectID"
names(subject_test) <- "subjectID"

# add column names for measurement files
featureNames <- read.table("./data/UCI HAR Dataset/features.txt")
names(X_train) <- featureNames$V2
names(X_test) <- featureNames$V2

# Load: activity labels
activity_labels <- read.table("./data/UCI HAR Dataset/activity_labels.txt")[,2]

# add column name for label files
y_train[,2] = activity_labels[y_train[,1]]
names(y_train) <- c("activity_ID", "activity_Label")
y_test[,2] = activity_labels[y_test[,1]]
names(y_test) <- c("activity_ID", "activity_Label")

# combine files into one dataset
train <- cbind(subject_train, y_train, X_train)
test <- cbind(subject_test, y_test, X_test)
combined <- rbind(train, test)

# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive activity names.
id_labels   = c("subjectID", "activity_ID", "activity_Label")
data_labels = setdiff(colnames(combined ), id_labels)
melt_data      = melt(combined , id = id_labels, measure.vars = data_labels)

# Apply mean function to dataset using dcast function
tidy_data   = dcast(melt_data, subjectID + activity_Label ~ variable, mean)

# 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.
write.table(tidy_data, file = "./tidy_data.txt")
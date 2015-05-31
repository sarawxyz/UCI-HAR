###
# UCI HAR data - accelerometers
###

# set up
setwd("Documents/DataScience/SlideRule/Data Wrangling/UCI-HAR/")
library(dplyr)
library(tidyr)


# read in data files
list.files("UCI HAR Dataset")
activity <- read.table("UCI HAR Dataset/activity_labels.txt", 
                         col.names = c("act_code", "activity"))
features <- read.table("UCI HAR Dataset/features.txt", 
                       col.names = c("f_num", "feature"))

list.files("UCI HAR Dataset/test")
subject_tst <- read.table("UCI HAR Dataset/test/subject_test.txt",
                          col.names = "subID")
X_tst <- read.table("UCI HAR Dataset/test/X_test.txt")
Y_tst <- read.table("UCI HAR Dataset/test/y_test.txt",
                    col.names = "act_code")

list.files("UCI HAR Dataset/train")
subject_trn <- read.table("UCI HAR Dataset/train/subject_train.txt",
                          col.names = "subID")
X_trn <- read.table("UCI HAR Dataset/train/X_train.txt")
Y_trn <- read.table("UCI HAR Dataset/train/y_train.txt",
                    col.names = "act_code")

# create one big dataset 'har': first rbind the various train and test
# data sets, then rename the feature columns to the feature name, 
# then cbind into a single data frame
subjects <- rbind(subject_trn, subject_tst)

activities <- rbind(Y_trn, Y_tst)
activities <- left_join(activities, activity, by = "act_code")
activities <- select(activities, -act_code)

measurements <- rbind(X_trn, X_tst)
names(measurements) <- features$feature

har <- tbl_df(cbind(subjects, activities, measurements))
head(har)

# only mean and stdev for each measure. rename features ro valid names
# to avoid "duplicate names" error, then select columns with "mean" or
# "std" in name

valid_names <- make.names(names=names(har), unique=TRUE, allow_ = TRUE)
names(har) <- valid_names

har_msd <- har %>%
      select(subID, activity, 
             contains("mean"), 
             contains("std"))


# create a second tidy data set with the average of each variable for 
# each activity and each subject. write to csv.

har_tidy <- har_msd %>%
      group_by(subID, activity) %>%
      summarise_each(funs(mean)) %>%
      un_group()

write.csv(har_tidy, "HAR_tidy.csv", row.names = FALSE)

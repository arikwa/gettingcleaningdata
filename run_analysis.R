#Setting up
#If neccesary - install packages (uncomment next two lines)
#install.packages("dplyr")
#install.packages("tidyr")
library(dplyr)
library(tidyr)

#downloading and unzipping the data files
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="project.zip",method="curl")
unzip("project.zip")

#reading and extracting using dplyr (on created data frames)
subject_test<- tbl_df(read.table("./UCI HAR Dataset/test/subject_test.txt"))
x_test<tbl_df(read.table("./UCI HAR Dataset/test/X_test.txt"))
y_test<-tbl_df(read.table("./UCI HAR Dataset/test/Y_test.txt"))
subject_train<-tbl_df(read.table("./UCI HAR Dataset/train/subject_train.txt"))
x_train<-tbl_df(read.table("./UCI HAR Dataset/train/X_train.txt"))
y_train<-tbl_df(read.table("./UCI HAR Dataset/train/Y_train.txt"))

#merging the data from the files (step 1)
x_data<-rbind_list(x_train,x_test)
subject_data<-rbind_list(subject_train,subject_test)
y_data<-rbind_list(y_train,y_test)

#Labeling the variable with the appropriate descriptive names.
#This is step 4. It's done before merging the data sets to make step 2 easier.
feature_names<-tbl_df(read.table("./UCI HAR Dataset/features.txt"))
names(x_data)<-feature_names[,2]
names(subject_data)<-c("Subject")
names(y_data)<-c("Activity")
combined_data<-cbind(subject_data,y_data,x_data)

#extracting the mean and std. dev. variables (excluding "angle") - (step 2)
step2_data<-select(combined_data, Subject,Activity,contains("mean|std"),-contains("meanFreq|angle"))

#Replacing the Activity numeric values with the corresponding descriptive names (step 3)
activity_names<-tbl_df(read.table("./UCI HAR Dataset/activity_labels.txt"))
steps3_4_data<-mutate(step2_data,Activity=activity_names[Activity,2])

#Tidying the data up (step 5)
step5_data<-group_by(steps3_4_data,Subject,Activity)
tidy_data<-summarise_each(step5_data,funs(mean))

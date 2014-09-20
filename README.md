HOW TO USE THE RAW DATA TO GET TO TIDY_DATA.TXT
===============================================

This file explains how to get from the raw data downloaded from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
to the output in tidy_data.txt by using the run_analysis.R script.
It also explains the code and reasoning behind it.


STEP 1: SET-UP THE ENVIRONMENT
——————————————————————————————
We will use the dplyr and tidyr packages. This requires you to have R version 3.0.2 or newer. In addition, we will be using dplyr version 2.0, so make sure you are up to date on both R and dplyr.

If you have not installed these packages, uncomment the following rows in the script:
#install.packages("dplyr")
#install.packages("tidyr")

Now you should have:
install.packages("dplyr")
install.packages("tidyr")

Next, make sure to load the appropriate libraries with the following script:
library(dplyr)
library(tidyr)


STEP 2: DOWNLOAD AND DATA UNZIP THE FILES
—————————————————————————————————————————
The URL for the data file was given as part of the project description. Assumption is that it is being downloaded to your working directory:

fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="project.zip",method="curl")
unzip("project.zip")

The file was downloaded to your working directory using the file URL, and was named “project.zip”. With the unzip command, we unzipped it, to the following folder/files in your working directory (for detailed description of what’s in the files, read CodeBook.md):

Folder: UCI HAR Dataset
	Files:
	activity_lables.txt (representing the names of the activities)
	features_info.txt (explanation of the experiment and measurement variables)
	features.txt (list of 561 measurement variables)
	README.txt (explanation about the experiment)
	Folders:
	test (data for the test subjects)
	train (data for the train subjects)
	Each of these two folders includes three files - datasets for the measurement variables, 	subject IDs, and activity code - for the test and train subject respectively. In addition,
	there are files for Inertial Signals, which were ignored for the purposes of this project, 	based on the TAs advice.


STEP 3: READ AND EXTRACT DATA USING DPLYR
—————————————————————————————————————————
I decided to use dplyr for the purpose of this analysis, as I find it smoother and easier.
Since dplyr in R studio did not recognize the txt files as data frames, I used tbl_df on read.table command on the files in the working directory (thus making sure data frames are created).
Use this script to read and extract the data:

subject_test<- tbl_df(read.table("./UCI HAR Dataset/test/subject_test.txt"))
x_test<tbl_df(read.table("./UCI HAR Dataset/test/X_test.txt"))
y_test<-tbl_df(read.table("./UCI HAR Dataset/test/Y_test.txt"))
subject_train<-tbl_df(read.table("./UCI HAR Dataset/train/subject_train.txt"))
x_train<-tbl_df(read.table("./UCI HAR Dataset/train/X_train.txt"))
y_train<-tbl_df(read.table("./UCI HAR Dataset/train/Y_train.txt"))



STEP 4: MERGE THE DATA FRAMES YOU CREATED FROM THE FILES
————————————————————————————————————————————————————————
Merging the data is the class project’s step 1 requirement. I integrated the project’s step 4 requirement into this process, as it will allow for an easier execution of the project’s step 2 later on.

From the raw data’s explanation files and URL (http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones) it is clear that the train and test x_data files are comparable, namely using the same variables in the same order for two sets of subjects (train and test subjects). I validated this assumption by using the dim() and names() commands, verifying the the columns/variables are indeed identical (they lack names - use “V3” for the third column, V7 for the seventh, etc.). The number of subjects in both also fits the 70-30% split described in the explanations and subject IDs and activity (y_data) correspond the way they should with both types and number of subjects.
Therefore, I used rbind_list to merge the x_data.
Use this script:

x_data<-rbind_list(x_train,x_test)
subject_data<-rbind_list(subject_train,subject_test)
y_data<-rbind_list(y_train,y_test)

Next, we will attribute the appropriate variable names for the x_data data frame. First we’ll read the relevant data of these names from features.txt file, and then assign them to x_data using the second column of feature_names data frame, which corresponds to the names (feature_names # of rows = data_x # of columns). We will also bind “Subject” and “Activity” as the names for subject_data and y_data:

feature_names<-tbl_df(read.table("./UCI HAR Dataset/features.txt"))
names(x_data)<-feature_names[,2]
names(subject_data)<-c("Subject")
names(y_data)<-c("Activity")

Now, we’ll merge all the data using c_bind - I checked the compatibility earlier in this step:
combined_data<-cbind(subject_data,y_data,x_data)

The reason I chose to use subject_data and y_data before x_data is because later it will make it easier to sort it by subject and activity, and it makes sense to me that tidy data would be presented first by the subject, then by the activities of that subject, and then by all the other corresponding variables.

This step actually completes the class project step 1 and step 4 requirements.


STEP 5: EXTRACT THE MEAN AND STD. DEV. MEASUREMENT VARIABLES FROM THE MERGED DATA FRAME
———————————————————————————————————————————————————————————————————————————————————————
Class project step requires us to extract from the 561 measurement variables only the ones that include the mean and standard deviation. Since we already applied the appropriate names to the variables, we can use the select command to create a dataset with the required variables:

step2_data<-select(combined_data, Subject,Activity,contains("mean|std"),-contains("meanFreq|angle"))

Combined data is the original data frame. We want to keep Subject and Activity, which is why we select them first. The variable names that include mean or std represent the variables we want, so we use the contain() command to get those. However, there are variables that have “meanFreq” as part of their name, and there are the angle variables that all have mean in their names, so we will use -contain() to get rid of those. I should note that I decided not to use the angle variables, as I feel they do not fit the requirement. Having said that, if you choose to include these variables, simply change -contains("meanFreq|angle") to -contains("meanFreq”).


STEP 6: REPLACE THE ACTIVITY NUMERIC VALUES WITH DESCRIPTIVE NAMES
——————————————————————————————————————————————————————————————————
This is the class project’s step 3. As before, we’ll load/read the appropriate file including the activity numeric and string values: activity_labels.txt in this case. This time, as we’re actually replacing the data, we’ll use mutate() command. Since I want to have the secondary data frame the way it is, in case something goes wrong, we’ll assign the revised data to a new data frame:

activity_names<-tbl_df(read.table("./UCI HAR Dataset/activity_labels.txt"))
steps3_4_data<-mutate(step2_data,Activity=activity_names[Activity,2])

The second column of activity_names is the string value corresponding to the numeric value (in the first column and in Activity)


STEP 7: TIDY UP THE DATA
————————————————————————
This is the class project’s step 5. It requires us to create a second, independent tidy data set with the average of each variable for each activity and each subject from the data set in step 4 (step 6 in this file). We’ll use the group_by() command to sort the data by subject and activity (in that order). Then, we’ll calculate the average of the remaining measurement variables using the summarise_each() command:

step5_data<-group_by(steps3_4_data,Subject,Activity)
tidy_data<-summarise_each(step5_data,funs(mean))

We now have the completed all the 5 steps the project required, and have the tidy data set. I understand this to be the correct tidy format (and not, say, have the activity each subject, or have the data sorted by subject and measurement variables (with values of those correspond to each activity as the variables).
In any case, we have 1 observation per row (unique subject and unique activity - means of measurement variables), and 1 variable per column (Subject, Activity, 66 measurement variable means), as it should be.


STEP 8: SAVE, SOURCE, RUN, WRITE
————————————————————————————————
It is my understanding that saving the tidy data set to the file is not part of the script - steps specified by the project do include those, and thus saving it is done from the console. If I’m wrong, just use the write.table line in the script, before this step.

Now - save your script, source/submit it, and run it in the R console.
Next - save tidy_data as a file:

write.table(tidy_data,file=“tidy_data.txt”, row.names=FALSE)

This will save the file in your working directory.

Good luck!





















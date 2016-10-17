run_analysis <- function(directory){
  
  #gotta have dplyr for inner_join(), below
  require(dplyr)
  
  setwd(directory)
  
  #I am sure there is a more elegant way to read in all the data than one by one with a 
  #bunch of hardcoding, and I imagine there are faster ways (fread?) to do it, but this 
  #works and it takes less than a minute, so I am going to live with it and get on with the show. 
  
  features <- read.table("features.txt")
  activity_labels <- read.table("activity_labels.txt")
  
  y_test <- read.table("test/y_test.txt")
  X_test <- read.table("test/X_test.txt")
  subject_test <- read.table("test/subject_test.txt")

  y_train <- read.table("train/y_train.txt")
  X_train <- read.table("train/X_train.txt")
  subject_train <- read.table("train/subject_train.txt")
  
  #There is an influential post that says we do not need anything in the Inertial
  #Signals folders. Good enough for me!!
  #total_acc_x_test <- read.table("test/Inertial_Signals/total_acc_x_test.txt")
  #total_acc_y_test <- read.table("test/Inertial_Signals/total_acc_y_test.txt")
  #total_acc_z_test <- read.table("test/Inertial_Signals/total_acc_z_test.txt")
  #body_gyro_x_test <- read.table("test/Inertial_Signals/body_gyro_x_test.txt")
  #body_gyro_y_test <- read.table("test/Inertial_Signals/body_gyro_y_test.txt")
  #body_gyro_z_test <- read.table("test/Inertial_Signals/body_gyro_z_test.txt")
  #body_acc_x_test <- read.table("test/Inertial_Signals/body_acc_x_test.txt")
  #body_acc_y_test <- read.table("test/Inertial_Signals/body_acc_y_test.txt")
  #body_acc_z_test <- read.table("test/Inertial_Signals/body_acc_z_test.txt")
  #total_acc_x_train <- read.table("train/Inertial_Signals/total_acc_x_train.txt")
  #total_acc_y_train <- read.table("train/Inertial_Signals/total_acc_y_train.txt")
  #total_acc_z_train <- read.table("train/Inertial_Signals/total_acc_z_train.txt")
  #body_gyro_x_train <- read.table("train/Inertial_Signals/body_gyro_x_train.txt")
  #body_gyro_y_train <- read.table("train/Inertial_Signals/body_gyro_y_train.txt")
  #body_gyro_z_train <- read.table("train/Inertial_Signals/body_gyro_z_train.txt")
  #body_acc_x_train <- read.table("train/Inertial_Signals/body_acc_x_train.txt")
  #body_acc_y_train <- read.table("train/Inertial_Signals/body_acc_y_train.txt")
  #body_acc_z_train <- read.table("train/Inertial_Signals/body_acc_z_train.txt")
  
  #convert the integer values in y_test to strings, based on the activity_labels data.frame
  y_test <- inner_join(y_test,activity_labels)
  #get rid of the integer column
  y_test <- data.frame(y_test$V2)
  
  mergetest1 <- cbind(subject_test,y_test)
  names(mergetest1) <- c("Subject","Activity")
  
  #Note syntax to access particular rows in a dataframe:mergetest1[300:310,]
  #mergetest1[300:310,]
  
  #Give column names in X_test descriptive labels
  #Of course, it's arguable if names like tBodyAcc-mean()-X or tBodyAcc-std()-X are "descriptive"
  #Out of the box, features$V2 is a factor, not a character, so convert it
  feature_names <- as.character(features$V2)
  colnames(X_test) <- feature_names
  
  #Now bind X_test to mergetest1
  mergetest2 <- cbind(mergetest1,X_test)
  
  #Gather all the column names
  all_names <- names(mergetest2)
  
  #Next, we only want the mean() and std() measurements, as I understand it  
  #Grep for mean() or std(), and NOT Freq() in their names (assumption on Freq())
  ##std_mean_vector <- intersect(grep("std()|mean()",all_names,value=T),grep("meanFreq()",all_names,value=T,invert=T))
  std_mean_vector <- intersect(grep("Subject|Activity|std()|mean()",all_names,value=T),grep("meanFreq()",all_names,value=T,invert=T))
  
  #Filter the data.frame for just mean() and std() measurements
  test_DF <- mergetest2[,std_mean_vector]
  
  #Go through this exact sequence for the train data
  #convert the integer values in y_train to strings, based on the activity_labels data.frame
  y_train <- inner_join(y_train,activity_labels)
  #get rid of the integer column
  y_train <- data.frame(y_train$V2)
  
  mergetrain1 <- cbind(subject_train,y_train)
  names(mergetrain1) <- c("Subject","Activity")
  
  #Note syntax to access particular rows in a dataframe:mergetrain1[300:310,]
  #mergetrain1[300:310,]
  
  #Give column names in X_train descriptive labels
  #Of course, it's arguable if names like tBodyAcc-mean()-X or tBodyAcc-std()-X are "descriptive"
  #Out of the box, features$V2 is a factor, not a character, so convert it
  feature_names <- as.character(features$V2)
  colnames(X_train) <- feature_names
  
  #Now bind X_train to mergetrain1
  mergetrain2 <- cbind(mergetrain1,X_train)
  
  #Gather all the column names
  all_names <- names(mergetrain2)
  
  #Next, we only want the mean() and std() measurements, as I understand it  
  #Grep for mean() or std(), and NOT Freq() in their names (assumption on Freq())
  ##std_mean_vector <- intersect(grep("std()|mean()",all_names,value=T),grep("meanFreq()",all_names,value=T,invert=T))
  std_mean_vector <- intersect(grep("Subject|Activity|std()|mean()",all_names,value=T),grep("meanFreq()",all_names,value=T,invert=T))
  
  #Filter the data.frame for just mean() and std() measurements
  train_DF <- mergetrain2[,std_mean_vector]
  
  #Combine the tidied, filtered data.frames for test and train. I see no reason to mark which DF a particular row came from.
  myBigDF <- rbind(test_DF,train_DF)
  #print(str(myBigDF))
  #print(unique(myBigDF$Subject))
  #print(unique(myBigDF$Activity))
  #Drum roll please... create a new data frame with the means of each measurement, grouped by Subject and Activity
  means_by_subj_and_activity <- myBigDF %>% group_by(Subject,Activity) %>% summarize_each(funs(mean))
  print(str(means_by_subj_activity))
  #Now write out this data.frame to a file on the disk
  write.table(means_by_subj_and_activity, file = "means_by_subject_and_activity.txt",quote = FALSE,row.names = FALSE)
  
}

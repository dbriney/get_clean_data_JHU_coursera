This document describes the code in my run_analysis.R script.

A disclaimer: I am running short on time (deadline down to hours), I want to stay on schedule, and it is not at all clear what information should go into codebook.md versus the also-required README.txt, so I am flying a bit by the seat of my pants. And, as anyone who has ever written any code for a living knows, I am fighting the syndrome of "Hey, my code works, dammit, why do I have to write a bunch of documentation??!!"

So here goes. I am interpreting the purpose of this file to be something of a pseudocode walkthrough of the script. 

ASSUMPTIONS prior to script execution:

1. The raw data file (UCI HAR Dataset.zip) has been downloaded and unzipped.

2. The "UCI HAR Dataset" directory that is created upon unzipping the .zip file is NOT in any of the relative paths cited in the .R script. Suffice it to say that having white space in the directory name was not a real happy thing in my Mac/Linux world. 

Code walkthrough:

1. require dplyr to be in the environment.

2. The script requires a "directory" input parameter, which is fed to the setwd() function, helping to mitigate the aforementioned whitespace in dirname issue.

3. The eight .txt files that are relevant to the project are individually loaded using read.table(). Yes, I know that there are more elegant ways to do this, but the performance of doing it this way is not punitive. The whole script takes ~ 20 seconds to execute. 

4. For the suite of "test" .txt files:

a. Convert the integer values for activity_labels (1-6) to strings in the y_test data.frame with an inner_join() on the activity_labels data.frame, e.g. convert all 1's to "LAYING" in y_test. 
b. This temporarily gives y_test two columns: V1 (integer) and V2 (string). Strip out the V1 field by defining y_test as y_test$V2.
c. Using cbind(), combine/merge the subject_test and y_test data.frames, resulting in one data.frame with two columns: one for subject (this is the person doing the "LAYING", etc) and the other for the activity ("LAYING", etc). 
d. Rename these two columns with descriptive names by passing in a character vector (c("Subject", "Activity")) to the names(y_test) function. 
e. The X_test data.frame out of the box has column names "V1", "V2"... "V561". We need to give these descriptive column names, so using the features data.frame, store the strings for each column (e.g. tBodyAcc-mean()-X), converted to characters from factors, in a character vector feature_names.
f. Using the colnames() function, rename the "V1", "V2"... "V561" column names in X_test to their corresponding strings as defined in feature_names. 
g. Using cbind(), combine/merge the "Subject + Activity" data.frame created in c. with the X_test data.frame. This gives a data.frame with 2947 observations (rows) and 563 measurements (columns). 
h. Since the project specifies inclusion of only the mean and standard deviation measurements, I interpret this to mean we should keep only those measurements/columns with std() and mean() in their names and filter out all others, including meanFreq(). Accomplish this by using intersect() plus grep() for "Subject|Activity|std()|mean()" and !grep(), i.e. invert=TRUE, for "meanFreq()", and storing the result in a character vector.
i. Filter the data.frame created in g. for only the desired measurements by defining the columns wanted using the character vector created in h and store the resulting data.frame in a new data.frame (test_DF <- mergetest2[,std_mean_vector]). This gives a "test" data.frame with 2947 observations (rows) and 68 measurements (columns). Sure seems right to me. 

5. For the suite of "train" .text files:

a. Repeat steps 4a through 4i above, using different variable names. The result is a "train" data.frame with 7352 observations (rows) and 68 measurements (columns). Sure seems right to me. 

6. Using rbind(), combine the "test" and "train" data.frames into one big data.frame with 10299 rows and the same 68 columns. I see no reason to differentiate the source of a particular observation (row) - i.e. no need to mark whether the row came from the test or the train data.frame. 

7. Create a new data.frame using the dplyr "%>%" operator to string a pass the data.frame created in 6. to group_by and then summarize_each, passing "Subject,Activity" to group_by and "funs(mean)" to summarize_each. The resulting data.frame has 180 rows (30 subjects by 6 activities) and 66 columns (the mean of the the measurements for each combination of Subject + Activity). This, as I understand it, is ultimately what we're after. 

8. Using write.table, with quote = FALSE and row.names = FALSE, create a .txt file on the file system for submission to the good folks at Coursera. 


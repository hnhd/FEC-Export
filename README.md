# FEC Contribution Data Download & Merge
This is a simple script that candidate or committee PAC "Itemized Individual Contributions" and "Other Campaign Contributions" data from the Federal Election Comission (FEC) between 2008 to 2016 and merges the exports into a singular CSV file to be used for analysis. 

## Script Purpose
This script reduces the time spent sorting through the FEC website GUI, downloading, and merging CSV files. 

## Running the Script
In order to run the script ensure that the the working directory is (1) located in a folder (2) that all required packages have been installed. Once both of those have been established, one should be able to run the script and output the contribution CSV into the respective folder. 

The script writes a function, called fec_extract(), which is then used to create the merged contribution CSVs. There are two inputs:

1. **cperson**: This is just the name of congressperson. This variable is responsible for naming the file and exported CSV.
2. **candidateCommitteeId**: This is the exact ID of the committee we're pulling files from. 

The example used in the script is Senator Susan Collins' Leadership Political Action Committee, DIRIGO PAC. The script should create a folder called "Collins" in which is contained the individual CSV sheets and the completed merged sheet entited "Contributions - Collins." The name for the sheet changes when the "cperson" variable is changed.

## Thoughts on Improvemnts and Other Considerations

As of now, the script is semi-inflexible. The script has a singular hard-input of the committee ID and is used to specifically download and merge the "Itemized Individual Contributions" and "Other Campaign Contributions" sections. That being said, the script can be easily rewritten to cater to different types of FEC exports.

There are multiple potential improvements to the code:
1. Remove the individual-specific folder and extraneous CSV files from the merging process. 
2. Build an "instruction" CSV, allowing individuals to aggregate folder names and committee ID's to make the script big-data compatable. 
3. Create an option to allow individuals to customize the year range used.

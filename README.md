# FEC-Export
This is a simple script that downloads "Itemized Individual Contributions" and "Other Campaign Contributions" data from the Federal Election Comission (FEC) from 2008 to 2016 and merges the exports into a singular CSV file to be used for analysis. Specifically,  the script exports a file 

## Script Purpose
This script reduces the time spent sorting through the FEC website GUI, downloading, and merging csv files. 

## Running the Script
In order to run the script ensure that the the working directory is (1) located in a folder (2) that all required packages have been installed. Once both of those have been established, one should be able to run the script and output the contribution csv into the respective folder. 

The example used in the script is Senator Susan Collins' Leadership Political Action Committee, DIRIGO PAC. The script should create a folder called "Collins" in which is contained the individual csv sheets and the completed merged sheet entited "Contributions - Collins."

## Thoughts on Improvemnts and Other Considerations

As of now, the script is semi-inflexible. The script has a singular hard-input of the committee ID and is used to specifically download and merge the "Itemized Individual Contributions" and "Other Campaign Contributions" sections. That being said,  

There are multiple potential improvements to the code:
1. Remove the individual-specific folder and extraneous csv files. 
2. Build an instruction csv, allowing individuals to aggregate folder names and committee ID's to make the script big-data compatable. 
3. Create an option to allow individuals to customize the year range used.

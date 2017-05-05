# FEC Contribution Data Download & Merge
This is a simple script that extracts candidate or leadership PAC "Itemized Individual Contributions" and "Other Campaign Contributions" data from the Federal Election Comission (FEC) between 2008 to 2018 and merges the exports into a singular CSV file to be used for analysis. 

## Script Purpose
This script reduces the time spent sorting through the FEC website GUI, downloading, and merging CSV files. 

## Running the Script
In order to run the script ensure that the the working directory is (1) located in the desired folder (2) that all required packages have been installed. Once both of those have been established, one should be able to run the script and output the contribution CSV into the respective folder. 

The script writes two functions, one called fec_lead_extract() the other fec_camp_extract(). As you might've guessed, the first script is for pulling and merging leadeship PAC contribution data, whereas the second is for pulling and merging campaign committee contribution data. 

### Necessary Fields

The following fields need to be populated to run fec_lead_extract():

|       variable       |                                                                                                              description                                                                                                             |        example       |
|:--------------------:|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|:--------------------:|
| cperson              | This is just the name of congressperson. This variable is responsible for naming the file and exported CSV.                                                                                                                          | 'Capito'             |
| candCmtNameMn        | This is just the name of the leadership PAC. This variable is used to distinguish leadership PAC data from campaign committee data. PAC names can be found [here](https://www.opensecrets.org/pacs/industry.php?txt=Q03&cycle=2016). | 'Wild and Wonderful' |
| candidateCommitteeId | This is the exact ID of the committee we're pulling files from.                                                                                                                                                                      | 'C00489336'          |

To run the script to return the aggregated data for Capito's leadership PAC, run the following code:

`fec_lead_extract("Capito", "Wild and Wonderful", "C00489336")`

The following fields need to be populated to run fec_camp_extract():

| variable |                                                            description                                                           |   example   |
|:--------:|:--------------------------------------------------------------------------------------------------------------------------------:|:-----------:|
| cperson  | This is just the name of congressperson. This variable is responsible for naming the file and exported CSV.                      | 'Capito'    |
| senID    | This is the exact ID of the senate committee we're pulling files from. Only applicable to current or former U.S. senators.       | 'S4WV00159' |
| houseID  | This is the exact ID of the house committee we're pulling files from. Only applicable to current or former U.S. representatives. | 'H0WV02138' |

To run the script to return the aggregated data for Capito's house and senate campaigns, run the following code:

`fec_camp_extract("Capito", "S4WV00159", "H0WV02138")`

### Script Storage Process

The example used in the script is Senator Shelley Moore Capito's Leadership Political Action Committee, WILD & WONDERFUL PAC. The script, when run, should create three folders entitled "Leadership", "Campaign", and "Final". Then, it should create folders within the Leadership and Campaign folders entitled "Capito" where downloaded sheets are stored. After that, the script will merge the downloaded sheets and put the output in the "Finals" folder where they can be used for analysis.

## Thoughts on Improvemnts and Other Considerations

As of now, the script is semi-inflexible. The script has a singular hard-input of the committee ID and is used to specifically download and merge the "Itemized Individual Contributions" and "Other Campaign Contributions" sections. That being said, the script can be easily rewritten to cater to different types of FEC exports.

There are multiple potential improvements to the code:
1. Remove the individual-specific folder and extraneous CSV files from the merging process. This is a low priority, as the CSV files are helpful for fact-checking work.
2. Create an option to allow individuals to customize the year range used.

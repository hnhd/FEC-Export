# ===========================================================================================
# Troubleshooting & Prelimnary Informaton
# ===========================================================================================

# 1.) Set working directory to the file where the csvs are located.
# 2.) Ensure all packages have been installed.

# ===========================================================================================
# Load Libraries & Working Directory
# ===========================================================================================

# load packages
library(gtools) # needed for smartbind
library(httr)
library(jsonlite)
library(tidyverse)

# set the working directory
setwd()

# ===========================================================================================
# Build the Function
# ===========================================================================================

fec_lead_extract <- function(cperson, typeCmt, candidateCommitteeId){ # wrap the process in a function
dfCmt <- data.frame(
  "cont_type" = c(rep("Itemized Individual Contributions", 6), rep("Other Committees Contributions", 6)),
  "abbrev" = c(rep("II", 6), rep("OC", 6)),
  "lnnum" = c(rep("F3X#11AI", 6), rep("F3X#11C", 6)),
  "year" = c(rep(c("2008", "2010", "2012", "2014", "2016", "2018"), 2)))

dir.create(cperson)

for (i in 1:length(dfCmt$cont_type)) {
  electionYear = dfCmt$year[i]
  lineDescription = dfCmt$cont_type[i]
  POST(url = "http://www.fec.gov/fecviewer/ExportImageSearchResults.do",
       body = list(format = "json",
                   candCmteIdName = candidateCommitteeId,
                   state = "",
                   district = "",
                   city = "",
                   treasurerName = "",
                   reportYear = "",
                   covStartDate = "",
                   covEndDate = "",
                   defaultTab = "1"),
       encode = "form") -> res
  
  res_j <- fromJSON(content(res, as="text"))
  
  candCmteName <- res_j$fec.gov$results$match$Name
  candidateCommitteeName <- res_j$fec.gov$results$match$Name
  
  POST(url = "http://www.fec.gov/fecviewer/ExportCandCmteTransactions.do",
       body = list(candidateCommitteeId = candidateCommitteeId, # manual
                   
                   electionYr = dfCmt$year[i], # cycle through
                   lineDescription = dfCmt$cont_type[i], # cycle through
                   lineNumber = dfCmt$lnnum[i], # cycle through
                   
                   candCmteName = candCmteName, # create variable
                   candidateCommitteeName = candidateCommitteeName, # create variable
                   
                   recordCount = "100000", # permanent
                   comingFromCashExpSummary = "false", # permanent
                   commingFrom = "twoYearSummary", # permanent
                   format = "csv"), # permanent
       encode = "form") -> res_2
  writeBin(res_2$content, paste0(cperson, "/", dfCmt$abbrev[i], "_", dfCmt$year[i], ".csv"))
}

# ===========================================================================================
# Merge the Data Frames
# ===========================================================================================

# compile list of csv's to merge
files <- list.files(cperson) # identify files in the same folder
files <- files[!grepl("Contributions", files)] # exclude contribution files
files <- files[grep('[0-9]{4}.csv', files)] # get the names of the csv files

# create empty data frames
II <- data.frame()
OC <- data.frame()

# merge the files
for (i in 1:length(files)) {
  if(ncol(read.csv(paste0(cperson, "/", files[i]), skip = 7)) == 18) {
    II <- rbind(II, read.csv(paste0(cperson, "/", files[i]), skip =7))
  } else if(ncol(read.csv(paste0(cperson, "/", files[i]), skip = 7)) == 16) {
    OC <- rbind(OC, read.csv(paste0(cperson, "/", files[i]), skip =7))
  } 
}

# remove extra columns
II$X <- NULL 
OC$X <- NULL

# add identifier columns
II$contrib <- "Individual Contribution"
OC$contrib <- "Committee Contribution"

# merge the data tables
merged <- smartbind(II, OC)

# rename the columns
colnames(merged) <- c("Contributor Name","Employer","Occupation","Description","City","State","Zip","Receipt Date","Amount","Memo Code","Report Type","Report Year","Image Number","Transaction Code","Other Id","Candidate Id","Transaction PGI", "Contribution Type")

# ===========================================================================================
# Export Merged Data Frame
# ===========================================================================================

# export a csv
write.csv(merged, paste0(cperson, "/", cperson, " - ", typeCmt, " Contributions.csv"), row.names = FALSE)
}

# ===========================================================================================
# Run the Function
# ===========================================================================================

# The function needs two variables to work properly:

# 1.) cperson: This is just the name of congressperson. This variable is purely aesthetic.
# 2.) candidateCommitteeId: This is the exact ID of the committee we're pulling files from.
#     The names for the Leadership PACS can be retreived from: 
#           https://www.opensecrets.org/pacs/industry.php?txt=Q03&cycle=2016.

fec_lead_extract("Heitkamp", "Leadership PAC", "C00536607")




df <- read.csv(file = "instructions.csv", header = FALSE)
colnames(df) <- c("candidate", "committee", "ID")

for (i in 1:length(df$candidate)) {
  fec_extract(df$candidate[i], df$committee[i], df$ID[i])
}



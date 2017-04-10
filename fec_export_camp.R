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

fec_camp_extract <- function(cperson, senID, houseID) {
if (houseID == "") {
dfCmt <- data.frame(
  "cont_type" = rep("Itemized Individual Contributions", 6),
  "abbrev" = rep("II", 6),
  "elec" = rep("SEN", 6),
  "lnnum" = rep("F3X#11AI", 6),
  "candidateCommitteeId" = rep(senID, 6),
  "year" = c("2008", "2010", "2012", "2014", "2016", "2018"))
} else if (senID == "") {
dfCmt <- data.frame(
  "cont_type" = rep("Itemized Individual Contributions", 6),
  "abbrev" = rep("II", 6),
  "elec" = rep("HS", 6),
  "lnnum" = rep("F3X#11AI", 6),
  "candidateCommitteeId" = rep(houseID, 6),
  "year" = c("2008", "2010", "2012", "2014", "2016", "2018"))  
} else {
dfCmt <- data.frame(
  "cont_type" = rep("Itemized Individual Contributions", 12),
  "abbrev" = rep("II", 12),
  "elec" = c(rep("SEN", 6), rep("HR", 6)),
  "lnnum" = rep("F3X#11AI", 12),
  "candidateCommitteeId" = c(rep(senID, 6), rep(houseID, 6)),
  "year" = rep(c("2008", "2010", "2012", "2014", "2016", "2018"),2))
}

dir.create(cperson)

for (i in 1:length(dfCmt$cont_type)) {
  electionYear = dfCmt$year[i]
  lineDescription = dfCmt$cont_type[i]
  POST(url = "http://www.fec.gov/fecviewer/ExportImageSearchResults.do",
       body = list(format = "json",
                   candCmteIdName = dfCmt$candidateCommitteeId[i],
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
       body = list(candidateCommitteeId = dfCmt$candidateCommitteeId[i], # cycle through
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
  writeBin(res_2$content, paste0(cperson, "/", dfCmt$elec[i], "_", dfCmt$year[i], ".csv"))
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

# merge the files
for (i in 1:length(files)) {
  if(ncol(read.csv(paste0(cperson, "/", files[i]), skip = 7)) == 18) {
    II <- rbind(II, read.csv(paste0(cperson, "/", files[i]), skip = 7))
  } else {}
}

# remove extra columns
II$X <- NULL 

# rename the columns
colnames(II) <- c("Contributor Name","Employer","Occupation","Description","City","State","Zip","Receipt Date","Amount","Memo Code","Report Type","Report Year","Image Number","Transaction Code","Other Id","Candidate Id","Transaction PGI")

# ===========================================================================================
# Export Merged Data Frame
# ===========================================================================================

# export a csv
write.csv(II, paste0(cperson, "/", cperson, " - ", " Campaign Contributions.csv"), row.names = FALSE)
}

# ===========================================================================================
# Run the Function
# ===========================================================================================

# The function needs at least two inputs to work properly:

# 1.) cperson: This is just the name of congressperson. This variable is purely aesthetic.
# 2.) senID:
# 3.) houseID:

fec_camp_extract("Johnson", senID = "S4LA00065", houseID = "")



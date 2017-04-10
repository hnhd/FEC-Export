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

# create folders
dir.create('Leadership')
dir.create('Campaign')
dir.create('Final')

# ===========================================================================================
# Build the Functions
# ===========================================================================================
  
fec_lead_extract <- function(cperson, candCmteNameMn, candidateCommitteeId){ # wrap the process in a function
dfCmt <- data.frame(
  "cont_type" = c(rep("Itemized Individual Contributions", 6), rep("Other Committees Contributions", 6)),
  "abbrev" = c(rep("II", 6), rep("OC", 6)),
  "lnnum" = c(rep("F3X#11AI", 6), rep("F3X#11C", 6)),
  "year" = c(rep(c("2008", "2010", "2012", "2014", "2016", "2018"), 2)))

dir.create(paste0('Leadership', '/', cperson))

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
  writeBin(res_2$content, paste0('Leadership',"/", cperson, "/", dfCmt$abbrev[i], "_", dfCmt$year[i], ".csv"))
}

# ===========================================================================================
# Merge the Data Frames
# ===========================================================================================

# compile list of csv's to merge
files <- list.files(paste0('Leadership', '/', cperson)) # identify files in the same folder
files <- files[!grepl("Contributions", files)] # exclude contribution files
files <- files[grep('[0-9]{4}.csv', files)] # get the names of the csv files

# create empty data frames
II <- data.frame()
OC <- data.frame()

# merge the files
for (i in 1:length(files)) {
  if(ncol(read.csv(paste0('Leadership', '/', cperson, "/", files[i]), skip = 7)) == 18) {
    II <- rbind(II, read.csv(paste0('Leadership', '/', cperson, "/", files[i]), skip =7))
  } else if(ncol(read.csv(paste0('Leadership', '/', cperson, "/", files[i]), skip = 7)) == 16) {
    OC <- rbind(OC, read.csv(paste0('Leadership', '/', cperson, "/", files[i]), skip =7))
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
write.csv(merged, paste0('Final', "/", cperson, " - ", candCmteNameMn, " Contributions",".csv"), row.names = FALSE)
}
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
  
  dir.create(paste0("Campaign", "/", cperson))
  
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
    writeBin(res_2$content, paste0("Campaign", "/", cperson, "/", dfCmt$elec[i], "_", dfCmt$year[i], ".csv"))
  }
  
  # ===========================================================================================
  # Merge the Data Frames
  # ===========================================================================================
  
  # compile list of csv's to merge
  files <- list.files(paste0("Campaign", "/", cperson)) # identify files in the same folder
  files <- files[!grepl("Contributions", files)] # exclude contribution files
  files <- files[grep('[0-9]{4}.csv', files)] # get the names of the csv files
  
  # create empty data frames
  II <- data.frame()
  
  # merge the files
  for (i in 1:length(files)) {
    if(ncol(read.csv(paste0("Campaign", "/", cperson, "/", files[i]), skip = 7)) == 18) {
      II <- rbind(II, read.csv(paste0("Campaign", "/",cperson, "/", files[i]), skip = 7))
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
  write.csv(II, paste0("Final", "/", cperson, " - ", " Campaign Contributions.csv"), row.names = FALSE)
}

# ===========================================================================================
# Run the Functions
# ===========================================================================================

# The function needs two variables to work properly:

# 1.) cperson: This is just the name of congressperson. This variable is purely aesthetic.
# 2.) candidateCommitteeId: This is the exact ID of the committee we're pulling files from.
#     The names for the Leadership PACS can be retreived from: 
#           https://www.opensecrets.org/pacs/industry.php?txt=Q03&cycle=2016.

df <- read.csv(file = "instructions.csv", header = TRUE)
colnames(df) <- c("candidate", "lname", "lID", "sID", "hID")

for (i in 1:length(df$candidate)) {
  fec_lead_extract(cperson = df$candidate[i], 
                   candCmteNameMn = df$lname[i], 
                   candidateCommitteeId = df$lID[i])
  fec_camp_extract(cperson = df$candidate[i], 
                   senID = as.character(df$sID[i]), 
                   houseID = as.character(df$hID[i]))
}

fec_lead_extract(cperson = df$candidate[3], 
                 candCmteNameMn = df$lname[3], 
                 candidateCommitteeId = df$lID[3])

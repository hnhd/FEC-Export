# ===========================================================================================
# Troubleshooting & Prelimnary Informaton
# ===========================================================================================

# 1.) Set working directory to the file where the csvs are located.
# 2.) Ensure all packages have been installed.

# ===========================================================================================
# Loading Data & Preliminary Cleaning
# ===========================================================================================

# load packages
library(gtools) # needed for smartbind
library(httr)
library(jsonlite)
library(tidyverse)

# load customizable variables
cperson <- "Johnson" # identify candidate
setwd() # set the working directory in code
candidateCommitteeId <- "C00497842"

dfCmt <- data.frame(
  "cont_type" = c(rep("Itemized Individual Contributions", 5), rep("Other Committees Contributions", 5)),
  "abbrev" = c(rep("II", 5), rep("OC", 5)),
  "lnnum" = c(rep("F3X#11AI", 5), rep("F3X#11C", 5)),
  "year" = c(rep(c("2008", "2010", "2012", "2014", "2016"), 2)))

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
  writeBin(res_2$content, paste0(dfCmt$abbrev[i], "_", dfCmt$year[i], ".csv"))
}

# compile list of csv's to merge
files <- list.files() # identify files in the same folder
files <- files[!grepl("Contributions", files)] # exclude contribution files
files <- files[grep('[0-9]{4}.csv', files)] # get the names of the csv files

# ===========================================================================================
# Merge the Data Frames
# ===========================================================================================

# create empty data frames
II <- data.frame()
OC <- data.frame()

# merge the files
for (i in 1:length(files)) {
  if(ncol(read.csv(files[i], skip = 7)) == 18) {
    II <- rbind(II, read.csv(files[i], skip =7))
  } else if(ncol(read.csv(files[i], skip = 7)) == 16) {
    OC <- rbind(OC, read.csv(files[i], skip =7))
  } 
}

# remove extra columns
II$X <- NULL 
OC$X <- NULL

# add identifier columns
II$contrib <- "Individual Contribution"
OC$contrib <- "Committee Contribution"

# write function that converts currenct format to number format
currency_number <- function(currency){
  number <- as.character(currency)
  number <- sub('\\$','', number)
  number <- sub('\\.00','', number)
  number <- sub(',','', number)
  number <- sub('\\(','-', number)
  number <- sub('\\)','', number)
  number <- as.numeric(number)
  print(number)
}

# merge the data tables
merged <- smartbind(II, OC)

# change the format
merged$Amount <- currency_number(merged$Amount)

# rename the columns
colnames(merged) <- c("Contributor Name","Employer","Occupation","Description","City","State","Zip","Receipt Date","Amount","Memo Code","Report Type","Report Year","Image Number","Transaction Code","Other Id","Candidate Id","Transaction PGI", "Contribution Type")

# ===========================================================================================
# Export Merged Data Frame
# ===========================================================================================

# export a csv
write.csv(merged, paste(cperson, " - Leadership Contributions.csv"), row.names = FALSE)

library(httr)
library(jsonlite)
library(tidyverse)

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
                   
                   candCmteName = candCmteName, # create variable
                   candidateCommitteeName = candidateCommitteeName, # create variable
                   
                   recordCount = "100000", # permanent
                   comingFromCashExpSummary = "false", # permanent
                   lineNumber = dfCmt$lnnum[i], # permanent
                   commingFrom = "twoYearSummary", # permanent
                   format = "csv"), # permanent
       encode = "form") -> res_2
  writeBin(res_2$content, paste0(dfCmt$abbrev[i], "_", dfCmt$year[i], ".csv"))
}



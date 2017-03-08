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

# load customizable variables
cperson <- "Cruz" # identify candidate
setwd() # set the working directory in code

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

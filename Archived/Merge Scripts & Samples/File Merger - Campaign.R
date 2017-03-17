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

# merge the files
for (i in 1:length(files)) {
   II <- rbind(II, read.csv(files[i]))
}

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

# change the format
II$Amount <- currency_number(II$Amount)

# rename the columns
colnames(II) <- c("Contributor Name","Employer/Occupation", "City","State","Zip","Receipt Date","Amount","Memo Code", "Description")

# ===========================================================================================
# Export Merged Data Frame
# ===========================================================================================

# export a csv
write.csv(II, paste(cperson, " - Campaign Contributions.csv"), row.names = FALSE)

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
cperson <- "Heller" # identify candidate
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
   II <- rbind(II, read.csv(files[i], skip = 7))
}

# rename the columns
colnames(II) <- c("Contributor Name","Employer","Occupation","Description","City","State","Zip","Receipt Date","Amount","Memo Code","Report Type","Report Year","Image Number","Transaction Code","Other Id","Candidate Id","Transaction PGI")

# ===========================================================================================
# Export Merged Data Frame
# ===========================================================================================

# export a csv
write.csv(II, paste(cperson, " - Campaign Contributions.csv"), row.names = FALSE)

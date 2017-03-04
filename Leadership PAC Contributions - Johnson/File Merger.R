library(stringr)
library(gtools)

files <- list.files() # identify files in the same folder
files <- files[grep('*.csv', files)] # get the names of the csv files

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

# change the formet
merged$Amount <- currency_number(merged$Amount)

# merge the data tables
merged <- smartbind(II, OC)

# rename the columns
colnames(merged) <- c("Contributor Name","Employer","Occupation","Description","City","State","Zip","Receipt Date","Amount","Memo Code","Report Type","Report Year","Image Number","Transaction Code","Other Id","Candidate Id","Transaction PGI", "Contribution Type")

# export a csv
write.csv(merged, "Johnson - Contributions.csv", row.names = FALSE)


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
merged$Amount <- currency_number(merged$Amount)
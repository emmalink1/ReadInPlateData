library(plater) 
library(readxl)
library(tidyverse)
library(writexl)
library(stringr)

## ExcelPlateRead reads plate reader data out of any number of excel workbooks with any number of sheets, converts to csv, then reads into R using plater
## For ease of downstream applications, you should have consistently named files with Batch # or run date in the name

## This method uses readxl to read in all sheets from any number of excel workbooks (https://readxl.tidyverse.org/articles/readxl-workflows.html)

##1) Get everything out of excel, into a csv in plater ready format

## First, add all your excel workbooks to a unique folder. Here we navigate to that folder (paste the path for yours in here). 

setwd("./ReadInPlateData/Data/RawSheet")

## get list of all workbooks in that unique directory (paste it in here)
file_list <- list.files(path="./ReadInPlateData/Data/RawSheet")

##A function which takes a workbook and reads all sheets to csv. ***** Remember to set cell range to the range that your data is in in your sheets (it might be different!). ******
## Currently, the range is set to A1:M9 to read in the metadata files 
read_then_csv <- function(sheet, path) {
  pathbase <- path %>%
    basename() %>%
    tools::file_path_sans_ext()
  path %>%
    read_excel(sheet = sheet, range = "A1:M9") %>% 
    write_csv(paste0(pathbase, "-", sheet, ".csv"), quote = FALSE)
}

##Calls read_then_csv on all items in file_list and saves them to current working directory ("./ReadInPlateData/Data/RawSheet")

for (i in 1:length(file_list)) {
  XLS = file_list[i] 
  XLS %>% 
    excel_sheets() %>%
    set_names() %>%
    map(read_then_csv, path = XLS)
}

##*** Here you must manually move the csv's to their own folder. Sorry, couldn't automate that for ya. 

# 2) use plater to get everything read into R from csvs 

## Make sure the csvs are in their own folder or this part won't work! 
## Navigate to the folder with the csvs
setwd("./ReadInPlateData/Data/Raw_CSV")
file_list <- list.files(path = "./ReadInPlateData/Data/Raw_CSV")
check_plater_format(file_list[1])
## Here, define whatever you want the name of the file to be 
MyMetadata <- read_plates(files = file_list)

##If you get an error here, read_plates *should* tell you what file it failed to read. Open up that file and make sure that it looks right. 
## Plater cannot read in NAs, so if there is a plate that had reader errors or other NAs, you may have to throw that one out. 

## You should now have a dataset with 3 columns: 
## Plate, chr type, with plate number on the end of the batch worksheet name
## wells, chr type; 
## and plate reads, int type, probably named something weird

## You can proceed to rearranging, cleaning, and calculating for the given assay you're working on 
## I reccommend saving your read-in dataset before working on it any further 

write.csv(MyMetadata, "/Users/emmalink/Documents/R/SEECRSLabRepos/ReadInPlateData/Data/Metadata/ExampleReadInMetadata")


library(plater) 
library(readxl)
library(tidyverse)
library(writexl)
library(stringr)

## Plate Data Prep reads plate reader data out of any number of excel workbooks with any number of sheets, converts to csv, then reads into R using plater
## It relies upon consistently named workbooks and sheets. The naming convention used for files is: 
## 202#_PARCE_EEA_Batch#_EL and sheets are named with 3 digit plot number (ex 202) and EEA blank plates are Bpl 
## However the code, if changed, is flexible to any naming convention 

## This method uses readxl to read in all sheets from any number of excel workbooks (https://readxl.tidyverse.org/articles/readxl-workflows.html)


##1) Get everything out of excel, into a csv in plater ready format

##Get list of excel workbooks from all run days. First, add all your excel workbooks to a unique folder. 
##This command navigates to your working directory (here,/EEA_Raw_2021 )
setwd("/Users/emmalink/Downloads/eeafiles")

##get list of all workbooks in this directory
file_list <- list.files(path="/Users/emmalink/Downloads/eeafiles")

##A function which takes a workbook and reads all sheets to csv. Remember to set range to what you need it to be. 
read_then_csv <- function(sheet, path) {
  pathbase <- path %>%
    basename() %>%
    tools::file_path_sans_ext()
  path %>%
    read_excel(sheet = sheet, range = "A1:M9") %>% 
    write_csv(paste0(pathbase, "-", sheet, ".csv"), quote = FALSE)
}

##Calls read_then_csv on all items in file_list and saves them to current working directory (EEA_2021_excel)

for (i in 1:length(file_list)) {
  XLS = file_list[i] 
  XLS %>% 
    excel_sheets() %>%
    set_names() %>%
    map(read_then_csv, path = XLS)
}

## Manually move the csv's to their own folder 

# 2) use plater to get everything read into R from csvs 

## Make sure the csvs are in their own folder or this part won't work! 
## Navigate to the folder with the csvs
setwd("/Users/emmalink/Documents/R/PARCE/Analysis 2020/EEA_Analysis /EEA_2021_csv")
file_list <- list.files(path = "/Users/emmalink/Documents/R/PARCE/Analysis 2020/EEA_Analysis /EEA_2021_csv")
check_plater_format(file_list[1])
EEAData2021 <- read_plates(files = file_list)

##If you get an error here, read_plates *should* tell you what file it failed to read. Open up that file and make sure that it looks right. 
## Plater cannot read in NAs, so if there is a plate that had reader errors or other NAs, you may have to throw that one out. 

## You should now have a dataset with 3 columns: 
## Plate, chr type, with plate number on the end of the batch worksheet name
## wells, chr type; 
## and plate reads, int type, probably named something weird

## You can proceed to rearranging, cleaning, and calculating for the given assay you're working on 

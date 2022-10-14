# README ####
# 
# this script download and merge the weather data for AgrImOnIA Dataset
# press ->  Alt + o           <-  to collapse all folders
# press ->  ctrl + shift + O  <-  to see the structure of the script

# made by Dr. Alessandro Fusta Moro, University of Turin
# contact me at alessandro.fustamoro@gmail.com

# LIBRARY ####
library(doParallel)
library(foreach)
library(ncdf4)
library(ecmwfr)

# PARALLELING OPTIONS ####
# the code uses parallelized cycle within "foreach"
# set the number of cores to use in the parallelisation: choose option 1. or 2.

# 1. IF YOU HAVE WINDOWS
cores<-detectCores()
registerDoParallel(cores = (cores/2))

# 2. IF YOU HAVE LINUX
registerDoParallel()

# Weather ----------------------------------------------------------------------
# A.0. Data Download ====

# Some steps are needed before to proceed:

# 1. you must have an account on Climate Data Store service
# 2. you must have downloaded the folder called "FUNCTIONS" in your working directory
# 
BoundaryLombardy <- c(46.95, 8.05, 44.35, 11.85) # set the box of your interest
# BoundaryLowerSaxony <- c(54.15, 6.25, 50.95, 11.95)
id<-"119479" # set the ID of your CDS account
source("FUNCTIONS/ERA5datadownload.R") #recall function
dataset<-c("ERA5Land","ERA5SL")
years<-c(2016:2021)
bound<-list(BoundaryLombardy)
for(d in dataset){for(y in years){for(b in bound){
  data<-tryCatch({
    setTimeLimit(elapsed=1)
    ERA5datadownload(id,d,y,b)
    setTimeLimit(elapsed = Inf)
    c(iter = c(d,y,b), slp = era5[d,y,b])
  },error=function(e)NULL)}}}

# now in your personal webpage you can find all the request pending
# data need to be downloaded directly from the site
# files downloaded are in this order (starting from the bottom of the webpage)
# --> dataset : 6 files from ERA5Land
#               6 files from ERA5 Single Levels (use SL)
# --> year --> within each dataset:
#               from 2016 to 2021
# --> region --> Lombardy 

# IMPORTANT: save your files in a folder named "rawdata" and rename the files
# according to the year and the dataset (example: ERA5 Land 2017 Lombardia.nc)

# A.1. From netcdf to Points Dataframe ====
# _ A.1.1. ERA5 Land ####
# you must have raw netcdf files downloaded from CDS at section A.1.1

source("FUNCTIONS/ERA5netcdftopoints.R") #recall functions
path_in<-"ERA5/rawdata/"
path_out<-"ERA5/HourlyPointsDataframe/"
dataset<-"Land"
year<-c(2016:2021)
region<-"Lombardy"
# this cycle use "foreach" and "doParallel" packages and need PARALLELING OPTIONS set
# if you don't want to parallelise your cycle, use for(.. in ..){ ... } instead
foreach (y = year, .packages = "ncdf4") %dopar% {
  ERA5netcdftopoints(dataset=dataset,
                     year=y,
                     region=region,
                     newfile=T,
                     path_in=path_in,
                     path_out=path_out,
                     print=F)}

# _ A.1.2. ERA5 Single Levels ####
# you must have raw netcdf files downloaded from CDS at section A.1.1

source("FUNCTIONS/ERA5netcdftopoints.R") #recall functions
path_in<-"ERA5/rawdata/"
path_out<-"ERA5/HourlyPointsDataframe/"
dataset<-"Single Levels"
year<-c(2016:2021)
region<-"Lombardy"
# this cycle use "foreach" and "doParallel" packages and need PARALLELING OPTIONS set
# if you don't want to parallelise your cycle, use for(.. in ..){ ... } instead
foreach (y = year, .packages = "ncdf4") %dopar% {
  ERA5netcdftopoints(dataset=dataset,
                     year=y,
                     region=region,
                     newfile=T,
                     path_in=path_in,
                     path_out=path_out,
                     print=F)}


# A.2. From Hourly to Daily ====
# _ A.2.1. ERA5 Land ####
source("FUNCTIONS/ERA5_Land_fromHourlytoDaily.R") #recall functions
path_in<-"ERA5/HourlyPointsDataframe/"
path_out<-"ERA5/DailyPointsDataframe/"
dataset<-"Land"
year<-c(2016:2021)
region<-"Lombardy"
# this cycle use "foreach" and "doParallel" packages and need PARALLELING OPTIONS set
# if you don't want to parallelise your cycle, use for(.. in ..){ ... } instead
foreach (y = year) %dopar% {
  ERA5_Land_fromHourlytoDaily(
    year=y,
    region=region,
    dataset = dataset,
    newfile=T,
    path_in=path_in,
    path_out=path_out,
    print = F
  )
}


# _ A.2.2. ERA5 Single Levels ####
source("FUNCTIONS/ERA5_SL_fromHourlytoDaily.R") #recall functions
path_in<-"ERA5/HourlyPointsDataframe/"
path_out<-"ERA5/DailyPointsDataframe/"
dataset<-"Single Levels"
year<-c(2016:2021)
region<-"Lombardy"
# this cycle use "foreach" and "doParallel" packages and need PARALLELING OPTIONS set
# if you don't want to parallelise your cycle, use for(.. in ..){ ... } instead
foreach (y = year) %dopar% {
  ERA5_SL_fromHourlytoDaily(
    year=y,
    region=region,
    dataset=dataset,
    newfile=T,
    path_in=path_in,
    path_out=path_out,
    print=F
  )
}


# A.3. Merge all datasets across years ====
# _ A.3.1. ERA5 Land ####
path_in <- "ERA5/DailyPointsDataframe/"
path_out <- "ERA5/DailyPointsDataframe/2016_2021/"
dataset<-"Land"
region<-"Lombardy"
landfiles<-list.files(path = path_in,pattern = dataset)
Land<-data.frame()
# this cycle use "foreach" and "doParallel" packages and need PARALLELING OPTIONS set
# if you don't want to parallelise your cycle, use for(.. in ..){ ... } instead
Land<-foreach (ly = 1:length(landfiles), .combine = rbind) %dopar% {
  load(paste0(path_in,landfiles[[ly]]))
  Land<-df_daily
}
Land$mode_wind_direction_10m<-as.factor(Land$mode_wind_direction_10m)
save(Land,file=paste0(path_out,"Daily ",dataset," 2016_2021 ",region,".Rdata"))
rm(landfiles)


# _ A.3.2. ERA5 Single Levels####
path_in <- "ERA5/DailyPointsDataframe/"
path_out <- "ERA5/DailyPointsDataframe/2016_2021/"
region<-"Lombardy"
#Single Levels
dataset<-"Single Levels"
slfiles<-list.files(path = path_in,pattern = dataset)
SingleLevels<-data.frame()
# this cycle use "foreach" and "doParallel" packages and need PARALLELING OPTIONS set
# if you don't want to parallelise your cycle, use for(.. in ..){ ... } instead
SingleLevels<-foreach (ly = 1:length(slfiles), .combine = rbind) %dopar% {
  load(paste0(path_in,slfiles[[ly]]))
  SingleLevels<-df_daily
}
SingleLevels$mode_wind_direction_100m<-as.factor(SingleLevels$mode_wind_direction_100m)
SingleLevels$precipitation_type<-as.factor(SingleLevels$precipitation_type)
save(SingleLevels,file=paste0(path_out,"Daily ",dataset," 2016_2021 ",region,".Rdata"))
rm(slfiles)

gc()

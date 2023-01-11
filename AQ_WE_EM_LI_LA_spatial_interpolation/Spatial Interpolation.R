# README ####
# 
# this script interpolate weather/emission/land data with 
# air quality monitoring station localisations for AgrImOnIA Dataset

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


# YOU NEED THESE FOLDERS IN YOUR WORKING DIRECTORY:
# AQ -> where is stored air quality measurements
# ERA5/DailyPointsDataframe/2016_2021 -> filled from Weather.R
# CAMS/DailyPointsDataframe -> filled from Emission.R
# MERGED -> empty
# SIARL -> with raw SIARL data
# CLC -> with CORINE Land Cover file
# ANAGRAFICA -> with Metadata_monitoring_network_registry.csv
# BDN -> with BDN data from matlab script BDNDailySpline.m

# Spatial Interpolation -------------------------------------------------------------
# C.1. Loading Input Files ====
# _ C.1.1. AQ data ####
path_in<-"AQ/"
file<-"AQOutput_20220607.csv" #the output from AQHourly2Daily.m
AQ<-read.csv(file = paste0(path_in,file))
rm(file,path_in)
AQ<-AQ[,c(2,10,11,1,3:9)]
AQ$time<-as.Date(substr(AQ$time,1,10))
# 

# _ C.1.2. ERA5 data ####

# ERA5 Land
path_in<-"ERA5/DailyPointsDataframe/2016_2021/"
file<-"Daily Land 2016_2021 Lombardy.Rdata"
load(paste0(path_in,file))

# ERA5 Single Level
path_in<-"ERA5/DailyPointsDataframe/2016_2021/"
file<-"Daily Single Levels 2016_2021 Lombardy.Rdata"
load(paste0(path_in,file))
rm(file,path_in)
#

# _ C.1.3. CAMS data ####
path_in<-"CAMS/DailyPointsDataframe/"
file<-"Daily nh3 nox so2 2016_2020 Lombardy.Rdata"
load(paste0(path_in,file))
rm(file,path_in)
#
# C.2. KNN Spatial Interpolation ====
# _ C.2.1. Interpolation AQ with ERA5 ####
# ___ C.2.1.1. Interpolation AQ with ERA5Land ####
source("FUNCTIONS/AQinterpPARALLEL.R") # it uses parallelization
# source("FUNCTIONS/AQinterp.R") # if you don't want to parallelize, it will take a lot of time
AQ_ERA5Land <- AQinterpPARALLEL(AQ,Land,knn=4,13)
path_out<-"MERGED/"
file = "AQ+ERA5Land"
save(AQ_ERA5Land,file=paste0(path_out,file,".Rdata"))
rm(AQ_ERA5Land,Land,file,path_out,pos_mode_wind)
#

# ___ C.2.1.2. Interpolation AQ with ERA5Single ####
source("FUNCTIONS/AQinterpPARALLEL.R") # it uses parallelization
# source("FUNCTIONS/AQinterp.R") # # if you don't want to parallelize, it will take a lot of time
AQ_ERA5SL<-AQinterpPARALLEL(AQ,SingleLevels,4,6)
path_out<-"MERGED/"
file = "AQ+ERA5SL"
save(AQ_ERA5SL,file=paste0(path_out,file,".Rdata"))

rm(AQ_ERA5SLPL,file,path_out,pos_mode_wind)
#

# _ C.2.2. Interpolation AQ with CAMS ####
source("FUNCTIONS/AQinterpPARALLEL.R") # it uses parallelization
AQ_no21<-subset(AQ,time<"2021-01-01") #CAMS doesn't have data about 2021
AQ_CAMS <- AQinterpPARALLEL(AQ_no21,cams_daily,4,31)
path_out<-"MERGED/"
file = "AQ+CAMS"
save(AQ_CAMS,file =paste0(path_out,file,".Rdata"))
rm(AQ_CAMS,AQ_no21,cams_daily,path_out,file)
#

# C.3. Interpolation with shapefile and raster ====
# _ C.3.1. CORINE Land Cover data ####
path_in<-"CLC/"
CLC<-readOGR(dsn = "CLC", layer = "CLC18_IT")
CLC <- spTransform(CLC,CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
AQ_meta<-unique(AQ[,c(1:3)])
coordinates(AQ_meta)<-c("Longitude","Latitude")
crs(AQ_meta)<-("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")
AQ_CLC<-cbind(as.data.frame(AQ_meta),as.data.frame(over(AQ_meta,CLC[,5])))
AQ_CLC$CODE18[AQ_CLC$IDStations=="STA-CH0011A"]<-"111"
AQ_CLC$CODE18[AQ_CLC$IDStations=="STA-CH0033A"]<-"211"
AQ_CLC$CODE18[AQ_CLC$IDStations=="STA-CH0043A"]<-"121"
path_out<-"MERGED/"
file = "AQ+CLC"
save(AQ_CLC,file =paste0(path_out,file,".Rdata"))
rm(AQ_CLC,AQ_meta,CLC,path_in,path_out,file)
#
clc_fix <- as.data.frame(cbind(Agrimonia_Dataset[,c(1)],Agrimonia_Dataset$LA_land_use))
names(clc_fix)<-c("IDStations","LA_land_use")
# _ C.3.2. SIARL data ####

AQ_meta<-unique(AQ[,c(1:3)]) #from C.1.1 
coordinates(AQ_meta)<-c("Longitude","Latitude")
crs(AQ_meta)<-("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")
path_in<-"SIARL/"
year<-2016
SIARL16<-raster::raster(paste0(path_in,year,"/w001001.adf"))
AQ_SIARL16<-cbind(as.data.frame(AQ_meta),
                  as.data.frame(extract(SIARL16,AQ_meta)))
names(AQ_SIARL16)[4]<-"SIARL"
AQ_16<-subset(AQ,time<=as.Date("2016-12-31"))
AQ_SIARL16<-merge(AQ_16,AQ_SIARL16,all.x=T)
year<-2017
SIARL17<-raster::raster(paste0(path_in,year,"/w001001.adf"))
AQ_SIARL17<-cbind(as.data.frame(AQ_meta),
                  as.data.frame(extract(SIARL17,AQ_meta)))
names(AQ_SIARL17)[4]<-"SIARL"
AQ_17<-subset(AQ,time<=as.Date("2017-12-31")&time>=as.Date("2017-01-01"))
AQ_SIARL17<-merge(AQ_17,AQ_SIARL17,all.x=T)
year<-2018 #watch out beacuse the raster is slightly different from other years
SIARL18<-raster::raster(paste0(path_in,year,"/w001001.adf"))
AQ_SIARL18<-cbind(as.data.frame(AQ_meta),
                  as.data.frame(extract(SIARL18,AQ_meta)))
names(AQ_SIARL18)[4]<-"SIARL"
AQ_18<-subset(AQ,time<=as.Date("2018-12-31")&time>=as.Date("2018-01-01"))
AQ_SIARL18<-merge(AQ_18,AQ_SIARL18,all.x=T)
year<-2019
SIARL19<-raster::raster(paste0(path_in,year,"/w001001.adf"))
AQ_SIARL19<-cbind(as.data.frame(AQ_meta),
                  as.data.frame(extract(SIARL19,AQ_meta)))
names(AQ_SIARL19)[4]<-"SIARL"
AQ_19<-subset(AQ,time<=as.Date("2019-12-31")&time>=as.Date("2019-01-01"))
AQ_SIARL19<-merge(AQ_19,AQ_SIARL19,all.x=T)

AQ_SIARL<-rbind(AQ_SIARL16,AQ_SIARL17,AQ_SIARL18,AQ_SIARL19)

rm(SIARL16,SIARL17,SIARL18,SIARL19,path_in,
   AQ_SIARL16,AQ_SIARL17,AQ_SIARL18,AQ_SIARL19,
   AQ_16,AQ_17,AQ_18,AQ_19)

path_out<-"MERGED/"
file = "AQ+SIARL"
save(AQ_SIARL,file =paste0(path_out,file,".Rdata"))
rm(AQ_SIARL,AQ_meta,path_out,file)
#

save(AQ_SIARL,file = )
# _ C.3.3. DTM data ####
# Altitude of station from Station
path_in<-"ANAGRAFICA/"
file<-"Metadata_monitoring_network_registry.csv"
ANA<-read.csv(paste0(path_in,file))
ANA[is.na(ANA$Altitude),1:3] #1 stations has NA
staz<-unique(ANA$IDStation[is.na(ANA$Altitude)])
ANA$Altitude[ANA$IDStation==staz]<-11 # checked manually = 11 meters
AQ_meta<-unique(AQ[,c(1:3)]) #from C.1.1 
AQ_ALT<-merge(AQ_meta,ANA[,c(2,5,9,10)],all.x=T)
# names(AQ_DTM)[4]<-"DTM"
AQ_ALT<-unique(AQ_ALT)
path_out<-"MERGED/"
file="AQ+ALT"
save(AQ_ALT,file = paste0(path_out,file,".Rdata"))
rm(AQ_ALT)

# _ C.3.4. BDN  ####
path_in<-"BDN/"
file<-"BDN-01062022.csv"
BDN<-read.csv(paste0(path_in,file))
BDN<-BDN[,c(4,1,2,3)]
BDN$Time<-as.Date(BDN$Time,format = "%d-%m-%Y")
AQ_BDN<-merge(AQ_meta,BDN)
path_out<-"MERGED/"
file<-"AQ+BDN"
save(AQ_BDN,file = paste0(path_out,file,".Rdata"))
rm(AQ_BDN,AQ_meta,BDN,file,path_in,path_out)
#

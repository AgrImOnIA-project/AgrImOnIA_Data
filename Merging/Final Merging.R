# README ####
# 
# this script merge the different interpolated datasets for AgrImOnIA Dataset
# press ->  Alt + o           <-  to collapse all folders
# press ->  ctrl + shift + O  <-  to see the structure of the script

# made by Dr. Alessandro Fusta Moro, University of Turin
# contact me at alessandro.fustamoro@gmail.com

# Merging -------------------------------------------------------------------
# D.1. Import and Merge ====
# _ D.1.1. Air Quality ####

path_in<-"AQ/"
file<-"AQOutput_20220607.csv"
AQ<-read.csv(file = paste0(path_in,file))
rm(file,path_in)
AQ<-AQ[,c(2,11,10,1,3:9)]
AQ$time<-as.Date(substr(AQ$time,1,10))
#

# _ D.1.2. ERA5 ####

path_in<-"MERGED/"
file<-"AQ+ERA5Land"
load(paste0(path_in,file,".Rdata"))
file<-"AQ+ERA5SL"
load(paste0(path_in,file,".Rdata"))
AgrImOnIAdata<-merge(AQ,merge(AQ_ERA5Land,AQ_ERA5SL),all.x=T)
#
rm(AQ,AQ_ERA5Land,AQ_ERA5SL)
gc()
# _ D.1.3. CAMS ####

path_in<-"MERGED/"
file<-"AQ+CAMS"
load(paste0(path_in,file,".Rdata"))
AgrImOnIAdata<-merge(AgrImOnIAdata,AQ_CAMS,all.x=T)
rm(AQ_CAMS)
gc()
#

# _ D.1.4. BDN ####

path_in<-"MERGED/"
file<-"AQ+BDN"
load(paste0(path_in,file,".Rdata"))
names(AQ_BDN)[4]<-"time"
AgrImOnIAdata<-merge(AgrImOnIAdata,AQ_BDN,all.x=T)
rm(AQ_BDN)
gc()
#

# _ D.1.5. CLC ####

path_in<-"MERGED/"
file<-"AQ+CLC"
load(paste0(path_in,file,".Rdata"))
AgrImOnIAdata<-merge(AgrImOnIAdata,AQ_CLC,all.x=T)
rm(AQ_CLC)
#

# _ D.1.6. SIARL ####

path_in<-"MERGED/"
file<-"AQ+SIARL"
load(paste0(path_in,file,".Rdata"))
AgrImOnIAdata<-merge(AgrImOnIAdata,AQ_SIARL,all.x=T)
rm(AQ_SIARL)
gc()
#

# _ D.1.7. DTM ####
# with altitude from metadata
path_in<-"MERGED/"
file<-"AQ+ALT"
load(paste0(path_in,file,".Rdata"))

AgrImOnIAdata<-merge(AgrImOnIAdata,AQ_ALT,all.x=T)
rm(AQ_ALT)
gc()
# with raster
# path_in<-"MERGED/"
# file<-"AQ+DTM"
# load(paste0(path_in,file,".Rdata"))
# AgrImOnIAdata<-merge(AgrImOnIAdata,AQ_ALT,all.x=T)

# _ D.1.8. Save and cut dataset ====
#save
file<-"AgrImOnIAdata"
summary(AgrImOnIAdata)
names(AgrImOnIAdata)

AgrImOnIAdata<-AgrImOnIAdata[,c(1:4,65,5:11,12:16,29,17:28,30:32,37,51,48,57,61,62,63,64)]
AgrImOnIAdata<-AgrImOnIAdata[,c(1:6,12,7:11,13:ncol(AgrImOnIAdata))]
names(AgrImOnIAdata)<-c(
  "IDStations",
  "Latitude",
  "Longitude",
  "Time",
  "Altitude",
  "AQ_pm10",
  "AQ_pm25",
  "AQ_co",
  "AQ_nh3",
  "AQ_nox",
  "AQ_no2",
  "AQ_so2",
  "WE_temp_2m",
  "WE_wind_speed_10m_mean",
  "WE_wind_speed_10m_max",
  "WE_mode_wind_direction_10m",
  "WE_tot_precipitation",
  "WE_precipication_t",
  "WE_surface_pressure",
  "WE_solar_radiation",
  "WE_hvi","WE_lvi",
  "WE_rh_min",
  "WE_rh_mean",
  "WE_rh_max",
  "WE_wind_speed_100m_mean",
  "WE_wind_speed_100m_max",
  "WE_mode_wind_direction_100m",
  "WE_blh_layer_max",
  "WE_blh_layer_min",
  "EM_nh3_livestock_mm",
  "EM_nh3_agr_soils",
  "EM_nh3_agr_waste_burn",
  "EM_nh3_sum",
  "EM_nox_traffic",
  "EM_nox_sum",
  "EM_so2_sum",
  "LI_pigs",
  "LI_bovine",
  "LA_CORINE",
  "LA_siarl"
)

#temperature from kelvin to celsius
AgrImOnIAdata$WE_temp_2m<-AgrImOnIAdata$WE_temp_2m-273.15
#some post corrections
AgrImOnIA.Dataset <- AgrImOnIAdata
rm(AgrImOnIAdata)
names(AgrImOnIA.Dataset)[c(40,41)]<-c("LA_land_use","LA_soil_use")
AgrImOnIA.Dataset<-cbind(AgrImOnIA.Dataset[,1:20],AgrImOnIA.Dataset[,23:39],AgrImOnIA.Dataset[,21:22],AgrImOnIA.Dataset[,40:41])
names(AgrImOnIA.Dataset)[c(38,39)]<-c("LA_hvi","LA_lvi")
#exporting in csv
write.table(cbind(AgrImOnIA.Dataset[,1],
                  format(AgrImOnIA.Dataset[,c(2,3)],digits=9,scientific=F),AgrImOnIA.Dataset[,c(4,5)],
                  format(AgrImOnIA.Dataset[,c(6:15)],digits=4,scientific=T),AgrImOnIA.Dataset[,16],
                  format(AgrImOnIA.Dataset[,c(17)],digits=4,scientific=T),AgrImOnIA.Dataset[,18],
                  format(AgrImOnIA.Dataset[,c(19:25)],digits=4,scientific=T),AgrImOnIA.Dataset[,26],
                  format(AgrImOnIA.Dataset[,c(27:39)],digits=4,scientific=T),AgrImOnIA.Dataset[,c(40:41)]
), file="AgrImOnIA_Dataset.csv",row.names = F,col.names=names(AgrImOnIA.Dataset),
quote = F,sep = ",",dec = ".")

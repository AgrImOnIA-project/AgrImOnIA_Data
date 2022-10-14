# README ####
# 
# this script download and merge the emission data for AgrImOnIA Dataset
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

# Emission ----------------------------------------------------------------------
# B.O. Data Download ====

# 1. you must have an account on Atmosphere Data Store service
wf_set_key(user = "", # <---- set your userID on ADS
           key = "", # <---- set your key (if you don't know use "wf_get_key")
           service = "ads")

request <- list(
  version = "latest",
  format = "zip",
  variable = c("ammonia", "carbon_dioxide", "carbon_dioxide_excl_short_cycle", "carbon_monoxide", "nitrogen_oxides", "sulphate", "sulphur_dioxide", "sulphur_oxides"),
  source = c("anthropogenic", "aviation", "biogenic", "shipping", "soil"),
  year = "2016",
  dataset_short_name = "cams-global-emission-inventories",
  target = "download.zip"
)
ncfile <- wf_request(user = "9114",
                     request = request,
                     transfer = TRUE,
                     path = "~",
                     verbose = FALSE) # STOP RUNNING MANUALLY
request <- list(
  version = "latest",
  format = "zip",
  variable = c("ammonia", "carbon_dioxide", "carbon_dioxide_excl_short_cycle", "carbon_monoxide", "nitrogen_oxides", "sulphate", "sulphur_dioxide", "sulphur_oxides"),
  source = c("anthropogenic", "aviation", "biogenic", "shipping", "soil"),
  year = "2017",
  dataset_short_name = "cams-global-emission-inventories",
  target = "download.zip"
)
ncfile <- wf_request(user = "9114",
                     request = request,
                     transfer = TRUE,
                     path = "~",
                     verbose = FALSE) # STOP RUNNING MANUALLY
request <- list(
  version = "latest",
  format = "zip",
  variable = c("ammonia", "carbon_dioxide", "carbon_dioxide_excl_short_cycle", "carbon_monoxide", "nitrogen_oxides", "sulphate", "sulphur_dioxide", "sulphur_oxides"),
  source = c("anthropogenic", "aviation", "biogenic", "shipping", "soil"),
  year = "2018",
  dataset_short_name = "cams-global-emission-inventories",
  target = "download.zip"
)
ncfile <- wf_request(user = "9114",
                     request = request,
                     transfer = TRUE,
                     path = "~",
                     verbose = FALSE) # STOP RUNNING MANUALLY
request <- list(
  version = "latest",
  format = "zip",
  variable = c("ammonia", "carbon_dioxide", "carbon_dioxide_excl_short_cycle", "carbon_monoxide", "nitrogen_oxides", "sulphate", "sulphur_dioxide", "sulphur_oxides"),
  source = c("anthropogenic", "aviation", "biogenic", "shipping", "soil"),
  year = "2019",
  dataset_short_name = "cams-global-emission-inventories",
  target = "download.zip"
)
ncfile <- wf_request(user = "9114",
                     request = request,
                     transfer = TRUE,
                     path = "~",
                     verbose = FALSE) # STOP RUNNING MANUALLY
request <- list(
  version = "latest",
  format = "zip",
  variable = c("ammonia", "carbon_dioxide", "carbon_dioxide_excl_short_cycle", "carbon_monoxide", "nitrogen_oxides", "sulphate", "sulphur_dioxide", "sulphur_oxides"),
  source = c("anthropogenic", "aviation", "biogenic", "shipping", "soil"),
  year = "2020",
  dataset_short_name = "cams-global-emission-inventories",
  target = "download.zip"
)
ncfile <- wf_request(user = "9114",
                     request = request,
                     transfer = TRUE,
                     path = "~",
                     verbose = FALSE) # STOP RUNNING MANUALLY

# now in your personal webpage you can find all the request pending

# Extract zip files in the same folder of the project

# B.1. From netcdf to Points Dataframe ====
# _ B.1.1. ammonia ####

source("FUNCTIONS/getvarCAMS.R")
B_LO <- c(8.05,11.85,44.35,46.95) #boundary of Lombardy
# B_LO <- c(54.15, 6.25, 50.95, 11.95)
region<-"Lombardy"
# region<-"Lower Saxony"
path_in<-"CAMS/rawdata/"
pollutant<-"ammonia"
dataset<-"CAMS-GLOB-ANT_v4.2"
nc<-nc_open(paste0(path_in,dataset,"_",pollutant,"_",2016,".nc"))
variables<-names(nc$var)
delete_variables<-list("date","fef","slv")
"%notin%"<-Negate("%in%")
variables<-variables[variables %notin% delete_variables]
rm(nc,years)
cams_nh3<-data.frame()
cams_nh3<-foreach (years = 2016:2020,
                   .combine = rbind,
                   .packages = "ncdf4") %dopar%
  {
    nc<-nc_open(paste0(path_in,"CAMS-GLOB-ANT_v4.2_",pollutant,"_",years,".nc"))
    df_amm<-getvarCAMS(nc=nc,
                       year=years,
                       boundary=B_LO,
                       variables = variables)
    amm_agl<-df_amm[[1]]
    names(amm_agl)[4]<-"nh3_livestock_manure_management"
    amm_ags<-df_amm[[2]]
    names(amm_ags)[4]<-"nh3_agriculture_soils"
    amm_awb<-df_amm[[3]]
    names(amm_awb)[4]<-"nh3_agriculture_waste_burning"
    amm_ene<-df_amm[[4]]
    names(amm_ene)[4]<-"nh3_power_generation"
    amm_ind<-df_amm[[5]]
    names(amm_ind)[4]<-"nh3_industry"
    amm_res<-df_amm[[6]]
    names(amm_res)[4]<-"nh3_residential_commercial"
    amm_shp<-df_amm[[7]]
    names(amm_shp)[4]<-"nh3_ships"
    amm_sum<-df_amm[[8]]
    names(amm_sum)[4]<-"nh3_sum"
    amm_swd<-df_amm[[9]]
    names(amm_swd)[4]<-"nh3_solid_water_waste"
    amm_tnr<-df_amm[[10]]
    names(amm_tnr)[4]<-"nh3_off_road_transportation"
    amm_tro<-df_amm[[11]]
    names(amm_tro)[4]<-"nh3_road_transportation"
    amm <- merge(amm_agl,
                 merge(amm_ags,
                       merge(amm_awb,
                             merge(amm_ene,
                                   merge(amm_ind,
                                         merge(amm_res,
                                               merge(amm_shp,
                                                     merge(amm_sum,
                                                           merge(amm_swd,
                                                                 merge(amm_tnr,amm_tro))))))))))
  }

path_out<-"CAMS/MonthlyPointsDataframe/"
save(cams_nh3,file=paste0(path_out,pollutant," 2016_2020 ",region,".Rdata"))
rm(delete_variables,pollutant,variables)
# _ B.1.2. nitrogen dioxides ####

source("FUNCTIONS/getvarCAMS.R")
B_LO <- c(8.05,11.85,44.35,46.95) #boundary of Lombardy
region<-"Lombardy"
path_in<-"CAMS/rawdata/"
years<-2016
pollutant<-"nitrogen-oxides"
nc<-nc_open(paste0(path_in,dataset,"_",pollutant,"_",years,".nc"))
variables<-names(nc$var)
delete_variables<-list("date","fef","slv")
"%notin%"<-Negate("%in%")
variables<-variables[variables %notin% delete_variables]
rm(nc,years)
cams_nox<-data.frame()
cams_nox<-foreach (years = 2016:2020,
                   .combine = rbind,
                   .packages = "ncdf4") %dopar%
  {
    nc<-nc_open(paste0(path_in,"CAMS-GLOB-ANT_v4.2_",pollutant,"_",years,".nc"))
    df_nox<-getvarCAMS(nc=nc,
                       year=years,
                       boundary=B_LO,
                       variables = variables)
    nox_agl<-df_nox[[1]]
    names(nox_agl)[4]<-"nox_livestock_manure_management"
    nox_ags<-df_nox[[2]]
    names(nox_ags)[4]<-"nox_agriculture_soils"
    nox_awb<-df_nox[[3]]
    names(nox_awb)[4]<-"nox_agriculture_waste_burning"
    nox_ene<-df_nox[[4]]
    names(nox_ene)[4]<-"nox_power_generation"
    nox_ind<-df_nox[[5]]
    names(nox_ind)[4]<-"nox_industry"
    nox_res<-df_nox[[6]]
    names(nox_res)[4]<-"nox_residential_commercial"
    nox_shp<-df_nox[[7]]
    names(nox_shp)[4]<-"nox_ships"
    nox_sum<-df_nox[[8]]
    names(nox_sum)[4]<-"nox_sum"
    nox_swd<-df_nox[[9]]
    names(nox_swd)[4]<-"nox_solid_water_waste"
    nox_tnr<-df_nox[[10]]
    names(nox_tnr)[4]<-"nox_off_road_transportation"
    nox_tro<-df_nox[[11]]
    names(nox_tro)[4]<-"nox_road_transportation"
    nox <- merge(nox_agl,
                 merge(nox_ags,
                       merge(nox_awb,
                             merge(nox_ene,
                                   merge(nox_ind,
                                         merge(nox_res,
                                               merge(nox_shp,
                                                     merge(nox_sum,
                                                           merge(nox_swd,
                                                                 merge(nox_tnr,nox_tro))))))))))
  }
path_out<-"CAMS/MonthlyPointsDataframe/"
save(cams_nox,file=paste0(path_out,pollutant," 2016_2020 ",region,".Rdata"))
rm(delete_variables,pollutant,variables)

# _ B.1.3. sulfur dioxide ####

source("FUNCTIONS/getvarCAMS.R")
region<-"Lombardy"
B_LO <- c(8.05,11.85,44.35,46.95) #boundary of Lombardy
path_in<-"CAMS/rawdata/"
years<-2016
pollutant<-"sulphur-dioxide"
dataset<-"CAMS-GLOB-ANT_v4.2"
nc<-nc_open(paste0(path_in,dataset,"_",pollutant,"_",years,".nc"))
variables<-names(nc$var)
delete_variables<-list("agl","ags","date","fef","slv")
"%notin%"<-Negate("%in%")
variables<-variables[variables %notin% delete_variables]
rm(nc,years)
cams_so2<-data.frame()
cams_so2<-foreach (years = 2016:2020,
                   .combine = rbind,
                   .packages = "ncdf4") %dopar%
  {
    nc<-nc_open(paste0(path_in,"CAMS-GLOB-ANT_v4.2_",pollutant,"_",years,".nc"))
    df_so2<-getvarCAMS(nc=nc,
                       year=years,
                       boundary=B_LO,
                       variables = variables)
    so2_awb<-df_so2[[1]]
    names(so2_awb)[4]<-"so2_agriculture_waste_burning"
    so2_ene<-df_so2[[2]]
    names(so2_ene)[4]<-"so2_power_generation"
    so2_ind<-df_so2[[3]]
    names(so2_ind)[4]<-"so2_industry"
    so2_res<-df_so2[[4]]
    names(so2_res)[4]<-"so2_residential_commercial"
    so2_shp<-df_so2[[5]]
    names(so2_shp)[4]<-"so2_ships"
    so2_sum<-df_so2[[6]]
    names(so2_sum)[4]<-"so2_sum"
    so2_swd<-df_so2[[7]]
    names(so2_swd)[4]<-"so2_solid_water_waste"
    so2_tnr<-df_so2[[8]]
    names(so2_tnr)[4]<-"so2_off_road_transportation"
    so2_tro<-df_so2[[9]]
    names(so2_tro)[4]<-"so2_road_transportation"
    so2 <- merge(so2_awb,
                 merge(so2_ene,
                       merge(so2_ind,
                             merge(so2_res,
                                   merge(so2_shp,
                                         merge(so2_sum,
                                               merge(so2_swd,
                                                     merge(so2_tnr,so2_tro))))))))
  }
path_out<-"CAMS/MonthlyPointsDataframe/"
save(cams_so2,file=paste0(path_out,pollutant," 2016_2020 ",region,".Rdata"))
rm(delete_variables,pollutant,variables,path_in,path_out)

# _ B.1.4. merging all emissions ####

path_in <- "CAMS/MonthlyPointsDataframe/"
path_out <- "CAMS/MonthlyPointsDataframe/"
region<-"Lombardy"
# if you don't have cams_nh3 ; cams_nox ; cams_so2 in your environment:
# load(paste0(path_in,"ammonia 2016_2020 Lombardy.Rdata")
# load(paste0(path_in,"nitrogen-oxides 2016_2020 Lombardy.Rdata"))
# load(paste0(path_in,"sulphur-dioxide 2016_2020 Lombardy.Rdata"))

cams<-merge(cams_nh3,merge(cams_nox,cams_so2))
save(cams,file = paste0(path_out,"nh3 nox so2 2016_2020 ",region,".Rdata"))
rm(cams_nh3,cams_nox,cams_so2,path_in,path_out,dataset)
gc()
# B.2. From Monthly to Daily ====
# _ B.2.1. add last month data (as average of observations of the same period) &
# transformation units of measure ####

path_in<-"CAMS/MonthlyPointsDataframe/"

# if you don't have cams in your environment:
# load(paste0(path_in,"nh3 nox so2 2016_2020 Lombardy.Rdata")) 

cams[,-c(1:3)]<-cams[,-c(1:3)]*10^6 #from kg to mg
cams[,-c(1:3)]<-cams[,-c(1:3)]*86400 #from sec to day
lon<-unique(cams$Lon)
lat<-unique(cams$Lat)
cams$time<-as.Date(cams$time)
cams$months<-months(cams$time,abbreviate = FALSE)
cams_gen <- subset(cams,months=="gennaio")
cams<-cams[,-35]
cams_end_df<-foreach (xf = lon, .combine = rbind, .packages = "doParallel") %dopar% {
  subx<-subset(cams_gen,round(Lon,2)==round(xf,2))
  foreach (yf = lat, .combine = rbind) %dopar% {
    subxy<-subset(subx,round(Lat,2)==round(yf,2))
    val<-c()
    for (var in 1:ncol(cams[,-c(1:3)])) {
      val[var]<-mean(subxy[,3+var])}
    end_df<-as.data.frame(t(val))
    names(end_df)<-names(cams[,-c(1:3)])
    meta_df<-data.frame(Lon=xf,
                        Lat=yf,
                        time=as.Date("2020/12/31"))
    df<-cbind(meta_df,end_df)
  }
}

cams<- rbind(cams,cams_end_df)
rm(cams_end_df,cams_gen,lat,lon)
path_out<-"CAMS/MonthlyPointsDataframe/"
region<-"Lombardy"
save(cams,file = paste0(path_out,"nh3 nox so2 2016_2020 ",region," vers2.Rdata"))

# _ B.2.2. Hermite spline ----

path_in<-"CAMS/MonthlyPointsDataframe/"

# if you don't have cams (64233 obs of 14 vars) in your environment:
# load(paste0(path_in,"nh3 nox so2 2016_2020 Lombardy vers2.Rdata")) 

lon<-unique(cams$Lon)
lat<-unique(cams$Lat)
nvar<-ncol(cams[,-c(1:3)])
days<-seq(as.Date("2016-01-01",tz="UTC"),
          as.Date("2020-12-31",tz="UTC"),
          by="days")
df_days<-data.frame(time=days)
cams_daily<-data.frame()
cams_daily<-foreach(xf = lon, .combine = rbind, .packages = "doParallel") %dopar% {
  subx<-subset(cams,round(Lon,2)==round(xf,2))
  foreach (yf = lat, .combine = rbind) %dopar% {
    subxy<-subset(subx,round(Lat,2)==round(yf,2))
    subxy$time<-as.Date(subxy$time)
    subxy<-merge(subxy,df_days,all.y=T)
    subxy<-subxy[order(subxy$time),]
    subxy$timeid<-1:nrow(subxy)
    d_matr<-matrix(data=NA,nrow=nrow(subxy),ncol=nvar)
    colnames(d_matr)<-names(cams[,-c(1:3)])
    for (v in 1:nvar) {
      splineH<-splinefun(subxy$timeid,subxy[,3+v],method = "monoK.FC")
      k<-which(v==1:nvar)
      d_matr[,k]<-splineH(subxy$timeid)
    }
    df_daily_meta<-data.frame(Lon=rep(xf,length(days)),
                              Lat=rep(yf,length(days)),
                              days=days)
    df_daily <- cbind(df_daily_meta,as.data.frame(d_matr))
  }}
cams_daily[cams_daily<0]<-0
path_out<-"CAMS/DailyPointsDataframe/"
region<-"Lombardy"
save(cams_daily, file = paste0(path_out,"Daily nh3 nox so2 2016_2020 ",region,".Rdata"))

rm(df_days,days,lat,lon,nvar,path_in,path_out,region)
gc()
# _ B.2.3. plot original data VS reconstructed data from spline ----

#original data
path_in<-"CAMS/MonthlyPointsDataframe/"
load(paste0(path_in,"nh3 nox so2 2016_2020 Lombardy vers2.Rdata"))
# spline data
path_in<-"CAMS/DailyPointsDataframe/"
load(paste0(path_in,"Daily nh3 nox so2 2016_2020 Lombardy.Rdata"))

lon<-sample(unique(cams$Lon),1)
lat<-sample(unique(cams$Lat),1)
sample_cams<-cams[cams$Lon==lon&cams$Lat==lat,]
sample_cams_daily<-cams_daily[cams_daily$Lon==lon&cams_daily$Lat==lat,]

dfcompare1<-data.frame(time=sample_cams$time,
                       monthly=sample_cams$nh3_livestock_manure_management)
dfcompare2<-data.frame(time=sample_cams_daily$days,
                       daily=sample_cams_daily$nh3_livestock_manure_management)
dfcompare<-merge(dfcompare1,dfcompare2,all.y=T)

ggplot(dfcompare,aes(time,daily))+
  geom_line(aes(time,daily))+
  geom_point(aes(time,monthly),col=2,size=2)+
  labs(title="Ammonia emissions from livestock manure management from a random cell",
       subtitle = "Comparison of original monthly data and daily data calculated with Hermite spline",
       y="nh3 emission [mg/m2*day]",
       x="Date",
       caption = "data retrieved from CAMS GLOBAL EMISSIONS INVENTORY")+
  theme(legend.position = "right")
rm(cams,cams_daily,dfcompare,dfcompare1,dfcompare2,sample_cams,sample_cams_daily,lon,lat)
gc()
ERA5_RelativeHumidity<-function(year,region,dataset,dtm,newfile=F,path_in,path_out,print=T){
  ERA5_files <- list.files(path=path_in,pattern = "*.nc") # take all files
  ERA5_files <- subset(ERA5_files,grepl(dataset,ERA5_files)) # only dataset
  ERA5_files <- subset(ERA5_files,grepl(region,ERA5_files)) #only region
  ERA5_file <- subset(ERA5_files,grepl(year,ERA5_files)) #only year
  nc<-nc_open(paste0(path_in,ERA5_file))
  lon<-nc$dim$longitude$vals
  lat<-nc$dim$latitude$vals
  lev<-nc$dim$level$vals
  tim<-nc$dim$time$vals
  df<-data.frame(x=rep(lon,length(lat)),y=rep(lat,each=length(lon)))
  coordinates(df)<-c("x","y")
  df$alt<-raster::extract(dtm,df,method="simple")
  rh <- ncvar_get(nc,"r")
  df2<-data.frame(x=rep(df$x,length(ncvar_get(nc,"time"))),
                  y=rep(df$y,length(ncvar_get(nc,"time"))),
                  z=rep(df$alt,length(ncvar_get(nc,"time"))))
  df2$lev600<-c(rh[,,1,])
  df2$lev700<-c(rh[,,2,])
  df2$lev800<-c(rh[,,3,])
  df2$lev900<-c(rh[,,4,])
  df2$lev925<-c(rh[,,5,])
  df2$lev950<-c(rh[,,6,])
  df2$lev975<-c(rh[,,7,])
  df2$lev1000<-c(rh[,,8,])
  df2$actualRH<-c(rep(NA,length(nrow(df2))))
  df2$actualRH<-df2$lev1000
  df2$actualRH[df2$z>=106]<-df2$lev975[df2$z>=106]
  df2$actualRH[df2$z>=321]<-df2$lev950[df2$z>=321]
  df2$actualRH[df2$z>=541]<-df2$lev925[df2$z>=541]
  df2$actualRH[df2$z>=766]<-df2$lev900[df2$z>=766]
  df2$actualRH[df2$z>=1350]<-df2$lev800[df2$z>=1350]
  df2$actualRH[df2$z>=2361]<-df2$lev700[df2$z>=2361]
  df2$actualRH[df2$z>=3489]<-df2$lev600[df2$z>=3489]
  df2$t<-rep(tim,each=length(lat)*length(lon))
  start<-as.POSIXct(paste0(year,"/1/1 00:00:00"))
    end<-as.POSIXct(paste0(year,"/12/31 23:00:00"))
  days<-days<-seq(start,end,by="hours")
  df2$days<-rep(days,each=(length(lon)*length(lat)))
  df2<-df2[,c(1,2,14,12)]
  if (newfile==T){
    output<-paste0(dataset," ",year," ",region,".Rdata")
    save(df2,file = paste0(path_out,output))
  }
  if (print==T){
  return(df2)}
}
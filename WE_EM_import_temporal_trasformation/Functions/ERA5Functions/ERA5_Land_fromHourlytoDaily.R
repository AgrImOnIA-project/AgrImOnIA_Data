ERA5_Land_fromHourlytoDaily <- function(year,region,dataset,newfile,path_in,path_out,print=T){
  ERA5_files <- list.files(path=path_in,pattern = "*.Rdata") # take all files
  ERA5_files <- subset(ERA5_files,grepl(dataset,ERA5_files)) # only dataset
  ERA5_files <- subset(ERA5_files,grepl(region,ERA5_files)) #only region
  ERA5_file <- subset(ERA5_files,grepl(year,ERA5_files)) #only year
  load(paste0(path_in,ERA5_file))
  lon<-unique(df$Lon)
  lat<-unique(df$Lat)
  time<-unique(df$time)
  daily<-seq(1,length(time),by=24) #first hour of each days
  # from u10 and v10 to wind speed and direction
  df$ws<-sqrt((df$u10^2)+(df$v10^2)) #wind speed in m/s
  # df$ws_kmh<-df$ws*3.6 #wind speed in km/h
  df$wa<-atan2(df$u10/df$ws,df$v10/df$ws) #wind direction in radius
  df$wa_deg<-180-(df$wa*180/pi) #wind direction in angle
  classi <- seq(0,360,by=22.5)
  df$wa_deg_cl<-array(NA,nrow(df))
  df$wa_deg_cl[which(df$wa_deg>= classi[1]&df$wa_deg<= classi[2])]<-"S"
  df$wa_deg_cl[which(df$wa_deg>= classi[2]&df$wa_deg<= classi[4])]<-"SW"
  df$wa_deg_cl[which(df$wa_deg>= classi[4]&df$wa_deg<= classi[6])]<-"W"
  df$wa_deg_cl[which(df$wa_deg>= classi[6]&df$wa_deg<= classi[8])]<-"NW"
  df$wa_deg_cl[which(df$wa_deg>= classi[8]&df$wa_deg<= classi[10])]<-"N"
  df$wa_deg_cl[which(df$wa_deg>= classi[10]&df$wa_deg<= classi[12])]<-"NE"
  df$wa_deg_cl[which(df$wa_deg>= classi[12]&df$wa_deg<= classi[14])]<-"E"
  df$wa_deg_cl[which(df$wa_deg>= classi[14]&df$wa_deg<= classi[16])]<-"SE"
  df$wa_deg_cl[which(df$wa_deg>= classi[16]&df$wa_deg<= classi[17])]<-"S"
  names(df)[6]<-"d2m"
  df$rh<-100*(exp(((17.625*df$d2m)/(243.04+df$d2m))-((17.625*df$t2m)/(243.04+df$t2m))))
  df<-df[,-6]
  getmode <- function(v) {
    uniqv <- unique(v)
    uniqv[which.max(tabulate(match(v, uniqv)))]
  }
  # ------- daily trasformation --------- #
  # 
  # Col   Variables                  trasformation:                   cycle var
  # 12    wind speed                 simple mean and max              sm & 1
  # 15    wind angle class           most frequent class (45° size)   w  
  # 6     temperature                simple mean                      sm
  # 7-8   vegetation index           fixed daily values (from 01:00)  fd       
  # 9     surface solar radiation    max value (from 01:00)           max
  # 10    surface pressure           simple mean                      sm
  # 11    total precipitation        cumulative sum                   cs
  # 16    relative humidity          min, mean, max                   rh
  daily_values_1<-list()
  for (x in 1:length(lon)) {
    sub1<-subset(df,round(Lon,2)==round(lon[x],2))
    daily_values_2<-list()
    for (y in 1:length(lat)) {
      sub2<-subset(sub1,round(Lat,2)==round(lat[y],2))
      sub2<-sub2[order(sub2$time),]
      daily_values_3<-list()
      for (d in 1:length(daily)) {
        daily_values_4<-list()
        for (sm in c(12,6,10)) { #wind speed, temperature, surface pressure
          daily_values_4[[sm]]<-mean(sub2[c(daily[d]:(daily[d]+23)),sm])
          ifelse(d==1,
                 daily_values_3[[sm]]<-daily_values_4[[sm]],
                 daily_values_3[[sm]]<-c(daily_values_3[[sm]],
                                         daily_values_4[[sm]]))
        }
          daily_values_4[[1]]<-max(sub2[c((daily[d]):(daily[d]+23)),12]) #max of wind speed
          ifelse(d==1,
               daily_values_3[[1]]<-daily_values_4[[1]],
               daily_values_3[[1]]<-c(daily_values_3[[1]],
                                      daily_values_4[[1]]))
        for (w in 15) { #mode of wind direction
          daily_values_4[[w]]<-getmode(sub2[c(daily[d]:(daily[d]+23)),w])
          ifelse(d==1,
                 daily_values_3[[w]]<-daily_values_4[[w]],
                 daily_values_3[[w]]<-c(daily_values_3[[w]],
                                        daily_values_4[[w]]))
        }
        for (fd in c(7,8)) { #vegetation index, fixed daily value
          daily_values_4[[fd]]<-sub2[(daily[d]+1),fd]
          ifelse(d==1,
                 daily_values_3[[fd]]<-daily_values_4[[fd]],
                 daily_values_3[[fd]]<-c(daily_values_3[[fd]],
                                         daily_values_4[[fd]]))
        }
          sr<-sub2[c((daily[d]+1):(daily[d]+23)),9]
          daily_values_4[[9]]<-max(sr[!is.na(sr)]) #surface solar radiation
          ifelse(d==1,
               daily_values_3[[9]]<-daily_values_4[[9]],
               daily_values_3[[9]]<-c(daily_values_3[[9]],
                                      daily_values_4[[9]]))
          daily_values_4[[11]]<-sum(sub2[c(daily[d]:(daily[d]+23)),11]) #total precipitation
          ifelse(d==1,
               daily_values_3[[11]]<-daily_values_4[[11]],
               daily_values_3[[11]]<-c(daily_values_3[[11]],
                                       daily_values_4[[11]]))
          daily_values_4[[3]]<-min(sub2[c(daily[d]:(daily[d]+23)),16]) #min relative humidity
          ifelse(d==1,
                 daily_values_3[[3]]<-daily_values_4[[3]],
                 daily_values_3[[3]]<-c(daily_values_3[[3]],
                                         daily_values_4[[3]]))
          daily_values_4[[4]]<-mean(sub2[c(daily[d]:(daily[d]+23)),16]) #mean relative humidity
          ifelse(d==1,
                 daily_values_3[[4]]<-daily_values_4[[4]],
                 daily_values_3[[4]]<-c(daily_values_3[[4]],
                                        daily_values_4[[4]]))
          daily_values_4[[5]]<-max(sub2[c(daily[d]:(daily[d]+23)),16]) #max relative humidity
          ifelse(d==1,
                 daily_values_3[[5]]<-daily_values_4[[5]],
                 daily_values_3[[5]]<-c(daily_values_3[[5]],
                                        daily_values_4[[5]]))
        
      }
      for (dv2 in c(12,6,10,1,15,7,8,9,11,3,4,5)) {
        ifelse(y==1,
               daily_values_2[[dv2]]<-daily_values_3[[dv2]],
               daily_values_2[[dv2]]<-c(daily_values_2[[dv2]],
                                        daily_values_3[[dv2]]))
      }
    }
    for (dv1 in c(12,6,10,1,15,7,8,9,11,3,4,5)) {
      ifelse(x==1,
             daily_values_1[[dv1]]<-daily_values_2[[dv1]],
             daily_values_1[[dv1]]<-c(daily_values_1[[dv1]],
                                      daily_values_2[[dv1]]))
    }
  }
  
  days<-seq(as.Date(paste0(year,"/1/1")),
            as.Date(paste0(year,"/12/31")),
            by="day")
  df_daily<-data.frame(Lon=rep(lon,each=(length(lat)*length(days))),
                       Lat=rep(lat,length(lon),each=length(days)),
                       days=days,
                       mean_temperature=daily_values_1[[6]],
                       mean_wind_speed_10m=daily_values_1[[12]],
                       max_wind_speed_10m=daily_values_1[[1]],
                       mode_wind_direction_10m=daily_values_1[[15]],
                       sum_total_precipitation=daily_values_1[[11]],
                       mean_surface_pressure=daily_values_1[[10]],
                       max_surface_solar_radiation=daily_values_1[[9]],
                       fixed_high_vegetation_index=daily_values_1[[7]],
                       fixed_low_vegetation_index=daily_values_1[[8]],
                       min_relative_numidity=daily_values_1[[3]],
                       mean_relative_numidity=daily_values_1[[4]],
                       max_relative_numidity=daily_values_1[[5]]
  )
  # --- saving output
  if (newfile==T){
    output<-paste0("Daily ",dataset," ",year," ",region,".Rdata")
    save(df_daily,file=paste0(path_out,output))}
  if (print==T){
  return(df_daily)}
}

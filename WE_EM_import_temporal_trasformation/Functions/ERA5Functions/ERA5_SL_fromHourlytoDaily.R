#function to convert hourly ERA5 SL points dataframe to daily points dataframe
ERA5_SL_fromHourlytoDaily <- function(year,region,dataset,newfile,path_in,path_out,print=T){
  ERA5_files <- list.files(path=path_in,pattern = "*.Rdata") # take all files
  ERA5_files <- subset(ERA5_files,grepl(dataset,ERA5_files)) # only dataset
  ERA5_files <- subset(ERA5_files,grepl(region,ERA5_files)) #only region
  ERA5_file <- subset(ERA5_files,grepl(year,ERA5_files)) #only year
  load(paste0(path_in,ERA5_file))
  lon<-unique(df$Lon)
  lat<-unique(df$Lat)
  time<-unique(df$time)
  daily<-seq(1,length(time),by=24) #first hour of each days
  # --- WIND ---
  # from u10 and v10 to wind speed and direction
  df$ws<-sqrt((df$u100^2)+(df$v100^2)) #wind speed in m/s
  # df$ws_kmh<-df$ws*3.6 #wind speed in km/h
  df$wa<-atan2(df$u100/df$ws,df$v100/df$ws) #wind direction in radius
  df$wa_deg<-df$wa*180/pi #wind direction in angle
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
  getmode <- function(v) {
    uniqv <- unique(v)
    uniqv[which.max(tabulate(match(v, uniqv)))]
  }
  # ------- daily trasformation --------- #
  # 
  # Col   Variables                  trasformation:                   cycle
  # 8     wind speed                 simple mean and max              sm
  # 10    wind angle                 mode                             mf  
  # 6     Boundary layer height      max (11) e min (12)              mm           
  # 7     Precipitation type         factorial
  # 9     Trapping layer height      NO
  # 10    Trapping layer base        NO
  #   the cycle take 1 point at 1 time
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
        for (sm in 8) { #wind speed
          daily_values_4[[sm]]<-mean(sub2[c((daily[d]):(daily[d]+23)),sm])
          ifelse(d==1,
                 daily_values_3[[sm]]<-daily_values_4[[sm]],
                 daily_values_3[[sm]]<-c(daily_values_3[[sm]],
                                         daily_values_4[[sm]]))
        }
        daily_values_4[[1]]<-max(sub2[c(daily[d]:(daily[d]+23)),8]) #max of wind speed
        ifelse(d==1,
               daily_values_3[[1]]<-daily_values_4[[1]],
               daily_values_3[[1]]<-c(daily_values_3[[1]],
                                      daily_values_4[[1]]))
        daily_values_4[[2]]<-getmode(sub2[c(daily[d]:(daily[d]+23)),11]) #mode of wind direction
        ifelse(d==1,
               daily_values_3[[2]]<-daily_values_4[[2]],
               daily_values_3[[2]]<-c(daily_values_3[[2]],
                                      daily_values_4[[2]]))
        for (mm in 6) {
          daily_values_4[[14]]<-max(sub2[c((daily[d]+1):(daily[d]+23)),mm])
          daily_values_4[[15]]<-min(sub2[c((daily[d]+1):(daily[d]+23)),mm])
          ifelse(d==1,
                 daily_values_3[[14]]<-daily_values_4[[14]],
                 daily_values_3[[14]]<-c(daily_values_3[[14]],
                                         daily_values_4[[14]]))
          ifelse(d==1,
                 daily_values_3[[15]]<-daily_values_4[[15]],
                 daily_values_3[[15]]<-c(daily_values_3[[15]],
                                         daily_values_4[[15]]))
        }
        daily_values_4[[7]]<-ifelse(
          round(sum(sub2[c((daily[d]+1):(daily[d]+23)),7]),0)==0,
          0,
          getmode(round(sub2[c((daily[d]+1):(daily[d]+23)),7],0)))
        ifelse(d==1,
               daily_values_3[[7]]<-daily_values_4[[7]],
               daily_values_3[[7]]<-c(daily_values_3[[7]],
                                      daily_values_4[[7]]))
      }
      for (dv2 in c(8,1,2,14,15,7)) {
        ifelse(y==1,
               daily_values_2[[dv2]]<-daily_values_3[[dv2]],
               daily_values_2[[dv2]]<-c(daily_values_2[[dv2]],
                                        daily_values_3[[dv2]]))
      }
    }
    for (dv1 in c(8,1,2,14,15,7)) {
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
                       mean_wind_speed_100m=daily_values_1[[8]],
                       max_wind_speed_100m=daily_values_1[[1]],
                       mode_wind_direction_100m=daily_values_1[[2]],
                       max_boundary_layer_heigth=daily_values_1[[14]],
                       min_boundary_layer_heigth=daily_values_1[[15]],
                       precipitation_type=daily_values_1[[7]]
  )
  
  # --- saving output
  if (newfile==T){
    output<-paste0("Daily ",dataset," ",year," ",region,".Rdata")
    save(df_daily,file=paste0(path_out,output))}
  if (print==T){
  return(df_daily)}
}

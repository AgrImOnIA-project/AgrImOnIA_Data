ERA5netcdftopoints <- function(dataset,year,region,newfile=F,path_in,path_out,print=T){
  ERA5_files <- list.files(path=path_in,pattern = "*.nc") # take all files
  ERA5_files <- subset(ERA5_files,grepl(dataset,ERA5_files)) # only dataset
  ERA5_files <- subset(ERA5_files,grepl(region,ERA5_files)) #only region
  ERA5_file <- subset(ERA5_files,grepl(year,ERA5_files)) #only year
  nc<-nc_open(paste0(path_in,ERA5_file))
  lat <- ncvar_get(nc,"latitude")
  long <- ncvar_get(nc,"longitude")
  t <-ncvar_get(nc,"time")
  nvar <- nc$nvars
  varname <- names(nc$var)
  matr<-matrix(nrow = length(t)*length(long)*length(lat),
               ncol = 2)
  matr[,1]<-rep(rep(long,length(lat)),length(t))
  matr[,2]<-rep(rep(lat,each=length(long)),length(t))
  colnames(matr)<-c("Lon","Lat")
  df<-data.frame(matr)
  matr<-matrix(nrow = length(t)*length(long)*length(lat),
               ncol = nvar)
  start<-paste0(year,"-01-01 00:00:00")
  end<-paste0(year,"-12-31 23:00:00" )
  daytime<-seq.POSIXt(as.POSIXct(start,tz="UTC"),
                      as.POSIXct(end,tz="UTC"),
                      by="hour",tz="UTC")
  df$time<-rep(daytime,each=length(long)*length(lat))
  for (k in 1:nvar) {
    var<-ncvar_get(nc,varname[k])
    matr[,k]<-c(var)}
  colnames(matr)<-c(varname)
  df<-cbind(df,as.data.frame(matr))
  if (newfile==T){
    output<-paste0(dataset," ",year," ",region,".Rdata")
    save(df,file = paste0(path_out,output))
  }
  if (print == T){
  return(df)}
}


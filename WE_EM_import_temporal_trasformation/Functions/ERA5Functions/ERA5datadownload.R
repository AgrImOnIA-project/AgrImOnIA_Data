# README ----
# that functions requires 4 arguments:
# 1. user --> this number can be retrieved from your login webpage in CDS, 
# it has 6 number
# 2. dataset --> dataset compatible are: 
# 2.1 "ERA5Land" -> if you want data from era5land reanalysis
# 2.2 "ERA5SL"   -> if you want data from era5 single levels dataset
# 2.3 "ERA5PL"   -> if you want data from era5 pressure levels dataset
# 3. year --> multiple year must be written as c("XXXX","YYYY","ZZZZ")
# 4. boundary --> the geographical area you need, must be written as a vector of
# 4 coordinates starting from north and going anti-clockwise

# when you run the function the request is available in your CDS webpage request

# function ----
ERA5datadownload <- function(user,dataset,year,boundary){
  #boundary = start from up and going anti-clockwise (es. c(46.95, 8.05, 44.35, 11.85))
  if (dataset=="ERA5Land"){
    dataset2<-"reanalysis-era5-land"
    variables<-c("10m_u_component_of_wind", "10m_v_component_of_wind","2m_dewpoint_temperature", "2m_temperature", "leaf_area_index_high_vegetation", "leaf_area_index_low_vegetation", "surface_net_solar_radiation", "surface_pressure", "total_precipitation")
  }
  if (dataset=="ERA5SL"){
    dataset2<-"reanalysis-era5-single-levels"
    variables<- c("100m_u_component_of_wind", "100m_v_component_of_wind", "boundary_layer_dissipation", "boundary_layer_height", "precipitation_type", "trapping_layer_base_height", "trapping_layer_top_height")
  }
  if (dataset=="ERA5PL"){
    dataset2<-"reanalysis-era5-pressure-levels"
    variables<-"relative_humidity"
  }
  key<-wf_get_key(user = user,service = "cds" ) # user account of Alessandro Fusta 
  wf_set_key(user = user,key = key,service = "cds")
  request <- list(
    format = "netcdf",
    variable = variables,
    year = year,
    month = c("01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"),
    day = c("01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31"),
    time = c("00:00", "01:00", "02:00", "03:00", "04:00", "05:00", "06:00", "07:00", "08:00", "09:00", "10:00", "11:00", "12:00", "13:00", "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00", "21:00", "22:00", "23:00"),
    area = boundary,
    dataset_short_name = dataset2,
    target = "download.nc"
  )
  ncfile <- wf_request(user = user,
                       request = request,
                       transfer = TRUE,
                       path = "~",
                       verbose = FALSE)
}

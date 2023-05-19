#################################################################
########## ARPA Lombardia data download and management ##########
#################################################################

### 25/03/2022
### Paolo Maranzano

### Packages
library(ARPALData)
library(tidyverse)
library(ggplot2)
library(readxl)
library(openxlsx)
library(lubridate)

### Setting working directory
setwd("C:/Users/paulm/Google Drive (p.maranzano@campus.unimib.it)/CARIPLO/Data/Dataset ARPA Lombardia/ARPA_WebData/")

###########################################
########## Stations (point) data ##########
###########################################

### Metadata
Metadata_ARPALom <- read_excel("../../Metadata_AQ/Metadata_EEA_ARPA_UBA.xlsx", sheet = "MetadataARPALom")

### Download stations data
ARPALom_2016_2021 <- get_ARPA_Lombardia_AQ_data(ID_station = Metadata_ARPALom$IDStation,
                                                Year = 2016:2021,
                                                Frequency = "hourly",
                                                parallel = T,
                                                verbose = T)

ARPALom_2016_2021 <- ARPALom_2016_2021 %>%
  select(IDStation,NameStation,Date,Ammonia,CO,NO2,NOx,Ozone,PM10,PM2.5,Sulfur_dioxide,BlackCarbon)

write_csv(x = ARPALom_2016_2021, file = "ARPALom_PointData_2016_2021.csv")

# Save multiple objects
save(Metadata_ARPALom, ARPALom_2016_2021, file = "ARPALom_PointData_2016_2021.RData")

########################################
########## Municipal/LAU data ##########
########################################

### Metadata
Metadata_ARPALom_mun <- get_ARPA_Lombardia_AQ_municipal_registry()
Metadata_ARPALom_mun <- Metadata_ARPALom_mun %>%
  filter(is.na(DateStop))

wb <- createWorkbook("Metadata_ARPALom_Municip")
addWorksheet(wb,"MetadataARPALomLAU")
writeData(wb, sheet = "MetadataARPALomLAU", Metadata_ARPALom_mun, colNames = T)
saveWorkbook(wb,"Metadata_ARPALom_Municip.xlsx",overwrite = T)

### Download municipal/LAU data
ARPALom_mun_2017_2021 <- get_ARPA_Lombardia_AQ_municipal_data(ID_station = Metadata_ARPALom_mun$IDStation,
                                                              Year = 2017:2021,
                                                              Frequency = "daily",
                                                              parallel = T,
                                                              verbose = T)

write_csv(x = ARPALom_mun_2017_2021, file = "ARPALom_MunicipData_2016_2021.csv")

# Save multiple objects
save(Metadata_ARPALom_mun, ARPALom_mun_2017_2021, file = "ARPALom_MunicipData_2016_2021.RData")


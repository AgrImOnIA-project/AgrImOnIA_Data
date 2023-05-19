library(ARPALData)
library(tidyverse)
library(imputeTS)
library(tsibble)
library(lubridate)
library(readxl)

setwd("C:/Users/paulm/Google Drive (p.maranzano@campus.unimib.it)/CARIPLO/Data/ARPA_DatiOrari/Dati_originali/")

################
##### PM10 #####
################
ARPA_metadata <- read_excel("../../Metadata_AQ/Metadata_EEA_ARPA_UBA.xlsx", sheet = "MetadataARPALom")

PM10_metadata <- read_excel("PM10_orario_2010-2021.xlsx", n_max = 8)
PM10_data <- read_excel("PM10_orario_2010-2021.xlsx",
                        col_types = c("date", "numeric", "numeric", 
                                      "numeric", "numeric", "numeric", 
                                      "numeric", "numeric", "numeric", 
                                      "numeric", "numeric", "numeric", 
                                      "numeric", "numeric", "numeric", 
                                      "numeric", "numeric", "numeric", 
                                      "numeric", "numeric", "numeric", 
                                      "numeric", "numeric", "numeric", 
                                      "numeric", "numeric", "numeric", 
                                      "numeric", "numeric", "numeric", 
                                      "numeric", "numeric", "numeric", 
                                      "numeric", "numeric"))
PM10_data <- PM10_data[10:dim(PM10_data)[1],]
colnames(PM10_data) <- PM10_metadata[2,]
colnames(PM10_data)[1] <- "Date"

PM10_data <- PM10_data %>%
  select(-c("NA")) %>%
  mutate(Date = lubridate::ymd_hms(Date)) %>%
  as_tsibble(index = Date)

PM10_stats <- data.frame(t(PM10_metadata[c(1:2),])[-1,])
colnames(PM10_stats) <- c("IDSensor","IDStation")
PM10_stats <- PM10_stats %>%
  mutate(NameStation_long = rownames(PM10_stats),
         IDSensor = as.integer(IDSensor),
         IDStation = as.numeric(IDStation)) %>%
  filter(!is.na(IDStation))
PM10_stats <- left_join(x = PM10_stats, y = ARPA_metadata, by=c("IDSensor","IDStation"))
PM10_stats <- PM10_stats %>%
  mutate(Pollutant = "PM10")

PM10_data <- PM10_data %>%
  filter(Date >= as_datetime("2016-01-01 01:00:00")) %>%
  pivot_longer(cols = 2:last_col(), names_to = "IDStation", values_to = "PM10") %>%
  mutate(IDStation = as.numeric(IDStation)) %>%
  as_tibble()
PM10_data <- left_join(x = PM10_data, y = PM10_stats %>% select(IDStation,NameStation_long),
                       by=c("IDStation"))


###############
##### NH3 #####
###############
NH3_metadata <- read_excel("NH3_orari_2007-2021.xlsx", n_max = 8)
NH3_data <- read_excel("NH3_orari_2007-2021.xlsx",
                       col_types = c("date", "numeric", "numeric", "numeric", "numeric", "numeric", 
                                     "numeric", "numeric", "numeric", "numeric", "numeric", "numeric", 
                                     "numeric", "numeric", "numeric"), skip = 9)
NH3_data <- NH3_data[10:dim(NH3_data)[1],]
colnames(NH3_data) <- NH3_metadata[2,]
colnames(NH3_data)[1] <- "Date"

NH3_data <- NH3_data %>%
  mutate(Date = lubridate::ymd_hms(Date)) %>%
  as_tsibble(index = Date)

NH3_stats <- data.frame(t(NH3_metadata[c(1:2),])[-1,])
colnames(NH3_stats) <- c("IDSensor","IDStation")
NH3_stats <- NH3_stats %>%
  mutate(NameStation_long = rownames(NH3_stats),
         IDSensor = as.integer(IDSensor),
         IDStation = as.numeric(IDStation)) %>%
  filter(!is.na(IDStation))
NH3_stats <- left_join(x = NH3_stats, y = ARPA_metadata, by=c("IDSensor","IDStation"))
NH3_stats <- NH3_stats %>%
  mutate(Pollutant = "Ammonia")

NH3_data <- NH3_data %>%
  filter(Date >= as_datetime("2016-01-01 01:00:00")) %>%
  pivot_longer(cols = 2:last_col(), names_to = "IDStation", values_to = "NH3") %>%
  mutate(IDStation = as.numeric(IDStation)) %>%
  as_tibble()
NH3_data <- left_join(x = NH3_data, y = NH3_stats %>% select(IDStation,NameStation_long),
                       by=c("IDStation"))


######################################
##### Join datasets and metadata #####
######################################
ARPA_HourlyData <- full_join(x = PM10_data,y = NH3_data, by = c("Date","IDStation"))
ARPA_HourlyData <- ARPA_HourlyData %>%
  mutate(NameStation_long = ifelse(is.na(NameStation_long.x),NameStation_long.y,NameStation_long.x)) %>%
  select(IDStation,NameStation_long, Date,PM10,NH3) %>%
  arrange(Date,IDStation,NameStation_long)

ARPA_HourlyMetadata <- bind_rows(PM10_stats,NH3_stats)



####################################
##### Export data and metadata #####
####################################
write.csv(x = ARPA_HourlyMetadata, file = "ARPA_HourlyMetadata_PM10_NH3.csv")
write.csv(x = ARPA_HourlyData, file = "ARPA_HourlyData_PM10_NH3.csv")




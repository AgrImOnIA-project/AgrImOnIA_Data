# Air Quality (AQ) and livestock (LI) data

## AQ data
- ARPALData_download_2016_2021.R: download air quality data from ARPA Lombardy
- ARPA_Hourly_PM10_NH3_DataManagement.R: management of raw data downloaded from ARPA Lombardy
- AQDatabase.m: Script to create the AQ dataset adding buffer data to the Lomabardy region
- AQHourly2Daily.m: Script to chance from hourly to daily time series   

the EEAFunctions folder contains the EEA helper function and example while the Input folder contain the Input data for AQHourly2Daily script. 

## LI data

- BDNCreateDataset.m: Script to create the BDN dataset (run each section individually and make sure you have downloaded the files indicated in the section headings)  
- BDNDailySpline.m: Script to convert from bi-annual to daily time series 

the Input filder contains the shape file (.sh) of bovines and pigs



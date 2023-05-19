Air quality data are downloaded from ARPA Lombardy for the Lombardy region while they are downloaded from EEA for the buffer.

# ARPA data download and management
The script where data from ARPA are downloaded is ARPALData_download_2016_2021.R
The script where data are managed is ARPA_Hourly_PM10_NH3_DataManagement.R

# EEA Helper function
> Useful MATLAB function to download, filter and reshape EEA environmental data


## How it works 

- EEADownload: is the function to download data from EEA
- EEAReshape: is the function to filter and reshape
- EEAMerge: is the function to merge several time series 
- SSMHourly2Daily: convert from hourly to daily time series (and use state space model for missing imputation)


## Example

```
%% General settings
clear all
close all

FileName = 'DownloadData.mat'; 

country = "IT"; % italy


%% Download data

% download SO2 and NOx
[table_no2, metadata_no2] = EEADownload('tStart',"2020",'tEnd',"2021", 'CountryCode',country,'Pollutant',1,'Source',"All");
[table_nox metadata_nox] = EEADownload('tStart',"2020",'tEnd',"2021",'CountryCode',country,'Pollutant',9,'Source',"All");

%% Fitler


% define the box (latitude,longitude)
Box = struct('LatitudeMin',42.90,'LatitudeMax',...
        47.70,'LongitudeMin',6.00,'LongitudeMax',13.30);

[DataTime_no2, anagrafica_no2] = EEAReshape(table_no2,metadata_no2,'Box',Box);
[DataTime_nox anagrafica_nox] = EEAReshape(table_nox,metadata_nox,'Box',Box);


%% merge time series

% Merge single dataset to one datasets;
[TimeTable Anagrafica] = EEAMerge(...
    DataTime_no2, anagrafica_no2,DataTime_nox, anagrafica_nox);

%% Conver from hourly to daily 
% this function work for each station 

% define output file
output = matfile(FileName,'Writable',true);

IdStation = 'STA.IT0267A';

hData = TimeTable(TimeTable.IDStation == IdStation,"SO2");
[output.DailyData output.Uncetanlty] = SSMHourly2Daily(hData,"Threshold",6);


% Protect row data from rewriting
output.Properties.Writable = false;
``` 



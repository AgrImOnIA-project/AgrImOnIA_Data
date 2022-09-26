%% DOWNLOAD DATA FROM EUROPIEN ENVIRONMENT AGENCY (EEA)
% Author Jacopo Rodeschini

clear all

% select country - global variables
country = "IT"; % italy
%country = "CH"; % swiss
%country = "DE"; % germany 

%% IMPORT LIBRARY 
addpath(genpath('EEAFunctions'))

%% GENERAL SETTINGS 

% global file name
FileName_DownLoad = sprintf("EEA-%s/%s_EEAData.mat",country,country);
FileName_Rashape = sprintf("EEA-%s/%s_EEAReshape.mat",country,country);
FileName_Merge = sprintf("EEA-%s/%s_EEAMerged.mat",country,country);

OutputCsv_Data = sprintf('EEA-%s/%s_EEATimeTable.csv',country,country);
OutputCsv_Metadata = sprintf('EEA-%s/%s_EEAMetadatacsv',country,country);

%% DOWNLOAD .csv FILE FORM EEA SERVICE

file = matfile(FileName_DownLoad,'Writable',true);


[file.table_so2 file.metadata_so2]  = EEADownload('CountryCode',country,...
    'Pollutant',1,'Source',"All",'TimeZone',"UTC+1");

[file.table_pm10, file.metadata_pm10] = EEADownload('CountryCode',country,'Pollutant',5,'Verbose',true);
[file.table_o3, file.metadata_o3] = EEADownload('CountryCode',country,'Pollutant',7,'Source',"All");
[file.table_no2, file.metadata_no2] = EEADownload('CountryCode',country,'Pollutant',8,'Source',"All");
[file.table_nox file.metadata_nox] = EEADownload('CountryCode',country,'Pollutant',9,'Source',"All");
[file.table_co file.metadata_co] = EEADownload('CountryCode',country,'Pollutant',10,'Source',"All");
[file.table_pm25 file.metadata_pm25]= EEADownload('CountryCode',country,'Pollutant',6001,'Source',"All");

% Protect row data from rewriting
file.Properties.Writable = false;

%% Start to Filter Data

% Create new file in order to save new results;
export = matfile(FileName_Rashape,'Writable',true);

% Italian Box
if(country == 'IT')
    Box = struct('LatitudeMin',42.90,'LatitudeMax',...
        47.70,'LongitudeMin',6.00,'LongitudeMax',13.30);
% German box
elseif(country == 'CH') 
    Box = {};
% German box
elseif(country == 'DE') 
    Box = struct('LatitudeMin',51.40,'LatitudeMax',...
        53.90,'LongitudeMin',7.15,'LongitudeMax',11.90);
else
    disp("Select country before proceeding")
end

[export.DataTime_so2, export.anagrafica_so2] = EEAReshape(file.table_so2,file.metadata_so2,'Box',Box);
[export.DataTime_pm10, export.anagrafica_pm10] = EEAReshape(file.table_pm10,file.metadata_pm10,'Box',Box);
[export.DataTime_o3, export.anagrafica_o3] = EEAReshape(file.table_o3,file.metadata_o3,'Box',Box );
[export.DataTime_no2, export.anagrafica_no2] = EEAReshape(file.table_no2,file.metadata_no2,'Box',Box);
[export.DataTime_nox export.anagrafica_nox] = EEAReshape(file.table_nox,file.metadata_nox,'Box',Box);
[export.DataTime_co export.anagrafica_co] = EEAReshape(file.table_co,file.metadata_co,'Box',Box);
[export.DataTime_pm25 export.anagrafica_pm25] = EEAReshape(file.table_pm25,file.metadata_pm25,'Box',Box);

% Protect row data from rewriting
export.Properties.Writable = false;

%% Merge datasets -> ARPALData format

merge = matfile(FileName_Merge,'Writable',true);

% Merge single dataset to one datasets;
[merge.TimeTable merge.Anagrafica] = EEAMerge(...
    export.DataTime_so2, export.anagrafica_so2, ...
    export.DataTime_pm10, export.anagrafica_pm10,...
    export.DataTime_o3, export.anagrafica_o3,...
    export.DataTime_no2, export.anagrafica_no2,...
    export.DataTime_nox, export.anagrafica_nox,...
    export.DataTime_co, export.anagrafica_co,...
    export.DataTime_pm25, export.anagrafica_pm25);

% Protect row data from rewriting
merge.Properties.Writable = false;

%% save in .csv format

writetimetable(merge.TimeTable,OutputCsv_Data);
writetable(merge.Anagrafica,OutputCsv_Metadata);



function [Table Metadata ErrorPath] = EEADownload(options)
%% EXPORT DATA FROM EUROPIEN ENVIRONMENT AGENCY
% Author: Jacopo Rodeschini (UniBg Researcher)
% Parallel toolbox required
% link download data:
% https://discomap.eea.europa.eu/map/fme/AirQualityExport.htm
%
% Output:
% Table = Signle table of pollutant in the specified time
% ErrorPath = error on url -> try to manual download
%
%  PARAMETERS [deafult values]
%  CountryCode = IT
%  CityName = ""
%  Pollutant = 10 (pm10)
%  tStart = "2016"
%  tEnd = "2021"
%  Source = "All"
%  TimeCoverage= "Year"
%  Cluster = local
%  Verbose = true
%  TimeZone = "Europe/Zurich"
%
%  EXAMPLE
%  path = EEADownload('tStart','2016','tEnd','2018','Pollutant','5')
%  path = EEADownload('Pollutant','10')
%  path = EEADownload('Pollutant',"10",'Source',"All",'CountryCode',"IT");
%  path = EEADownload('Source',"E1a",'CountryCode',"DE");
%  path = EEADownload('CountryCode',"DE",'CityName',"Hannover",'Pollutant',"5",'Source',"All");
%  path = EEADownload('CountryCode',"IT",'CityName',"Milano",'Pollutant',"5",'Source',"All");
%
%
%  For more comprensive parameters values,
%  plese visit: https://discomap.eea.europa.eu/map/fme/AirQualityExport.htm


%%

arguments
    options.CountryCode(1,1)= "IT";
    options.CityName(1,1) = "";
    options.PollutantCode(1,1) = 5; %pm10
    options.tStart(1,1) = "2016";
    options.tEnd(1,1) = "2021";
    options.Source(1,1) = "All";
    options.TimeCoverage(1,1) = "Year";
    options.Verbose(1,1) = true;
    options.TimeZone(1,1) = "UTC+1"; 
end   

options.Station = "";
options.Samplingpoint = "";
options.UpdateDate(1,1) = "";
    
tic 
url = sprintf('https://fme.discomap.eea.europa.eu/fmedatastreaming/AirQualityDownload/AQData_Extract.fmw?CountryCode=%s&CityName=%s&Pollutant=%d&Year_from=%s&Year_to=%s&Station=%s&Samplingpoint=%s&Source=%s&Output=%s&UpdateDate=%s&TimeCoverage=%s',...
    options.CountryCode,options.CityName,options.PollutantCode,options.tStart,...
    options.tEnd,options.Station,options.Samplingpoint,options.Source,...
    "TEXT",options.UpdateDate,options.TimeCoverage);

opts = weboptions('Timeout',20,'ContentType','text');

if(options.Verbose)
    disp(sprintf('1) - Start procedure to download [Pollutant: %d]',options.PollutantCode));
    disp(sprintf('\t TimeZone: %s',options.TimeZone));
end

try
    
    linkfile = websave('Downolad_link.txt',url,opts);
    
    if(options.Verbose)
        disp(sprintf('2) - Save resource url file [path:%s]', linkfile));
    end
    
    
    fid = fopen(linkfile,'r');
    str = fscanf(fid,'%s');
    fclose(fid);
    delete(linkfile); 
    
   
catch Ex
    disp(Ex)
    disp(url)
    disp(Ex.identifier)
    Table = {};
    Metadata = {};
    return;
end


if(length(str) == 0)
    e = MException('MyComponent:noSuchVariable',...
        'Variable [ID:%d] - Not found',options.PollutantCode);
    throw(e)
end

link = split(str,'.csv');
link(end) = [];

link = strip(link,char(65279));
link = strip(link);

totFile = length(link);

Table = cell(totFile,1);


path = cell(totFile,1);
link = strcat(link,repmat('.csv',totFile,1)); 


DownloadOpt = weboptions('Timeout',10,'ContentType','table');
if(options.Verbose)
    disp(sprintf('3) - Start Download 0 of %d file ...',totFile));
end

ErrorPath = [];
data = [];
complete = zeros(totFile,1,'uint8');
parfor (i=1:length(link), parcluster('local'))
    try
        % download csv
        path = websave(link{i}(end-28:end),link{i},DownloadOpt);

        % create table
        Table{i} = EEAImportfile(path,options.TimeZone);

        % delete file
        delete(path)
        complete(i) = 1;

    catch Ex
        ex = struct('path',link{i},'Exception',Ex);
        ErrorPath = [ErrorPath; ex];
    end
end

if(options.Verbose)
    sec = toc;
    d = sum(complete);
    disp(sprintf('4) - Download Complete - %d (%d,%d)', d/ totFile,d,totFile ))
    disp(sprintf('5) - Time to download - %d sec',sec ))
end
    
% create single table
Table = vertcat(Table{:});

% Clear AirPollutant (string) add AirPollutantCode; 
Table = addvars(Table,repmat(uint32(options.PollutantCode),[size(Table,1),1]),...
    'NewVariableNames','AirPollutantCode','After','AirQualityStation');

% sort rows
Table = sortrows(Table,'DatetimeEnd');

% download metadata file
if(options.Verbose)
    disp('6) - Create metadata file')
end
metaUrl = 'https://discomap.eea.europa.eu/map/fme/metadata/PanEuropean_metadata.csv';
path = websave("metadata.csv",metaUrl,opts);

% load metadata
temp = EEAImportMetadata(path);
delete(path);

% Extract station informations (IT/DE - Lat/Lon)
index = ismember(temp.AirQualityStation,Table.AirQualityStation);
temp = temp(index,:);

temp(temp.AirPollutantCode ~= options.PollutantCode,:) =  [];

[~,idx] = unique(temp.AirQualityStation);
temp = temp(idx,:);

if(options.Verbose)
    disp('7) - Add metadata information: [Name of pollutant, Label of pollutant]')
end

% Extract pollutant name
polUrl = 'https://dd.eionet.europa.eu/vocabulary/aq/pollutant/csv';
path = websave("pollutant.csv",polUrl,opts);

name = EEAVocabularyImport(path);
delete(path);

Metadata = join(temp,name, "LeftKeys",{'AirPollutantCode'},'RightKeys',{'pollutantCode'});

end


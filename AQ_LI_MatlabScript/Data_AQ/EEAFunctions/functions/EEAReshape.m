function [TimeTable Metadata] = EEAReshape(DataTable,Metadata,options)
%% RESHAPE & FILTER DATA FROM EUROPIEN ENVIRONMENT AGENCY
% convert single table in timeTable with preallocate space and nan
% Author: Jacopo Rodeschini (UniBg Researcher)
% Parallel toolbox required
% support different UTCx timezone (and DST), default output in UTC format
% link download data: https://discomap.eea.europa.eu/map/fme/AirQualityExport.htm
% 
% 
% [TimeTable, Metadata]EEAReshape(DataTable,Metadata,Name,Value)
%
% Input
% - DataTable: table(:,7) output from EEADownload
% - Metadata : table(:,15) output from EEADownload
% {name:value} pair
% - Cluster
% - Box
% - shapefile
%
% Output
% - Timeteble: timetable matlab format in UTC time zone
% - Metadata: metadata of station in Timetable
%%

arguments
    DataTable(:,7) table = {};
    Metadata(:,15) table = {};
    options.Cluster(1,1) = parcluster('local');
    options.Box = struct('LatitudeMin',43.90,'LatitudeMax',...
       46.70,'LongitudeMin',7.50,'LongitudeMax',12.30);
    options.TimeZone  = {}; % OUTPUT timezone 
    options.shapefile(1,1) = "./ShapeFile/ShapeFIle_EU_NUTS3/NUTS_RG_03M_2021_3035.shp";
    
end

if(isempty(options.TimeZone))
    options.TimeZone = DataTable.DatetimeEnd(1).TimeZone;    
end

% filter over box se è specificato
if(~isempty(options.Box))
    disp("Filter over box")
    index_sts = Metadata.Latitude >= options.Box.LatitudeMin & Metadata.Latitude <= options.Box.LatitudeMax & ...
        Metadata.Longitude >= options.Box.LongitudeMin & Metadata.Longitude <=options.Box.LongitudeMax;

    Metadata = Metadata(index_sts,:);
else
    disp("Full data kept")
end

index = minute(DataTable.DatetimeEnd) ~= 0 | second(DataTable.DatetimeEnd) ~= 0 ;
DataTable(index,:) = [];

% check olty for the validate sample 
index = (DataTable.Validity == 1 | DataTable.Validity == 2 | DataTable.Validity == 3) ...
    & DataTable.Verification ~= 0 ...
    & ismember(DataTable.AirQualityStation,Metadata.AirQualityStation);

DataTable = DataTable(index,:);

% clean the metadata
index = ismember(Metadata.AirQualityStation,DataTable.AirQualityStation);
Metadata = Metadata(index,:);

% Check tStart and tEnd
tStart = min(DataTable.DatetimeEnd);
tStart.TimeZone = options.TimeZone;
tStart = dateshift(tStart,'start','year') + hours(1);

tEnd = max(DataTable.DatetimeEnd);
tEnd.TimeZone = options.TimeZone;
tEnd = dateshift(dateshift(tEnd,'end','year'),'end','day');

nHours = hours(time(between(tStart,tEnd,'time')));

varType = {'categorical', 'categorical','double', 'double'};
varName = {'Countrycode', 'AirQualityStation', 'AirPollutantCode', 'Concentration'};


timeFormat = timetable('Size',[nHours+1 length(varName)],'VariableType',varType,...
    'TimeStep',hours(1),'StartTime',tStart,'VariableNames',varName);

timeFormat.Concentration(:,1) = NaN;

pollutant = unique(DataTable.AirPollutantCode);
countryCode = unique(DataTable.Countrycode);

% adj static observation
timeFormat.AirPollutantCode(:,1) = pollutant;
timeFormat.Countrycode(:,1) = countryCode;

% Compute unique station type
nStations = unique(DataTable.AirQualityStation);

partial_tbl = cell(length(nStations),1);

for i = 1:length(nStations)

    temp = timeFormat;
    
 
    unique_stat = DataTable(DataTable.AirQualityStation == nStations(i),:);
    
   
    temp(unique_stat.DatetimeEnd,:) = unique_stat(:,varName);
    temp.AirQualityStation(:,1) = nStations(i);
    
    if ~isregular(temp)
        disp("erros")
    end
    
    partial_tbl{i} = temp;
    
end


% ensemble;
TimeTable = vertcat(partial_tbl{:});
TimeTable = sortrows(TimeTable,'Time');

% Add metadata Region - Province name
if isfile(options.shapefile)
    S = shaperead(options.shapefile);
    info = shapeinfo(options.shapefile);
    proj = info.CoordinateReferenceSystem;
    
    % filter over country
    index =  strcmp(vertcat({S.CNTR_CODE})',string(countryCode));
    S = S(index);
    
    reg = find(cell2mat(vertcat({S.LEVL_CODE})') == 2);
    prov = find(cell2mat(vertcat({S.LEVL_CODE})') == 3);
    
    % coversion reference system - Region and province
    poly_reg = cell(length(reg),1);
    poly_prov = cell(length(prov),1);
    
    for i = 1: length(reg)
        [lat lon] = projinv(proj,[S(reg(i)).X],[S(reg(i)).Y]);
        poly_reg{i} = [lat; lon]';
    end
    
    for i = 1: length(prov)
        [lat lon] = projinv(proj,[S(prov(i)).X],[S(prov(i)).Y]);
        poly_prov{i} = [lat; lon]';
    end
    
    % check metadata
    
    index_reg = nan(size(Metadata,1),1);
    for k = 1:length(reg)
        idx = inpolygon(Metadata.Latitude,Metadata.Longitude, poly_reg{k}(:,1),poly_reg{k}(:,2));
        index_reg(idx) = reg(k);
    end
    
    index_prov = nan(size(Metadata,1),1);
    for k = 1:length(prov)
        idx = inpolygon(Metadata.Latitude,Metadata.Longitude, poly_prov{k}(:,1),poly_prov{k}(:,2));
        index_prov(idx) = prov(k);
    end
    
    
    NUTS_NAME = strvcat(S.NUTS_NAME);
    
    Metadata = addvars(Metadata, NUTS_NAME(index_prov,:),NUTS_NAME(index_reg,:),...
        'NewVariableNames',{'Province','Region'},'After','Countrycode');
else
    Metadata = addvars(Metadata, nan(size(Metadata,1),1),nan(size(Metadata,1),1),...
        'NewVariableNames',{'Province','Region'},'After','Countrycode'); 
end
end


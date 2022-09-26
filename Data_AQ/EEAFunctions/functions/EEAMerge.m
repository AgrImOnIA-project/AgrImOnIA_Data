function [TimeTable Metadata] = EEAMerge(DataTable,Metadata)
%% MERGE DATA FROM EUROPIEN ENVIRONMENT AGENCY
% convert different timeTable in single timeTable (ARPAL data format)
% Author: Jacopo Rodeschini (UniBg Researcher)
% support different UTCx timezone (and DST), output in UTC format

% link download data:
% https://discomap.eea.europa.eu/map/fme/AirQualityExport.htm

arguments (Repeating)
    DataTable(:,4) timetable
    Metadata(:,17) table
end


% stacked table; 
DataTable = vertcat(DataTable{:});
Metadata = vertcat(Metadata{:});

% Extract unique station code
Station = unique(Metadata.AirQualityStation);

[pollutant_code,index] = unique(Metadata.AirPollutantCode);
pollutant_name = string(Metadata.Notation(index)); 

tStart = min(DataTable.Time);
tEnd = max(DataTable.Time);


nHours = hours(time(between(tStart,tEnd,'time')));

varName = cell(length(pollutant_code)+1,1);
varType = cell(length(pollutant_code)+1,1);


varType(1) = {'categorical'};
varName(1) = {'AirQualityStation'};

varType(2:end) = {'double'};
varName(2:end) = cellstr(pollutant_name);

timeFormat = timetable('Size',[nHours+1 length(varName)],'VariableType',varType,...
    'TimeStep',hours(1),'StartTime',tStart,'VariableNames',varName);

timeFormat{:,pollutant_name} = NaN; 


dataComposer = cell(length(Station),1);
for i = 1: length(Station)  
dataComposer{i} = timeFormat;
dataComposer{i}{:,'AirQualityStation'} = Station(i);
index_st = DataTable.AirQualityStation == Station(i); 
    
    for k = 1: length(pollutant_code)
    
        index = index_st & DataTable.AirPollutantCode == pollutant_code(k);
        
        dataComposer{i}(DataTable.Time(index),pollutant_name(k)) = DataTable(index,'Concentration');
           
    end  
end

% ensemble
TimeTable = vertcat(dataComposer{:});

% sort
TimeTable = sortrows(TimeTable,'Time');

% extract metadata 
[~,index] = unique(Metadata(:,{'AirQualityStation','AirPollutantCode'}));

Metadata = Metadata(index,:); 

Id_sensor = string(Metadata.AirQualityStation) + repmat('_',size(Metadata,1),1) + Metadata.AirPollutantCode;


% Clear AirPollutant (string) add AirPollutantCode; 
Metadata = addvars(Metadata,Id_sensor,'NewVariableNames','Id_sensor','After','AirQualityStation');


TimeTable.Properties.VariableNames('AirQualityStation') = {'IDStation'};

% modify IDstation with double
TimeTable = addvars(TimeTable,double(TimeTable.IDStation),...
     'NewVariableNames','IDStation_Double','Before','IDStation');

Metadata.Properties.VariableNames({'AirQualityStation','AirPollutantCode'}) ...
                                            = {'IDStation','IDSensor'};
Metadata.Properties.VariableNames({'ObservationDateBegin',...
                    'ObservationDateEnd'}) = {'DateStart','DateStop'};
Metadata.Properties.VariableNames('Notation') = {'Pollutant'};
Metadata.Properties.VariableNames({'AirQualityStationType',...
    'AirQualityStationArea'}) = {'ARPA_stat_type','ARPA_zone'};

end

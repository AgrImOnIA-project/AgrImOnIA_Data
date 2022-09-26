%% Convert hourly time series to daily time series 

clear all
close all

%% RUN THIS ON HPC Environment

fprintf("%s ## Start Hourly to Daily alghoritm \n",string(datetime(now(),'ConvertFrom','datenum')))


% set file path
FileName = "Input/AQDATA";
FileName_OUT_DIR = sprintf("OUTPUT/%s",datetime("today",'Format','uuuuMMdd'));
FileName_OUT = sprintf("%s/OUTPUT",FileName_OUT_DIR);


file = matfile(FileName,'Writable',false);
output = matfile(FileName_OUT,'Writable',true);


% load data
t = string(datetime(now(),'ConvertFrom','datenum'));
fprintf("%s ## Folder: %s \n%s ## Filename: %s \n", ...
    t, pwd,t, FileName)

AQFinal = file.AQDATA;
AQFreq  = file.AQFREQ; 

% Create OUT dir
if ~isfolder(FileName_OUT_DIR)
    mkdir(FileName_OUT_DIR);
end

%% Handle station 708
% bi-hourly -> hourly

index = AQFreq.IDStation == '708'; 
AQFreq.PM25(index) = 'Hourly'; 

%% Handle Ammonia Station 583 - ITALY

AQFreq(AQFreq.IDStation == "583",'NH3') = {'Hourly'}; 

inx = AQFinal.IDStation == "583"; 
output.DeleteDailyValue = AQFinal(inx,{'NH3'});

AQFinal.NH3(inx) = AQFinal.Ammonia_h(inx); 

%% Handel Negative value - ITALY 

it = AQFreq.Nation =='IT' | AQFreq.Nation =='CH'; 
inx = ismember(AQFinal.IDStation, AQFreq.IDStation(it)); 

neg = AQFinal{:,3:end} < 0;

% save negative value in table (only italy)
output.NegativeValue = AQFinal(any(neg,2) & inx,:); 

% replace negative value
for i = 1: size(neg,2)
    AQFinal(neg(:,i),3+i -1) = {nan}; 
end

%% Conver Dataset to Daily

AQFreq.O3Ignore = []; % unusefull
AQFreq.NO = [];  % no data available 

% Consider only italian station 
inx = AQFreq.Nation =='IT' | AQFreq.Nation =='CH'; 
AQFreq(~inx,:) = [];

VarName = AQFreq.Properties.VariableNames(2:end);

tStart = dateshift(min(AQFinal.Date),'start','day');
tEnd = dateshift(max(AQFinal.Date),'end','day'); 
nDays = caldays(between(tStart,tEnd,'days'));

t = string(datetime(now(),'ConvertFrom','datenum'));
fprintf("%s ## Dataset Load 100% \n%s ## Start Date: %s, Stop Date: %s,  Data length: %d \n",...
    t, t, string(tStart), string(tEnd),nDays);

VarType = {'categorical', 'double','double','double', ...
    'double', 'double', 'double', 'double'};


timeFormat = timetable('Size',[nDays length(VarName)],'VariableType',VarType,...
    'TimeStep',days(1),'StartTime',tStart ,'VariableNames',VarName);
timeFormat(:,VarName(3:end)) = {nan};
timeFormat(:,VarName(1:2)) = {categorical(nan)};

tempTable = cell(size(AQFreq,1),1);
tempTable_uncertainty = cell(size(AQFreq,1),1);

t = string(datetime(now(),'ConvertFrom','datenum'));
fprintf("%s ## Start computing for each stations \n%s ## Total Station: %d \n",...
t,t,size(AQFreq,1));


%########## PARALLEL COMPUTING ############
% parpool('local',30); 
% parfor (i = 1:size(AQFreq,1),60)
%##########################################
for i = 1:size(AQFreq,1)
%##########################################
    
    % Select station and pollutant
    temp = AQFreq(i,:);  
    temp(:, isundefined(temp{1,:})) = []; 
    
    IDStation = temp.IDStation; 
    Pollutant = temp.Properties.VariableNames(3:end); 
    
    fprintf("%s ## Iteration: %d, Station ID: %s , Total pollutant: %d \n",...
    string(datetime(now(),'ConvertFrom','datenum')),i,...
    string(IDStation),length(Pollutant));
    
    if isempty(Pollutant)
        continue
    end

    % Create temp Table 
    tempTable{i} = timeFormat; % data
    tempTable_uncertainty{i} = timeFormat;
    tempTable_uncertainty{i}(:,Pollutant) = {nan};

    % check if hourly or daily 
    daily = Pollutant(temp{:,Pollutant} == 'Daily'); 
    hourly = Pollutant(temp{:,Pollutant} == 'Hourly');
    
    inx = AQFinal.IDStation == IDStation;
    
    % Daily
    
    if ~isempty(daily)

        temp = retime(AQFinal(inx, daily),'daily',@nanmean); % this step to uniform the sampling time
        tempTable{i}(temp.Properties.RowTimes,daily) = temp(:,daily);
        
        tempTable_uncertainty{i}(temp.Properties.RowTimes,daily) = {0}; % add 0   
        tempTable_uncertainty{i}{:,daily}(isnan(temp{:,daily})) = nan;  % add unknown
    
    end
     

    % Hourly
    if ~isempty(hourly)
    
    
        [temp, uncertainty] = SSMHourly2Daily(AQFinal(inx,hourly),'Threshold',6);
        tempTable{i}(temp.Properties.RowTimes,hourly) = temp(:,hourly); 
        
        tempTable_uncertainty{i}(temp.Properties.RowTimes,hourly) = uncertainty(:,hourly);  
    
    end

    tempTable{i}(:,'IDStation') = {IDStation};       
    tempTable_uncertainty{i}(:,'IDStation') = {IDStation};
   
    fprintf("%s ## END Iteration: %d, Statin ID: %s \n",...
        string(datetime(now(),'ConvertFrom','datenum')),i,...
        string(IDStation));

end

fprintf("%s ## End computing for each stations \n ",string(datetime(now(),'ConvertFrom','datenum')));

Daily = vertcat(tempTable{:}); 
Daily = sortrows(Daily,'Time');

uncertainty = vertcat(tempTable_uncertainty{:}); 
uncertainty = sortrows(uncertainty,'Time');

t = string(datetime(now(),'ConvertFrom','datenum'));
fprintf("%s ## Output file: %s",t, FileName_OUT);

%% Save results

% save structure .mat
output.Daily = Daily; 
output.Uncertainty = uncertainty;
output.Properties.Writable = false; 

% save csv format
writetimetable(Daily,sprintf('%s/Daily.csv',FileName_OUT_DIR));
writetimetable(uncertainty,sprintf('%s/Uncertainty.csv',FileName_OUT_DIR));
writetimetable(output.NegativeValue, sprintf('%s/NegativeValue.csv',FileName_OUT_DIR))

% save .mat format
save(sprintf('%s/Daily.mat',FileName_OUT_DIR),"Daily",'-mat');
save(sprintf('%s/Uncertainty.mat',FileName_OUT_DIR),"uncertainty",'-mat');

fprintf("%s ## End alghoritm \n",string(datetime(now(),'ConvertFrom','datenum')));






%% Settings
clear all
close all

% Check reference system 
info = shapeinfo('../ShapeFile/ShapeFile_Lomb/Comunali_2021/Com01012022_WGS84.shp');
proj = info.CoordinateReferenceSystem;


%% Import BDN data 
% Read shape file 

Suini  = shaperead("pigs.shp");
Bovini = shaperead("bovines.shp"); 

%% Import ARPA end Buffer stations
load('../Data_AQ/Input/Anagrafica.mat');

%% Italian Stations

inx = find(AnagraficaAQ.CNTR_CODE == 'IT');
[~,index] = unique(AnagraficaAQ.IDStation(inx));
Metadata = AnagraficaAQ(inx(index),:);

[Metadata.X,Metadata.Y] = projfwd(proj,Metadata.Latitude, Metadata.Longitude); 


%% Find Livestrock Data for Stations 

% Attribute: 
% TYPEINT 1 == inside only in the Lombardy Region
% TYPEINT 2 == inside only in the buffer

inx = find(([Suini.TYPEINT]' == 1 | [Suini.TYPEINT]' == 2) ...
       & datetime(vertcat(Suini.DATE)) == datetime(2021,12,31)); 


comm = nan(size(Metadata,1),1); 
center_com = nan(size(Metadata,1),2);

warning('off','all')
for i = 1:length(inx)
    poly = polyshape(Suini(inx(i),:).X,Suini(inx(i),:).Y);
    index = isinterior(poly,Metadata.X,Metadata.Y);
    
    comm(index) = Suini(inx(i),:).PRO_COM;
    center_com(index,1) = Suini(inx(i),:).CenterX;
    center_com(index,2) = Suini(inx(i),:).CenterY;
end
warning('on','all')



%% Check station with centroid outside the augmented Lombardy region

% Centre of the municipal inside augmented Lombardy region 
commX = [Suini(inx,:).CenterX]';
commY = [Suini(inx,:).CenterY]'; 

% Stations with centre outside the augmented Lombardy region 
inx_nan = find(isnan(comm));

% Compute the distances 
k_dist = pdist2([Metadata.X(inx_nan),Metadata.Y(inx_nan)],[commX ,commY]);

% Search the min distances 
[~,index] = min(k_dist);

comm(inx_nan) = Suini(inx(index),:).PRO_COM;
center_com(inx_nan,:) = [Suini(inx(index),:).CenterX, Suini(inx(index),:).CenterY];

% Add new centres 
Metadata = addvars(Metadata,comm,'NewVariableNames',"Comune"); 
Metadata.CenterX = center_com(:,1);
Metadata.CenterY = center_com(:,2);

%% Add municipal surface [m2] in the metadata

[uniq, inde_uni] = unique([Suini.PRO_COM]); 

[~,index] = ismember(Metadata.Comune,uniq); 

surface = [Suini(inde_uni(index),:).Shape_Area]';

Metadata = addvars(Metadata,surface,'NewVariableNames',"AREA_M2"); 

%% Create time series with pchip spline

tStart = datetime(2016,1,1);
tStart.TimeZone = "UTC";
tStart = dateshift(tStart,'start','year');

tEnd = datetime(2021,12,31);
tEnd.TimeZone = "UTC";
tEnd = dateshift(dateshift(tEnd,'end','year'),'end','day');

nHours = hours(time(between(tStart,tEnd,'time')));


partial_tbl = cell(size(Metadata,1),1);

for i = 1:size(Metadata,1)

    % Select all items for particolar munipalities (13 istanze)
    inx_PIGS = find([Suini.PRO_COM] == Metadata.Comune(i)); 
    inx_BOVI = find([Bovini.PRO_COM] == Metadata.Comune(i)); 

    % Check if all station are in municipaly
    if(isempty(inx_PIGS) || isempty(inx_BOVI))
        disp("Error")
        disp(fprintf("Stations %s",Metadata.IDStation(i)))
        continue
    end

    % timetable with bi-annual data [Pigs,Bovine] 
    temp = timetable([Suini(inx_PIGS,:).NUMEROCAPI]',[Bovini(inx_BOVI,:).NUMEROCAPI]',...
        'RowTimes',datetime(vertcat(Suini(inx_BOVI,:).DATE),'Format','dd-MM-uuuu'),...
        'VariableNames',{'PIGS','BOVINE'});
   

    % rettime with 'pchip' spline
    daily = retime(temp,'regular','pchip','TimeStep',days(1));
  
    % double to integer
    daily.PIGS = round(daily.PIGS);
    daily.BOVINE = round(daily.BOVINE);

    % Compute the density [number / km2]
    area  = Metadata.AREA_M2(i) / 10^6;
    
    daily.PIGS = daily.PIGS / area ;
    daily.BOVINE = daily.BOVINE / area;


    % add station name
    daily = addvars(daily, repmat(Metadata.IDStation(i),size(daily,1),1),...
        'NewVariableNames',"IDStation");

    % add the table in the staked table
    partial_tbl{i} = daily;     

end

%% Result 

% stacked all tables
BDNTimeTable = vertcat(partial_tbl{:});

BDNTimeTable(datetime(2015,12,31),:) = [];  

% Sort over time
BDNTimeTable = sortrows(BDNTimeTable,'Time');


% Chenge the name of the livestock variables 
BDNTimeTable.Properties.VariableNames{'PIGS'} = 'LI_pigs';
BDNTimeTable.Properties.VariableNames{'BOVINE'} = 'LI_bovine';

%% Save results 
save(sprintf("BDN-%s.mat",datetime('today','Format','ddMMuuuu')),'BDNTimeTable','Metadata','-mat');



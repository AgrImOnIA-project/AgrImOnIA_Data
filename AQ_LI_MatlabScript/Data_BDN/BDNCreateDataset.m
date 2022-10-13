%% CREATE Livestock Dataset 2016 - 2021
% Data format - matlab table;


%% Build Pigs Dataset
% 1) Download the single excel file from the link: 
% https://www.vetinfo.it/j6_statistiche/index.html#/report-pbi/31]
% 
Suini = [
    importBDRSuinifile('Suini30062021.xlsx');
    importBDRSuinifile('Suini30062020.xlsx');
    importBDRSuinifile('Suini30062019.xlsx');
    importBDRSuinifile('Suini30062018.xlsx');
    importBDRSuinifile('Suini30062017.xlsx');
    importBDRSuinifile('Suini30062016.xlsx');
    importBDRSuinifile('Suini31122021.xlsx');
    importBDRSuinifile('Suini31122020.xlsx');
    importBDRSuinifile('Suini31122019.xlsx');
    importBDRSuinifile('Suini31122018.xlsx');
    importBDRSuinifile('Suini31122017.xlsx');
    importBDRSuinifile('Suini31122016.xlsx');
    importBDRSuinifile('Suini31122015.xlsx'); % usefull for the spline 
];
% 
% % Change variable name
Suini.Properties.VariableNames{'SIGLA_PROV_AZIENDA'} = 'PROVINCIA';
% 
% % remove undefined value in regione
Suini(isundefined(Suini.REGIONE),:) = [];
date = unique(Suini.DATARIFERIMENTO);
% 

%% Build Bovines Dataset
% 1) Download the single excel file from the link: 
% [https://www.vetinfo.it/j6_statistiche/index.html#/report-pbi/1]

Bovini = [
    importBDRBovinifile('Bovini30062016.xlsx',datetime(2016,06,30));
    importBDRBovinifile('Bovini30062017.xlsx',datetime(2017,06,30));
    importBDRBovinifile('Bovini30062018.xlsx',datetime(2018,06,30));
    importBDRBovinifile('Bovini30062019.xlsx',datetime(2019,06,30));
    importBDRBovinifile('Bovini30062020.xlsx',datetime(2020,06,30));
    importBDRBovinifile('Bovini30062021.xlsx',datetime(2021,06,30));
    importBDRBovinifile('Bovini31122015.xlsx',datetime(2015,12,31));
    importBDRBovinifile('Bovini31122016.xlsx',datetime(2016,12,31));
    importBDRBovinifile('Bovini31122017.xlsx',datetime(2017,12,31));
    importBDRBovinifile('Bovini31122018.xlsx',datetime(2018,12,31));
    importBDRBovinifile('Bovini31122019.xlsx',datetime(2019,12,31));
    importBDRBovinifile('Bovini31122020.xlsx',datetime(2020,12,31));
    importBDRBovinifile('Bovini31122021.xlsx',datetime(2021,12,31));   
];
% 
% % Change variable name
Bovini.Properties.VariableNames{'NR_ALLEV_BOV_BUFREGIONE'} = 'REGIONE';
% 
% % remove undefined
Bovini(isundefined(Bovini.REGIONE),:) = [];
date = unique(Bovini.DATARIFERIMENTO);
%

%% Load Italian municipalities dataset
% in order to merge dataset in shape a common shape file it's necessary
% have the name and code of the Italian municipalities. Download this file
% form the following link: https://www.istat.it/it/archivio/6789 uder the
% "Elenco dei codici e delle denominazioni delle unità territoriali"
% section. Than run this code. 

ComuniItaliani = [
    importComunifile('ElencoComuni-al-30_06_2016.xls',datetime(2016,06,30),2);
    importComunifile('ElencoComuni-al-30_06_2017.xls',datetime(2017,06,30),2);
    importComunifile('ElencoComuni-al-30_06_2018.xls',datetime(2018,06,30),2);
    importComunifile('ElencoComuni-al-30_06_2019.xls',datetime(2019,06,30),2);
    importComunifile('ElencoComuni-al-30_06_2020.xls',datetime(2020,06,30),2);
    importComunifile('ElencoComuni-al-30_06_2021.xls',datetime(2021,06,30),2);
];


%% save data in Allevamenti.mat file in current folder
% Oprional 
% save("Allevamenti.mat",'-v7.3');

%% Create municiaplly Istat code (Municipality code alphanumeric format) 

Allevamenti = [{Suini};{Bovini}];
clear Suini;
clear Bovini;

for i = 1:length(Allevamenti)
    
    % Merge by province
    [log,idx] = ismember(Allevamenti{i}.PROVINCIA,ComuniItaliani.SiglaAutomobilistica);
    % sum(log == 0) check if alwais have a pair
    
    % codice provincia
    Allevamenti{i} = addvars(Allevamenti{i},ComuniItaliani{idx,'CodiceProvincia1'},...
        ComuniItaliani{idx,'RipartizioneGeografica'},...
        'NewVariableNames',{'CodiceProvincia1', 'RipartizioneGeografica'});
    
    prog = str2num(num2str([
        mod(floor(Allevamenti{i}.CodiceProvincia1 ./ 10 .^ (2:-1:0)), 10) ...
        mod(floor(Allevamenti{i}.ISTAT_COMUNE_AZIENDA ./ 10 .^ (2:-1:0)), 10)],'%d'));
    
    Allevamenti{i} = addvars(Allevamenti{i},prog,'NewVariableNames','CodiceComuneFormatoAlfanumerico');
    
end

%% Add shape file (.sh)
% Download Italian Italian municipalities boundaries (2021) from the following
% link: https://www.istat.it/it/archivio/222527. Then run this code. 

% add shape file path 2021
path = './ShapeFile/ShapeFile_Lomb/Comunali_2021/Com01012022_WGS84.shp';
info = shapeinfo(path);
proj = info.CoordinateReferenceSystem;

Municipal = shaperead(path);

% for every municipalities create center (X,Y) coordinate
warning('off','all')
for i = 1:length(Municipal)
    temp = polyshape(Municipal(i).X,Municipal(i).Y);
    [x,y] = centroid(temp); % determinate the center
    Municipal(i).CenterX = x;
    Municipal(i).CenterY = y;
end
warning('on','all')

% Shape file region (Eurostat)
path_region = "../ShapeFile/ShapeFIle_EU_NUTS3/NUTS_RG_03M_2021_3035.shp"; % etsg...

% Shaper file buffer (With R Script)
path_buffer = "../ShapeFile/Buffer/Lombardia/LombardyBuffer.shp"; % wgs84

S = shaperead(path_region);
info = shapeinfo(path_region);
p = info.CoordinateReferenceSystem;

% Lombardu NUTS code (Eurostat)
nutsid = find(string(deblank(vertcat({S.NUTS_ID})')) == "ITC4");

buffer = shaperead(path_buffer); 
[bufLat,bufLon] = reducem([buffer.Y]',[buffer.X]');

[tempLat,tempLon] = projinv(p,[S(nutsid).X],[S(nutsid).Y]);

% Change reference system 
[regX, regY] = projfwd(proj,tempLat,tempLon);
[bufX, bufY] = projfwd(proj,bufLat,bufLon); % trasformo


% border of lombardy region
regionPoly = polyshape(regX,regY); % region poligon
bufferPoly = polyshape(bufX,bufY); % buffer poligon

% centro dei comuni italiani (estratto dai poligoni)
centerX = [Municipal.CenterX]';
centerY = [Municipal.CenterY]';

[Municipal.TYPEINT] = deal(0);

% municipality inside a region
[Municipal(isinterior(regionPoly,centerX,centerY)).TYPEINT] = deal(1);

% municipality inside only in a buffer
[Municipal(isinterior(bufferPoly,centerX,centerY)).TYPEINT] = deal(2);

% TYPEINT 1 == inside only in a lombardi region
% TYPEINT 2 == inside only in a buffer

%% Build shape file

GeoTable = cell(2,1);
Time = sort(unique(Allevamenti{1}.DATARIFERIMENTO));

% Pigs dataset
for k = 1:length(Time)
    
    tempTable = Municipal;
    
    temp = Allevamenti{1}(Allevamenti{1}.DATARIFERIMENTO == Time(k), :);
    [tempTable(1:end).NUMEROCAPI] = deal(0);
    [tempTable(1:end).NALLEVAMENTI] = deal(0);
    
    [tempTable(1:end).CINGHIALI] = deal(0);
    [tempTable(1:end).MAIALI] = deal(0);
    [tempTable(1:end).GRASSI] = deal(0);
    [tempTable(1:end).MAGRONI] = deal(0);
    [tempTable(1:end).MAGONCELLI] = deal(0);
    [tempTable(1:end).LATTONZI] = deal(0);
    [tempTable(1:end).SCROFE] = deal(0);
    [tempTable(1:end).SCROFETTE] = deal(0);
    [tempTable(1:end).VERRI] = deal(0);
    
    com = [tempTable.PRO_COM]';
    
    for j = 1:length(com)
        inx = temp.CodiceComuneFormatoAlfanumerico == com(j);
        
        tempTable(j).NUMEROCAPI = ...
            sum(temp.NUMEROCAPI(inx), 'omitnan');
        
        tempTable(j).NALLEVAMENTI = ...
            sum(temp.NUMEROALLEVAMENTI(inx), 'omitnan');
        
        tempTable(j).CINGHIALI = ...
            sum(temp.DICUICINGHIALI(inx), 'omitnan');
        
        tempTable(j).MAIALI = ...
            sum(temp.DICUIMAIALI(inx), 'omitnan');
        
        tempTable(j).GRASSI = ...
            sum(temp.DICUIGRASSI(inx), 'omitnan');
        
        tempTable(j).MAGRONI = ...
            sum(temp.DICUIMAGRONI(inx), 'omitnan');
        
        tempTable(j).MAGRONCELLI = ...
            sum(temp.DICUIMAGRONCELLI(inx), 'omitnan');
        
        tempTable(j).LATTONZI = ...
            sum(temp.DICUILATTONZOLI(inx), 'omitnan');
        
        tempTable(j).SCROVE = ...
            sum(temp.DICUISCROFE(inx), 'omitnan');
        
        tempTable(j).SCROFETTE = ...
            sum(temp.DICUISCROFETTE(inx), 'omitnan');
        
        tempTable(j).VERRI = ...
            sum(temp.DICUIVERRI(inx), 'omitnan');
        
        
    end
    
    [tempTable(1:end).DATE] = deal(string(Time(k)));
    
    % stacked 
    GeoTable{1} = [GeoTable{1}; tempTable];
    
end


% Bovines dataset 
for k = 1:length(Time)
    tempTable = Municipal;
    
    temp = Allevamenti{2}(Allevamenti{2}.DATARIFERIMENTO == Time(k), :);
   
    
    [tempTable(1:end).NUMEROCAPI] = deal(0);
    [tempTable(1:end).NALLEVAMENTI] = deal(0);
    
    [tempTable(1:end).BOVINI] = deal(0);
    [tempTable(1:end).BUFALINI] = deal(0);
    
    
    com = [tempTable.PRO_COM]';
    
    for j = 1:length(com)
        inx = temp.CodiceComuneFormatoAlfanumerico == com(j);
        
        tempTable(j).NUMEROCAPI = ...
            sum(temp.NUMEROCAPI(inx), 'omitnan');
        
        tempTable(j).NALLEVAMENTI = ...
            sum(temp.NUMEROALLEVAMENTI(inx), 'omitnan');
        
        tempTable(j).BOVINI = ...
            sum(temp{inx & temp.SPECIE == 'BOVINI','NUMEROCAPI'}, 'omitnan');
        
        tempTable(j).BUFALINI = ...
            sum(temp{inx & temp.SPECIE == 'BUFALINI','NUMEROCAPI'}, 'omitnan');
        
    end
    
    [tempTable(1:end).DATE] = deal(string(Time(k)));
    
    % stacked
    GeoTable{2} = [GeoTable{2}; tempTable];
    
end



%% Save in shape file format

% Write shape file (.sh)
shapewrite(GeoTable{1},"pigs.shp");
shapewrite(GeoTable{2},"bovines.shp");








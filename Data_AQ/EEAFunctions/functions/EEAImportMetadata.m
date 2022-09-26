function metadata = EEAImportMetadata(filename)
%Import data from a text file

%% Input handling
if nargin < 2
    dataLines = [2, Inf];
end

%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 25);
 
% Specify range and delimiter
opts.DataLines = dataLines;
opts.Delimiter = ["\t", ","];

% Specify column names and types
opts.VariableNames = ["Countrycode", "Var2", "Var3", "Var4", "AirQualityStation", "Var6", "Var7", "Var8", "Var9", "Var10", "AirPollutantCode", "ObservationDateBegin", "ObservationDateEnd", "Var14", "Longitude", "Latitude", "Altitude", "MeasurementType", "AirQualityStationType", "AirQualityStationArea", "Var21", "Var22", "InletHeight", "BuildingDistance", "Var25"];
opts.SelectedVariableNames = ["Countrycode", "AirQualityStation", "AirPollutantCode", "ObservationDateBegin", "ObservationDateEnd", "Longitude", "Latitude", "Altitude", "MeasurementType", "AirQualityStationType", "AirQualityStationArea", "InletHeight", "BuildingDistance"];
opts.VariableTypes = ["categorical", "string", "string", "string", "categorical", "categorical", "string", "string", "string", "string", "double", "datetime", "datetime", "string", "double", "double", "double", "categorical", "categorical", "categorical", "string", "string", "double", "double", "string"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, ["Var2", "Var3", "Var4", "Var7", "Var8", "Var9", "Var10", "Var14", "Var21", "Var22", "Var25"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["Countrycode", "Var2", "Var3", "Var4", "AirQualityStation", "Var6", "Var7", "Var8", "Var9", "Var10", "Var14", "MeasurementType", "AirQualityStationType", "AirQualityStationArea", "Var21", "Var22", "Var25"], "EmptyFieldRule", "auto");
opts = setvaropts(opts, "ObservationDateBegin", "InputFormat", "yyyy-MM-dd'T'HH:mm:ss");
opts = setvaropts(opts, "ObservationDateEnd", "InputFormat", "yyyy-MM-dd'T'HH:mm:ss");
opts = setvaropts(opts, "AirPollutantCode", "TrimNonNumeric", true);
opts = setvaropts(opts, "AirPollutantCode", "ThousandsSeparator", ",");

% Import the data
metadata = readtable(filename, opts);



end

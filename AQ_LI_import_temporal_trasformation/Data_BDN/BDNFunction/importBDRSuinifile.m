function Suini31122021 = importBDRSuinifile(workbookFile, sheetName, dataLines)
%IMPORTFILE Import data from a spreadsheet
%  SUINI31122021 = IMPORTFILE(FILE) reads data from the first worksheet
%  in the Microsoft Excel spreadsheet file named FILE.  Returns the data
%  as a table.
%
%  SUINI31122021 = IMPORTFILE(FILE, SHEET) reads from the specified
%  worksheet.
%
%  SUINI31122021 = IMPORTFILE(FILE, SHEET, DATALINES) reads from the
%  specified worksheet for the specified row interval(s). Specify
%  DATALINES as a positive scalar integer or a N-by-2 array of positive
%  scalar integers for dis-contiguous row intervals.
%
%% Input handling

% If no sheet is specified, read first sheet
if nargin == 1 || isempty(sheetName)
    sheetName = 1;
end

% If row start and end points are not specified, define defaults
if nargin <= 2
    dataLines = [4, 80591];
end

%% Set up the Import Options and import the data
opts = spreadsheetImportOptions("NumVariables", 26);

% Specify sheet and range
opts.Sheet = sheetName;
opts.DataRange = "A" + dataLines(1, 1) + ":Z" + dataLines(1, 2);

% Specify column names and types
opts.VariableNames = ["REGIONE", "ASL", "COMUNE", "NUMEROALLEVAMENTI", "DICUICONSOLOCINGHIALI", "DICUICONMAIALIECINGHIALI", "NUMEROCAPI", "DICUICINGHIALI", "DICUIMAIALI", "DICUIGRASSI", "DICUIMAGRONI", "DICUIMAGRONCELLI", "DICUILATTONZOLI", "DICUISCROFE", "DICUISCROFETTE", "DICUIVERRI", "DATARIFERIMENTO", "CODICE_REGIONE", "CODICE_ASL", "SIGLA_PROV_AZIENDA", "ISTAT_COMUNE_AZIENDA", "TIPO_STRUTTURA", "ORIENTAMENTOPRODUTTIVO", "MODALITAALLEVAMENTO", "CODICE_ASL_PER_DENSITA", "DESC_ASL_PER_DENSITA"];
opts.VariableTypes = ["categorical", "categorical", "categorical", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "datetime", "double", "categorical", "categorical", "double", "categorical", "categorical", "categorical", "categorical", "categorical"];

% Specify variable properties
opts = setvaropts(opts, ["REGIONE", "ASL", "COMUNE", "CODICE_ASL", "SIGLA_PROV_AZIENDA", "TIPO_STRUTTURA", "ORIENTAMENTOPRODUTTIVO", "MODALITAALLEVAMENTO", "CODICE_ASL_PER_DENSITA", "DESC_ASL_PER_DENSITA"], "EmptyFieldRule", "auto");
opts = setvaropts(opts, "DATARIFERIMENTO", "InputFormat", "");

% Import the data
Suini31122021 = readtable(workbookFile, opts, "UseExcel", false);

for idx = 2:size(dataLines, 1)
    opts.DataRange = "A" + dataLines(idx, 1) + ":Z" + dataLines(idx, 2);
    tb = readtable(workbookFile, opts, "UseExcel", false);
    Suini31122021 = [Suini31122021; tb]; %#ok<AGROW>
end

Suini31122021(ismissing(Suini31122021.REGIONE),:) = []; 

end

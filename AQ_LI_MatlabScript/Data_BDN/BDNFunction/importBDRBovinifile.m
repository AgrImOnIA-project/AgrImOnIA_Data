function Bovini30062016 = importBDRBovinifile(workbookFile, riftime)
%IMPORTFILE Import data from a spreadsheet
%  BOVINI30062016 = IMPORTFILE(FILE) reads data from the first worksheet
%  in the Microsoft Excel spreadsheet file named FILE.  Returns the data
%  as a table.
%
%  BOVINI30062016 = IMPORTFILE(FILE, SHEET) reads from the specified
%  worksheet.
%
%  BOVINI30062016 = IMPORTFILE(FILE, SHEET, DATALINES) reads from the
%  specified worksheet for the specified row interval(s). Specify
%  DATALINES as a positive scalar integer or a N-by-2 array of positive
%  scalar integers for dis-contiguous row intervals.
%

%% Input handling

% If no sheet is specified, read first sheet
sheetName = 1;


% If row start and end points are not specified, define defaults
dataLines = [4, 60097];


%% Set up the Import Options and import the data
opts = spreadsheetImportOptions("NumVariables", 18);

% Specify sheet and range
opts.Sheet = sheetName;
opts.DataRange = "A" + dataLines(1, 1) + ":R" + dataLines(1, 2);

% Specify column names and types
opts.VariableNames = ["NR_ALLEV_BOV_BUFREGIONE", "ASL", "COMUNE", "NUMEROALLEVAMENTI", "NUMEROCAPI", "SPECIE", "CODICE_REGIONE", "CODICE_ASL", "PROVINCIA", "ISTAT_COMUNE_AZIENDA", "TIPOSTRUTTURA", "ORIENTAMENTOPRODUTTIVO", "CLASSE_CONSISTENZA", "MODALITA_ALLEVAMENTO", "TIPOLOGIA_PRODUTTIVA", "KEY", "CODICE_ASL_PER_DENSITA", "DESC_ASL_PER_DENSITA"];
opts.VariableTypes = ["categorical", "categorical", "categorical", "double", "double", "categorical", "double", "categorical", "categorical", "double", "categorical", "categorical", "categorical", "categorical", "categorical", "categorical", "string", "string"];

% Specify variable properties
opts = setvaropts(opts, ["CODICE_ASL_PER_DENSITA", "DESC_ASL_PER_DENSITA"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["NR_ALLEV_BOV_BUFREGIONE", "ASL", "COMUNE", "SPECIE", "CODICE_ASL", "PROVINCIA", "TIPOSTRUTTURA", "ORIENTAMENTOPRODUTTIVO", "CLASSE_CONSISTENZA", "MODALITA_ALLEVAMENTO", "TIPOLOGIA_PRODUTTIVA", "KEY", "CODICE_ASL_PER_DENSITA", "DESC_ASL_PER_DENSITA"], "EmptyFieldRule", "auto");

% Import the data
Bovini30062016 = readtable(workbookFile, opts, "UseExcel", false);

for idx = 2:size(dataLines, 1)
    opts.DataRange = "A" + dataLines(idx, 1) + ":R" + dataLines(idx, 2);
    tb = readtable(workbookFile, opts, "UseExcel", false);
    Bovini30062016 = [Bovini30062016; tb]; %#ok<AGROW>
end

Bovini30062016 = addvars(Bovini30062016,repmat(riftime,size(Bovini30062016,1),1), 'NewVariableNames', {'DATARIFERIMENTO'});

end

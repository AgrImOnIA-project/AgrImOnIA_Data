function ElencoComuni = importComunifile(workbookFile, time, sheetName, dataLines)
%IMPORTFILE Import data from a spreadsheet
%  ELENCOCOMUNIITALIANI = IMPORTFILE(FILE) reads data from the first
%  worksheet in the Microsoft Excel spreadsheet file named FILE.
%  Returns the data as a table.
%
%  ELENCOCOMUNIITALIANI = IMPORTFILE(FILE, SHEET) reads from the
%  specified worksheet.
%
%  ELENCOCOMUNIITALIANI = IMPORTFILE(FILE, SHEET, DATALINES) reads from
%  the specified worksheet for the specified row interval(s). Specify
%  DATALINES as a positive scalar integer or a N-by-2 array of positive
%  scalar integers for dis-contiguous row intervals.
%
%  See also READTABLE.
%
%% Input handling

if nargin == 2 || isempty(sheetName)
    sheetName = 1;
end

% If row start and end points are not specified, define defaults
if nargin <= 3
    dataLines = [2, 7979];
end

%% Set up the Import Options and import the data
opts = spreadsheetImportOptions("NumVariables", 23);

% Specify sheet and range
opts.Sheet = sheetName;
opts.DataRange = "A" + dataLines(1, 1) + ":W" + dataLines(1, 2);

% Specify column names and types
opts.VariableNames = ["CodiceRegione", "CodiceCittMetropolitana", "CodiceProvincia1", "ProgressivoDelComune2", "CodiceIstatDelComunealfanumerico", "CodiceIstatDelComunenumerico", "DenominazioneItalianaEStraniera", "DenominazioneInItaliano", "DenominazioneAltraLingua", "CodiceRipartizioneGeografica", "RipartizioneGeografica", "DenominazioneRegione", "DenominazioneCittMetropolitana", "DenominazioneProvinciaCittMetropolitana", "FlagComuneCapoluogoDiProvincia", "SiglaAutomobilistica", "CodiceComuneNumericoCon110Provincedal2010Al2016", "CodiceComuneNumericoCon107Provincedal2006Al2009", "CodiceComuneNumericoCon103Provincedal1995Al2005", "CodiceCatastaleDelComune", "CodiceNUTS12010", "CodiceNUTS220103", "CodiceNUTS32010"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "string", "string", "string", "double", "categorical", "categorical", "categorical", "categorical", "double", "categorical", "double", "double", "double", "string", "categorical", "categorical", "categorical"];

% Specify variable properties
opts = setvaropts(opts, ["DenominazioneItalianaEStraniera", "DenominazioneInItaliano", "DenominazioneAltraLingua", "CodiceCatastaleDelComune"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["DenominazioneItalianaEStraniera", "DenominazioneInItaliano", "DenominazioneAltraLingua", "RipartizioneGeografica", "DenominazioneRegione", "DenominazioneCittMetropolitana", "DenominazioneProvinciaCittMetropolitana", "SiglaAutomobilistica", "CodiceCatastaleDelComune", "CodiceNUTS12010", "CodiceNUTS220103", "CodiceNUTS32010"], "EmptyFieldRule", "auto");

% Import the data
ElencoComuni = readtable(workbookFile, opts, "UseExcel", false);

for idx = 2:size(dataLines, 1)
    opts.DataRange = "A" + dataLines(idx, 1) + ":W" + dataLines(idx, 2);
    tb = readtable(workbookFile, opts, "UseExcel", false);
    ElencoComuni = [ElencoComuni; tb]; %#ok<AGROW>
end

ElencoComuni = addvars(ElencoComuni,repmat(time,size(ElencoComuni,1),1), 'NewVariableNames','DATARIFERIMENTO'); 


end

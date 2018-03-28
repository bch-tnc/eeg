function winDefs = readWinDefs(excelFile)
% function winDefs = readWinDefs(excelFile)

if nargin < 1
    excelFile = 'windowDefinition.xlsx';
end

filename = 'windowDefinitions.xlsx'; % insert spreadsheet name here
winDefs = xlsread(filename);


return
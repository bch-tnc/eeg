function winDefs = readWinDefs(excelFile)
% function winDefs = readWinDefs(excelFile)

if nargin < 1
    excelFile = 'windowDefinitions.xlsx';
end

winDefs = xlsread(excelFile);


return
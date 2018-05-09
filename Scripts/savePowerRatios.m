function savePowerRatios(traceStruct,expPath,header,filename)
% function savePowerRatios(powerRatios,savefile)
% Saves powerRatio data to an Excel file

cd(expPath)

currMouse = traceStruct.mouse;
currWin   = traceStruct.winNum;
currGenotype = traceStruct.genotype;
powerRatios = traceStruct.powerRatios;

if nargin < 4
    filename = 'powerData.csv';
end
if nargin < 3
    header = {'Mouse','Window','Genotype','Delta','Theta','Alpha','Beta','Gamma'};
end

% if listing.name == filename
fid = fopen(filename,'a');
if fid == -1, error('Cannot open file'); end

% taken from
% https://www.mathworks.com/matlabcentral/answers/70018-how-to-write-cell-array-into-a-csv-file
% by Cedric Wannaz
% writes entries in cell arrays to .csv file
fprintf(fid, '%s,', header{1,1:end-1}) ;
fprintf(fid, '%s\n', header{1,end}) ;
fclose('all');

% write label
winText = {sprintf('%d',currMouse),sprintf('%d',currWin),sprintf('%d',currGenotype)};
fid = fopen(filename,'a');
if fid == -1, error('Cannot open file'); end

fprintf(fid, '%s,', winText{1});
fprintf(fid, '%s,', winText{2});
fprintf(fid, '%s,', winText{3});
fclose('all');

% write values to .csv
dlmwrite(filename,powerRatios,'precision',10,'-append','coffset',0);

fclose('all');
return
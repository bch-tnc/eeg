function savePowerRatios(traceStruct,expPath,header,filename)
% function savePowerRatios(powerRatios,savefile)
% Saves powerRatio data to an Excel file

cd(expPath)

currMouse = traceStruct.mouse;
currWin   = traceStruct.winNum;
currGenotype = traceStruct.genotype;
powerRatios = traceStruct.powerRatios;

numAvgs = size(powerRatios,1);

if nargin < 4
    filename = 'powerData.csv';
end
if nargin < 3
    header = {'Mouse','Window','Genotype','Delta','Theta','Alpha','Beta','Gamma'};
end

% open savefile
fid = fopen(filename,'a');
if fid == -1, error('Cannot open file'); end

% taken from
% https://www.mathworks.com/matlabcentral/answers/70018-how-to-write-cell-array-into-a-csv-file
% by Cedric Wannaz
% write header
fprintf(fid, '%s,', header{1,1:end-1}) ;
fprintf(fid, '%s\n', header{1,end}) ;

winText = {sprintf('%d',currMouse),sprintf('%d',currWin),sprintf('%d',currGenotype)};

% write values to .csv
for k = 1:numAvgs
    fprintf(fid, '%s,', winText{1});
    fprintf(fid, '%s,', winText{2});
    fprintf(fid, '%s,', winText{3});
    dlmwrite(filename,powerRatios(k,:),'precision',10,'-append','coffset',0);
end

fclose('all');
return
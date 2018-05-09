function powerRatios = calcPowerRatios(traceStruct,scriptPath,expPath,isPlotted)
% function powerRatios = calcPowerRatios(traceStruct)
% calculates the power ratios for the window of EEG data contained in
% traceStruct

if nargin < 4
    isPlotted = 0; % don't plot by default
end

bandDef = [0.5  4     % delta
           4    8     % theta
           8   13     % alpha
          13   30     % beta
          30   80];   % gamma
bandNames = {'Delta','Theta','Alpha','Beta','Gamma'};
numBands = size(bandDef,1);

filename = 'powerData.csv';
header = {'Mouse','Window','Genotype','Delta','Theta','Alpha','Beta','Gamma'};

cd(expPath)

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

currMouse    = traceStruct.mouse;
currWin      = traceStruct.winNum;
currGenotype = traceStruct.genotype;
fprintf('Calculating Mouse %d Window %d\n',currMouse,currWin)
currTrace = traceStruct.trace;
currTrace(isnan(currTrace)) = 0; % make NaN and Inf values 0 so that
currTrace(isinf(currTrace)) = 0; % you get valid FFT
Fs = traceStruct.Fs;

% fft, including frequency vector setup
N = 2.^nextpow2(length(currTrace));
f = (-N/2:N/2-1)*(Fs/N);
FFT = abs(fftshift(fft(currTrace,N)));

% calculate power band values
cd(scriptPath)
[bandPowers,totalPower] = calcBandPower(FFT,f,isPlotted);
cd(expPath)

powerRatios = bandPowers/totalPower;

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

% plot power ratios
if isPlotted
    figure
    for l = 1:numBands % color-codes each band
        bar(l,powerRatios(l))
        hold on
    end
    hold off
    text = sprintf('Mouse %d Power Ratios',currMouse);
    title(text)
    set(gca,'xtick',1:numBands,'xticklabel',bandNames) % labels each bar w/ text
    xlabel('Band')
    ylabel('Power')
    xlim([0 numBands+1])
end

fclose('all');
return
%% outputPower
% Writes Power Band Values to a .csv file

scriptPath = pwd;
% get directory name of the folder containing our stitched .mat data files
% pathname = uigetdir;
% for now, just run off the hard drive
currExpPath = 'G:\EEG\G1';
cd(currExpPath)

filename = 'powerData.csv';
header = {'Mouse','Window','Genotype','Delta','Theta','Alpha','Beta','Gamma'};

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

numWin = size(expData,2);

for k = 1:numWin
    currMouse    = expData(k).mouse;
    currWin      = expData(k).winNum;
    currGenotype = expData(k).genotype;
    fprintf('Calculating Mouse %d Window %d\n',currMouse,currWin)
    currTrace = expData(k).trace;
    currTrace(isnan(currTrace)) = 0; % make NaN and Inf values 0 so that
    currTrace(isinf(currTrace)) = 0; % you get valid FFT

    % fft, including frequency vector setup
    N = 2.^nextpow2(length(currTrace));
    f = (-N/2:N/2-1)*(Fs/N);
    FFT = abs(fftshift(fft(currTrace,N)));

    % calculate power band values
    cd(scriptPath)
    [meanPowers,bandPowers,totalPower,totalPowerAvg] = calcBandPower(FFT,f);
    cd(currExpPath)

%     % works just as well as the summing method in the for-loop
%     % this is left here to find the average of the total power
%     FFTbands = FFT(find(f>=bands(1,1) & f<bands(dim(1),dim(2))));
%     totalPower = sum(FFTbands);
%     totalPowerAvg = totalPower/length(FFTbands);

    bandPowerRatios = meanPowers/totalPowerAvg;

    % write label
    winText = {sprintf('%d',currMouse),sprintf('%d',currWin),sprintf('%d',currGenotype)};
    fid = fopen(filename,'a');
    if fid == -1, error('Cannot open file'); end
    
    fprintf(fid, '%s,', winText{1});
    fprintf(fid, '%s,', winText{2});
    fprintf(fid, '%s,', winText{3});
    fclose('all');
    
    % write values to .csv
    dlmwrite(filename,bandPowerRatios,'precision',10,'-append','coffset',0);
    
    % save values to expData
    expData(k).powerRatios = bandPowerRatios;
    
%     % for-loop to color-code each band
%     figure
%     for l = 1:numBands
%         stem(l,bandPowerRatios(l))
%         hold on
%     end
%     hold off
%     text = sprintf('Mouse %d Power Ratio',currMouse);
%     title(text)
%     set(gca,'xtick',1:numBands,'xticklabel',bandNames) % labels each stem w/ text
%     xlabel('Band')
%     ylabel('Power')
%     legend(bandNames)
%     xlim([0 numBands+1])
end

fclose('all');
% why am I saving to expData.mat? won't it overwrite what I calculated in
% extractWindows.m?: you don't - you also save the powerratio values
savefile = 'expData.mat';
save(savefile,'expData','Fs','startDate')
fprintf('Saved experiment data to %s\n',savefile)


cd(scriptPath)
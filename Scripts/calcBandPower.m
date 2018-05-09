function [bandPowers,totalPower] = calcBandPower(FFT,f,isPlotted,bandDef,bandNames)
% function bandPower = calcBandPower(FFT,f,bandDef)
% Oscillation band power calculation

%% Power Bands Plot
% default band definition
if nargin < 5
    bandNames = {'Delta','Theta','Alpha','Beta','Gamma'};
    header = {'Mouse','Window','Genotype','Delta','Theta','Alpha','Beta','Gamma'};
end
if nargin < 4    
    bandDef = [0.5  4     % delta
               4    8     % theta
               8   13     % alpha
              13   30     % beta
              30   80];   % gamma
end
if nargin < 3
    isPlotted = false;
end
    
dim = size(bandDef);
numBands = dim(1);
bandPowers = zeros(1,numBands);

df = f(2)-f(1); % frequency step

if isPlotted
    figure
end

for i = 1:numBands
    currBand = bandDef(i,:);
    lowBound = currBand(1);
    upBound  = currBand(2);
    
    % pull out FFT values corresponding to the vector and 
    % find index vector corresponding to desired band in FFT
    bandFFT = FFT(find(f>=lowBound & f<upBound));
       fFFT = f(find(f>=lowBound & f<upBound));

    if isPlotted
        % plot the different bands
        plot(fFFT,bandFFT)
        hold on
    end
    
    % calculates absolute band powers
    bandPowers(i) = sum(bandFFT)*df; 
end

% find total avg power over the entire bandDef range
lowBound = bandDef(1,1); upBound = bandDef(dim(1),dim(2));
bandFFT       = FFT(find(f>=lowBound & f<upBound));
fFFT          = f(find(f>=lowBound & f<upBound));
totalPower    = sum(bandFFT)*df;

return
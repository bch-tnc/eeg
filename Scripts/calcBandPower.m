function [meanPowers,bandPowers] = calcBandPower(FFT,f,bandDef)
% function bandPower = calcBandPower(FFT,bandDef,f)
% Oscillation band power calculation

%% Power Bands Plot
% default band definition
if nargin < 3    
    bandDef = [0.5  4     % delta
             4    8     % theta
             8   13     % alpha
            13   30     % beta
            30   80];   % gamma
end
bandNames = {'Delta','Theta','Alpha','Beta','Gamma'};
    
dim = size(bandDef);
numBands = dim(1);
bandPowers = zeros(1,numBands);
meanPowers = zeros(1,numBands);

figure(4)
for i = 1:numBands
    currBand = bandDef(i,:);
    lowBound = currBand(1);
    upBound  = currBand(2);
    
    % find index vector corresponding to desired band in FFT
    tempF = f;
    
    % pull out FFT values corresponding to the vector
    bandFFT = FFT(find(f>=lowBound & f<upBound));
       fFFT = f(find(f>=lowBound & f<upBound));
    
    % plot the different bands
    plot(fFFT,bandFFT)
    hold on
    
    % calculates absolute band powers and mean powers
    meanPower = mean(bandFFT);
    bandSum = sum(bandFFT);
    meanPowers(i) = meanPower;
    bandPowers(i) = bandSum; 
end

return
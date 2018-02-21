%% Analysis Plots
% Throws some plots onto the screen that may or may not be useful to the
% typical neuroscientist

% Plots include: (will be populated as I implement them)
%   - FFT (freqz and fft)
%   - Spectrogram
%   - FFT graph color-coded by band
%   - Power of Oscillation Bands 

% Assumes that the correct trace windows has already been loaded into the
% workspace.

%% FFT
figure(1)
N = 2.^nextpow2(length(trace_window));
freqz(trace_window,N)
title('FFT of the Trace Window Using freqz')

figure(2)
f = (-N/2:N/2-1)*(Fs/N);
FFT = abs(fftshift(fft(trace_window,N)));
plot(f(N/2:end),FFT(N/2:end))
title('FFT of the Trace Window Using fft')
xlabel('Frequency (Hz)')
ylabel('Magnitude')
xlim([0 Fs/2])
grid on

% % Spectrum Analyzer
% SpecAnalyze = dsp.SpectrumAnalyzer('SampleRate',Fs,'PlotAsTwoSidedSpectrum',false);
% SpecAnalyze(trace_window)

%% Spectrogram
M = 64;
hannwin = hann(M);
overlapPercent = 50;
L = M*(overlapPercent/100);
figure(3)
spectrogram(trace_window,hannwin,L,N,Fs,'yaxis')
title('Spectrogram')

%% Power Bands Plot
bands = [0.5  4     % delta
         4    8     % theta
         8   13     % alpha
        13   30     % beta
        30   80];   % gamma

dim = size(bands);
numBands = dim(1);
bandPowers = zeros(1,numBands);
totalPower = 0;

figure(4)
for i = 1:numBands
    currBand = bands(i,:);
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
    totalPower = totalPower + bandSum;
end

% metadata for the FFT graph (corresponding to Figure 4)
hold off
title('FFT of the EEG Recording')
xstart = 0; xend = bands(dim(1),dim(2)); % 0 so user knows delta band starts at 0.5Hz
xlim([xstart, xend])
legend('Delta','Theta','Alpha','Beta','Gamma')

% works just as well as the summing method in the for-loop
% this is left here to find the average of the total power
FFTbands = FFT(find(f>=bands(1,1) & f<bands(dim(1),dim(2))));
totalPower = sum(FFTbands);
totalPowerAvg = totalPower/length(FFTbands);

% power ratios
bandsPowerRatio = meanPowers/totalPowerAvg;

% for-loop to color-code each band
figure(5)
for i = 1:numBands
    stem(i,bandsPowerRatio(i))
    hold on
end
hold off
title('Power Ratio of Various Oscillation Bands')
legend('Delta','Theta','Alpha','Beta','Gamma')
xlim([0 numBands+1])

    
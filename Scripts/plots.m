%% Analysis Plots
% Throws some plots onto the screen that may or may not be useful to the
% typical neuroscientist

% Plots include: (will be populated as I implement them)

% Assumes that the correct trace windows has already been loaded into the
% workspace.

%% FFT
% figure(1)
% N = 2.^nextpow2(length(trace_window));
% freqz(trace_window,N)
% title('FFT using freqz')

figure(2)
f = (-N/2:N/2-1)*(Fs/N);
T = abs(fftshift(fft(trace_window,N)));
plot(f(N/2:end),T(N/2:end))
title('FFT graph')
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
bandsPower = zeros(1,numBands);

for i = 1:numBands
    currBand = bands(i,:);
    lowBound = currBand(1);
    upBound  = currBand(2);
    
    tempVec = T;
    tempVec = tempVec(tempVec>=lowBound);
    tempVec = tempVec(tempVec<upBound);
    
    meanPower = mean(sum(tempVec));
    bandsPower(i) = meanPower;
end

T2 = T;
T2 = T2(T2>=bands(1,1));
T2 = T2(T2<bands(dim(1),dim(2)));
totalPower = sum(T2);

bandsPowerRatio = bandsPower/totalPower;

figure
stem(bandsPowerRatio)
title('Power Ratio of Various Oscillation Bands')
    
    
%% Analysis Plots
% Throws some plots onto the screen that may or may not be useful to the
% typical neuroscientist

% Plots include: (will be populated as I implement them)

% Assumes that the correct trace windows has already been loaded into the
% workspace.

% FFT
figure(1)
N = 2.^nextpow2(length(trace_window));
freqz(trace_window,N)
title('FFT using freqz')

figure(2)
f = (-N/2:N/2-1)*(Fs/N);
T = mag2db(abs(fftshift(fft(trace_window,N))))/2;
plot(f(N/2:end),T(N/2:end))
title('FFT graph')
xlabel('Frequency (Hz)')
ylabel('dB')
xlim([0 Fs/2])

% % Spectrum Analyzer
% SpecAnalyze = dsp.SpectrumAnalyzer('SampleRate',Fs,'PlotAsTwoSidedSpectrum',false);
% SpecAnalyze(trace_window)

% Spectrogram
M = 64;
hannwin = hann(M);
overlapPercent = 50;
L = M*(overlapPercent/100);
figure(3)
spectrogram(trace_window,hannwin,L,N,'yaxis')
title('Spectrogram')

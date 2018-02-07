%% Prefilter
% Applies filtering before windowing so that unwanted frequencies aren't
% smeared out by windowing
% Would I need antialiasing filter???

origPath = pwd;
pathname = 'C:\Users\CH200595\Documents\MATLAB\eeg\Data';
cd(pathname)

load('1002_Traces_Full.mat')

plot(trace(:,2))
N = 2.^nextpow2(length(trace(:,2)));

f = (-N/2:N/2-1)*(Fs/N);
TRACE = fftshift(fft(trace(:,2),N));
plot(f,abs(TRACE))
title('FFT (Absolute Value)')
xlabel('Frequency (Hz)')
ylabel('Magnitude')
xlim([0 100])


cd(origPath)
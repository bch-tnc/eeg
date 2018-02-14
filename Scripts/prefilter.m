%% Prefilter
% Applies filtering before windowing so that unwanted frequencies aren't
% smeared out by windowing
% Would I need antialiasing filter???

origPath = pwd;
cd ..
cd Data

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

f0 = 60;
w0 = f0*2*pi/Fs;

% Notch filter @ 60Hz. Currently, the notch does not have a sharp cutoff
[b,a] = fir1(52,([59.5 60.5]/(Fs/2)),'stop');
freqz(b)
% Notch filter w/ iirnotch. This one is pretty good
[num,den] = iirnotch(w0,w0/35)
freqz(num,den)




cd(origPath)
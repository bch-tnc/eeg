%% Prefilter
% Applies filtering before windowing so that unwanted frequencies aren't
% smeared out by windowing
% Would I need antialiasing filter???

scriptPath = pwd;
cd ..
cd Data

load('1002_Traces_Full.mat')

% Simple FFT
N = 2.^nextpow2(length(trace(:,2)));
f = (-N/2:N/2-1)*(Fs/N);
TRACE = fftshift(fft(trace(:,2),N));
plot(f,abs(TRACE))
title('FFT (Absolute Value)')
xlabel('Frequency (Hz)')
ylabel('Magnitude')
xlim([0 100])

%% Filters
f0 = 60;
w0 = f0*2*pi/Fs;

% Notch filter @ 60Hz. Currently, the notch does not have a sharp cutoff
[b,a] = fir1(52,([59.5 60.5]/(Fs/2)),'stop');
figure
freqz(b)
title('60Hz Notch Filter Using Fir1')
% Notch filter w/ iirnotch. This one is pretty good
[num,den] = iirnotch(w0,w0/35);
figure
freqz(num,den)
title('60Hz Notch Filter Using iirnotch')


% Bandpass filter using Type II Chebyshev filter
% Adapted from:
% https://www.mathworks.com/matlabcentral/answers/361348-how-i-applly-a-bandpass-filter-in-a-signal
% under answer by Star Strider
trace_copy = trace(:,2);
N = 2.^nextpow2(length(trace_copy));

Fs = 1000;                                                  % Sampling Frequency (Hz)
Fn = Fs/2;                                                  % Nyquist Frequency (Hz)
Wp = [0.5   100]/Fn;                                         % Passband Frequency (Normalised)
Ws = [0.2   110]/Fn;                                         % Stopband Frequency (Normalised)
Rp =   1;                                                   % Passband Ripple (dB)
Rs = 150;                                                   % Stopband Ripple (dB)
[n,Ws] = cheb2ord(Wp,Ws,Rp,Rs);                             % Filter Order
[z,p,k] = cheby2(n,Rs,Ws);                                  % Filter Design
[sosbp,gbp] = zp2sos(z,p,k);                                % Convert To Second-Order-Section For Stability

figure
freqz(sosbp,N,Fs)                                      % Filter Bode Plot
title('Bandpass Filter Frequency Response')

trace_filtered = filtfilt(sosbp, gbp, trace_copy);    % Filter Signal

% overlaying time signals
figure
plot(trace_copy); hold on
plot(trace_filtered)
title('Trace Plots')
legend('Original','Bandpass Filtered')
hold off 

% overlaying both ffts
figure
N = 2.^nextpow2(length(trace(:,2)));
f = (-N/2:N/2-1)*(Fs/N);
TRACE = fftshift(fft(trace(:,2),N));
plot(f,abs(TRACE))

hold on
N = 2.^nextpow2(length(trace_filtered));
f = (-N/2:N/2-1)*(Fs/N);
TRACE_filt = fftshift(fft(trace_filtered,N));
plot(f,abs(TRACE_filt))
title('FFT (Absolute Value)')
xlabel('Frequency (Hz)')
ylabel('Magnitude')
xlim([0 100])
legend('Original','Bandpass Filtered')

cd(scriptPath)
%% Prefilter
% Applies filtering before windowing so that unwanted frequencies aren't
% smeared out by windowing
% Would I need antialiasing filter???

origPath = pwd;
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
N = 2.^nextpow2(length(trace_window));

Fs = 1000;                                                  % Sampling Frequency (Hz)
Fn = Fs/2;                                                  % Nyquist Frequency (Hz)
Wp = [1.0   20]/Fn;                                         % Passband Frequency (Normalised)
Ws = [0.5   21]/Fn;                                         % Stopband Frequency (Normalised)
Rp =   1;                                                   % Passband Ripple (dB)
Rs = 150;                                                   % Stopband Ripple (dB)
[n,Ws] = cheb2ord(Wp,Ws,Rp,Rs);                             % Filter Order
[z,p,k] = cheby2(n,Rs,Ws);                                  % Filter Design
[sosbp,gbp] = zp2sos(z,p,k);                                % Convert To Second-Order-Section For Stability

figure
freqz(sosbp,N,Fs)                                      % Filter Bode Plot
title('Bandpass Filter Frequency Response')

filtered_signal = filtfilt(sosbp, gbp, trace_window);    % Filter Signal

figure
plot(trace_window); hold on
plot(filtered_signal)
title('Trace Window Plots')
legend('Original','Bandpass Filtered')


cd(origPath)
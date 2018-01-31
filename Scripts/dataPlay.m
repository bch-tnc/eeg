% script to play around with mice data

% assumes that the necessary data files have already been loaded with
% DSI_Load.m

%% Setup
% save path so we return to the script's location at the end
origPath = pwd;

t = trace(:,1);
voltage = trace(:,2);

%% Plot Data
figure(1)
plot(t,voltage)
text = 'Entire Signal';
title(text)
xlabel('Time (s)')
ylabel('Voltage')

% extract a window of data
len_t = length(t);
len_win = floor(len_t/10);
win_start = floor(len_t/4);
win_end = win_start+len_win;
win_t = t(win_start:win_end);
win_volt = voltage(win_start:win_end);

figure(2)
plot(win_t,win_volt)
text = 'Signal window';
title(text)
xlabel('Time (s)')
ylabel('Voltage')


%% Processing
% This is where the processing will occur. For now, the example given is an
% FFT, but I want to look into integrating the MATLAB toolboxes that Sameer
% has been using into this section

% hand fft
N = 2.^nextpow2(length(t));
V = fftshift(fft(voltage,N));
f = (-N/2:N/2-1)*(Fs/N);
figure(3)
plot(f,V)
xlabel('Frequency (Hz)')
ylabel('Magnitude (Linear)')
text = 'FFT';
title(text)


%% Cleanup
cd(origPath)
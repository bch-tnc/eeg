%% Prefilter
% Applies filtering before windowing so that unwanted frequencies aren't
% smeared out by windowing
% Would I need antialiasing filter???

origPath = pwd;
pathname = 'C:\Users\CH200595\Documents\MATLAB\eeg\Data';
cd(pathname)

load('1002_Traces_Full.mat')

plot(trace(:,2))




cd(origPath)
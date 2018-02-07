function [tTTLnor,tTTLodd, EEGData] = readConvertedCSV(fileName,isTrigPlotted)
% function [tTTLnor,tTTLodd, EEGData] = readConvertedCSV(fileName,dbVal,freqsVal,isTrigPlotted)
% inputs: fileName to load; dBVal (i.e. 75) and freqsVal(69 or 96) are
% stored in Info
% to file; optional flag to plot TTL triggers
% Outputs:  tTTLnor and tTTLodd are lists of trigger times (in sec) 
%   for trigger signals based on TTL
% EEGData.waveform is the raw EEG traces (full signal)
%  time = 0 for waveoform is latest time at which all 3 signals started 

if nargin<4
    isTrigPlotted = false;
end

data = load(fileName);

% find start times of each trace
[eegOffsetSamps,normOffsetSamps,oddOffsetSamps]  = findTTLOffsetToEEG(data);

% pull out EEG, discardng any samples needed to align with TTL
EEGData.waveform = data.trace(eegOffsetSamps+1:end,2);
% BT change (bug fix!!!) June 26 - subtract start time so first sample is 0
% sec
EEGData.time = data.trace(eegOffsetSamps+1:end,1) - data.trace(eegOffsetSamps+1,1) ;


fsTTL = data.Fs;
fprintf('Fs TTL = %d\n', fsTTL);

pkThresh = 100;
% normal TTL signal; align by discarding samples to alsign
norTTLtime = data.trace_freqPulseNor(normOffsetSamps+1:end,1);
norTTLtime = norTTLtime - norTTLtime(1);  % first sample is t=0;
norData = data.trace_freqPulseNor(normOffsetSamps+1:end,2) ;

% analyzes TTL signals to get trigger times
tTTLnor = findTTLtrig(norTTLtime,norData, fsTTL, isTrigPlotted, pkThresh);
   
% same for oddball TTL 
oddTTLtime = data.trace_freqPulseOdd(oddOffsetSamps+1:end,1);  % bug fix 8/4
oddTTLtime = oddTTLtime - oddTTLtime(1);
oddData = data.trace_freqPulseOdd(oddOffsetSamps+1:end,2);
tTTLodd = findTTLtrig(oddTTLtime,oddData, fsTTL, isTrigPlotted, pkThresh);


%% Parameters
%% Parameters
%Data description parameters
par.folders = {'2015-01-28_12-52-05'};
% folderID | NSC ID | location (1 to 9 | animal # | treatment (1:veh, 2:drug) | 1:good 0:bad 

par.experiment = [...
    1, 1, 1, 1, 2, 1; ... %
    1, 2, 2, 1, 2, 1;... 
    1, 5, 5, 1, 2, 1;...
    1, 6, 6, 1, 2, 1;...
    1, 8, 8, 1, 2, 1;...
    1, 9, 9, 1, 2, 1];

par.basedir = 'Z:\Steven Gee\Steven EEG data Jan15';

%%Processing parameters
par.binsize = 10; % in seconds
par.srate = 2000;
par.ds = 4; %downsampling rate
par.stimlock = 1; %stim to lock time against
par.pretime = 0; %pre par.stimlock in min
par.posttime = 200; %post par.stimlock in min
par.dsrate = par.srate/par.ds; %sampling rate after downsampling

%% Load data, cut epochs, create description midget table
par.binsizei = round(par.binsize*par.dsrate);
par.nobins = floor((par.posttime-par.pretime)*60*par.dsrate/par.binsizei);
spgram = nan(par.binsizei, par.nobins, length(par.experiment));

for filenum = 1:length(par.experiment)
    filename = [par.basedir filesep par.folders{par.experiment(filenum,1)} filesep  'CSC0' num2str(par.experiment(filenum,2)) '.ncs'];
    [LFP ts] = ReadCSC(filename);
    hdr = nlynxhdr2mat(filename); %hdr will be a struct
    Fs = hdr.SamplingFrequency; %Get the SamplingFrequency field of the hdr struct
    if Fs ~= par.srate; fprintf('Sampling rate is fucked\n'); end
    events = getRawTTLs([par.basedir filesep par.folders{par.experiment(filenum,1)} filesep 'Events.nev']);
    triggerts = events(events(:,2) == 0,1);
    trigidx = find(ts > triggerts(par.stimlock), 1, 'first');
    tmp = LFP(trigidx+(par.pretime*par.srate*60):trigidx+(par.posttime*par.srate*60));
    tmp = tmp(1:par.ds:end);
    tmp = reshape(tmp(1:par.nobins*par.binsizei), par.binsizei, par.nobins);
    spgram(:,:,filenum) = abs(fft(tmp))/par.binsizei;
end
spgram = spgram(1:round(size(spgram,1)/2),:,:);

%% Save spgram

% save('Z:\Steven Gee', 'spgram', 'par', '-v7.3');

%% End of Calculation, start of plotting
return
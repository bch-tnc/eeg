%% Parameters
%Data description parameters
par.folders = {'2014-10-31_15-54-25' '2014-10-31_15-54-25'};
% folderID | NSC ID | treatment n/a | genotype 1:WT 2:KO | location (1: PC, 2: FC) | animal # (1 WT1, 2 WT2, 3 WT3, 4 WT4 , 5 KO2)  |  1:good 0:bad 
par.experiment = [...
    1, 1, 1, 1, 1, 1, 1; ... %Group1, csc1, HE, CA3, animal2, good
    1, 2, 1, 1, 2, 1, 1;...
    1, 3, 1, 1, 1, 2, 1;...
    1, 4, 1, 1, 2, 2, 1;...
    1, 5, 1, 1, 1, 4, 1;...
    1, 6, 1, 1, 2, 4, 1;...
    1, 7, 1, 2, 1, 5, 1;...
    1, 8, 1, 2, 2, 5, 1;...
    1, 11, 1, 1, 1, 3, 1;...
    1, 12, 1, 1, 2, 3, 1];

par.basedir = '/Users/Meera/Documents/Data/AEP';
addpath('/Users/Meera/Documents/MATLAB/dlbmatlab/Nlynx/');  
addpath('/Users/Meera/Documents/Data/AEP/');
%% Processing parameters
par.window = [-100 1000]; % in msec fron trigger
par.srate = 2000;
par.totstim = 117; 

%% Load data, cut epochs, create description midget table
data = nan(length(par.experiment)*par.totstim, round(diff(par.window)/1000*par.srate));
midget = nan(length(par.experiment)*par.totstim, 8);
tableindex = 1;
for filenum = 1:length(par.experiment)
    filename = [par.basedir filesep par.folders{par.experiment(filenum,1)} filesep 'CSC' num2str(par.experiment(filenum,2)) '.ncs'];
    [LFP ts] = ReadCSC(filename);
    hdr = nlynxhdr2mat(filename); %hdr will be a struct
    Fs = hdr.SamplingFrequency; %Get the SamplingFrequency field of the hdr struct
    if Fs ~= par.srate; fprintf('Sampling rate is fucked\n'); end
    events = getRawTTLs([par.basedir filesep par.folders{par.experiment(filenum,1)} filesep 'Events.nev']);
    triggerts = events(events(:,2) == 128,1);
    for epochidx = 1:length(triggerts)
        trigidx = find(ts > triggerts(epochidx), 1, 'first');
        data(tableindex,:) = LFP(trigidx+round(par.window(1)/1000*par.srate):trigidx+round(par.window(2)/1000*par.srate)-1);
        midget(tableindex,:) = [par.experiment(filenum,:) epochidx];
        tableindex = tableindex + 1;
    end
end
%% Save important stuff
save('Y:\AEP\meera\Summtable_test1_OLF.mat', 'data', 'midget','par');

%% For changing midget table after loading data
% midget = nan(length(par.experiment)*par.totstim, 8);
% tableindex = 1;
% for filenum = 1:length(par.experiment)
%     for epochidx = 1:par.totstim
%         midget(tableindex,:) = [par.experiment(filenum,:) epochidx];
%         tableindex = tableindex + 1;
%     end
% end



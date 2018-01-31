%% Pathdef
addpath('/Users/Meera/Documents/MATLAB/dlbmatlab/Nlynx/') 
addpath('/Users/Meera/Documents/MATLAB/Working_Scripts/Treadmill/')
par.datahome='/Users/Meera/Documents/Data/2014-12-23_12-37-06/';
cd(par.datahome);
%% Experiment desriptor file
%Treadmill_12_23_14;
%% Read files and split based on animal

% first read events
e = ReadNlynxEvents('Events.nev');
data.hdr=nlynxhdr2mat('1-CSC2.ncs');
% now find all 0x0002
tmp = e.timestamps(e.port_status(:,2)==1);
goodevents = [tmp(1:7) tmp(10:end)];
%oldevents = goodevents;

for i=1:length(goodevents)
    goodevents(i) = Nlynx_TimeStamp2Sample('1-CSC2.ncs', goodevents(i));
end
clear i;
% Animal 1 - need files 1-CSC2.ncs (HPC) 1-CSC3.ncs (PFC)
% Animal 2 - need files 2-CSC2.ncs (HPC) 2-CSC3.ncs (PFC)

CSC1_2 = ReadCSC('1-CSC2.ncs');
CSC1_3 = ReadCSC('1-CSC3.ncs');
CSC2_2 = ReadCSC('2-CSC2.ncs');
CSC2_3 = ReadCSC('2-CSC3.ncs');

% cable, between TTLs, animal label, geno

% removed 1 [1 2] 'KO3' 'KO'; ...
data.subjects={2 [1 2] 'KO4' 'KO'; ...
    1 [3 4] 'KO7' 'KO'; ...
    2 [3 4] 'WT1' 'WT'; ...
    1 [5 6] 'WT2' 'WT'; ...
    2 [5 6] 'WT4' 'WT'; ...
    1 [7 8] 'KO1' 'KO'; ...
    1 [9 10] 'KO3' 'KO'};

clear tmp

for subjectidx=1:length(data.subjects)
    tmp = data.subjects{subjectidx,1};
%     sample = Nlynx_TimeStamp2Sample(cscfn, time)
    
    switch tmp
        case 1
            HPCdata = CSC1_2(goodevents(data.subjects{subjectidx, 2}(1)):goodevents(data.subjects{subjectidx, 2}(2)));
            PFCdata = CSC1_3(goodevents(data.subjects{subjectidx, 2}(1)):goodevents(data.subjects{subjectidx, 2}(2)));

        case 2
            HPCdata = CSC2_2(goodevents(data.subjects{subjectidx, 2}(1)):goodevents(data.subjects{subjectidx, 2}(2)));
            PFCdata = CSC2_3(goodevents(data.subjects{subjectidx, 2}(1)):goodevents(data.subjects{subjectidx, 2}(2)));

    end
    %%lets make a directory for each type of file
    
    if ~exist('PFC', 'dir'), system('mkdir PFC'); end;
    if ~exist('HPC', 'dir'), system('mkdir HPC'); end;
    
    fnameHPC = ['./HPC/' data.subjects{subjectidx, 3} '_HPC.mat'];
    fnamePFC = ['./PFC/' data.subjects{subjectidx, 3} '_PFC.mat'];
    
    save(fnameHPC, 'HPCdata');
    save(fnamePFC, 'PFCdata');
    
end

%% Parameters
par.chans=[2 3]; %frontal=3, parietal=2, amygdala=12&13, entorhinal=14,15 DG=1, olf=4
par.srate=data.hdr.SamplingFrequency;
par.subjects=1:length(data.subjects);
par.FFTbin=2; %2 seconds
par.band=[5 12];
par.band_names={'theta'};
par.hpfcutoff=0.1; %Hz for 4th order Butterworth

%% Create data structures (actually cells)

%load WT data
cd([par.datahome '/HPC']);
filez = dir('WT*.mat');
for i=1:length(filez)
    tmp = load(filez(i).name);
    fields = fieldnames(tmp);
    WT{i} = eval(['tmp.' fields{1}]);
end
clear i;

%load KO data
filez = dir('KO*.mat');
for i=1:length(filez)
    tmp = load(filez(i).name);
    fields = fieldnames(tmp);
    KO{i} = eval(['tmp.' fields{1}]);
end
clear i;

%% FFT for Each File
%TotalpowMat=cell(length(data.subjects),2);
[b, a] = butter(4, par.hpfcutoff/(par.srate/2), 'high');

%for WT animals
for animidx=1:length(WT)
    % High pass filter :: fLFP_{V,T}
    fLFP{animidx} = filtfilt(b, a, WT{animidx});
    
    % FFT
    datStart=1;
    for i=1:floor((length(fLFP{animidx})/(par.srate*par.FFTbin)))
        datEnd=(datStart+par.srate*par.FFTbin)-1;
        powLFP= abs(fft(fLFP{animidx}(datStart:datEnd), par.srate*par.FFTbin)).^2; %power is volts squared
    
        %calculate the actual frequency domain range (for fft);
        faxis = [0:par.srate/par.srate*par.FFTbin/2:par.srate];
        faxis=faxis(1:end-1);
    
        % AUC for 5-12Hz
        trange = faxis(:)>=par.band(1) & faxis(:)<par.band(2);
        WTsum(i)=sum(powLFP(trange));

        datStart=datEnd+1;
        clear powLFP faxis trange;
    end
    AllWTsum{animidx}=WTsum;
    clear WTsum i;
end  

%for KO animals
for animidx=1:length(KO)
    % High pass filter :: fLFP_{V,T}
    fLFP{animidx} = filtfilt(b, a, KO{animidx});
    
    % FFT
    datStart=1;
    for i=1:floor((length(fLFP{animidx})/(par.srate*par.FFTbin)))
        datEnd=datStart+par.srate*par.FFTbin;
        powLFP= abs(fft(fLFP{animidx}(datStart:datEnd), par.srate*par.FFTbin)).^2; %power is volts squared
    
        %calculate the actual frequency domain range (for fft);
        faxis = [0:par.srate/par.srate*par.FFTbin/2:par.srate];
        faxis=faxis(1:end-1);
    
        % AUC for 5-12Hz
        trange = faxis(:)>=par.band(1) & faxis(:)<par.band(2);
        KOsum(i)=sum(powLFP(trange));
        
        datStart=datEnd+1;
        clear powLFP faxis trange;
    end
    AllKOsum{animidx}=KOsum;
    clear KOsum i;
end
%% Mean and Error for Each Animal

for i=1:length(AllWTsum)
    meantemp=mean(AllWTsum{i});
    stdtemp=std(AllWTsum{i});
    semtemp=stdtemp/sqrt(length(AllWTsum{i})-1);
    
    WTmean(i)=meantemp;
    WTstd(i)=stdtemp;
    WTsem(i)=semtemp;
    
    clear meantemp stdtemp semtemp;
end
clear i;

for i=1:length(AllKOsum)
    meantemp=mean(AllKOsum{i});
    stdtemp=std(AllKOsum{i});
    semtemp=stdtemp/sqrt(length(AllKOsum{i})-1);
    
    KOmean(i)=meantemp;
    KOstd(i)=stdtemp;
    KOsem(i)=semtemp;
    
    clear meantemp stdtemp semtemp;
end
clear i;
%% Compare Across Genotypes
WTAllmean=mean(WTmean);
KOAllmean=mean(KOmean);
sig=ttest2(WTmean,KOmean);


%% Plot Average and STD
errorbar(KOmean,KOmean,KOstd)
errorbar(KOmean,KOstd)
hold on 
errorbar(WTmean,WTstd,'r')
%% Create time spectroram file

% folderID | genotype 1:WT 2:KO | location (1: PFC, 2: HPC) | animal # (1 KO3, 2 KO1, 3 WT4, 4 WT2 , 5 WT1, 6 KO7, 7 KO4)  |  1:good 0:bad 
par.experiment = [...
    1, 2, 1, 1, 1; ... 
    1, 2, 1, 2, 1; ... 
    1, 1, 1, 3, 1; ... 
    1, 1, 1, 4, 1; ... 
    1, 1, 1, 5, 1; ... 
    1, 2, 1, 6, 1; ...
    1, 2, 1, 7, 1; ...
    
    2, 2, 2, 1, 1; ... 
    2, 2, 2, 2, 1; ... 
    2, 1, 2, 3, 1; ... 
    2, 1, 2, 4, 1; ... 
    2, 1, 2, 5, 1; ... 
    2, 2, 2, 6, 1; ...
    2, 2, 2, 7, 1];
animals={'KO3', 'KO1', 'WT4' ,'WT2', 'WT1', 'KO7', 'KO4'};
location={'PFC' ,'HPC'};
par.basedir = '/Users/Meera/Documents/Data/2014-12-23_12-37-06';

par.folders = {'PFC' 'HPC'};

%%Processing parameters
par.binsize = 10; % in seconds
par.srate = 2000;
par.filelen=9; % in minutes

%Load data, cut epochs, create description midget table
par.binsizei = round(par.binsize*par.srate);
par.nobins = floor((par.filelen*60*par.srate)/par.binsizei);
spgram = nan(par.binsizei, par.nobins, length(par.experiment(:,1)));

for filenum = 1:length(par.experiment(:,1))
    filename = [animals{(par.experiment(filenum,4))} '_' location{(par.experiment(filenum,4))} '.mat'];
    cd([par.basedir filesep par.folders{par.experiment(filenum,1)}]);
    tempstr = load(filename);
    idx=[par.folders{par.experiment(filenum,1)} 'data']
    LFP=tempstr.(idx);
    hdr = data.hdr; %hdr will be a struct
    Fs = hdr.SamplingFrequency; %Get the SamplingFrequency field of the hdr struct
    if Fs ~= par.srate; fprintf('Sampling rate is fucked\n'); end
    tmp = reshape(LFP(1:par.nobins*par.binsizei), par.binsizei, par.nobins);
    spgram(:,:,filenum) = abs(fft(tmp))/par.binsizei;
end
spgram = spgram(1:round(size(spgram,1)/2),:,:);

%% Output time spectroram

% folderID | genotype 1:WT 2:KO | location (1: PFC, 2: HPC) | animal # (1 KO3, 2 KO1, 3 WT4, 4 WT2 , 5 WT1, 6 KO7, 7 KO4)  |  1:good 0:bad 
anim = 3;
location = 1;
geno = 1;

taxis = linspace(0, size(spgram,2)*par.binsize, size(spgram,2))/60; 
faxis = linspace(0, par.srate/2, size(spgram,1));
figure()
%imagesc(taxis, faxis, conv2    (spgram(:,:,par.experiment(:,4) == anim & par.experiment(:,3) == location)   , ones(1,10), 'same'))
imagesc(taxis, faxis, conv2(mean(spgram(:,:,par.experiment(:,2) == geno & par.experiment(:,3) == location),3), ones(1,10), 'same'))
ylim([0 100])
colorbar
caxis([0 1E-4])
title('WT PFC')
grid on

%%
    %Sum AUC for theta
TotalpowMat{animidx,1}=powLFP;
TotalpowMat{:,2}='WT'
end

%%
%for KO animals 
for animidx=1:length(WT)
    %% High pass filter :: fLFP_{V,T}
    fLFP{animidx} = filtfilt(b, a, (WT{animidx});
    
    %% FFT
    powLFP{animidx} = abs(fft(fLFP{animidx}));

%%   
TotalpowMat{animidx,1}=powLFP;
%clear powLFP
end

%% Geno Average
    wtidx = find(not(cellfun('isempty', strfind(ex.animdays(:,4), 'WT'))));
    koidx = find(not(cellfun('isempty', strfind(ex.animdays(:,4), 'KO'))));
    
    powmat = nan(par.FFTbin*par.srate, length(par.ads));
    powmad = nan(par.FFTbin*par.srate, length(par.ads)); 
    relpowmat = nan(par.FFTbin*par.srate, length(par.ads));
    relpowmad = nan(par.FFTbin*par.srate, length(par.ads)); 
    
    for adidx = 1:length(par.ads)
        powmat(:,adidx) = transpose(squeeze(nanmedian(TotalpowMat{adidx, 1}(par.plotchanidx,:,:),3)));
        powmad(:,adidx) = transpose(squeeze(mad(TotalpowMat{adidx,1} (par.plotchanidx,:,:),1,3)));
        relpowmat(:,adidx) = powmat(:,adidx)/sum(powmat(:,adidx));
        relpowmad(:,adidx) = powmat(:,adidx)/sum(powmat(:,adidx));
    end
    
    WTspectrum = mean(powmat(:,wtidx),2);
    WTspectrumSTD=nanstd(powmat(:,wtidx),[],2);
    KOspectrum = mean(powmat(:,koidx),2);
    KOspectrumSTD=nanstd(powmat(:,koidx),[],2);
    clear powmat


%% Hibert





plot(data)
% filter design - first number after (fir1) gives you "accuracy" of filter
% - > #, more accurate
%filter size shouldn't be any shorter than two lengths of your frequency of
%interest, n overlap should be about 10%
myfilt = fir1(1000, [5 12]/ (2000/2));

% check filter
freqz(myfilt, 1, 4096, 2000);

% filter data
datafilt = Filter0(myfilt, data);


plot(data)
hold on
plot(datafilt, 'r')

% hilbert function
datahilb = hilbert(datafilt);
amp = abs(datahilb); % abs gives instantaneous amplitude
plot(data)
hold on
plot(datafilt, 'r')
plot(amp, 'g')

%--- below code for fft - you want to do --- fftdata ./ (1/f)


eeg_sr = header.rate/header.nchannels; % sampling rate - 2000 for you
buffersize = eeg_sr*2;
% buffersize = eeg_sr/2;

% buffersize2 = floor(eeg_sr/4); %buffersize - overlap;
buffersize2 = buffersize;

% power spectrum plotting frequency range
pl = 1; ph = 100;

%calculate the actual frequency domain range (for fft) (x-axis)
faxis = [0:eeg_sr/buffersize/2:eeg_sr];

%[data.p data.f] = psd(eeg,2^12,srate,2^11,2^10);

% to flatten spectral plot
data.pfsq = data.p./(1./data.f);

trange = find(faxis(:)>=tl & faxis(:)<th);
ff = abs(ff(1:trange(end),:)).^2;    

chunk = datafilt(1:2000*2);
plot(chunk)
fdata = fft(chunk, 1000);
fdata = abs(fdata).^2;
plot(fdata)
chunk = data(1:2000*2);
fdata = fft(chunk, 1000);
fdata = abs(fdata).^2;
plot(fdata)

%---
% wavelets - there are toolboxes
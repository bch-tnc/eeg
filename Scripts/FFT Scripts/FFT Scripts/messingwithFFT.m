
%% Plotting single animal spectrograms
% folderID | NSC ID | location (1 to 9) | animal # | treatment (1:veh, 2:drug) | 1:good 0:bad 

anim = 1;
electr = 8;
trt = 2;

taxis = linspace(0, size(spgram,2)*par.binsize, size(spgram,2))/60; %#ok<UNRCH>
faxis = linspace(0, par.dsrate/2, size(spgram,1));
figure()
imagesc(taxis, faxis, conv2(mean(spgram(:,:,par.experiment(:,5) == trt & par.experiment(:,3) == electr & par.experiment(:,4) == anim & par.experiment(:,6) ==1),3), ones(1,10), 'same'))
ylim([0 100])
colorbar
caxis([0 1E-4])
title('electrode 8 :  PC')
grid on


%% Mean power in band over time

par.band1 = [1 4];
par.band2 = [4 12];
par.band3 = [30 100];
par.band4 = [12 20];
par.band5 = [20 30];

apple = [par.band1; par.band2; par.band3; par.band4; par.band5];

idx = [1 2 3 4 5];
idx_label = {'Delta: 1-4 Hz', 'Theta: 4-12 Hz', 'Gamma: 30-100 Hz', 'Alpha: 12-20 Hz', 'Beta: 20-30 Hz'};

anim = 1;
electr = 2;
trt = 2;

for bananas = idx
    oranges = idx_label(1,bananas);

taxis = linspace(0, size(spgram,2)*par.binsize, size(spgram,2))/60; %#ok<UNRCH>

band_pow = sum(spgram(apple(bananas,1)/((par.dsrate/2)/size(spgram,1))+1:apple(bananas,2)/((par.dsrate/2)/size(spgram,1)), :, :));
box = 1;


figure()
hold on
plot(taxis, mean(band_pow(:,:,par.experiment(:,5) == trt & par.experiment(:,3) == electr & par.experiment(:,4) == anim & par.experiment(:,6) ==1),3), 'k');


legend('FC')
xlabel('Time (min)')
ylabel('Power')
title([oranges])
grid on
axis tight
ylim ([-.0001 .0008])
xlim ([0 100])
% idx = idx+1;
end

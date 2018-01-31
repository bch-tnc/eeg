%% Averaging...
% folderID | NSC ID | treatment n/a | genotype 1:WT 2:KO | location (1: PC,
% 2: FC) | animal # (1 WT1, 2 WT2, 3 WT3, 4 WT4 , 5 KO2)  |  1:good 0:bad 

%% FC - WT 
taxis = linspace(par.window(1), par.window(2), round(diff(par.window)/1000*par.srate));
midget_select1 = (midget(:,4) == 1 & midget(:,5) == 2 & midget(:,7) == 1 & (midget(:,8) < 61));
midget_select2 = (midget(:,4) == 1 & midget(:,5) == 2 & midget(:,7) == 1 & ((midget(:,8) > 60 & midget(:,8) < 83) | (midget(:,8) > 84 & midget(:,8) < 92) | (midget(:,8) > 94 & midget(:,8) < 105) | (midget(:,8) > 107 & midget(:,8) < 118)));



figure()
hold on
plot(taxis,mean(data(midget_select1,:)), 'k')
plot(taxis,mean(data(midget_select2,:)), 'r')


legend('75dB', '90dB')
xlabel('Time [msec]')
title('WT FC')
grid off
axis tight

%% PC - WT 
taxis = linspace(par.window(1), par.window(2), round(diff(par.window)/1000*par.srate));
midget_select1 = (midget(:,4) == 1 & midget(:,5) == 1 & midget(:,7) == 1 & (midget(:,8) < 61));
midget_select2 = (midget(:,4) == 1 & midget(:,5) == 1 & midget(:,7) == 1 & ((midget(:,8) > 60 & midget(:,8) < 83) | (midget(:,8) > 84 & midget(:,8) < 92) | (midget(:,8) > 94 & midget(:,8) < 105) | (midget(:,8) > 107 & midget(:,8) < 118)));



figure()
hold on
plot(taxis,mean(data(midget_select1,:)), 'k')
plot(taxis,mean(data(midget_select2,:)), 'r')


legend('75dB', '90dB')
xlabel('Time [msec]')
title('WT PC')
grid off
axis tight

%% PC - WT all animals
studanim = [1 2 3 4 5];

for idx=studanim
taxis = linspace(par.window(1), par.window(2), round(diff(par.window)/1000*par.srate));
midget_select1 = (midget(:,6) == idx & midget(:,4) == 1 & midget(:,5) == 1 & midget(:,7) == 1 & (midget(:,8) < 61));
midget_select2 = (midget(:,6) == idx & midget(:,4) == 1 & midget(:,5) == 1 & midget(:,7) == 1 & ((midget(:,8) > 60 & midget(:,8) < 83) | (midget(:,8) > 84 & midget(:,8) < 92) | (midget(:,8) > 94 & midget(:,8) < 105) | (midget(:,8) > 107 & midget(:,8) < 118)));



figure()
hold on
plot(taxis,mean(data(midget_select1,:)), 'k')
plot(taxis,mean(data(midget_select2,:)), 'r')


legend('75dB', '90dB')
xlabel('Time [msec]')
title(['WT PC' idx])
grid off
axis tight
end


%
%% calcGroupAvg
% calculates the power avgs amongst an experiment's mice
% in the future, add option to also sort by treatment type
% also add ability to check possible window types

scriptPath = pwd;

% later, make the script automatically cycle through all experiments
% for now, the script runs on a specific folder
currExpPath = uigetdir('../');
cd(currExpPath)
load('expData.mat')

window   = input('What window to average? (Enter a number): ');
genotype = input('What genotype to average? (Enter a number): ');

holder = size(expData(1).powerRatios);

numSubwindows = holder(1);
numBands = holder(2);
powerSum = zeros(numSubwindows,numBands);
numWin   = 0;
for k = 1:length(expData)
    currWin = expData(k).winNum;
    currGeno = expData(k).genotype;
    if currWin == window && currGeno == genotype
        powerSum = powerSum + expData(k).powerRatios;
        numWin = numWin + 1;
    end
end

powerAvg = powerSum/numWin;
%% Return to Sender
cd(scriptPath)
%% calcGroupAvg
% calculates the power avgs amongst an experiment's mice
% in the future, add option to also sort by treatment type
% also add ability to check possible window types

scriptPath = pwd;

% later, make the script automatically cycle through all experiments
% for now, the script runs on a specific folder
cd(currExpPath)
load('expData.mat')

genotype = input('What genotype to average? (Enter a number): ');
window   = input('What window to average? (Enter a number): ');

numBands = length(expData(1).powerRatios);
powerSum = zeros(1,numBands);
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
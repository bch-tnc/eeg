%% outputPower
% Writes Power Band Values to a .csv file

scriptPath = pwd;

cd ..
cd Data

% later, make outputPower work for multiple experiments
% for now, the folder w/ all the necessary .mat files are in 1 folder
listing = dir;
currExp = listing(10).name;

cd(currExp)

filename = 'powerData.csv';
header = {'Window','Delta','Theta','Alpha','Beta','Gamma'};

numWin = size(expData,2);

for i = 1:numWin
    fprintf('%d\n',expData(i).mouse)
    fprintf('%d\n',expData(i).winNum)
    plot(expData(i).trace)
end



cd(scriptPath)
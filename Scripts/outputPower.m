%% outputPower
% Writes Power Band Values to a .csv file

cd ..
cd Data

% later, make outputPower work for multiple experiments
% for now, the folder w/ all the necessary .mat files are in 1 folder
listing = dir;
currExp = listing(10).name;

cd(currExp)

filename = 'powerData.csv';
header = {'Window','Delta','Theta','Alpha','Beta','Gamma'};
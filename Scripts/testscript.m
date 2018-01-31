% test script to try out new functions

% learning how to read in .xlsx files
% consider testing how long it takes to read in such a file
filename = 'WOI.xlsx';
num = xlsread(filename)

mouse = num(1,1);
startTime_24 = num(1,2);
elapsedTime_min = num(1,3);
%% Extract Windows of EEG data
% Kenny Yau

% assumes that the necessary data files have already been stitched with
% DSI_Load.m

%% Metadata Collection
origPath = pwd;
scriptName = mfilename; % gets name of the script

%% Extracting the Signal Windows
% reads in an .xlsx file that contains the desired windows for each mouse
% data
%
% Spreadsheet format will be:
% Column A | Column B   | Column C
% MouseID  | Start Time | Length (min)
%
% Format of Data:
% Mouse ID: XXXX
%     Time: Any time format that Excel knows (suggestion - HH:MM:SS (24hr))
%   Length: In minutes (this resolution is probably good enough)
%     Date: Any date format that Excel knows
%
% This requires certain information to be already present;
% i.e. sampling rate of data and start time of the recording.
% For recordings that last longer than 1 day, we may also need user to record
% the start date of the specified window. Calculating the window time will
% then also require the start date of the recording.
%
% So far, all requirements are stored during the recording process, and the
% .mat files saved by DSI_Load contains this information.

filename = 'WOI.xlsx'; % insert spreadsheet name here
WOI = xlsread(filename);

% get directory name of the folder containing our stitched .mat data files
% pathname = uigetdir;
% for now, assume it's in the eeg/Data directory
cd ..
cd Data

% get list of needed mouse IDs
mice = WOI(:,1);
[mouseID,ia,ic] = unique(mice); % use ia to associate multiple start times 
                                % with the same mouseID. it contains the
                                % index of the first instance of a unique
                                % mouseID.
numMice = length(mouseID);

%% Cycle Through .mat Files
listing = dir('*.mat'); % returns a struct containing info about all .mat files

dim = size(listing);
numItems = dim(1);

% read in .mat file, perform operations
for i = 1:numMice % step through all entries of mouseID
    currMouse = mouseID(i);
    for j = 1:numItems % load the corresponding .mat file for the mouse
        currFile = listing(j).name; % get filename
        fileID = strsplit(currFile,'_'); % parse filename for mouseID
        fileID = str2num(char(fileID(1))); % str2num works for the startTime-> fracTime code below
        if currMouse == fileID
            load(currFile)
            fprintf('Loaded %s\n',currFile)
            break % stop cycling through the filenames once we've found the file
        end
    end
    
    % do window extraction here
    % Excel stores times as normalized fractions of the day
    % ex. 12:00pm is stored as 0.5
    % We convert startTime to this normalized fraction units first in order
    % to do comparisons.
    
    % convert startTime to fractional time
    time = str2num(char(strsplit(char(startTime.EEG),':'))); % num format
    hrs = time(1); min = time(2); sec = time(3);
    fracTime = ((hrs*60 + min)*60 + sec)/86400; % 86400 is number of sec/day
    
    % calculate window indices
    excelTime = WOI(numMice,2);
    timeDiff = excelTime - fracTime;

    sampleStart = round(timeDiff*86400*Fs);
    windowSize = WOI(numMice,3)*60*Fs;
    sampleEnd = sampleStart + windowSize;

    % plot, but also save the variables to a .mat file
    % what to save??!!
    % - the window of data, sampling rate, startDate, new startTime
    % - figure out how to save new startDate later
    trace_window = trace(sampleStart:sampleEnd,2);
    savefile = sprintf('%d_Traces_W%d.mat',currMouse,1);
    save(savefile,'trace_window','Fs','startDate')
    fprintf('Saved to %s\n',savefile);
end

%% Return to Sender
cd(origPath)
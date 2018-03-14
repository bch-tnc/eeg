%% Extract Windows of EEG data
% Kenny Yau

% assumes that the necessary data files have already been stitched with
% DSI_Load.m and that the files have already been prefiltered (60Hz notch,
% 0.5-100Hz bandpass)

%% Metadata Collection
scriptPath = pwd;
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
% Mouse ID: a number
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
numEntries = size(WOI,1);

% get directory name of the folder containing our stitched .mat data files
% pathname = uigetdir;
% for now, assume it's in the eeg/Data directory
% also assume this script is in the eeg/Scripts Folder
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

% constants
SEC_PER_DAY = 86400;
SEC_PER_MIN = 60;
MIN_PER_HOUR = 60;

% later, make extractWindows work for multiple experiments
% for now, the folder w/ all the necessary .mat files are in 1 folder
listing = dir;
currExp = listing(10).name;

cd(currExp)

varFiles = dir('*Full*.mat'); % gets info about all .mat files with full EEG recordings in the current folder
numVarFiles = size(varFiles,1);

isData2Save = false;

% create a struct
expData = struct;
currStructEntry = 1;

% read in .mat file, perform operations
for i = 1:numMice % step through all entries of mouseID
    currMouse = mouseID(i);
    for j = 1:numVarFiles % load the corresponding .mat file for the mouse
        currFile = varFiles(j).name; % get filename
        fileID = strsplit(currFile,'_'); % parse filename for mouseID
        fileID = str2num(char(fileID(1))); % str2num works for the startTime-> fracTime code below
        if currMouse == fileID
            load(currFile)
            fprintf('Loaded %s\n',currFile)
            isData2Save = true;
            break % stop cycling through the filenames once we've found the file
        end
    end
    
    % do window extraction here
    % Excel stores times as normalized fractions of the day
    % ex. 12:00pm is stored as 0.5
    % We convert startTime to this normalized fraction units first in order
    % to do comparisons.
    if isData2Save
        % convert startTime to fractional time
        time = str2num(char(strsplit(char(startTime.EEG),':'))); % num format
        hrs = time(1); min = time(2); sec = time(3);
        fracTime = ((hrs*60 + min)*60 + sec)/86400; % 86400 is number of sec/day
        
        % loop through all WOI entries for a given mouseID
        % assumes entries for same mouseID are next to each other
        currEntry = ia(i); % ex. mouseID 121 starts on row 5
        currEntryName = WOI(currEntry,1);
        % offset = ia(i)-1;
        currGenotype = WOI(currEntry,3); % col 3 is genotype

        
        while (currEntryName == currMouse && currEntry <= numEntries)
            currWindow = WOI(currEntry,2); % col 2 is window type
            
            % calculate window indices
            excelTime = WOI(currEntry,4); % col 4 contains the start time
            timeDiff = excelTime - fracTime;

            windowSize = WOI(currEntry,5)*60*Fs; % col 5 contains the length
            sampleStart = round(timeDiff*86400*Fs)+1;
            sampleEnd = sampleStart + windowSize;

            % saves certain variables to a .mat file
            % - the window of data, sampling rate, startDate, new startTime
            % - figure out how to save new startDate later
            trace_window = trace(sampleStart:sampleEnd,2);
            % windowNum = currEntry - offset;
            savefile = sprintf('%d_Traces_W%d.mat',currMouse,currWindow);
            save(savefile,'trace_window','Fs','startDate')
            fprintf('Saved to %s\n',savefile);
            
            % add data to the experimentData struct
            expData(currStructEntry).mouse = currMouse;
            expData(currStructEntry).winNum = currWindow;
            expData(currStructEntry).trace = trace_window;
            expData(currStructEntry).genotype = currGenotype;

            currEntry = currEntry + 1;
            currStructEntry = currStructEntry + 1;

            if currEntry < numEntries
                currEntryName = WOI(currEntry,1);
            end
        end
    end
    
    isData2Save = false;
end

% save experiment data
savefile = sprintf('expData.mat');
save(savefile,'expData','Fs','startDate')
fprintf('Saved experiment data to %s\n',savefile)

%% Return to Sender
cd(scriptPath)
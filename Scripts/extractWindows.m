%% Extract Windows of EEG data
% Kenny Yau

% assumes that the necessary data files have already been stitched with
% DSI_Load.m, and that the window definitions have been updated

%% Constants
SEC_PER_DAY = 86400;
SEC_PER_MIN = 60;
MIN_PER_HOUR = 60;

bandDef = [0.5  4     % delta
           4    8     % theta
           4   13     % BT
           8   13     % alpha
          13   30     % beta
          30   80]    % gamma
      
    dims = size(bandDef);      
numBands = dims(1);

bandNames = {'Delta','Theta','BT','Alpha','Beta','Gamma'};
   header = {'Mouse','Window','Genotype','Delta','Theta','BT','Alpha','Beta','Gamma'};

%% Metadata Collection
scriptPath = pwd;
scriptName = mfilename; % gets name of the script
addpath(scriptPath) % temporarily adds the script directory to the path

%% Extracting the Signal Windows
% reads in an .xlsx file that contains the desired windows for each mouse
% data
%
% Spreadsheet format will be:
% Column A | Column B | Column C | Column D   |
% MouseID  | Window # | Genotype | Start Time |
%
% Explanation of spreadsheet entries:
% Mouse ID: a number identifier for the mouse
% Window #: corresponds to the kind of window defined in winDefs.xlsx
% Genotype: genotype of the mouse
%     Time: Any time format that Excel knows (suggestion - HH:MM:SS (24hr))
%
% This requires certain information to be already present;
% i.e. sampling rate of data and start time of the recording.
% For recordings that last longer than 1 day, we may also need user to record
% the start date of the specified window. Calculating the window time will
% then also require the start date of the recording.
%
% So far, all requirements are stored during the recording process, and the
% .mat files saved by DSI_Load contains this information.

winDefs = readWinDefs();
numWinDefs = size(winDefs,1);

filename = 'WOI.xlsx'; % insert spreadsheet name here
WOI = xlsread(filename);
numEntries = size(WOI,1);

% get list of needed mouse IDs
mice = WOI(:,1);
[mouseID,firstEntryRow,~] = unique(mice); % use ia to associate multiple start times 
                                % with the same mouseID. it contains the
                                % index of the first instance of a unique
                                % mouseID.
numMice = length(mouseID);

%% Cycle Through .mat Files

% get directory name of the folder containing our stitched .mat data files
currExpPath = uigetdir('../'); % start a directory up
cd(currExpPath)

varFiles = dir('*Full*.mat'); % gets info about all .mat files with full EEG recordings in the current folder
numVarFiles = size(varFiles,1);

isData2Save = false;
isPlotted = false; % plots eeg signal, fft, and power ratio values

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
        currEntry = firstEntryRow(i); % ex. mouseID 121 starts on row 5
        currEntryName = WOI(currEntry,1);
        % offset = firstEntryRow(i)-1;
        currGenotype = WOI(currEntry,3); % col 3 is genotype

        % implementing a do-while loop
        while true
            currWindow = WOI(currEntry,2); % col 2 is window type
            excelTime  = WOI(currEntry,4); % col 4 contains the start time
            windowLengthMin = winDefs(currWindow,2);
 
            % calculate window indices
            timeDiff = excelTime - fracTime;
            windowSize = windowLengthMin*SEC_PER_MIN*Fs;
            sampleStart = round(timeDiff*SEC_PER_DAY*Fs)+1;
            sampleEnd = sampleStart + windowSize;
            
            % saves certain variables to a .mat file
            % - the window of data, sampling rate, startDate, new startTime
            % - figure out how to save new startDate later
            trace_window = trace(sampleStart:sampleEnd,2);
            savefile = sprintf('%d_Traces_W%d.mat',currMouse,currWindow);
            save(savefile,'trace_window','Fs','startDate');
            fprintf('Saved to %s\n',savefile);
            
            % subwindows-related variables
            numSubWindows = winDefs(currWindow,3);
            subwindowSize = floor(windowLengthMin/numSubWindows*SEC_PER_MIN*Fs);
            subwindowStart = 1;
            subwindowEnd = subwindowStart+subwindowSize;  
            
            % visualize subwindows
            if isPlotted    
                figure
                plot(trace_window)
                text = sprintf('Animal %d, Window %d',currMouse,currWindow);
                title(text)
                hold on
            end
                
            subwinStartIdx = zeros(1,numSubWindows);
            powerRatios = zeros(numSubWindows+1,numBands);
            
            % save subwindows
            for k = 1:numSubWindows
                subwindow = trace_window(subwindowStart:subwindowEnd);
%                 savefile = sprintf('%d_Traces_W%d-%d.mat',currMouse,currWindow,k);
%                 save(savefile,'subwindow','Fs','startDate')
%                 fprintf('Saved sub-window to %s\n',savefile);

                % create subwindow struct
                subwinData = struct;
                subwinData.mouse = currMouse;
                subwinData.winNum = k;
                subwinData.trace = subwindow;
                subwinData.genotype = currGenotype;
                subwinData.Fs = Fs;
                
                cd(scriptPath)
                powerRatios(k+1,:) = calcPowerRatios(subwinData,scriptPath,currExpPath,isPlotted,bandDef,bandNames);
                
                if isPlotted
                    plot(subwindowStart:subwindowEnd,subwindow)
                    hold on
                end
                
                subwinStartIdx(k) = subwindowStart;
                subwindowStart = subwindowStart + subwindowSize;
                subwindowEnd = subwindowEnd + subwindowSize;
            end
                
            % add data to the experimentData struct
            expData(currStructEntry).mouse = currMouse;
            expData(currStructEntry).winNum = currWindow;
            expData(currStructEntry).trace = trace_window;
            expData(currStructEntry).genotype = currGenotype;
            expData(currStructEntry).Fs = Fs;
            expData(currStructEntry).subwinStartIdx = subwinStartIdx;
            expData(currStructEntry).subwindowSize = subwindowSize;

            cd(scriptPath)
            powerRatios(1,:) = calcPowerRatios(expData(currStructEntry),scriptPath,currExpPath,isPlotted,bandDef,bandNames);
            
            expData(currStructEntry).powerRatios = powerRatios;
            
            % save power ratios
            cd(scriptPath)
            savePowerRatios(expData(currStructEntry),currExpPath,header)
            
            % move to next item in WOI
            currEntry = currEntry + 1;
            currStructEntry = currStructEntry + 1;
            if currEntry <= numEntries
                currEntryName = WOI(currEntry,1);
            end
%             text = sprintf('currEntry: %d | currStructEntry: %d | currEntryName: %d',currEntry,currStructEntry,currEntryName);
%             disp(text)
            
            if currEntryName ~= currMouse || currEntry > numEntries
                break;
            end
        end
    end
    
    isData2Save = false;
end

% save experiment data
savefile = sprintf('expData.mat');
save(savefile,'expData','Fs','startDate','-v7.3') % v7.3 for files > 2GB
fprintf('Saved experiment data to %s\n',savefile)

%% Return to Sender
rmpath(scriptPath)
cd(scriptPath)
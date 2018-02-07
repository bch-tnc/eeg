% test script to try out new functions
%% Metadata Collection
origPath = pwd;
scriptName = mfilename; % gets name of the script

%% Extracting the Signal Windows
% Format of Excel Entries
% Mouse ID: XXXX
%     Time: Any time format that Excel knows (suggestion - HH:MM:SS (24hr))
%   Length: In minutes (this resolution is probably good enough)
%     Date: Any date format that Excel knows

% Format of .mat filenames
% XXXX_*.mat, where XXXX is the 4-digit mouseID number

filename = 'WOI.xlsx';
WOI = xlsread(filename);

cd(pathname)

% get list of needed mouse IDs
mice = WOI(:,1);
[mouseID,ia,ic] = unique(mice); % use ia to associate multiple start times 
                                % with the same mouseID. it contains the
                                % index of the first instance of a unique
                                % mouseID.
numMice = length(mouseID);

%% Cycle Through .mat Files
% get directory name of the folder containing our stitched .mat data files
% pathname = uigetdir;
% for now, assume it's the below directory
pathname = 'C:\Users\CH200595\Documents\MATLAB\eeg\Data';
% disp(pathname)
cd(pathname)
listing = dir('*.mat'); % returns a struct containing info about .mat files in the directory

dim = size(listing);
numItems = dim(1);

% read in .mat file, perform operations
% step through all entries of mouseID
for i = 1:numMice
    currMouse = mouseID(i);
    for j = 1:numItems
        currFile = listing(j).name;
        fileID = strsplit(currFile,'_');
        if strcmp(currMouse,fileID(1))
            load(currFile)
            fprintf('Loaded %s\n',currFile)
            break
        end
    end
    % do window extraction here?!
    
    % time stuff for this recording
    time = str2num(char(strsplit(char(startTime.EEG),':'))); % num format
    hrs = time(1); min = time(2); sec = time(3);
    fracTime = ((hrs*60 + min)*60 + sec)/86400; % 86400 is number of sec/day
    
    % window stuff
    excelTime = WOI(numMice,2);
    timeDiff = excelTime - fracTime;

    sampleStart = round(timeDiff*86400*Fs);
    windowSize = WOI(numMice,3)*60*Fs;
    sampleEnd = sampleStart + windowSize;

    figure
    plot(trace(sampleStart:sampleEnd,1),trace(sampleStart:sampleEnd,2))
end

% % date stuff
% % datedatetime(startDate.EEG,'InputFormat','yyyy/MM/dd');
% 
% % time stuff
% time = str2num(char(strsplit(char(startTime.EEG),':'))); % num format
% hrs = time(1); min = time(2); sec = time(3);
% 
% fracTime = ((hrs*60 + min)*60 + sec)/86400; % 86400 is number of sec/day
% excelTime = WOI(1,2);
% timeDiff = excelTime - fracTime;
% 
% sampleStart = round(timeDiff*86400*Fs);
% windowSize = WOI(1,3)*60*Fs;
% sampleEnd = sampleStart + windowSize;
% 
% plot(trace(sampleStart:sampleEnd,1),trace(sampleStart:sampleEnd,2))

%% Return to Sender
cd(origPath)

% %% v0.1
% %% Cycle Through .mat Files
% % get directory name of the folder containing our stitched .mat data files
% % pathname = uigetdir;
% % for now, assume it's the below directory
% pathname = 'C:\Users\CH200595\Documents\MATLAB\eeg\Data';
% % disp(pathname)
% cd(pathname)
% listing = dir; % returns a struct containing info about the current directories' items
% 
% dim = size(listing);
% numItems = dim(1);
% 
% isFileRead = false;
% while ~(isFileRead)
%     for i = 3:numItems % starts on 3 because 1 & 2 are current and previous directory
%         if ~listing(i).isdir % if not a directory (i.e. it's a file)
%                              % in the future, also check if the file is a .mat
%                              % file AND if the data file has the correct
%                              % nomenclature
%             % ways to check if it's a .mat file:
%             % 1) take last 4 characters and check if they are ".mat"
%             % 2) use some kind of string parsing on the "." delimiter and
%             % check if the end is a .mat
%             
%             currName = listing(i).name;
%             [~,~,ext] = fileparts(currName);
%             
%             if strcmp(ext,'.mat') % only load if file is a .mat file
%                 load(currName)
%                 fprintf('Loaded %s\n',currName)
%             end            
%         end
%     end
%     isFileRead = true;
% end
% 
% 
% %% Return to Sender
% cd(origPath)
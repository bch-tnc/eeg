% extract windows of EEG data

% assumes that the necessary data files have already been stitched with
% DSI_Load.m

origPath = pwd;

scriptName = mfilename; % gets name of the script

% get directory name of the folder containing our stitched .mat data files
% pathname = uigetdir;
pathname = 'C:\Users\CH200595\Documents\MATLAB\eeg\Data';
% disp(pathname)
cd(pathname)
listing = dir; % returns a struct containing info about the current directories' items

dim = size(listing);
numItems = dim(1);

% % cycle through items in the path
% for i = 3:numItems % starts on 3 because 1 & 2 are current and previous directory
%     if ~listing(i).isdir % if not a directory (i.e. it's a file)
%                          % in the future, also check if the file is a .mat
%                          % file AND if the data file has the correct
%                          % nomenclature
%         currName = listing(i).name;
%         disp(currName)
%     end
% end

isFileRead = false;
while ~(isFileRead)
    for i = 3:numItems % starts on 3 because 1 & 2 are current and previous directory
        if ~listing(i).isdir % if not a directory (i.e. it's a file)
                             % in the future, also check if the file is a .mat
                             % file AND if the data file has the correct
                             % nomenclature
            % ways to check if it's a .mat file:
            % 1) take last 4 characters and check if they are ".mat"
            % 2) use some kind of string parsing on the "." delimiter and
            % check if the end is a .mat
            currName = listing(i).name;
            
            % disp(currName)
            isFileRead = 1;
            break;
        end
    end
end

load(currName)

%% Extracting the Signal Windows
% reads in an .xlsx file and 



cd(origPath)
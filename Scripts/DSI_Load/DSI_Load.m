clear

origPath = pwd;

%checks and closes waitbar from previous instance if there was a crash during loading
if ishandle('w') == 1
  close(w)
end

%turn off the waitbar and run in the background
waitbarOn = 0;
%set checkbox GUI variables to initial states (not loading)
eeg_select=0;
freq_select=0;
activity_select=0;
temp_select=0;
sig_select=0;
loadAll=0;
%Load Trace Selection GUI.  Both the DSILoadDlg.m and DSILoadDlg.fig must
%be in the path in order for the GUI to load
DSILoadDlg



%if load all button is not clicked, load a single mouse only
if loadAll == 0
    %filename and path retrieved from dialog box
    [filename, pathname] = uigetfile('*.txt', 'Select EEG file for mouse');

    %if no file is selected in the dialog box, exit gracefully instead of ugly error message
    if filename == 0
        errordlg('No input file selected.  Please select an EEG .txt file to use this script', 'Input File Error');
        return;
    end

    %change to the directory containing the EEG files if not there already
    currentdir = pwd;
    if strcmp(pathname, currentdir) == 0
        cd(pathname);
    end

    %get mousenumber from filename by reading up to the first period '.'
    [mou, ~] = strtok(filename,'.');

    mouse = {mou};

elseif loadAll == 1
    pathname = uigetdir;
    
    %change to the directory containing the EEG files if not there already
    currentdir = pwd;
    if strcmp(pathname, currentdir) == 0
         cd(pathname);
    end
    
    filenames = dir('*.txt'); % grabs info about all .txt files in the specified directory
    % filenames = dir('Mouse*.txt'); % original line - dunno why the Mouse
    % was included
    
    mousefiles = [];
    for i=1:length(filenames)
        mousefiles{i}=filenames(i).name; % returns all files that have to do with a mouse
    end
    
    [mousenumbers, ~]= strtok(mousefiles, '.'); % returns the mouse number associated with each file
    
    mouse = unique(mousenumbers); % finds all unique instances of mouse numbers
end


%if no checkboxes are selected in DSILoadDLg, close out of script
if eeg_select == 0 && freq_select==0 && activity_select==0 && temp_select==0 && sig_select==0
   errordlg('No file-type checkboxes selected for processing, exiting.', 'Input Filetype Error'); 
   return;
end

%timer function for calculating total script processing time
%this can be removed in later versions of the script along with "tok" at the bottom
%tic;



for n=1:length(mouse)
fprintf('Working with %s\n',char(mouse(n)))
%get all files for appropriate mouse number
filefilter = strcat(mouse{n}, '.*');
filelist = dir(filefilter);
%count those files
nFiles = length(filelist);

%initialize variables to hold traces that are selected in dlg box
trace = [];
trace_temp = [];
trace_activity = [];
trace_signalstr = [];
trace_freqPulse = [];


%Cases that are run for each check box
if eeg_select == 1
    
    listcount = 1;
    EEGfilelist = [];
    %Filter: only select EEG text files, and add them to their own list for loading
    for j=1:nFiles
        if isempty(strfind(filelist(j).name, 'EEG')) == 0 && isempty(strfind(filelist(j).name, '.txt')) == 0
            
            EEGfilelist{listcount} = filelist(j).name;
            listcount = listcount +1;
        end
        
    end
    
    if isempty(EEGfilelist) == 0
        %get start time info from header
        fid = fopen(EEGfilelist{1});
        paramIds = textscan(fid,'%s %s %s %s',1,'HeaderLines',1);
        fclose(fid);
        startDate.EEG = paramIds{3};
        startTime.EEG = paramIds{4};
            
        testEEGChan = importdata(char(EEGfilelist(1)), ',', 5);
        
        if iscell(testEEGChan) == 1
            twochannel = 1;
        else
            twochannel = 0;
        end
        %clear testEEGchan
        
        %total number of EEG text files
        tot_EEGfiles=length(EEGfilelist);
        
        %variable that holds trace of concatenated EEG traces
        
        %loading bar
        if waitbarOn == 1
        w = waitbar(0, 'Initializing Load');
        else
            fprintf('Loading EEG Files\n')
        end
      
        
        %load and concatenate each of the EEG files from the list
        for ii = 1:tot_EEGfiles
            
            % load new contents
            % newData = load(char(EEGfilelist(ii)), '-ascii');
            if twochannel == 0
                newData = importdata(char(EEGfilelist(ii)), ',', 5);
            end
            
            if twochannel == 1
                newData = importdata(char(EEGfilelist(ii)), ',', 6);
            end
            
            %occasionally, DSI will create blank text files with no data,
            %this ensures that text files contain data before they are
            %concatenated
            if isfield(newData, 'data') == 1
                newTrc = newData.data;
                [row_newTrc, col_newTrc] = size(newTrc);
                
                %when the mouse is removed from the receiver pad, sometimes
                %DSI makes timestamps with no associated data column.  If
                %the size of the trace section does not match the existing
                %trace variable, a column of zeros is added (as opposed to
                %NaNs)
                if col_newTrc == 1 && twochannel == 0
                    newTrc=[newTrc NaN(size(newTrc))];
                    
                elseif col_newTrc == 1 && twochannel == 1
                    newTrc=[newTrc NaN(size(newTrc)) NaN(size(newTrc))];
                end
            end
            
            % concatenate vertically
            trace =  vertcat(trace, newTrc);
            
            %update waitbar with current loop
            if waitbarOn == 1
            waitbar(ii/tot_EEGfiles,w,'Loading EEG Files...')
            else
                fprintf('.\n')
            end
        end
        
        if exist('w')
        close(w)
        end
        
        clear newData newTrc listcount tot_EEGfiles row_newTrc col_newTrc
        
    elseif isempty(EEGfilelist) == 1
        fprintf('No EEG text files in directory, skipping.\n')
        fprintf('\n')
    end
end

if temp_select == 1
    
    listcount = 1;
    Tempfilelist = [];
    %Filter: only select Temperature text files, and add them to their own list for loading
    for j=1:nFiles
        if isempty(strfind(filelist(j).name, 'Temperature')) == 0 && isempty(strfind(filelist(j).name, '.txt')) == 0
            
            Tempfilelist{listcount} = filelist(j).name;
            listcount = listcount + 1;
        end
        
    end
    
    if isempty(Tempfilelist) == 0
        
        %total number of EEG text files
        tot_Tempfiles=length(Tempfilelist);
        
        %variable that holds trace of concatenated EEG traces
        
        
        %loading bar
        if waitbarOn == 1
            w = waitbar(0, 'Initializing Load');
        else
            fprintf('Loading Temp Files\n')
        end
        
        %load and concatenate each of the EEG files from the list
        for ii = 1:tot_Tempfiles
            
            % load new contents
            
            newData = importdata(char(Tempfilelist(ii)), ',', 5);
            
            %occasionally, DSI will create blank text files with no data,
            %this ensures that text files contain data before they are
            %concatenated
            if isfield(newData, 'data') == 1
                newTrc = newData.data;
                [row_newTrc, col_newTrc] = size(newTrc);
            
            else
                break
            
            end
            
            
            %when the mouse is removed from the receiver pad, sometimes
            %DSI makes timestamps with no associated data column.  If
            %the size of the trace section does not match the existing
            %trace variable, a column of zeros is added (as opposed to
            %NaNs)
                if col_newTrc == 1
                    
                    newTrc=[newTrc NaN(size(newTrc))];
                    
                end
                
                
            % concatenate vertically
            trace_temp =  vertcat(trace_temp, newTrc);
            
            if waitbarOn == 1
                waitbar(ii/tot_Tempfiles,w,'Loading Temperature Files...')
            else
                fprintf('.\n')
            end
            
        end
        
        if exist('w')
        close(w)
        end
        
        clear newData newTrc listcount tot_Tempfiles row_newTrc col_newTr
        
    elseif isempty(Tempfilelist) == 1
        fprintf('No Temperature text files in directory, skipping.\n')
        fprintf('\n')
    end
end



if activity_select == 1
    
    listcount = 1;
    Activityfilelist = [];
    %Filter: only select Temperature text files, and add them to their own list for loading
    for j=1:nFiles
        if isempty(strfind(filelist(j).name, 'Activity')) == 0 && isempty(strfind(filelist(j).name, '.txt')) == 0
            
            Activityfilelist{listcount} = filelist(j).name;
            listcount = listcount + 1;
        end
        
    end
    
    if isempty(Activityfilelist) == 0
        
        %total number of EEG text files
        tot_Activityfiles=length(Activityfilelist);
        
        %variable that holds trace of concatenated EEG traces
        
        
        %loading bar
        if waitbarOn == 1
            w = waitbar(0, 'Initializing Load');
        else
            fprintf('Loading Activity Files\n')
        end
        %load and concatenate each of the EEG files from the list
        for ii = 1:tot_Activityfiles
            
            % load new contents
            
            newData = importdata(char(Activityfilelist(ii)), ',', 5);
            
            %occasionally, DSI will create blank text files with no data,
            %this ensures that text files contain data before they are
            %concatenated
            if isfield(newData, 'data') == 1
                
                newTrc = newData.data;
                [row_newTrc, col_newTrc] = size(newTrc);
            end
            

            %when the mouse is removed from the receiver pad, sometimes
            %DSI makes timestamps with no associated data column.  If
            %the size of the trace section does not match the existing
            %trace variable, a column of zeros is added (as opposed to
            %NaNs)
                if col_newTrc == 1
                    
                    newTrc=[newTrc NaN(size(newTrc))];
                    
                end
            
            % concatenate vertically
            trace_activity =  vertcat(trace_activity, newTrc);
            
            if waitbarOn == 1
                waitbar(ii/tot_Activityfiles,w,'Loading Activity Files...')
            else
                fprintf('.\n')
            end
        end
        
        if exist('w')
        close(w)
        end
        
        clear newData newTrc listcount tot_Activityfiles row_newTrc col_newTrc
        
        
    elseif isempty(Activityfilelist) == 1
        fprintf('No Activity text files in directory, skipping.\n')
        fprintf('\n')
    end
    
end

if sig_select == 1
    
    listcount = 1;
  Signalfilelist = [];
 %Filter: only select Temperature text files, and add them to their own list for loading
    for j=1:nFiles
        if isempty(strfind(filelist(j).name, 'Signal')) == 0 && isempty(strfind(filelist(j).name, '.txt')) == 0
            
            Signalfilelist{listcount} = filelist(j).name;
            listcount = listcount + 1;
        end
        
    end
    
    %only process files if there are appropriate signal text files in the
    %directory
    if isempty(Signalfilelist) == 0
    %total number of EEG text files
    tot_Signalfiles=length(Signalfilelist);
    
    %variable that holds trace of concatenated EEG traces
    
    
    %loading bar
    if waitbarOn == 1
        w = waitbar(0, 'Initializing Load');
    else
        fprintf('Loading Signal Strength Files\n')
    end
    
    %load and concatenate each of the EEG files from the list
    for ii = 1:tot_Signalfiles
        
        % load new contents
        
        newData = importdata(char(Signalfilelist(ii)), ',', 5);
        
        %occasionally, DSI will create blank text files with no data,
            %this ensures that text files contain data before they are
            %concatenated
        if isfield(newData, 'data') == 1
            newTrc = newData.data;
            [row_newTrc, col_newTrc] = size(newTrc);
        end
        
        
         %when the mouse is removed from the receiver pad, sometimes
            %DSI makes timestamps with no associated data column.  If
            %the size of the trace section does not match the existing
            %trace variable, a column of zeros is added (as opposed to
            %NaNs)
                if col_newTrc == 1
                    
                    newTrc=[newTrc NaN(size(newTrc))];
                    
                end
                
        % concatenate vertically
        trace_signalstr =  vertcat(trace_signalstr, newTrc);
        
        if waitbarOn == 1
            waitbar(ii/tot_Signalfiles,w,'Loading Signal Strength Files...')
        else
            fprintf('.\n')
        end
    end
    
    if exist('w')
    close(w)
    end
    
    clear newData newTrc listcount tot_Signalfiles row_newTrc col_newTrc
     
    %exit gracefully if no signal text files 
    elseif isempty(Signalfilelist) == 1
        fprintf('No Signal Strength text files in directory, skipping.\n')
        fprintf('\n')
    end
    
end





if freq_select == 1
    
    %Stimulus to frequency converter does not have mouse name in file, it
    %is not associated with any one mouse, but the whole recording session.
    %Therefore the files need to be searched for and loaded independently
    %of the individual mouse data
    Freqfiles=dir('C12V*');
    
   
    %only make a trace if there are frequency text files present in the
    %directory
    if isempty(Freqfiles) == 0;
        
         listcount = 1;
        Freqfilelist = [];
        %Filter: only select EEG text files, and add them to their own list for loading
        for j=1:length(Freqfiles)
            if isempty(strfind(Freqfiles(j).name, 'Frequency')) == 0 && isempty(strfind(Freqfiles(j).name, '.txt')) == 0
                
                Freqfilelist{listcount} = Freqfiles(j).name;
                listcount = listcount + 1;
            end
            
        end
        
        fid = fopen(Freqfilelist{1});
            paramIds = textscan(fid,'%s %s %s %s',1,'HeaderLines',1);
            fclose(fid);
            startDate.C12V = paramIds{3};
            startTime.C12V = paramIds{4};
        
        %total number of C12v text files
        tot_Freqfiles=length(Freqfilelist);
        
        %variable that holds trace of concatenated EEG traces
        
        
        %loading bar
        if waitbarOn == 1
            w = waitbar(0, 'Initializing Load');
        else
            fprintf('Loading C12V files\n')
        end
        %load and concatenate each of the EEG files from the list
        for ii = 1:tot_Freqfiles
            
            % load new contents
            
            newData = importdata(char(Freqfilelist(ii)), ',', 5);
            
            %occasionally, DSI will create blank text files with no data,
            %this ensures that text files contain data before they are
            %concatenated
            if isfield(newData, 'data') == 1
                newTrc = newData.data;
                [row_newTrc, col_newTrc] = size(newTrc);
            
            %if there are C12V text files, but the first one is empty, exit
            %loop
            elseif isfield(newData, 'data') == 0 && ii == 1
                fprintf('Only empty Frequency C12V text files in directory, skipping.\n')
                fprintf('\n')
                
                break
            end
            
            %when the mouse is removed from the receiver pad, sometimes
            %DSI makes timestamps with no associated data column.  If
            %the size of the trace section does not match the existing
            %trace variable, a column of zeros is added (as opposed to
            %NaNs)
                if col_newTrc == 1
                    
                    newTrc=[newTrc NaN(size(newTrc))];
                    
                end
                
                
            % concatenate vertically
            trace_freqPulse =  vertcat(trace_freqPulse, newTrc);
            if waitbarOn == 1
                waitbar(ii/tot_Freqfiles,w,'Loading External Pulse Frequency Files...')
            else
                fprintf('.\n')
            end
        end
        
        if exist('w')
        close(w)
        end
        
        clear newData newTrc tot_Freqfiles  row_newTrc col_newTrc
   
    %if there are no freq. text files, print the following error message    
    elseif isempty(Freqfiles) == 1
        fprintf('No Frequency C12V text files in directory, skipping.\n')
        fprintf('\n')
    end
    
end

%detect sampling frequency from one of the traces (non-empty one)
Fs_activity = [];
Fs_temp = [];
Fs_sig = [];

if isempty(trace) == 0
    Fs = 1/(trace(2,1)-trace(1,1));
    
    if isempty(trace_activity) == 0
        %activity often has a different sampling rate than the rest of the
        %variables, so it is saved seperately
        Fs_activity = 1/(trace_activity(2,1)-trace_activity(1,1));
    end
    
    if isempty(trace_freqPulse) == 0
        Fs = 1/(trace_freqPulse(2,1)-trace_freqPulse(1,1));
    end
    
    if isempty(trace_temp) == 0
        Fs_temp = 1/(trace_temp(2,1)-trace_temp(1,1));
    end
    
    if isempty(trace_signalstr) == 0
        Fs_sig = 1/(trace_signalstr(2,1)-trace_signalstr(1,1));
        
    end
else
    Fs='Not Detected';
end

% if isempty(trace_activity) == 0
%     %activity often has a different sampling rate than the rest of the
%     %variables, so it is saved seperately
%     Fs_activity = 1/(trace_activity(2,1)-trace_activity(1,1));
% end

%replace first column of traces (30 second chunks) with a new vector
%spanning the whole duration of the recording

if isempty(trace) == 0
    trace(:,1) = linspace(0,length(trace)/Fs,length(trace));
end

if isempty(trace_temp) == 0
    trace_temp(:,1) = linspace(0,length(trace_temp)/Fs_temp,length(trace_temp));
end

if isempty(trace_activity) == 0
    trace_activity(:,1) = linspace(0,length(trace_activity)/Fs_activity,length(trace_activity));
end

if isempty(trace_signalstr) == 0
    trace_signalstr(:,1) = linspace(0,length(trace_signalstr)/Fs_sig,length(trace_signalstr));
end

if isempty(trace_freqPulse) == 0
    trace_freqPulse(:,1) = linspace(0,length(trace_freqPulse)/Fs,length(trace_freqPulse));
end

savestring = strcat(mouse{n}, '_Traces_Full.mat');

%save .mat files 1 directory up from text files for easier location

currPath=pwd;
cd('..')

% Saving data, status messages
fprintf('Saving %s to disk...\n', savestring)
% save final output as a matlab binary file for speed
save(savestring, 'trace', 'trace_temp', 'trace_activity', 'trace_signalstr', 'trace_freqPulse', 'n','mouse',...
    'Fs', 'Fs_temp', 'Fs_sig', 'Fs_activity','startTime','startDate', '-v7')
fprintf('done!\n')


%return to original path w/ text files for next mouse
cd(currPath)

end

cd('..')
%clear unused variables
clear filefilter filelist savestring nFiles ii j currentdir filename *filelist activity_select eeg_select freq_select sig_select temp_select loadAll listcount w mou testEEGChan  

cd(origPath); % return to original folder where DSI_Load.m is located
function varargout = DSILoadDlg(varargin)
% DSILOADDLG MATLAB code for DSILoadDlg.fig
%      DSILOADDLG, by itself, creates a new DSILOADDLG or raises the existing
%      singleton*.
%
%      H = DSILOADDLG returns the handle to a new DSILOADDLG or the handle to
%      the existing singleton*.
%
%      DSILOADDLG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DSILOADDLG.M with the given input arguments.
%
%      DSILOADDLG('Property','Value',...) creates a new DSILOADDLG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DSILoadDlg_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DSILoadDlg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DSILoadDlg

% Last Modified by GUIDE v2.5 08-Jul-2015 13:13:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DSILoadDlg_OpeningFcn, ...
                   'gui_OutputFcn',  @DSILoadDlg_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before DSILoadDlg is made visible.
function DSILoadDlg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DSILoadDlg (see VARARGIN)

% Choose default command line output for DSILoadDlg
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
 %UIWAIT makes DSILoadDlg wait for user response (see UIRESUME)
 uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DSILoadDlg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%varargout{1} = handles.output;


% --- Executes on button press in eeg.
function eeg_Callback(hObject, eventdata, handles)
% hObject    handle to eeg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of eeg


eeg_check = get(hObject, 'Value');

if eeg_check == 1
   assignin('base','eeg_select',1);
elseif eeg_check == 0
   assignin('base','eeg_select',0);
end



% --- Executes on button press in activity.
function activity_Callback(hObject, eventdata, handles)
% hObject    handle to activity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of activity
activity_check = get(hObject, 'Value');

if activity_check == 1
   assignin('base','activity_select',1);
elseif activity_check == 0
   assignin('base','activity_select',0);
end
% --- Executes on button press in temp.
function temp_Callback(hObject, eventdata, handles)
% hObject    handle to temp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of temp
temp_check = get(hObject, 'Value');

if temp_check == 1
   assignin('base','temp_select',1);
elseif temp_check == 0
   assignin('base','temp_select',0);
end

% --- Executes on button press in freq.
function freq_Callback(hObject, eventdata, handles)
% hObject    handle to freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of freq
freq_check = get(hObject, 'Value');

if freq_check == 1
   assignin('base','freq_select',1);
elseif freq_check == 0
   assignin('base','freq_select',0);
end

% --- Executes on button press in sig.
function sig_Callback(hObject, eventdata, handles)
% hObject    handle to sig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of sig
sig_check = get(hObject, 'Value');

if sig_check == 1
   assignin('base','sig_select',1);
elseif sig_check == 0
   assignin('base','sig_select',0);
end
% --- Executes on button press in select.
function select_Callback(hObject, eventdata, handles)
% hObject    handle to select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close(handles.figure1);


% --- Executes on button press in loadall.
function loadall_Callback(hObject, eventdata, handles)
% hObject    handle to loadall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
all = get(hObject, 'Value');

if all == 1
    assignin('base','loadAll',1);
elseif all == 0
    assignin('base','loadAll',0);
end

close(handles.figure1);


% --- Executes on button press in selectAll.
function selectAll_Callback(hObject, eventdata, handles)
% hObject    handle to selectAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%When select all button is pressed, check all boxes, and send variables to
%base workspace
set(handles.eeg,'Value',1);
    assignin('base','eeg_select',1);
    
set(handles.activity,'Value',1);
    assignin('base','activity_select',1);

set(handles.temp,'Value',1);
    assignin('base','temp_select',1);


set(handles.freq,'Value',1);
    assignin('base','freq_select',1);

set(handles.sig,'Value',1);
   assignin('base','sig_select',1);

